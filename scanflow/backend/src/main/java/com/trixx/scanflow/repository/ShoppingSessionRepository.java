package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.ShoppingSession;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ShoppingSessionRepository extends JpaRepository<ShoppingSession, UUID> {
}
