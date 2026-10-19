package com.trixx.scanflow.catalogue;

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
class ProductAndCashierFlowTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

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

        String checkoutRequest = """
            {
              "items": [
                { "productId": "MZ-001", "quantity": 2 }
              ]
            }
            """;

        mockMvc.perform(post("/api/v1/pos/checkouts")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(checkoutRequest))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.items[0].quantity").value(2))
            .andExpect(jsonPath("$.totalAmount").value(360.0));

        mockMvc.perform(get("/api/v1/products")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content[0].sku").value("MZ-001"));
    }
}
