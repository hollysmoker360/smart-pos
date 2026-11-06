package com.trixx.scanflow.catalogue;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.trixx.scanflow.repository.InventoryMovementRepository;
import com.trixx.scanflow.repository.RetailOrderRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ProductAndCashierFlowTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private RetailOrderRepository orderRepository;

    @Autowired
    private InventoryMovementRepository inventoryMovementRepository;

    @Test
    void duplicateBarcodeAndSkuAreRejectedCaseInsensitivelyBeforePersistingProduct() throws Exception {
        String registerRequest = """
            {
              "businessName": "FreshMart Duplicate",
              "email": "dup@freshmart.co.ke",
              "phone": "254700000010",
              "ownerName": "Alice Smith",
              "password": "StrongPass123!"
            }
            """;

        MvcResult registerResult = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(registerRequest))
            .andExpect(status().isCreated())
            .andReturn();

        String token = objectMapper.readTree(registerResult.getResponse().getContentAsString()).path("token").asText();

        String createProductRequest = """
            {
              "sku": "DUP-001",
              "name": "Duplicate Product",
              "barcode": "6401234500099",
              "price": 120.00,
              "taxRate": 0.16,
              "stock": 5,
              "category": "Groceries"
            }
            """;

        mockMvc.perform(post("/api/v1/products")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(createProductRequest))
            .andExpect(status().isCreated());

        mockMvc.perform(post("/api/v1/products")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
            {
              "sku": "dup-001",
              "name": "Duplicate Product 2",
              "barcode": "6401234500099",
              "price": 140.00,
              "taxRate": 0.16,
              "stock": 6,
              "category": "Groceries"
            }
            """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("A product with this SKU already exists"));

        mockMvc.perform(post("/api/v1/products")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
            {
              "sku": "DUP-002",
              "name": "Duplicate Product 2",
              "barcode": "6401234500099",
              "price": 140.00,
              "taxRate": 0.16,
              "stock": 6,
              "category": "Groceries"
            }
            """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("A product with this barcode already exists"));
    }

    @Test
    @WithMockUser(roles = "CUSTOMER")
    void customerCannotUseCashierCheckout() throws Exception {
      mockMvc.perform(post("/api/v1/pos/checkouts")
          .contentType(MediaType.APPLICATION_JSON)
          .content("""
            {
              "branchId": "00000000-0000-0000-0000-000000000001",
              "items": [{"productId": "SKU-1", "quantity": 1}],
              "idempotencyKey": "unauthorized-checkout",
              "paymentMethod": "CASH",
              "cashReceived": 100
            }
            """))
        .andExpect(status().isForbidden());
    }

    @Test
    void registerBusinessCreateProductAndCompleteCashierCheckout() throws Exception {
        String registerRequest = """
            {
              "businessName": "FreshMart",
              "email": "manager@freshmart.co.ke",
              "phone": "254700000001",
              "ownerName": "Alice Smith",
              "password": "StrongPass123!"
            }
            """;

        MvcResult registerResult = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(registerRequest))
            .andExpect(status().isCreated())
            .andReturn();

        String token = objectMapper.readTree(registerResult.getResponse().getContentAsString()).path("token").asText();

        String createProductRequest = """
            {
              "sku": "MZ-001",
              "name": "Maize Flour 2kg",
              "barcode": "6401234500010",
              "price": 180.00,
              "taxRate": 0.16,
              "stock": 25,
              "category": "Groceries"
            }
            """;

        mockMvc.perform(post("/api/v1/products")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(createProductRequest))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.sku").value("MZ-001"))
            .andExpect(jsonPath("$.name").value("Maize Flour 2kg"));

        MvcResult branchesResult = mockMvc.perform(get("/api/v1/businesses/me/branches")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andReturn();
        String branchId = objectMapper.readTree(branchesResult.getResponse().getContentAsString()).get(0).path("id").asText();
        java.util.Map<String, Object> checkoutBody = new java.util.HashMap<>();
        checkoutBody.put("branchId", branchId);
        checkoutBody.put("idempotencyKey", "freshmart-checkout-001");
        checkoutBody.put("paymentMethod", "CASH");
        checkoutBody.put("cashReceived", 500.00);
        checkoutBody.put("items", java.util.List.of(java.util.Map.of("productId", "MZ-001", "quantity", 2)));
        String checkoutRequest = objectMapper.writeValueAsString(checkoutBody);

        mockMvc.perform(post("/api/v1/pos/quotes")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"branchId": "%s", "items": [{"productId": "MZ-001", "quantity": 2}]}
                    """.formatted(branchId)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.subtotalAmount").value(360.0))
            .andExpect(jsonPath("$.taxAmount").value(57.6))
            .andExpect(jsonPath("$.totalAmount").value(417.6))
            .andReturn();
        long ordersBeforeCheckout = orderRepository.count();
        long movementsBeforeCheckout = inventoryMovementRepository.count();
        MvcResult firstCheckout = mockMvc.perform(post("/api/v1/pos/checkouts")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(checkoutRequest))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.items[0].quantity").value(2))
            .andExpect(jsonPath("$.orderStatus").value("PAID"))
            .andExpect(jsonPath("$.paymentStatus").value("SUCCEEDED"))
            .andExpect(jsonPath("$.totalAmount").value(417.6))
            .andExpect(jsonPath("$.changeDue").value(82.4))
            .andReturn();
        String firstOrderId = objectMapper.readTree(firstCheckout.getResponse().getContentAsString())
                .path("orderId").asText();

        MvcResult duplicateCheckout = mockMvc.perform(post("/api/v1/pos/checkouts")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(checkoutRequest))
                    .andExpect(status().isCreated())
                    .andReturn();
        org.junit.jupiter.api.Assertions.assertEquals(firstOrderId, objectMapper.readTree(
                duplicateCheckout.getResponse().getContentAsString()).path("orderId").asText());

        checkoutBody.put("cashReceived", 501.00);
        mockMvc.perform(post("/api/v1/pos/checkouts")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(checkoutBody)))
            .andExpect(status().isBadRequest());

        org.junit.jupiter.api.Assertions.assertEquals(ordersBeforeCheckout + 1, orderRepository.count());
        org.junit.jupiter.api.Assertions.assertEquals(movementsBeforeCheckout + 1, inventoryMovementRepository.count());

        mockMvc.perform(get("/api/v1/products")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
          .andExpect(jsonPath("$.content[0].stock").value(23))
            .andExpect(jsonPath("$.content[0].sku").value("MZ-001"));
    }

    @Test
    void guestCheckoutCreatesReceiptAndExitToken() throws Exception {
        String registerRequest = """
            {
              "businessName": "Guest Mart",
              "email": "guest@guestmart.co.ke",
              "phone": "254700000020",
              "ownerName": "Guest Owner",
              "password": "StrongPass123!"
            }
            """;

        MvcResult registerResult = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(registerRequest))
            .andExpect(status().isCreated())
            .andReturn();
        String token = objectMapper.readTree(registerResult.getResponse().getContentAsString()).path("token").asText();

        mockMvc.perform(post("/api/v1/products")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "sku": "GUEST-001",
                      "name": "Guest Item",
                      "barcode": "6401234500999",
                      "price": 250.00,
                      "taxRate": 0.16,
                      "stock": 10,
                      "category": "Groceries"
                    }
                    """))
            .andExpect(status().isCreated());

        MvcResult branchesResult = mockMvc.perform(get("/api/v1/businesses/me/branches")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andReturn();
        String branchId = objectMapper.readTree(branchesResult.getResponse().getContentAsString()).get(0).path("id").asText();

        MvcResult guestSession = mockMvc.perform(post("/api/v1/public/branches/{branchId}/shopping-sessions", branchId))
            .andExpect(status().isCreated())
            .andReturn();
        String sessionId = objectMapper.readTree(guestSession.getResponse().getContentAsString()).path("sessionId").asText();
        String guestToken = objectMapper.readTree(guestSession.getResponse().getContentAsString()).path("accessToken").asText();

        mockMvc.perform(post("/api/v1/public/shopping-sessions/{sessionId}/items", sessionId)
                .header("X-Shopping-Session-Token", guestToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"productIdentifier\":\"GUEST-001\",\"quantity\":2}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.totalAmount").value(500.0));

        MvcResult checkoutResult = mockMvc.perform(post("/api/v1/public/shopping-sessions/{sessionId}/checkout", sessionId)
                .header("X-Shopping-Session-Token", guestToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "paymentMethod": "CASH",
                      "cashReceived": 600.00,
                      "idempotencyKey": "guest-checkout-1"
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.paymentStatus").value("SUCCEEDED"))
            .andExpect(jsonPath("$.changeDue").value(100.0))
            .andExpect(jsonPath("$.exitTokenCode").exists())
            .andReturn();

        String exitToken = objectMapper.readTree(checkoutResult.getResponse().getContentAsString()).path("exitTokenCode").asText();

        mockMvc.perform(post("/api/v1/public/exit-tokens/{tokenCode}/verify", exitToken))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("VERIFIED"));
    }
}
