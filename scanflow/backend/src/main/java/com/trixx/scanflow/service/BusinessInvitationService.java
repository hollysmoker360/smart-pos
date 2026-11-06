package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.BusinessInvitation;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.domain.UserRole;
import com.trixx.scanflow.repository.BusinessInvitationRepository;
import com.trixx.scanflow.repository.BusinessRepository;
import com.trixx.scanflow.repository.UserRepository;
import com.trixx.scanflow.security.JwtService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Locale;
import java.util.UUID;

@Service
public class BusinessInvitationService {
    private static final Duration INVITATION_LIFETIME = Duration.ofDays(7);
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final BusinessInvitationRepository invitationRepository;
    private final BusinessRepository businessRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuditLogService auditLogService;
    private final String publicBaseUrl;

    public BusinessInvitationService(BusinessInvitationRepository invitationRepository,
                                     BusinessRepository businessRepository,
                                     UserRepository userRepository,
                                     PasswordEncoder passwordEncoder,
                                     JwtService jwtService,
                                     AuditLogService auditLogService,
                                     @Value("${app.public-url}") String publicBaseUrl) {
        this.invitationRepository = invitationRepository;
        this.businessRepository = businessRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.auditLogService = auditLogService;
        this.publicBaseUrl = publicBaseUrl.replaceAll("/$", "");
    }

    @Transactional
    public CreatedInvitation createInvitation(User actor, CreateInvitationRequest request) {
        String ownerEmail = request.ownerEmail().trim().toLowerCase(Locale.ROOT);
        if (userRepository.findByEmail(ownerEmail).isPresent()) {
            throw new IllegalArgumentException("An account with that email already exists");
        }

        String rawToken = createToken();
        Instant expiresAt = Instant.now().plus(INVITATION_LIFETIME);
        BusinessInvitation invitation = invitationRepository.save(new BusinessInvitation(
                request.businessName().trim(), request.ownerName().trim(), ownerEmail,
                request.ownerPhone().trim(), hashToken(rawToken), expiresAt, actor));
        auditLogService.record(null, actor, "BUSINESS_INVITATION_CREATED", "BusinessInvitation",
                invitation.getId().toString(), ownerEmail);

        return new CreatedInvitation(invitation.getId().toString(), invitation.getBusinessName(), ownerEmail,
                publicBaseUrl + "/accept-invitation?token=" + rawToken, expiresAt);
    }

    @Transactional
    public AcceptedInvitation acceptInvitation(String rawToken, String rawPassword) {
        if (rawToken == null || rawToken.isBlank()) {
            throw new IllegalArgumentException("Invitation token is required");
        }
        BusinessInvitation invitation = invitationRepository.findByTokenHash(hashToken(rawToken.trim()))
                .orElseThrow(() -> new IllegalArgumentException("Invitation is invalid or expired"));
        if (invitation.getAcceptedAt() != null || !invitation.getExpiresAt().isAfter(Instant.now())) {
            throw new IllegalArgumentException("Invitation is invalid or expired");
        }
        if (userRepository.findByEmail(invitation.getOwnerEmail()).isPresent()) {
            throw new IllegalArgumentException("An account with that email already exists");
        }

        Business business = businessRepository.save(new Business(
                invitation.getBusinessName(), invitation.getOwnerEmail(), invitation.getOwnerPhone()));
        User owner = new User(business, invitation.getOwnerEmail(), invitation.getOwnerPhone(),
                invitation.getOwnerName(), passwordEncoder.encode(rawPassword), UserRole.OWNER);
        owner = userRepository.save(owner);
        invitation.accept(business, owner, Instant.now());
        auditLogService.record(business, owner, "BUSINESS_OWNER_INVITATION_ACCEPTED", "Business",
                business.getId().toString(), "Owner account created; branch setup pending");

        return new AcceptedInvitation(business, owner, jwtService.generateToken(owner));
    }

    private static String createToken() {
        byte[] randomBytes = new byte[32];
        SECURE_RANDOM.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }

    private static String hashToken(String token) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is not available", exception);
        }
    }

    public record CreateInvitationRequest(String businessName, String ownerName, String ownerEmail, String ownerPhone) {}
    public record CreatedInvitation(String invitationId, String businessName, String ownerEmail,
                                    String invitationUrl, Instant expiresAt) {}
    public record AcceptedInvitation(Business business, User owner, String token) {}
}
