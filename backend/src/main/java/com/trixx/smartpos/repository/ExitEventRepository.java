package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.ExitEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ExitEventRepository extends JpaRepository<ExitEvent, UUID> {
}
