import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductArtwork extends StatelessWidget {
  final Product product;
  final BoxFit fit;

  const ProductArtwork({
    super.key,
    required this.product,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (product.thumbnail.isEmpty) return const _TankMiniatureArtwork();

    return CachedNetworkImage(
      imageUrl: product.thumbnail,
      fit: fit,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7965B2),
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF7965B2),
        size: 40,
      ),
    );
  }
}

class _TankMiniatureArtwork extends StatelessWidget {
  const _TankMiniatureArtwork();

  @override
  Widget build(BuildContext context) {
    const bodyColor = Color(0xFF779B73);
    const darkColor = Color(0xFF465E4A);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F4E9), Color(0xFFE0EAD8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 16,
            right: 18,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: bodyColor.withValues(alpha: 0.45),
              size: 24,
            ),
          ),
          Positioned(
            left: 18,
            top: 25,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: bodyColor.withValues(alpha: 0.3),
              size: 15,
            ),
          ),
          SizedBox(
            width: 190,
            height: 128,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 30,
                  child: Container(
                    width: 142,
                    height: 34,
                    decoration: BoxDecoration(
                      color: darkColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF344A38),
                        width: 3,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        5,
                        (index) => Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8C6A7),
                            shape: BoxShape.circle,
                            border: Border.all(color: darkColor, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 52,
                  child: Container(
                    width: 112,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bodyColor,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: darkColor, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 77,
                  left: 63,
                  child: Container(
                    width: 56,
                    height: 25,
                    decoration: BoxDecoration(
                      color: const Color(0xFF91AD82),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: darkColor, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 86,
                  left: 24,
                  child: Container(
                    width: 53,
                    height: 8,
                    decoration: BoxDecoration(
                      color: darkColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 38,
                  child: Icon(
                    Icons.star_rounded,
                    color: Color(0xFFE8D795),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 11,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'MINIATUR KOLEKSI',
                style: TextStyle(
                  color: darkColor,
                  fontSize: 9,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
