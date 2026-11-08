import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService;

  ProductProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  List<Product> _allProducts = [];
  final Set<int> _favoriteIds = {};
  final Map<int, int> _cart = {};

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedCategory = 'Semua';
  String sortMode = 'popular';

  List<Product> get products {
    final query = searchQuery.toLowerCase();
    final filtered = _allProducts.where((product) {
      final matchesCategory =
          selectedCategory == 'Semua' || product.category == selectedCategory;
      final matchesSearch =
          query.isEmpty ||
          product.title.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    switch (sortMode) {
      case 'priceLow':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceHigh':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return filtered;
  }

  List<String> get categories {
    final values = _allProducts.map((product) => product.category).toSet().toList()
      ..sort();
    return ['Semua', ...values];
  }

  List<Product> get favoriteProducts =>
      _allProducts.where((product) => _favoriteIds.contains(product.id)).toList();

  List<Product> get cartProducts =>
      _allProducts.where((product) => _cart.containsKey(product.id)).toList();

  int get cartItemCount =>
      _cart.values.fold(0, (total, quantity) => total + quantity);

  int get nextProductId =>
      _allProducts.fold<int>(0, (maxId, product) {
        return product.id > maxId ? product.id : maxId;
      }) +
      1;

  double get cartTotal => cartProducts.fold(
    0,
    (total, product) => total + product.price * quantityFor(product.id),
  );

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  int quantityFor(int productId) => _cart[productId] ?? 0;

  void addProduct(Product product) {
    _allProducts = [..._allProducts, product];
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _allProducts.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      throw StateError('Produk ${product.id} tidak ditemukan.');
    }

    _allProducts[index] = product;
    notifyListeners();
  }

  void deleteProduct(int productId) {
    _allProducts.removeWhere((product) => product.id == productId);
    _favoriteIds.remove(productId);
    _cart.remove(productId);
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final products = await _apiService.getProducts();
      _allProducts = [...products, _tankMiniature];
    } catch (e) {
      errorMessage = 'Gagal memuat produk. Periksa koneksi internet.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query.trim();
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setSortMode(String mode) {
    sortMode = mode;
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (!_favoriteIds.add(product.id)) {
      _favoriteIds.remove(product.id);
    }
    notifyListeners();
  }

  void addToCart(Product product) {
    _cart.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void updateCartQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = quantity;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  static const Product _tankMiniature = Product(
    id: -1,
    title: 'Miniatur Tank Baja Koleksi',
    description:
        'Miniatur tank baja bergaya kendaraan klasik untuk koleksi dan pajangan. '
        'Model die-cast berukuran saku dengan detail trek dan kubah yang keren. '
        'Produk miniatur dekoratif ini bukan kendaraan sungguhan dan tidak '
        'memiliki fungsi operasional.',
    category: 'koleksi',
    price: 29.90,
    rating: 4.9,
    thumbnail: '',
    brand: 'Pastella Collectibles',
    stock: 18,
  );
}
