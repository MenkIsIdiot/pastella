import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _shippingMethod = 'regular';
  String _paymentMethod = 'cod';

  double get _shippingCost => _shippingMethod == 'express' ? 9.99 : 4.99;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final total = provider.cartTotal + _shippingCost;

    return Scaffold(
      backgroundColor: pastelCream,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: pastelCream,
        foregroundColor: pastelText,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            _sectionCard(
              title: 'Alamat pengiriman',
              icon: Icons.location_on_outlined,
              child: Column(
                children: [
                  _textField(
                    controller: _nameController,
                    label: 'Nama penerima',
                    hint: 'Nama lengkap',
                    icon: Icons.person_outline_rounded,
                    validator: (value) => _required(value, 'Nama penerima'),
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _phoneController,
                    label: 'Nomor telepon',
                    hint: 'Contoh: 08123456789',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final error = _required(value, 'Nomor telepon');
                      if (error != null) return error;
                      if (value!.trim().replaceAll(RegExp(r'\D'), '').length <
                          8) {
                        return 'Nomor telepon minimal 8 digit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _addressController,
                    label: 'Alamat lengkap',
                    hint: 'Jalan, nomor rumah, kecamatan, kota',
                    icon: Icons.home_outlined,
                    maxLines: 3,
                    validator: (value) => _required(value, 'Alamat lengkap'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Pilih pengiriman',
              icon: Icons.local_shipping_outlined,
              child: RadioGroup<String>(
                groupValue: _shippingMethod,
                onChanged: (value) {
                  if (value != null) setState(() => _shippingMethod = value);
                },
                child: Column(
                  children: [
                    _optionTile(
                      value: 'regular',
                      title: 'Reguler',
                      subtitle: '2–4 hari kerja',
                      trailing: '\$4.99',
                    ),
                    const Divider(height: 1),
                    _optionTile(
                      value: 'express',
                      title: 'Express',
                      subtitle: '1–2 hari kerja',
                      trailing: '\$9.99',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Metode pembayaran',
              icon: Icons.payment_rounded,
              child: RadioGroup<String>(
                groupValue: _paymentMethod,
                onChanged: (value) {
                  if (value != null) setState(() => _paymentMethod = value);
                },
                child: Column(
                  children: [
                    _optionTile(
                      value: 'cod',
                      title: 'Bayar di tempat',
                      subtitle: 'Pembayaran saat pesanan diterima',
                    ),
                    const Divider(height: 1),
                    _optionTile(
                      value: 'transfer',
                      title: 'Transfer bank',
                      subtitle: 'Instruksi pembayaran demo',
                    ),
                    const Divider(height: 1),
                    _optionTile(
                      value: 'ewallet',
                      title: 'E-wallet',
                      subtitle: 'Simulasi pembayaran demo',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Ringkasan pesanan',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  ...provider.cartProducts.map(
                    (product) => _orderLine(
                      '${product.title} × ${provider.quantityFor(product.id)}',
                      _formatPrice(
                        product.price * provider.quantityFor(product.id),
                      ),
                    ),
                  ),
                  const Divider(height: 22),
                  _orderLine('Subtotal', _formatPrice(provider.cartTotal)),
                  const SizedBox(height: 8),
                  _orderLine('Pengiriman', _formatPrice(_shippingCost)),
                  const SizedBox(height: 11),
                  _orderLine(
                    'Total pembayaran',
                    _formatPrice(total),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Checkout ini merupakan simulasi. Pembayaran dan pengiriman '
              'belum terhubung ke layanan eksternal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          child: ElevatedButton(
            onPressed: provider.cartProducts.isEmpty ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: pastelPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text('Buat pesanan · ${_formatPrice(total)}'),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: pastelPurple),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: pastelText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: pastelPurple, size: 20),
        filled: true,
        fillColor: pastelCream.withValues(alpha: 0.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorMaxLines: 2,
      ),
    );
  }

  Widget _optionTile({
    required String value,
    required String title,
    required String subtitle,
    String? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: RadioListTile<String>(
        value: value,
        contentPadding: EdgeInsets.zero,
        activeColor: pastelPurple,
        title: Text(
          title,
          style: const TextStyle(
            color: pastelText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        secondary: trailing == null
            ? null
            : Text(
                trailing,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: pastelPurple,
                ),
              ),
      ),
    );
  }

  Widget _orderLine(String label, String value, {bool isTotal = false}) {
    final style = TextStyle(
      color: isTotal ? pastelText : Colors.black54,
      fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
      fontSize: isTotal ? 15 : 12,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style.copyWith(color: pastelPurple)),
      ],
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  String _formatPrice(double amount) => '\$${amount.toStringAsFixed(2)}';

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();
    if (provider.cartProducts.isEmpty) return;

    final orderId =
        'PS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final total = provider.cartTotal + _shippingCost;
    final recipient = _nameController.text.trim();
    final address = _addressController.text.trim();
    final shippingMethod = _shippingMethod == 'express' ? 'Express' : 'Reguler';
    final paymentMethod = switch (_paymentMethod) {
      'transfer' => 'Transfer bank',
      'ewallet' => 'E-wallet',
      _ => 'Bayar di tempat',
    };

    provider.clearCart();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _OrderConfirmationScreen(
          orderId: orderId,
          recipient: recipient,
          address: address,
          shippingMethod: shippingMethod,
          paymentMethod: paymentMethod,
          total: total,
        ),
      ),
    );
  }
}

class _OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final String recipient;
  final String address;
  final String shippingMethod;
  final String paymentMethod;
  final double total;

  const _OrderConfirmationScreen({
    required this.orderId,
    required this.recipient,
    required this.address,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 94,
                  height: 94,
                  decoration: const BoxDecoration(
                    color: pastelMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 54,
                    color: Color(0xFF46885C),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pesanan berhasil dibuat!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pastelText,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Ini adalah konfirmasi demo. Tidak ada pembayaran '
                  'sungguhan yang diproses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _confirmationLine('Nomor pesanan', orderId),
                      const Divider(height: 22),
                      _confirmationLine('Penerima', recipient),
                      const SizedBox(height: 12),
                      _confirmationLine('Alamat', address),
                      const SizedBox(height: 12),
                      _confirmationLine('Pengiriman', shippingMethod),
                      const SizedBox(height: 12),
                      _confirmationLine('Pembayaran', paymentMethod),
                      const Divider(height: 22),
                      _confirmationLine(
                        'Total',
                        '\$${total.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.storefront_rounded),
                    label: const Text('Kembali ke toko'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastelPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmationLine(String label, String value, {bool isTotal = false}) {
    final color = isTotal ? pastelText : Colors.black54;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isTotal ? pastelPurple : pastelText,
              fontSize: isTotal ? 15 : 12,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
