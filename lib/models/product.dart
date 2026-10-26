class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final String thumbnail;
  final String brand;
  final int stock;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.brand,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Produk tanpa nama',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Lainnya',
      price: (json['price'] as num? ?? 0).toDouble(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      thumbnail: json['thumbnail'] ?? '',
      brand: json['brand'] ?? 'Tanpa merek',
      stock: json['stock'] ?? 0,
    );
  }
}
