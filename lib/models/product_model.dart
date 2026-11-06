class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String sellerLocation;
  final String name;
  final String category;
  final String description;
  final double price;
  final String unit; // 'kg', 'bundle', 'litre', 'bag', 'piece'
  final String? imageUrl;
  final bool inStock;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerLocation,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.unit = 'kg',
    this.imageUrl,
    this.inStock = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'sellerLocation': sellerLocation,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'unit': unit,
      'imageUrl': imageUrl,
      'inStock': inStock,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? 'Organic Farmer',
      sellerPhone: json['sellerPhone'] as String? ?? '',
      sellerLocation: json['sellerLocation'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Organic Vegetables',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'kg',
      imageUrl: json['imageUrl'] as String?,
      inStock: json['inStock'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? sellerPhone,
    String? sellerLocation,
    String? name,
    String? category,
    String? description,
    double? price,
    String? unit,
    String? imageUrl,
    bool? inStock,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerLocation: sellerLocation ?? this.sellerLocation,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      inStock: inStock ?? this.inStock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
