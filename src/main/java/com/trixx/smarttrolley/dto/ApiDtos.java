package com.trixx.smarttrolley.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class ApiDtos {

    public record TrolleyClaimRequest(String qrCodeHash, Long customerId) {}

    public record ScanEventRequest(
            String eventId,
            String deviceCode,
            Long sessionId,
            String barcode,
            Long sequenceNumber,
            LocalDateTime timestamp,
            String rawPayload
    ) {}

    public record RemovalEventRequest(
            String eventId,
            String deviceCode,
            Long sessionId,
            String barcode,
            Long sequenceNumber
    ) {}

    public record PaymentInitiationRequest(
            Long orderId,
            String phoneNumber
    ) {}

    public record MpesaCallbackPayload(
            String checkoutRequestId,
            int resultCode,
            String resultDesc,
            String mpesaReceiptNumber
    ) {}

    public record ExitVerificationRequest(
            String tokenHash
    ) {}

    public record SupervisorOverrideRequest(
            Long branchId,
            Long supervisorId,
            String resourceType,
            String resourceId,
            String reason
    ) {}

    public record WeightVerificationRequest(
            Long basketId,
            BigDecimal measuredWeightGrams
    ) {}

    public record BasketItemDto(
            Long id,
            Long productId,
            String productName,
            String barcode,
            Integer quantity,
            BigDecimal unitPrice,
            BigDecimal lineTotal
    ) {}

    public record BasketDto(
            Long id,
            Long sessionId,
            Integer version,
            BigDecimal subtotal,
            BigDecimal taxAmount,
            BigDecimal discountAmount,
            BigDecimal totalAmount,
            BigDecimal expectedTotalWeight,
            String status,
            List<BasketItemDto> items
    ) {}

    public record ErrorResponse(
            String errorCode,
            String message,
            LocalDateTime timestamp
    ) {}
}
