package com.trixx.scanflow.auth;

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
class AuthAndBusinessFlowTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void registerBusinessThenLoginAndFetchCurrentBusiness() throws Exception {
        String registerRequest = """
            {
              "businessName": "Acme Groceries",
              "email": "owner@acmegrocery.co.ke",
              "phone": "254712345678",
              "ownerName": "Jane Doe",
              "password": "StrongPass123!"
            }
            """;

        MvcResult registerResult = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(registerRequest))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.business.name").value("Acme Groceries"))
            .andExpect(jsonPath("$.user.email").value("owner@acmegrocery.co.ke"))
            .andReturn();

        String response = registerResult.getResponse().getContentAsString();
        String token = objectMapper.readTree(response).path("token").asText();

        mockMvc.perform(get("/api/v1/businesses/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Acme Groceries"));
    }
}
