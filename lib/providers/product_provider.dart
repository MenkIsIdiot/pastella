import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> products = [];

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    searchQuery = '';

    notifyListeners();

    try {
      products = await _apiService.getProducts();
    } catch (e) {
      errorMessage = 'Gagal memuat produk. Periksa koneksi internet.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    final keyword = query.trim();

    if (keyword.isEmpty) {
      await fetchProducts();
      return;
    }

    isLoading = true;
    errorMessage = null;
    searchQuery = keyword;

    notifyListeners();

    try {
      products = await _apiService.searchProducts(keyword);
    } catch (e) {
      errorMessage = 'Pencarian gagal. Silakan coba kembali.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
