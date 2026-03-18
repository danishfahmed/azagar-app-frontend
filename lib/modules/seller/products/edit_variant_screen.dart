import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/models/seller_product_model.dart';

class EditVariantScreen extends StatefulWidget {
  final ProductVariant variant;

  const EditVariantScreen({super.key, required this.variant});

  @override
  State<EditVariantScreen> createState() => _EditVariantScreenState();
}

class _EditVariantScreenState extends State<EditVariantScreen> {
  late String? _selectedColor;
  late String? _selectedSize;
  late final TextEditingController _priceCtrl;
  late int _stockQty;

  static const _colors = [
    'Red',
    'Green',
    'Blue',
    'Yellow',
    'Pink',
    'Black',
    'White',
    'Orange',
  ];

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.variant.color;
    _selectedSize = widget.variant.size;
    _priceCtrl = TextEditingController(
      text: widget.variant.price == widget.variant.price.roundToDouble()
          ? widget.variant.price.toInt().toString()
          : widget.variant.price.toString(),
    );
    _stockQty = widget.variant.stock;
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedColor == null || _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select color and size'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final price = double.tryParse(_priceCtrl.text) ?? 0;

    final updated = ProductVariant(
      color: _selectedColor!,
      size: _selectedSize!,
      price: price,
      stock: _stockQty,
      isActive: widget.variant.isActive,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Variant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 24),

          // Color
          _label('Color'),
          const SizedBox(height: 8),
          _dropdown(
            value: _selectedColor,
            hint: 'Select Color',
            items: _colors,
            onChanged: (v) => setState(() => _selectedColor = v),
          ),

          const SizedBox(height: 18),

          // Size
          _label('Size'),
          const SizedBox(height: 8),
          _dropdown(
            value: _selectedSize,
            hint: 'Select Size',
            items: _sizes,
            onChanged: (v) => setState(() => _selectedSize = v),
          ),

          const SizedBox(height: 18),

          // Price
          _label('Price'),
          const SizedBox(height: 8),
          _field(controller: _priceCtrl, hint: '10,000'),

          const SizedBox(height: 18),

          // Stock Quantity
          _label('Stock Quantity'),
          const SizedBox(height: 8),
          _quantityRow(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Shared Widgets ─────────────────────────────────────────

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _quantityRow() {
    return Row(
      children: [
        _qtyBtn(Icons.remove, () {
          if (_stockQty > 0) setState(() => _stockQty--);
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$_stockQty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        _qtyBtn(Icons.add, () => setState(() => _stockQty++)),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
