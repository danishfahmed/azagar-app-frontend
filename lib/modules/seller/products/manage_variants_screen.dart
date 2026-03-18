import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/models/seller_product_model.dart';
import 'package:azager/modules/seller/products/add_variant_screen.dart';
import 'package:azager/modules/seller/products/edit_variant_screen.dart';

class ManageVariantsScreen extends StatefulWidget {
  final String productName;
  final String? sku;
  final List<ProductVariant> variants;

  const ManageVariantsScreen({
    super.key,
    required this.productName,
    this.sku,
    required this.variants,
  });

  @override
  State<ManageVariantsScreen> createState() => _ManageVariantsScreenState();
}

class _ManageVariantsScreenState extends State<ManageVariantsScreen> {
  late List<ProductVariant> _variants;

  // Available colours and sizes for the quick‑pick UI.
  static const _availableColors = <_ColorItem>[
    _ColorItem('Red', Color(0xFFE53935)),
    _ColorItem('Green', Color(0xFF43A047)),
    _ColorItem('Blue', Color(0xFF1E88E5)),
    _ColorItem('Yellow', Color(0xFFFFEB3B)),
    _ColorItem('Pink', Color(0xFFF48FB1)),
  ];

  static const _availableSizes = ['S', 'M', 'L', 'XL'];

  final Set<String> _selectedColors = {};
  final Set<String> _selectedSizes = {};

  @override
  void initState() {
    super.initState();
    _variants = List.from(widget.variants);

    // Pre‑select colours/sizes from existing variants.
    for (final v in _variants) {
      _selectedColors.add(v.color);
      _selectedSizes.add(v.size);
    }
  }

  void _deleteVariant(int index) {
    setState(() => _variants.removeAt(index));
  }

  Future<void> _editVariant(int index) async {
    final result = await Navigator.push<ProductVariant>(
      context,
      MaterialPageRoute(
        builder: (_) => EditVariantScreen(variant: _variants[index]),
      ),
    );
    if (result != null) {
      setState(() => _variants[index] = result);
    }
  }

  Future<void> _addVariant() async {
    final result = await Navigator.push<ProductVariant>(
      context,
      MaterialPageRoute(builder: (_) => const AddVariantScreen()),
    );
    if (result != null) {
      setState(() {
        _variants.add(result);
        _selectedColors.add(result.color);
        _selectedSizes.add(result.size);
      });
    }
  }

  void _save() {
    Navigator.pop(context, _variants);
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
          'Manage Variants',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 16),

                // Product Name
                Text(
                  'Product Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.sku != null && widget.sku!.isNotEmpty)
                  Text(
                    'SKU : ${widget.sku}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                const SizedBox(height: 18),

                // ── Colour picker ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Color:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 16, color: AppColors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  children: _availableColors.map((c) {
                    final selected = _selectedColors.contains(c.name);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedColors.remove(c.name);
                          } else {
                            _selectedColors.add(c.name);
                          }
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.color,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: AppColors.black, width: 2)
                              : null,
                        ),
                        child: selected
                            ? Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // ── Size picker ──
                Row(
                  children: [
                    Text(
                      'Size:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ..._availableSizes.map((s) {
                      final selected = _selectedSizes.contains(s);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedSizes.remove(s);
                              } else {
                                _selectedSizes.add(s);
                              }
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.fieldBorder,
                              ),
                              color: selected
                                  ? const Color(0xFFFFF3E0)
                                  : Colors.white,
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Variant List ──
                Text(
                  'Variant List',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                if (_variants.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No variants yet',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                // Table header
                ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF0F0F0)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Variant',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Stock',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Status',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table rows
                  for (int i = 0; i < _variants.length; i++)
                    _VariantRow(
                      variant: _variants[i],
                      onEdit: () => _editVariant(i),
                      onDelete: () => _deleteVariant(i),
                    ),
                ],

                const SizedBox(height: 16),

                // + Add Variant
                GestureDetector(
                  onTap: _addVariant,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Add Variant',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper types ────────────────────────────────────────────────────────────

class _ColorItem {
  final String name;
  final Color color;
  const _ColorItem(this.name, this.color);
}

// ─── Variant table row ───────────────────────────────────────────────────────

class _VariantRow extends StatelessWidget {
  final ProductVariant variant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VariantRow({
    required this.variant,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              variant.label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₦${_fmt(variant.price)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${variant.stock}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return v.toStringAsFixed(2);
  }
}
