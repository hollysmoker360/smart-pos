package com.trixx.smarttrolley.service;

import com.trixx.smarttrolley.domain.*;
import com.trixx.smarttrolley.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ManagementAndTheftPreventionService {

    private final ShoppingBasketRepository basketRepository;
    private final OrderRepository orderRepository;
    private final TrolleyDeviceRepository trolleyRepository;
    private final AuditEventRepository auditEventRepository;

    public ManagementAndTheftPreventionService(ShoppingBasketRepository basketRepository,
                                                OrderRepository orderRepository,
                                                TrolleyDeviceRepository trolleyRepository,
                                                AuditEventRepository auditEventRepository) {
        this.basketRepository = basketRepository;
        this.orderRepository = orderRepository;
        this.trolleyRepository = trolleyRepository;
        this.auditEventRepository = auditEventRepository;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> verifyWeightDiscrepancy(Long basketId, BigDecimal measuredWeightGrams) {
        ShoppingBasket basket = basketRepository.findById(basketId)
                .orElseThrow(() -> new IllegalArgumentException("BASKET_NOT_FOUND: Basket ID not found"));

        BigDecimal expectedWeight = basket.getExpectedTotalWeight();
        BigDecimal difference = measuredWeightGrams.subtract(expectedWeight).abs();
        boolean withinTolerance = difference.compareTo(new BigDecimal("50.00")) <= 0;

        Map<String, Object> result = new HashMap<>();
        result.put("basketId", basketId);
        result.put("expectedWeightGrams", expectedWeight);
        result.put("measuredWeightGrams", measuredWeightGrams);
        result.put("discrepancyGrams", difference);
        result.put("withinTolerance", withinTolerance);
        result.put("actionRequired", !withinTolerance);

        return result;
    }

    @Transactional
    public void recordSupervisorOverride(Long branchId, Long supervisorId, String resourceType, String resourceId, String reason) {
        AuditEvent audit = new AuditEvent(
                null,
                branchId,
                supervisorId,
                "SUPERVISOR_OVERRIDE",
                resourceType,
                resourceId,
                "Reason: " + reason
        );
        auditEventRepository.save(audit);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getBranchDashboardMetrics(Long branchId) {
        List<Order> orders = orderRepository.findByBranchIdOrderByCreatedAtDesc(branchId);
        List<TrolleyDevice> trolleys = trolleyRepository.findByBranchId(branchId);

        BigDecimal totalSales = BigDecimal.ZERO;
        long paidOrdersCount = 0;

        for (Order o : orders) {
            if ("PAID".equals(o.getOrderStatus()) || "EXIT_AUTHORIZED".equals(o.getOrderStatus()) || "COMPLETED".equals(o.getOrderStatus())) {
                totalSales = totalSales.add(o.getTotalAmount());
                paidOrdersCount++;
            }
        }

        long availableTrolleys = trolleys.stream().filter(t -> "AVAILABLE".equals(t.getDeviceStatus())).count();
        long activeTrolleys = trolleys.stream().filter(t -> "IN_USE".equals(t.getDeviceStatus())).count();

        Map<String, Object> metrics = new HashMap<>();
        metrics.put("branchId", branchId);
        metrics.put("totalSales", totalSales);
        metrics.put("completedOrders", paidOrdersCount);
        metrics.put("totalTrolleys", trolleys.size());
        metrics.put("availableTrolleys", availableTrolleys);
        metrics.put("activeTrolleys", activeTrolleys);
        metrics.put("timestamp", LocalDateTime.now());

        return metrics;
    }
}
