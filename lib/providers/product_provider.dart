import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _selectedCategory = 'All Categories';
  String _searchQuery = '';

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ProductModel> get filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'All Categories' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sellerLocation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sellerName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    await _db.initialize();
    _products = _db.getProducts();

    _isLoading = false;
    notifyListeners();
  }

  Future<ProductModel> addProduct({
    required String sellerId,
    required String sellerName,
    required String sellerPhone,
    required String sellerLocation,
    required String name,
    required String category,
    required String description,
    required double price,
    required String unit,
    String? imageUrl,
  }) async {
    final newProduct = ProductModel(
      id: 'prod_${const Uuid().v4().substring(0, 8)}',
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      sellerLocation: sellerLocation,
      name: name.trim(),
      category: category,
      description: description.trim(),
      price: price,
      unit: unit.trim(),
      imageUrl: imageUrl,
      inStock: true,
      createdAt: DateTime.now(),
    );

    final created = await _db.addProduct(newProduct);
    _products.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<void> deleteProduct(String productId) async {
    await _db.deleteProduct(productId);
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}
