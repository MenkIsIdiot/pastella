import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product_card.dart';

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

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
    );
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
      child: CachedNetworkImage(
        imageUrl: product.thumbnail,
        fit: BoxFit.contain,
        placeholder: (context, url) {
          return const Center(
            child: CircularProgressIndicator(color: pastelPurple),
          );
        },
        errorWidget: (context, url, error) {
          return const Icon(
            Icons.image_not_supported_outlined,
            size: 60,
            color: pastelPurple,
          );
        },
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
