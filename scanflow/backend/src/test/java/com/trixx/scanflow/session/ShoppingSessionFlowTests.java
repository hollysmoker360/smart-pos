package com.trixx.scanflow.session;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ShoppingSessionFlowTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void createSessionAddProductAndReadBasket() throws Exception {
        String registerRequest = """
            {
              "businessName": "MarketFlow",
              "email": "owner@marketflow.co.ke",
              "phone": "254700000002",
              "ownerName": "Grace Wanjiku",
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
                      "sku": "TEA-100",
                      "name": "Green Tea 100g",
                      "barcode": "1234567890123",
                      "price": 120.00,
                      "taxRate": 0.16,
                      "stock": 10,
                      "category": "Beverages"
                    }
                    """))
            .andExpect(status().isCreated());

        MvcResult sessionResult = mockMvc.perform(post("/api/v1/shopping-sessions")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "sessionType": "PHONE_SCANNING",
                      "branchName": "Main Branch"
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.status").value("ACTIVE"))
            .andReturn();

        String sessionId = objectMapper.readTree(sessionResult.getResponse().getContentAsString()).path("id").asText();

        mockMvc.perform(post("/api/v1/shopping-sessions/" + sessionId + "/items")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "productIdentifier": "TEA-100",
                      "quantity": 2
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.items[0].quantity").value(2));

        mockMvc.perform(get("/api/v1/shopping-sessions/" + sessionId + "/basket")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.items[0].productSku").value("TEA-100"))
            .andExpect(jsonPath("$.totalAmount").value(240.0));
    }

    @Test
    void guestPhoneSessionUsesCapabilityTokenAndExposesLiveBasketEndpoint() throws Exception {
        MvcResult registerResult = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "businessName": "Guest Market",
                      "email": "guest-owner@marketflow.co.ke",
                      "phone": "254700000003",
                      "ownerName": "Market Owner",
                      "password": "StrongPass123!"
                    }
                    """))
            .andExpect(status().isCreated())
            .andReturn();
        String ownerToken = objectMapper.readTree(registerResult.getResponse().getContentAsString())
                .path("token").asText();

        mockMvc.perform(post("/api/v1/products")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + ownerToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "sku": "RICE-001",
                      "name": "Rice 1kg",
                      "barcode": "6160000000001",
                      "price": 210.00,
                      "taxRate": 0.16,
                      "stock": 8,
                      "category": "Groceries"
                    }
                    """))
            .andExpect(status().isCreated());

        String branchId = objectMapper.readTree(mockMvc.perform(get("/api/v1/businesses/me/branches")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + ownerToken))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString())
            .get(0).path("id").asText();

        mockMvc.perform(get("/api/v1/public/branches/" + branchId))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.phoneScanningEnabled").value(true));

        MvcResult sessionResult = mockMvc.perform(post(
                    "/api/v1/public/branches/" + branchId + "/shopping-sessions"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.branchName").value("Main Branch"))
            .andExpect(jsonPath("$.accessToken").isNotEmpty())
            .andReturn();
        var session = objectMapper.readTree(sessionResult.getResponse().getContentAsString());
        String sessionId = session.path("sessionId").asText();
        String guestToken = session.path("accessToken").asText();

        mockMvc.perform(post("/api/v1/public/shopping-sessions/" + sessionId + "/items")
                .header("X-Shopping-Session-Token", guestToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"productIdentifier": "6160000000001", "quantity": 2}
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.items[0].productName").value("Rice 1kg"))
            .andExpect(jsonPath("$.totalAmount").value(420.0));

        mockMvc.perform(get("/api/v1/public/shopping-sessions/" + sessionId + "/basket")
                .header("X-Shopping-Session-Token", guestToken))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.items[0].quantity").value(2));

        mockMvc.perform(get("/api/v1/public/shopping-sessions/" + sessionId + "/basket")
                .header("X-Shopping-Session-Token", "invalid-token"))
            .andExpect(status().isForbidden());
    }
}
