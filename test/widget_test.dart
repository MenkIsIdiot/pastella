import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pastella/models/product.dart';
import 'package:pastella/providers/product_provider.dart';
import 'package:pastella/screens/checkout_screen.dart';
import 'package:pastella/screens/home_screen.dart';
import 'package:pastella/services/api_service.dart';

void main() {
  test('catalog filters products and updates favorites and cart', () async {
    final provider = ProductProvider(apiService: _FakeApiService());

    await provider.fetchProducts();
    expect(provider.products, hasLength(3));
    expect(provider.categories, ['Semua', 'beauty', 'fragrances', 'koleksi']);
    expect(provider.products.first.title, 'Miniatur Tank Baja Koleksi');

    provider.setCategory('beauty');
    expect(provider.products, hasLength(1));
    expect(provider.products.single.title, 'Produk Contoh');

    provider.setCategory('Semua');
    provider.setSearchQuery('fragrance');
    expect(provider.products.single.title, 'Parfum Contoh');

    final product = provider.products.single;
    provider.toggleFavorite(product);
    provider.addToCart(product);
    provider.addToCart(product);

    expect(provider.favoriteProducts, [product]);
    expect(provider.cartItemCount, 2);
    expect(provider.quantityFor(product.id), 2);
    expect(provider.cartTotal, 25);

    provider.updateCartQuantity(product, 1);
    expect(provider.cartItemCount, 1);
    expect(provider.cartTotal, 12.5);

    provider.clearCart();
    expect(provider.cartProducts, isEmpty);

    provider.setSearchQuery('');
    provider.setSortMode('priceLow');
    expect(provider.products.first.title, 'Produk Contoh');

    provider.setSearchQuery('tank baja');
    expect(provider.products.single.title, 'Miniatur Tank Baja Koleksi');
  });

  testWidgets('promo collection button scrolls to the product collection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProductProvider(apiService: _FakeApiService()),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final exploreButton = find.text('Jelajahi koleksi');
    expect(exploreButton, findsOneWidget);
    await tester.tap(exploreButton);
    await tester.pumpAndSettle();

    expect(find.text('Pilihan untukmu'), findsOneWidget);
  });

  testWidgets('checkout validates delivery details and confirms the order', (
    WidgetTester tester,
  ) async {
    final provider = ProductProvider(apiService: _FakeApiService());
    await provider.fetchProducts();
    provider.addToCart(provider.products.first);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: CheckoutScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final placeOrderButton = find.textContaining('Buat pesanan');
    await tester.ensureVisible(placeOrderButton);
    await tester.tap(placeOrderButton);
    await tester.pumpAndSettle();
    expect(find.text('Nama penerima wajib diisi'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.at(0));
    await tester.enterText(fields.at(0), 'Dina Contoh');
    await tester.ensureVisible(fields.at(1));
    await tester.enterText(fields.at(1), '08123456789');
    await tester.ensureVisible(fields.at(2));
    await tester.enterText(fields.at(2), 'Jalan Melati No. 10, Bandung');

    await tester.ensureVisible(placeOrderButton);
    await tester.tap(placeOrderButton);
    await tester.pumpAndSettle();

    expect(find.text('Pesanan berhasil dibuat!'), findsOneWidget);
    expect(find.text('Dina Contoh'), findsOneWidget);
    expect(provider.cartProducts, isEmpty);
  });
}

class _FakeApiService extends ApiService {
  @override
  Future<List<Product>> getProducts() async => const [
    Product(
      id: 1,
      title: 'Produk Contoh',
      description: 'Deskripsi produk.',
      category: 'beauty',
      price: 12.5,
      rating: 4.8,
      thumbnail: '',
      brand: 'Pastella',
      stock: 5,
    ),
    Product(
      id: 2,
      title: 'Parfum Contoh',
      description: 'Deskripsi produk.',
      category: 'fragrances',
      price: 12.5,
      rating: 4.6,
      thumbnail: '',
      brand: 'Pastella',
      stock: 3,
    ),
  ];
}
