package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.domain.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    Optional<User> findByPhone(String phone);
    boolean existsByRole(UserRole role);
}
