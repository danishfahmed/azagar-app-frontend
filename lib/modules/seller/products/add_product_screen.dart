import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/models/seller_product_model.dart';
import 'package:azager/modules/seller/products/manage_variants_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String? _selectedCategory;
  int _stockQty = 1;
  List<ProductVariant> _variants = [];

  // Placeholder image paths – in real app these come from image picker.
  final List<String> _images = [];

  final _categories = [
    'Bags',
    'Electronics',
    'Fashion',
    'Shoes',
    'Accessories',
    'Home & Kitchen',
    'Health & Beauty',
    'Others',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final category = _selectedCategory!;
    final name = _nameCtrl.text.trim();

    // Auto‑generate SKU on publish.
    final sku = SellerProduct.generateSku(category, name);

    final product = SellerProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      description: _descCtrl.text.trim(),
      imageUrls: List.from(_images),
      price: price,
      stockQuantity: _stockQty,
      sku: sku,
      variants: List.from(_variants),
    );

    Navigator.pop(context, product);
  }

  Future<void> _openManageVariants() async {
    final result = await Navigator.push<List<ProductVariant>>(
      context,
      MaterialPageRoute(
        builder: (_) => ManageVariantsScreen(
          productName: _nameCtrl.text.trim().isEmpty
              ? 'New Product'
              : _nameCtrl.text.trim(),
          variants: _variants,
        ),
      ),
    );
    if (result != null) {
      setState(() => _variants = result);
    }
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
          'Add Product',
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
          const SizedBox(height: 16),

          // Product Name
          _label('Product Name*'),
          const SizedBox(height: 8),
          _field(controller: _nameCtrl, hint: 'Powerbank'),

          const SizedBox(height: 18),

          // Category
          _label('Category*'),
          const SizedBox(height: 8),
          _dropdown(
            value: _selectedCategory,
            hint: 'Select Category',
            items: _categories,
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),

          const SizedBox(height: 18),

          // Description
          _label('Description*'),
          const SizedBox(height: 8),
          _field(controller: _descCtrl, hint: 'Description', maxLines: 3),

          const SizedBox(height: 18),

          // Add image
          _label('Add image'),
          const SizedBox(height: 8),
          _imageRow(),

          const SizedBox(height: 18),

          // Price
          _label('Price*'),
          const SizedBox(height: 8),
          _field(
            controller: _priceCtrl,
            hint: 'Description',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 18),

          // Stock Quantity
          _label('Stock Quantity'),
          const SizedBox(height: 8),
          _quantityRow(),

          const SizedBox(height: 18),

          // Manage Variants
          GestureDetector(
            onTap: _openManageVariants,
            child: Row(
              children: [
                Icon(Icons.add, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Manage Variants${_variants.isNotEmpty ? ' (${_variants.length})' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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

  Widget _imageRow() {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Existing image thumbnails
          for (final img in _images)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  img,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: const Color(0xFFF5F5F5),
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.lightGrey,
                    ),
                  ),
                ),
              ),
            ),

          // Add image button
          GestureDetector(
            onTap: () {
              // TODO: open image picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image picker coming soon'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: Icon(
                Icons.file_upload_outlined,
                size: 28,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityRow() {
    return Row(
      children: [
        _qtyBtn(Icons.remove, () {
          if (_stockQty > 1) setState(() => _stockQty--);
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
