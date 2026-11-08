import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _brandController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleController = TextEditingController(text: product?.title ?? '');
    _brandController = TextEditingController(text: product?.brand ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    _thumbnailController = TextEditingController(
      text: product?.thumbnail ?? '',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _thumbnailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelCream,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Produk' : 'Tambah Produk'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _textField(
              controller: _titleController,
              label: 'Nama produk',
              validator: _requiredValidator('Nama produk wajib diisi'),
            ),
            _textField(
              controller: _brandController,
              label: 'Merek',
              validator: _requiredValidator('Merek wajib diisi'),
            ),
            _textField(
              controller: _categoryController,
              label: 'Kategori',
              validator: _requiredValidator('Kategori wajib diisi'),
            ),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    controller: _priceController,
                    label: 'Harga',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _priceValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                    controller: _stockController,
                    label: 'Stok',
                    keyboardType: TextInputType.number,
                    validator: _stockValidator,
                  ),
                ),
              ],
            ),
            _textField(
              controller: _thumbnailController,
              label: 'URL gambar (opsional)',
              keyboardType: TextInputType.url,
            ),
            _textField(
              controller: _descriptionController,
              label: 'Deskripsi',
              validator: _requiredValidator('Deskripsi wajib diisi'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saveProduct,
              icon: Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
              label: Text(_isEditing ? 'Simpan perubahan' : 'Tambah produk'),
              style: FilledButton.styleFrom(
                backgroundColor: pastelPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  String? _priceValidator(String? value) {
    final price = double.tryParse(value?.trim() ?? '');
    if (price == null || !price.isFinite || price <= 0) {
      return 'Masukkan harga lebih dari 0';
    }
    return null;
  }

  String? _stockValidator(String? value) {
    final stock = int.tryParse(value?.trim() ?? '');
    if (stock == null || stock < 0) {
      return 'Masukkan stok 0 atau lebih';
    }
    return null;
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();
    final original = widget.product;
    final product = Product(
      id: original?.id ?? provider.nextProductId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim().toLowerCase(),
      price: double.parse(_priceController.text.trim()),
      rating: original?.rating ?? 0,
      thumbnail: _thumbnailController.text.trim(),
      brand: _brandController.text.trim(),
      stock: int.parse(_stockController.text.trim()),
    );

    if (original == null) {
      provider.addProduct(product);
    } else {
      provider.updateProduct(product);
    }
    Navigator.pop(context, product);
  }
}
