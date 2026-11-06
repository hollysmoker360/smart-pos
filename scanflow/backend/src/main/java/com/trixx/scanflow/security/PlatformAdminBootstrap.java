package com.trixx.scanflow.security;

import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.domain.UserRole;
import com.trixx.scanflow.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Locale;

@Component
@Profile("prod")
public class PlatformAdminBootstrap implements ApplicationRunner {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final String email;
    private final String fullName;
    private final String password;

    public PlatformAdminBootstrap(UserRepository userRepository,
                                  PasswordEncoder passwordEncoder,
                                  @Value("${app.bootstrap.platform-admin.email:}") String email,
                                  @Value("${app.bootstrap.platform-admin.name:}") String fullName,
                                  @Value("${app.bootstrap.platform-admin.password:}") String password) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.email = email.trim().toLowerCase(Locale.ROOT);
        this.fullName = fullName.trim();
        this.password = password;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!email.isBlank()) {
            User existing = userRepository.findByEmail(email).orElse(null);
            if (existing != null) {
                if (existing.getRole() != UserRole.PLATFORM_ADMIN) {
                    throw new IllegalStateException("Configured platform admin email is already assigned to another role");
                }
                return;
            }
            if (fullName.isBlank() || password.length() < 12 || password.length() > 72) {
                throw new IllegalStateException("Initial platform admin requires a name and a 12-72 character password");
            }
            User admin = new User(null, email, null, fullName, passwordEncoder.encode(password), UserRole.PLATFORM_ADMIN);
            admin.setTenantScope("PLATFORM");
            userRepository.save(admin);
            return;
        }

        if (!userRepository.existsByRole(UserRole.PLATFORM_ADMIN)) {
            throw new IllegalStateException("No platform admin exists; configure PLATFORM_ADMIN_EMAIL, PLATFORM_ADMIN_NAME and PLATFORM_ADMIN_PASSWORD for initial bootstrap");
        }
    }
}
