class InventoryItem {
  final String itemCode;
  final String itemType;
  final int quantity;

  const InventoryItem({
    required this.itemCode,
    required this.itemType,
    this.quantity = 0,
  });

  Map<String, dynamic> toJson() => {
        'item_code': itemCode,
        'item_type': itemType,
        'quantity': quantity,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      itemCode: json['item_code'] as String,
      itemType: json['item_type'] as String? ?? 'booster',
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  InventoryItem copyWith({
    int? quantity,
  }) {
    return InventoryItem(
      itemCode: itemCode,
      itemType: itemType,
      quantity: quantity ?? this.quantity,
    );
  }
}
