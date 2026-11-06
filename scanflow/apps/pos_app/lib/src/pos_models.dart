class PosUser {
  const PosUser({required this.fullName, required this.role});

  final String fullName;
  final String role;
}

class PosAuthSession {
  const PosAuthSession({required this.token, required this.user});

  final String token;
  final PosUser user;

  factory PosAuthSession.fromJson(Map<String, dynamic> json) => PosAuthSession(
        token: _string(json, 'token'),
        user: PosUser(
          fullName: _string(_map(json, 'user'), 'fullName'),
          role: _string(_map(json, 'user'), 'role'),
        ),
      );
}

class PosBranch {
  const PosBranch({
    required this.id,
    required this.name,
    required this.currency,
  });

  final String id;
  final String name;
  final String currency;

  factory PosBranch.fromJson(Map<String, dynamic> json) => PosBranch(
        id: _string(json, 'id'),
        name: _string(json, 'name'),
        currency: _string(json, 'currency'),
      );
}

class PosProduct {
  const PosProduct({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.stock,
    this.barcode,
  });

  final String id;
  final String sku;
  final String name;
  final String? barcode;
  final num price;
  final int stock;

  factory PosProduct.fromJson(Map<String, dynamic> json) => PosProduct(
        id: _string(json, 'id'),
        sku: _string(json, 'sku'),
        name: _string(json, 'name'),
        barcode: json['barcode'] as String?,
        price: _number(json, 'price'),
        stock: _number(json, 'stock').toInt(),
      );
}

class PosQuoteItem {
  const PosQuoteItem({
    required this.productId,
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.taxAmount,
    required this.lineTotal,
  });

  final String productId;
  final String sku;
  final String name;
  final int quantity;
  final num unitPrice;
  final num taxAmount;
  final num lineTotal;

  factory PosQuoteItem.fromJson(Map<String, dynamic> json) => PosQuoteItem(
        productId: _string(json, 'productId'),
        sku: _string(json, 'sku'),
        name: _string(json, 'name'),
        quantity: _number(json, 'quantity').toInt(),
        unitPrice: _number(json, 'unitPrice'),
        taxAmount: _number(json, 'taxAmount'),
        lineTotal: _number(json, 'lineTotal'),
      );
}

class PosQuote {
  const PosQuote({
    required this.currency,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final String currency;
  final List<PosQuoteItem> items;
  final num subtotal;
  final num tax;
  final num total;

  factory PosQuote.fromJson(Map<String, dynamic> json) => PosQuote(
        currency: _string(json, 'currency'),
        items: _list(json, 'items')
            .map((item) => PosQuoteItem.fromJson(item))
            .toList(growable: false),
        subtotal: _number(json, 'subtotalAmount'),
        tax: _number(json, 'taxAmount'),
        total: _number(json, 'totalAmount'),
      );
}

class PosReceipt {
  const PosReceipt({
    required this.orderNumber,
    required this.currency,
    required this.total,
    required this.cashReceived,
    required this.changeDue,
  });

  final String orderNumber;
  final String currency;
  final num total;
  final num cashReceived;
  final num changeDue;

  factory PosReceipt.fromJson(Map<String, dynamic> json) => PosReceipt(
        orderNumber: _string(json, 'orderNumber'),
        currency: _string(json, 'currency'),
        total: _number(json, 'totalAmount'),
        cashReceived: _number(json, 'cashReceived'),
        changeDue: _number(json, 'changeDue'),
      );
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Response is missing "$key".');
}

Map<String, dynamic> _map(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Response is missing "$key".');
}

num _number(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value;
  throw FormatException('Response is missing "$key".');
}

List<Map<String, dynamic>> _list(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException('Response is missing "$key".');
  return value.cast<Map<String, dynamic>>();
}
