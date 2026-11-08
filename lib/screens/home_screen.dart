import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_artwork.dart';
import 'checkout_screen.dart';
import 'detail_screen.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _collectionKey = GlobalKey();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exploreCollection() {
    final provider = context.read<ProductProvider>();
    provider.setCategory('Semua');
    provider.setSearchQuery('');
    _searchController.clear();

    if (_selectedTab != 0) setState(() => _selectedTab = 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _collectionKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
          alignment: 0.05,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: pastelCream,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(provider),
                if (_selectedTab == 0) _buildSearchField(provider),
                Expanded(child: _buildTabContent(provider)),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedTab,
            onDestinationSelected: (index) {
              setState(() => _selectedTab = index);
            },
            backgroundColor: Colors.white,
            indicatorColor: pastelLavender,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: const Icon(Icons.favorite_rounded),
                label: 'Favorit',
              ),
              NavigationDestination(
                icon: Badge(
                  label: Text('${provider.cartItemCount}'),
                  isLabelVisible: provider.cartItemCount > 0,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('${provider.cartItemCount}'),
                  isLabelVisible: provider.cartItemCount > 0,
                  child: const Icon(Icons.shopping_bag_rounded),
                ),
                label: 'Keranjang',
              ),
            ],
          ),
          floatingActionButton: _selectedTab == 0
              ? FloatingActionButton.extended(
                  onPressed: _createProduct,
                  backgroundColor: pastelPurple,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah produk'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeader(ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C86D8), pastelPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pastella',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: pastelText,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Belanja kecil, bahagia besar ✨',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Buka keranjang',
              onPressed: () => setState(() => _selectedTab = 2),
              icon: Badge(
                label: Text('${provider.cartItemCount}'),
                isLabelVisible: provider.cartItemCount > 0,
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: pastelText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Cari produk, merek, atau kategori...',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
          prefixIcon: const Icon(Icons.search_rounded, color: pastelPurple),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(ProductProvider provider) {
    final Widget content;
    if (provider.isLoading) {
      content = const Center(
        child: CircularProgressIndicator(color: pastelPurple),
      );
    } else if (provider.errorMessage != null && provider.products.isEmpty) {
      content = _buildErrorState(provider);
    } else {
      switch (_selectedTab) {
        case 1:
          content = _buildFavorites(provider);
          break;
        case 2:
          content = _buildCart(provider);
          break;
        default:
          content = _buildHomeContent(provider);
          break;
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.025, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(
          '$_selectedTab-${provider.isLoading}-'
          '${provider.errorMessage != null && provider.products.isEmpty}',
        ),
        child: content,
      ),
    );
  }

  Widget _buildHomeContent(ProductProvider provider) {
    if (provider.products.isEmpty) return _buildEmptyState(provider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildPromoBanner()),
        SliverToBoxAdapter(child: _buildCategories(provider)),
        SliverToBoxAdapter(
          child: Padding(
            key: _collectionKey,
            padding: const EdgeInsets.fromLTRB(20, 2, 12, 13),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.searchQuery.isNotEmpty
                        ? 'Hasil pencarian'
                        : provider.selectedCategory == 'Semua'
                        ? 'Pilihan untukmu'
                        : provider.selectedCategory
                              .replaceAll('-', ' ')
                              .toBeginningOfSentenceCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: pastelText,
                    ),
                  ),
                ),
                Text(
                  '${provider.products.length} produk',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Urutkan produk',
                  initialValue: provider.sortMode,
                  onSelected: provider.setSortMode,
                  icon: const Icon(Icons.tune_rounded, color: pastelPurple),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'popular',
                      child: Text('Rating tertinggi'),
                    ),
                    PopupMenuItem(
                      value: 'priceLow',
                      child: Text('Harga terendah'),
                    ),
                    PopupMenuItem(
                      value: 'priceHigh',
                      child: Text('Harga tertinggi'),
                    ),
                    PopupMenuItem(value: 'name', child: Text('Nama A–Z')),
                  ],
                ),
              ],
            ),
          ),
        ),
        _productGrid(provider, provider.products),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 3, 20, 19),
      child: Container(
        height: 157,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8F79CA), Color(0xFF65519F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: InkWell(
          onTap: _exploreCollection,
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -48,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 190,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 19, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'TEMUKAN FAVORIT BARU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hal kecil yang\nbikin harimu manis.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      children: [
                        Text(
                          'Jelajahi koleksi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 11),
          child: Text(
            'Jelajahi kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: pastelText,
            ),
          ),
        ),
        SizedBox(
          height: 43,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: provider.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              final selected = provider.selectedCategory == category;
              return ChoiceChip(
                label: Text(
                  category.replaceAll('-', ' '),
                  style: TextStyle(
                    color: selected ? Colors.white : pastelText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => provider.setCategory(category),
                backgroundColor: Colors.white,
                selectedColor: pastelPurple,
                side: BorderSide(
                  color: selected ? pastelPurple : Colors.transparent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 17),
      ],
    );
  }

  Widget _buildFavorites(ProductProvider provider) {
    final favorites = provider.favoriteProducts;
    if (favorites.isEmpty) {
      return _buildMessageState(
        icon: Icons.favorite_border_rounded,
        title: 'Belum ada yang disimpan',
        message: 'Tekan ikon hati pada produk yang kamu suka.',
        action: OutlinedButton.icon(
          onPressed: () => setState(() => _selectedTab = 0),
          icon: const Icon(Icons.storefront_outlined),
          label: const Text('Jelajahi produk'),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Text(
              'Produk favoritmu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: pastelText,
              ),
            ),
          ),
        ),
        _productGrid(provider, favorites),
      ],
    );
  }

  Widget _productGrid(ProductProvider provider, List<Product> products) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            imageHeroTag: _productHeroTag(product),
            isFavorite: provider.isFavorite(product.id),
            onFavoriteTap: () => provider.toggleFavorite(product),
            onAddToCart: () {
              provider.addToCart(product);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('${product.title} ditambahkan ke keranjang'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Lihat keranjang',
                      onPressed: () => setState(() => _selectedTab = 2),
                    ),
                  ),
                );
            },
            onTap: () => _openDetail(product),
          );
        }, childCount: products.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
      ),
    );
  }

  Widget _buildCart(ProductProvider provider) {
    if (provider.cartProducts.isEmpty) {
      return _buildMessageState(
        icon: Icons.shopping_bag_outlined,
        title: 'Keranjang masih kosong',
        message: 'Yuk, temukan sesuatu yang kamu suka hari ini.',
        action: ElevatedButton.icon(
          onPressed: () => setState(() => _selectedTab = 0),
          icon: const Icon(Icons.storefront_outlined),
          label: const Text('Mulai belanja'),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 13),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Keranjang belanja',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: pastelText,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: provider.clearCart,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Kosongkan'),
                style: TextButton.styleFrom(foregroundColor: Colors.black54),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            itemCount: provider.cartProducts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = provider.cartProducts[index];
              return _buildCartItem(provider, product);
            },
          ),
        ),
        _buildCartSummary(provider),
      ],
    );
  }

  Widget _buildCartItem(ProductProvider provider, Product product) {
    final quantity = provider.quantityFor(product.id);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: pastelLavender.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ProductArtwork(product: product),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: pastelText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: pastelPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _quantityButton(
                      icon: Icons.remove_rounded,
                      onTap: () =>
                          provider.updateCartQuantity(product, quantity - 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add_rounded,
                      onTap: () =>
                          provider.updateCartQuantity(product, quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 29,
      height: 29,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: pastelLavender,
          foregroundColor: pastelPurple,
        ),
        icon: Icon(icon, size: 17),
      ),
    );
  }

  Widget _buildCartSummary(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 19),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total belanja',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '\$${provider.cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: pastelPurple,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Lanjut'),
              style: ElevatedButton.styleFrom(
                backgroundColor: pastelPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ProductProvider provider) {
    return _buildMessageState(
      icon: Icons.cloud_off_rounded,
      title: 'Produk belum bisa dimuat',
      message:
          provider.errorMessage ?? 'Periksa koneksi internet lalu coba lagi.',
      action: ElevatedButton.icon(
        onPressed: provider.fetchProducts,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Coba Lagi'),
      ),
    );
  }

  Widget _buildEmptyState(ProductProvider provider) {
    return _buildMessageState(
      icon: Icons.search_off_rounded,
      title: 'Produk tidak ditemukan',
      message: 'Coba kata kunci atau kategori yang berbeda.',
      action: OutlinedButton.icon(
        onPressed: () {
          _searchController.clear();
          provider.setSearchQuery('');
          provider.setCategory('Semua');
        },
        icon: const Icon(Icons.filter_alt_off_rounded),
        label: const Text('Hapus filter'),
      ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: pastelLavender,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: pastelPurple),
            ),
            const SizedBox(height: 17),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: pastelText,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.4, color: Colors.black54),
            ),
            if (action != null) ...[const SizedBox(height: 17), action],
          ],
        ),
      ),
    );
  }

  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          product: product,
          imageHeroTag: _productHeroTag(product),
        ),
      ),
    );
  }

  void _createProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
  }

  String _productHeroTag(Product product) =>
      'product-image-${product.id}-$_selectedTab';
}

extension on String {
  String toBeginningOfSentenceCase() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
