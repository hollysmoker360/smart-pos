package com.trixx.smartpos;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.trixx.smartpos.model.*;
import com.trixx.smartpos.repository.*;
import com.trixx.smartpos.service.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class FullSystemFlowIntegrationTest {

    @Autowired private TenantRepository tenantRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private ProductRepository productRepository;
    @Autowired private ProductBarcodeRepository productBarcodeRepository;
    @Autowired private BranchPriceRepository branchPriceRepository;
    @Autowired private InventoryBalanceRepository inventoryBalanceRepository;

    @Autowired private ShoppingSessionService shoppingSessionService;
    @Autowired private CheckoutPaymentService checkoutPaymentService;
    @Autowired private ReceiptExitService receiptExitService;

    private UUID tenantId;
    private UUID branchId;
    private String barcode = "6001234567890";

    @BeforeEach
    void setUp() {
        Tenant tenant = Tenant.builder()
                .name("Nairobi Megastore")
                .code("NBO-MEGA")
                .contactEmail("admin@megastore.co.ke")
                .build();
        tenant = tenantRepository.save(tenant);
        tenantId = tenant.getId();

        Branch branch = Branch.builder()
                .tenantId(tenantId)
                .name("Westlands Branch")
                .code("WEST-01")
                .address("Westlands, Nairobi")
                .build();
        branch = branchRepository.save(branch);
        branchId = branch.getId();

        Product product = Product.builder()
                .tenantId(tenantId)
                .sku("MILK-1L")
                .name("Fresh Whole Milk 1L")
                .category("Dairy")
                .taxRate(new BigDecimal("16.00"))
                .build();
        product = productRepository.save(product);

        ProductBarcode pb = ProductBarcode.builder()
                .productId(product.getId())
                .barcode(barcode)
                .symbology("EAN-13")
                .build();
        productBarcodeRepository.save(pb);

        BranchPrice price = BranchPrice.builder()
                .branchId(branchId)
                .productId(product.getId())
                .price(new BigDecimal("120.00"))
                .costPrice(new BigDecimal("90.00"))
                .build();
        branchPriceRepository.save(price);

        InventoryBalance balance = InventoryBalance.builder()
                .branchId(branchId)
                .productId(product.getId())
                .availableQuantity(new BigDecimal("100.000"))
                .reservedQuantity(BigDecimal.ZERO)
                .damagedQuantity(BigDecimal.ZERO)
                .build();
        inventoryBalanceRepository.save(balance);
    }

    @Test
    void testEndToEndShoppingCheckoutPaymentExitFlow() {
        // 1. Create Shopping Session
        ShoppingSession session = shoppingSessionService.createSession(tenantId, branchId, null, "+254700000000");
        assertNotNull(session.getId());
        assertEquals("ACTIVE", session.getStatus());

        // 2. Add Item to Basket
        session = shoppingSessionService.addItemToBasket(session.getId(), barcode, 2);
        assertEquals(1, session.getItems().size());
        assertEquals(2, session.getItems().get(0).getQuantity());
        assertEquals(new BigDecimal("240.00"), session.getItems().get(0).getTotalPrice());

        // 3. Checkout Order
        Order order = checkoutPaymentService.checkout(session.getId());
        assertNotNull(order.getId());
        assertEquals("PENDING", order.getStatus());
        assertEquals(new BigDecimal("240.00"), order.getTotalAmount());

        // 4. Initiate M-Pesa STK Payment
        PaymentAttempt attempt = checkoutPaymentService.initiateMpesaPayment(order.getId(), "254700000000");
        assertNotNull(attempt.getId());
        assertEquals("PENDING", attempt.getStatus());

        // 5. Simulate Asynchronous Daraja Callback
        Map<String, Object> stkCallback = new HashMap<>();
        stkCallback.put("MerchantRequestID", attempt.getMerchantRequestId());
        stkCallback.put("CheckoutRequestID", attempt.getCheckoutRequestId());
        stkCallback.put("ResultCode", 0);
        stkCallback.put("ResultDesc", "The service request has been processed successfully.");

        Map<String, Object> body = new HashMap<>();
        body.put("stkCallback", stkCallback);

        Map<String, Object> callbackPayload = new HashMap<>();
        callbackPayload.put("Body", body);

        checkoutPaymentService.processDarajaCallback(callbackPayload);

        // Verify Payment Succeeded & Inventory Committed
        PaymentAttempt updatedAttempt = checkoutPaymentService.initiateMpesaPayment(order.getId(), "254700000000");
        // Re-check inventory
        InventoryBalance updatedBalance = inventoryBalanceRepository.findByBranchIdAndProductId(branchId, session.getItems().get(0).getProductId()).orElseThrow();
        assertEquals(new BigDecimal("98.000"), updatedBalance.getAvailableQuantity());

        // 6. Generate Receipt & Exit Pass
        Receipt receipt = receiptExitService.generateReceipt(order.getId());
        assertNotNull(receipt.getReceiptNumber());

        ExitToken exitToken = receiptExitService.getExitTokenForOrder(order.getId());
        assertNotNull(exitToken.getTokenHash());
        assertEquals("ELIGIBLE", exitToken.getStatus());

        // 7. Verify & Complete Exit Pass
        Map<String, Object> verification = receiptExitService.verifyExitToken(exitToken.getTokenHash());
        assertTrue((Boolean) verification.get("valid"));

        ExitEvent exitEvent = receiptExitService.completeExit(exitToken.getTokenHash(), null, true, "Verified by attendant");
        assertEquals("APPROVED", exitEvent.getResult());

        ExitToken completedToken = receiptExitService.getExitTokenForOrder(order.getId());
        assertEquals("USED", completedToken.getStatus());
    }

    @Test
    void testDuplicateCallbackProtection() {
        ShoppingSession session = shoppingSessionService.createSession(tenantId, branchId, null, "+254700000000");
        session = shoppingSessionService.addItemToBasket(session.getId(), barcode, 1);
        Order order = checkoutPaymentService.checkout(session.getId());
        PaymentAttempt attempt = checkoutPaymentService.initiateMpesaPayment(order.getId(), "254700000000");

        Map<String, Object> stkCallback = new HashMap<>();
        stkCallback.put("MerchantRequestID", attempt.getMerchantRequestId());
        stkCallback.put("CheckoutRequestID", attempt.getCheckoutRequestId());
        stkCallback.put("ResultCode", 0);

        Map<String, Object> body = new HashMap<>();
        body.put("stkCallback", stkCallback);

        Map<String, Object> callbackPayload = new HashMap<>();
        callbackPayload.put("Body", body);

        // First callback
        checkoutPaymentService.processDarajaCallback(callbackPayload);

        // Duplicate callback (should not throw error or double deduct stock)
        assertDoesNotThrow(() -> checkoutPaymentService.processDarajaCallback(callbackPayload));

        InventoryBalance updatedBalance = inventoryBalanceRepository.findByBranchIdAndProductId(branchId, session.getItems().get(0).getProductId()).orElseThrow();
        assertEquals(new BigDecimal("99.000"), updatedBalance.getAvailableQuantity());
    }
}
