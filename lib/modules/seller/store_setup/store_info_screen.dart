import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/modules/seller/store_setup/widgets/step_indicator.dart';
import 'package:azager/modules/seller/store_setup/store_branding_screen.dart';

class StoreInfoScreen extends StatefulWidget {
  const StoreInfoScreen({super.key});

  @override
  State<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends State<StoreInfoScreen> {
  final _storeNameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCity;

  final _categories = [
    'Fashion',
    'Electronics',
    'Home & Garden',
    'Health & Beauty',
    'Food & Beverages',
    'Sports',
    'Books',
    'Others',
  ];

  final _cities = [
    'Lagos',
    'Abuja',
    'Port Harcourt',
    'Ibadan',
    'Benin City',
    'Kano',
    'Enugu',
    'Others',
  ];

  @override
  void dispose() {
    _storeNameController.dispose();
    _aboutController.dispose();
    _addressController.dispose();
    super.dispose();
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
          'Set Up Your Store',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: StepIndicator(currentStep: 1),
          ),

          // Form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 16),

                // Store Name
                _fieldLabel('Store Name'),
                const SizedBox(height: 8),
                _textField(
                  controller: _storeNameController,
                  hint: 'Enter your store name',
                ),

                const SizedBox(height: 18),

                // About Store
                _fieldLabel('About Store'),
                const SizedBox(height: 8),
                _textField(
                  controller: _aboutController,
                  hint: 'Enter your store description',
                ),

                const SizedBox(height: 18),

                // Category
                _fieldLabel('Category*'),
                const SizedBox(height: 8),
                _dropdown(
                  value: _selectedCategory,
                  hint: 'Select Category',
                  items: _categories,
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),

                const SizedBox(height: 18),

                // Store Address
                _fieldLabel('Store Address'),
                const SizedBox(height: 8),
                _textField(
                  controller: _addressController,
                  hint: 'Enter your store description',
                ),
                const SizedBox(height: 4),
                Text(
                  'Type "Online" if you don\'t have a physical shop address',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 18),

                // City
                _fieldLabel('City*'),
                const SizedBox(height: 8),
                _dropdown(
                  value: _selectedCity,
                  hint: 'Select Category',
                  items: _cities,
                  onChanged: (v) => setState(() => _selectedCity = v),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoreBrandingScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
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
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
    );
  }
}
