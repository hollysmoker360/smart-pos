package com.trixx.smartpos.controller;

import com.trixx.smartpos.model.Order;
import com.trixx.smartpos.model.Refund;
import com.trixx.smartpos.repository.OrderRepository;
import com.trixx.smartpos.repository.RefundRepository;
import com.trixx.smartpos.security.TenantContext;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

@RestController
@RequestMapping("/api/v1")
public class ManagementController {

    private final OrderRepository orderRepository;
    private final RefundRepository refundRepository;

    public ManagementController(OrderRepository orderRepository, RefundRepository refundRepository) {
        this.orderRepository = orderRepository;
        this.refundRepository = refundRepository;
    }

    @GetMapping("/reports/sales")
    public ResponseEntity<Map<String, Object>> getSalesReport() {
        List<Order> orders = orderRepository.findAll();

        BigDecimal grossSales = orders.stream()
                .filter(o -> "PAID".equalsIgnoreCase(o.getStatus()) || "EXIT_APPROVED".equalsIgnoreCase(o.getStatus()))
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long transactionCount = orders.stream()
                .filter(o -> "PAID".equalsIgnoreCase(o.getStatus()) || "EXIT_APPROVED".equalsIgnoreCase(o.getStatus()))
                .count();

        Map<String, Object> report = new HashMap<>();
        report.put("grossSales", grossSales);
        report.put("transactionCount", transactionCount);
        report.put("currency", "KES");
        report.put("generatedAt", Instant.now().toString());

        return ResponseEntity.ok(report);
    }

    @PostMapping("/refunds")
    public ResponseEntity<Refund> submitRefund(@RequestBody Map<String, Object> body) {
        String orderIdStr = (String) body.get("orderId");
        String reason = (String) body.get("reason");
        BigDecimal amount = new BigDecimal(body.get("amount").toString());

        Order order = orderRepository.findById(UUID.fromString(orderIdStr)).orElseThrow();

        Refund refund = Refund.builder()
                .tenantId(order.getTenantId())
                .branchId(order.getBranchId())
                .orderId(order.getId())
                .amount(amount)
                .reason(reason)
                .status("APPROVED")
                .createdAt(Instant.now())
                .build();

        refund = refundRepository.save(refund);
        order.setStatus("REFUNDED");
        orderRepository.save(order);

        return ResponseEntity.ok(refund);
    }

    @GetMapping("/admin/overview")
    public ResponseEntity<Map<String, Object>> getAdminOverview() {
        Map<String, Object> overview = new HashMap<>();
        overview.put("systemStatus", "OPERATIONAL");
        overview.put("activeTenants", 1);
        overview.put("activeBranches", 2);
        overview.put("totalTransactions", orderRepository.count());
        overview.put("serverTime", Instant.now().toString());
        return ResponseEntity.ok(overview);
    }
}
