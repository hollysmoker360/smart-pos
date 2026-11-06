package com.trixx.scanflow.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.domain.UserRole;
import com.trixx.scanflow.repository.AuditLogRepository;
import com.trixx.scanflow.repository.UserRepository;
import com.trixx.scanflow.security.JwtService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.security.crypto.password.PasswordEncoder;
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

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AuditLogRepository auditLogRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

        @Test
        void registrationRejectsInvalidInput() throws Exception {
                mockMvc.perform(post("/api/v1/auth/register")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                        {
                                            "businessName": " ",
                                            "email": "not-an-email",
                                            "phone": "254700000003",
                                            "ownerName": "Test Owner",
                                            "password": "short"
                                        }
                                        """))
                        .andExpect(status().isBadRequest())
                        .andExpect(jsonPath("$.message").value("Invalid request"));
        }

    @Test
    void registerBusinessThenLoginAndFetchCurrentBusiness() throws Exception {
        long auditLogCount = auditLogRepository.count();
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

        org.junit.jupiter.api.Assertions.assertEquals(auditLogCount + 2, auditLogRepository.count());
        mockMvc.perform(get("/api/v1/businesses/me/branches")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].name").value("Main Branch"));

        MvcResult loginResult = mockMvc.perform(post("/api/v1/auth/login")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "email": "OWNER@ACMEGROCERY.CO.KE",
                  "password": "StrongPass123!"
                }
                """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.user.role").value("OWNER"))
            .andReturn();

        token = objectMapper.readTree(loginResult.getResponse().getContentAsString()).path("token").asText();

        mockMvc.perform(post("/api/v1/auth/login")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "email": "owner@acmegrocery.co.ke",
                  "password": "incorrect-password"
                }
                """))
            .andExpect(status().isUnauthorized())
            .andExpect(jsonPath("$.message").value("Invalid email or password"));

        mockMvc.perform(get("/api/v1/businesses/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Acme Groceries"));

        mockMvc.perform(get("/api/v1/auth/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.user.role").value("OWNER"))
            .andExpect(jsonPath("$.business.id").isNotEmpty());

        mockMvc.perform(get("/api/v1/auth/me"))
            .andExpect(status().isForbidden());
    }

            @Test
            void platformAdminInvitesOwnerAndOwnerCreatesBranch() throws Exception {
            User platformAdmin = new User(null, "platform-admin@trixx.test", null, "TRIXX Platform Admin",
                passwordEncoder.encode("PlatformAdminPass123!"), UserRole.PLATFORM_ADMIN);
            platformAdmin.setTenantScope("PLATFORM");
            platformAdmin = userRepository.save(platformAdmin);
            String adminToken = jwtService.generateToken(platformAdmin);

            MvcResult invitationResult = mockMvc.perform(post("/api/v1/platform/business-invitations")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "businessName": "Kilimani Market",
                      "ownerName": "Sam Owner",
                      "ownerEmail": "sam.owner@kilimani.test",
                      "ownerPhone": "254700000091"
                    }
                    """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.ownerEmail").value("sam.owner@kilimani.test"))
                .andReturn();

            String inviteUrl = objectMapper.readTree(invitationResult.getResponse().getContentAsString())
                .path("invitationUrl").asText();
            String invitationToken = inviteUrl.substring(inviteUrl.indexOf("token=") + "token=".length());

            MvcResult acceptedResult = mockMvc.perform(post("/api/v1/auth/invitations/accept")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(java.util.Map.of(
                    "token", invitationToken,
                    "password", "OwnerSecurePass123!"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.business.name").value("Kilimani Market"))
                .andExpect(jsonPath("$.user.role").value("OWNER"))
                .andReturn();

                mockMvc.perform(post("/api/v1/auth/invitations/accept")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(java.util.Map.of(
                        "token", invitationToken,
                        "password", "AnotherSecurePass123!"))))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.message").value("Invitation is invalid or expired"));

            String ownerToken = objectMapper.readTree(acceptedResult.getResponse().getContentAsString()).path("token").asText();
            mockMvc.perform(get("/api/v1/businesses/me/branches")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + ownerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());

            MvcResult branchResult = mockMvc.perform(post("/api/v1/businesses/me/branches")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + ownerToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"name": "Kilimani West", "currency": "KES", "timezone": "Africa/Nairobi"}
                    """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Kilimani West"))
                .andReturn();
            String assignedBranchId = objectMapper.readTree(branchResult.getResponse().getContentAsString()).path("id").asText();

            mockMvc.perform(post("/api/v1/businesses/me/branches")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + ownerToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"name": "Kilimani East", "currency": "KES", "timezone": "Africa/Nairobi"}
                    """))
                .andExpect(status().isCreated());

            MvcResult foreignBusinessResult = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "businessName": "Foreign Market",
                      "email": "foreign.owner@market.test",
                      "phone": "254700000094",
                      "ownerName": "Foreign Owner",
                      "password": "ForeignOwnerPass123!"
                    }
                    """))
                .andExpect(status().isCreated())
                .andReturn();
            String foreignOwnerToken = objectMapper.readTree(foreignBusinessResult.getResponse().getContentAsString())
                .path("token").asText();
            MvcResult foreignBranchesResult = mockMvc.perform(get("/api/v1/businesses/me/branches")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + foreignOwnerToken))
                .andExpect(status().isOk())
                .andReturn();
            String foreignBranchId = objectMapper.readTree(foreignBranchesResult.getResponse().getContentAsString())
                .get(0).path("id").asText();

            mockMvc.perform(post("/api/v1/businesses/me/employee-invitations")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + ownerToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(java.util.Map.of(
                    "fullName", "Foreign Cashier",
                    "email", "foreign.cashier@market.test",
                    "phone", "254700000095",
                    "role", "CASHIER",
                    "branchIds", java.util.List.of(foreignBranchId)))))
                .andExpect(status().isBadRequest());

            MvcResult employeeInviteResult = mockMvc.perform(post("/api/v1/businesses/me/employee-invitations")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + ownerToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(java.util.Map.of(
                    "fullName", "Cashier One",
                    "email", "cashier@kilimani.test",
                    "phone", "254700000093",
                    "role", "CASHIER",
                    "branchIds", java.util.List.of(assignedBranchId)))))
                .andExpect(status().isCreated())
                .andReturn();
            String employeeInviteUrl = objectMapper.readTree(employeeInviteResult.getResponse().getContentAsString())
                .path("invitationUrl").asText();
            String employeeInviteToken = employeeInviteUrl.substring(employeeInviteUrl.indexOf("token=") + "token=".length());

            MvcResult employeeAcceptedResult = mockMvc.perform(post("/api/v1/auth/employee-invitations/accept")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(java.util.Map.of(
                    "token", employeeInviteToken,
                    "password", "CashierSecurePass123!"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.user.role").value("CASHIER"))
                .andReturn();
            String employeeToken = objectMapper.readTree(employeeAcceptedResult.getResponse().getContentAsString()).path("token").asText();

            mockMvc.perform(get("/api/v1/pos/branches")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + employeeToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(assignedBranchId))
                .andExpect(jsonPath("$.length()").value(1));

            mockMvc.perform(post("/api/v1/shopping-sessions")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + employeeToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"sessionType": "CASHIER", "branchName": "Kilimani West"}
                    """))
                .andExpect(status().isCreated());

            mockMvc.perform(post("/api/v1/shopping-sessions")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + employeeToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"sessionType": "CASHIER", "branchName": "Kilimani East"}
                    """))
                .andExpect(status().isForbidden());

            mockMvc.perform(post("/api/v1/platform/business-invitations")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + ownerToken)
                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                        {
                                            "businessName": "Unauthorized Market",
                                            "ownerName": "Untrusted Requester",
                                            "ownerEmail": "unauthorized@market.test",
                                            "ownerPhone": "254700000092"
                                        }
                                        """))
                .andExpect(status().isForbidden());

            org.junit.jupiter.api.Assertions.assertTrue(auditLogRepository.count() >= 2);
            }
}
