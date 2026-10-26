import 'package:dio/dio.dart';

import '../models/product.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<Product>> getProducts() async {
    final response = await _dio.get('/products', queryParameters: {'limit': 0});

    final List<dynamic> data = response.data['products'];

    return data.map((item) => Product.fromJson(item)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await _dio.get(
      '/products/search',
      queryParameters: {'q': query, 'limit': 0},
    );

    final List<dynamic> data = response.data['products'];

    return data.map((item) => Product.fromJson(item)).toList();
  }
}
