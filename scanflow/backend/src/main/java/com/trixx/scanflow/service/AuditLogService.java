package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.AuditLog;
import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.repository.AuditLogRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuditLogService {
    private final AuditLogRepository auditLogRepository;

    public AuditLogService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    @Transactional
    public void record(Business business, User actor, String action, String entityType, String entityId, String details) {
        auditLogRepository.save(new AuditLog(business, actor, action, entityType, entityId, details));
    }
}
