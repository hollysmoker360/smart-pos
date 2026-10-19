import 'dart:convert';

class ShoppingSessionDto {
  final String sessionId;
  final String customerId;
  final String trolleyId;
  final String branchId;
  final String status;
  final String createdAt;

  ShoppingSessionDto({
    required this.sessionId,
    required this.customerId,
    required this.trolleyId,
    required this.branchId,
    required this.status,
    required this.createdAt,
  });

  factory ShoppingSessionDto.fromJson(Map<String, dynamic> json) {
    return ShoppingSessionDto(
      sessionId: (json['sessionId'] ?? json['id'] ?? '').toString(),
      customerId: (json['customerId'] ?? '').toString(),
      trolleyId: (json['trolleyId'] ?? '').toString(),
      branchId: (json['branchId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}

class BasketItemDto {
  final String itemId;
  final String productId;
  final String productName;
  final String barcode;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double lineTotal;

  BasketItemDto({
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.lineTotal,
  });

  factory BasketItemDto.fromJson(Map<String, dynamic> json) {
    return BasketItemDto(
      itemId: (json['itemId'] ?? json['id'] ?? '').toString(),
      productId: (json['productId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      barcode: (json['barcode'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ShoppingBasketDto {
  final String basketId;
  final String sessionId;
  final int version;
  final List<BasketItemDto> items;
  final double subtotal;
  final double taxes;
  final double totalDiscounts;
  final double estimatedTotal;

  ShoppingBasketDto({
    required this.basketId,
    required this.sessionId,
    required this.version,
    required this.items,
    required this.subtotal,
    required this.taxes,
    required this.totalDiscounts,
    required this.estimatedTotal,
  });

  factory ShoppingBasketDto.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    return ShoppingBasketDto(
      basketId: (json['basketId'] ?? json['id'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      items: itemsList.map((i) => BasketItemDto.fromJson(i)).toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxes: (json['taxes'] ?? json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalDiscounts: (json['totalDiscounts'] ?? json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      estimatedTotal: (json['estimatedTotal'] ?? json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CheckoutSnapshotDto {
  final String orderId;
  final String sessionId;
  final double totalAmount;
  final String status;
  final String createdAt;

  CheckoutSnapshotDto({
    required this.orderId,
    required this.sessionId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory CheckoutSnapshotDto.fromJson(Map<String, dynamic> json) {
    return CheckoutSnapshotDto(
      orderId: (json['orderId'] ?? json['id'] ?? json['orderNumber'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}

class PaymentStatusDto {
  final String orderId;
  final String status;
  final String? providerReference;
  final String? message;

  PaymentStatusDto({
    required this.orderId,
    required this.status,
    this.providerReference,
    this.message,
  });

  factory PaymentStatusDto.fromJson(Map<String, dynamic> json) {
    return PaymentStatusDto(
      orderId: (json['orderId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      providerReference: json['providerReference']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class ReceiptDto {
  final String receiptNumber;
  final String orderId;
  final String branchName;
  final String customerName;
  final String issueTimestamp;
  final double totalPaid;
  final List<BasketItemDto> items;
  final String exitTokenCode;

  ReceiptDto({
    required this.receiptNumber,
    required this.orderId,
    required this.branchName,
    required this.customerName,
    required this.issueTimestamp,
    required this.totalPaid,
    required this.items,
    required this.exitTokenCode,
  });

  factory ReceiptDto.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    return ReceiptDto(
      receiptNumber: (json['receiptNumber'] ?? json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      branchName: (json['branchName'] ?? 'TRIXX Supermarket').toString(),
      customerName: (json['customerName'] ?? 'Customer').toString(),
      issueTimestamp: (json['issueTimestamp'] ?? '').toString(),
      totalPaid: (json['totalPaid'] ?? json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      items: itemsList.map((i) => BasketItemDto.fromJson(i)).toList(),
      exitTokenCode: (json['exitTokenCode'] ?? json['receiptNumber'] ?? '').toString(),
    );
  }
}

class ExitTokenDto {
  final String tokenCode;
  final String orderId;
  final String status;
  final String expiresAt;

  ExitTokenDto({
    required this.tokenCode,
    required this.orderId,
    required this.status,
    required this.expiresAt,
  });

  factory ExitTokenDto.fromJson(Map<String, dynamic> json) {
    return ExitTokenDto(
      tokenCode: (json['tokenCode'] ?? json['tokenHash'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      expiresAt: (json['expiresAt'] ?? '').toString(),
    );
  }
}

class TrolleyDeviceDto {
  final String deviceId;
  final String serialNumber;
  final String status;
  final int batteryLevel;
  final String branchId;

  TrolleyDeviceDto({
    required this.deviceId,
    required this.serialNumber,
    required this.status,
    required this.batteryLevel,
    required this.branchId,
  });

  factory TrolleyDeviceDto.fromJson(Map<String, dynamic> json) {
    return TrolleyDeviceDto(
      deviceId: (json['deviceId'] ?? '').toString(),
      serialNumber: (json['serialNumber'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      batteryLevel: (json['batteryLevel'] as num?)?.toInt() ?? 100,
      branchId: (json['branchId'] ?? '').toString(),
    );
  }
}

class DiscrepancyDto {
  final String discrepancyId;
  final String sessionId;
  final String type;
  final String description;
  final String status;

  DiscrepancyDto({
    required this.discrepancyId,
    required this.sessionId,
    required this.type,
    required this.description,
    required this.status,
  });

  factory DiscrepancyDto.fromJson(Map<String, dynamic> json) {
    return DiscrepancyDto(
      discrepancyId: (json['discrepancyId'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}
