package com.trixx.smarttrolley;

import com.trixx.smarttrolley.domain.*;
import com.trixx.smarttrolley.dto.ApiDtos.*;
import com.trixx.smarttrolley.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.math.BigDecimal;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class TrixxSystemIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private OrderRepository orderRepository;

    private String baseUrl;

    @BeforeEach
    public void setUp() {
        baseUrl = "http://localhost:" + port + "/api/v1";
    }

    @Test
    public void testEndToEndCustomerJourneyAndExitVerification() {
        // 1. Claim Trolley via QR Code
        TrolleyClaimRequest claimReq = new TrolleyClaimRequest("QR-TRL-WEST-001-HASH", 6L);
        ResponseEntity<ShoppingSession> claimRes = restTemplate.postForEntity(baseUrl + "/trolleys/claim", claimReq, ShoppingSession.class);
        assertEquals(HttpStatus.OK, claimRes.getStatusCode());
        assertNotNull(claimRes.getBody());
        Long sessionId = claimRes.getBody().getId();

        // 2. Scan Milk Barcode (6161100001011) - Selling Price KES 120.00
        ScanEventRequest scanReq1 = new ScanEventRequest(
                "EVT-TEST-001", "TRL-WEST-001", sessionId, "6161100001011", 1L, null, null
        );
        ResponseEntity<ShoppingBasket> scanRes1 = restTemplate.postForEntity(baseUrl + "/device-events/scans", scanReq1, ShoppingBasket.class);
        assertEquals(HttpStatus.OK, scanRes1.getStatusCode());
        assertNotNull(scanRes1.getBody());
        assertEquals(new BigDecimal("120.00"), scanRes1.getBody().getTotalAmount());

        // 3. Scan Bread Barcode (6161100002028) - Selling Price KES 65.00
        ScanEventRequest scanReq2 = new ScanEventRequest(
                "EVT-TEST-002", "TRL-WEST-001", sessionId, "6161100002028", 2L, null, null
        );
        ResponseEntity<ShoppingBasket> scanRes2 = restTemplate.postForEntity(baseUrl + "/device-events/scans", scanReq2, ShoppingBasket.class);
        assertEquals(HttpStatus.OK, scanRes2.getStatusCode());
        assertEquals(new BigDecimal("185.00"), scanRes2.getBody().getTotalAmount());

        // 4. Create Server-Authoritative Checkout
        ResponseEntity<Order> checkoutRes = restTemplate.postForEntity(baseUrl + "/shopping-sessions/" + sessionId + "/checkout", null, Order.class);
        assertEquals(HttpStatus.OK, checkoutRes.getStatusCode());
        assertNotNull(checkoutRes.getBody());
        Long orderId = checkoutRes.getBody().getId();
        assertEquals(new BigDecimal("185.00"), checkoutRes.getBody().getTotalAmount());
        assertEquals("CHECKOUT_PENDING", checkoutRes.getBody().getOrderStatus());

        // 5. Initiate M-Pesa STK Push
        PaymentInitiationRequest payReq = new PaymentInitiationRequest(orderId, "+254712345678");
        ResponseEntity<PaymentAttempt> payRes = restTemplate.postForEntity(baseUrl + "/orders/" + orderId + "/payments/mpesa", payReq, PaymentAttempt.class);
        assertEquals(HttpStatus.OK, payRes.getStatusCode());
        assertNotNull(payRes.getBody());
        String checkoutRequestId = payRes.getBody().getCheckoutRequestId();

        // 6. Simulate M-Pesa Callback Success
        MpesaCallbackPayload callback = new MpesaCallbackPayload(
                checkoutRequestId, 0, "Success", "QKH1234567"
        );
        ResponseEntity<Map> cbRes = restTemplate.postForEntity(baseUrl + "/webhooks/daraja/stk", callback, Map.class);
        assertEquals(HttpStatus.OK, cbRes.getStatusCode());

        // Verify Order is marked PAID
        Order paidOrder = orderRepository.findById(orderId).orElseThrow();
        assertEquals("PAID", paidOrder.getOrderStatus());

        // 7. Verify Receipt & Exit Token Generation
        ResponseEntity<Receipt> receiptRes = restTemplate.getForEntity(baseUrl + "/orders/" + orderId + "/receipt", Receipt.class);
        assertEquals(HttpStatus.OK, receiptRes.getStatusCode());
        assertNotNull(receiptRes.getBody().getReceiptNumber());

        ResponseEntity<ExitToken> tokenRes = restTemplate.getForEntity(baseUrl + "/orders/" + orderId + "/exit-token", ExitToken.class);
        assertEquals(HttpStatus.OK, tokenRes.getStatusCode());
        String tokenHash = tokenRes.getBody().getTokenHash();
        assertNotNull(tokenHash);

        // 8. Redeem Exit Token at Station Terminal
        ExitVerificationRequest exitReq = new ExitVerificationRequest(tokenHash);
        ResponseEntity<Map> exitRes = restTemplate.postForEntity(baseUrl + "/exit/redeem", exitReq, Map.class);
        assertEquals(HttpStatus.OK, exitRes.getStatusCode());
        assertTrue((Boolean) exitRes.getBody().get("verified"));

        // 9. Re-try redeeming the same exit token (Should fail as EXIT_TOKEN_ALREADY_USED)
        ResponseEntity<ErrorResponse> reuseRes = restTemplate.postForEntity(baseUrl + "/exit/redeem", exitReq, ErrorResponse.class);
        assertEquals(HttpStatus.CONFLICT, reuseRes.getStatusCode());
        assertEquals("EXIT_TOKEN_ALREADY_USED", reuseRes.getBody().errorCode());
    }
}
