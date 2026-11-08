import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_artwork.dart';
import 'product_form_screen.dart';

class DetailScreen extends StatelessWidget {
  final Product product;
  final Object? imageHeroTag;

  const DetailScreen({super.key, required this.product, this.imageHeroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelCream,
      appBar: AppBar(
        backgroundColor: pastelCream,
        foregroundColor: pastelText,
        elevation: 0,
        title: const Text(
          'Detail Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Kelola produk',
            onSelected: (action) {
              if (action == 'edit') {
                _editProduct(context);
              } else {
                _confirmDelete(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined),
                    const SizedBox(width: 12),
                    const Text('Edit produk'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded),
                    const SizedBox(width: 12),
                    const Text('Hapus produk'),
                  ],
                ),
              ),
            ],
          ),
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              final isFavorite = provider.isFavorite(product.id);
              return IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambahkan ke favorit',
                onPressed: () => provider.toggleFavorite(product),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.pinkAccent : pastelText,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(height: 24),
            _buildProductInformation(),
            const SizedBox(height: 20),
            _buildDescription(),
            const SizedBox(height: 20),
            _buildStockInformation(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    return OutlinedButton.icon(
                      onPressed: () {
                        provider.addToCart(product);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.title} ditambahkan ke keranjang',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Tambah ke keranjang'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: pastelPurple,
                        side: const BorderSide(color: pastelPurple),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProduct(BuildContext context) async {
    final updatedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
    if (updatedProduct != null && context.mounted) {
      Navigator.pop(context, updatedProduct);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('Produk "${product.title}" akan dihapus dari katalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && context.mounted) {
      context.read<ProductProvider>().deleteProduct(product.id);
      Navigator.pop(context);
    }
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: pastelLavender.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Hero(
        tag: imageHeroTag ?? 'product-image-${product.id}',
        child: ProductArtwork(product: product),
      ),
    );
  }

  Widget _buildProductInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: pastelMint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product.category.replaceAll('-', ' '),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: pastelText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: pastelText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: pastelPurple,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 23),
            const SizedBox(width: 5),
            Text(
              '${product.rating.toStringAsFixed(1)} / 5',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: pastelText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Merek: ${product.brand}',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi Produk',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: pastelText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.description.isNotEmpty
                ? product.description
                : 'Tidak ada deskripsi produk.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pastelPink.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: pastelPurple, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ketersediaan Stok',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: pastelText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.stock} unit tersedia',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
