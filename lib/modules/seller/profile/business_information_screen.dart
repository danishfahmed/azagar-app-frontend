import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';

class BusinessInformationScreen extends StatefulWidget {
  const BusinessInformationScreen({super.key});

  @override
  State<BusinessInformationScreen> createState() =>
      _BusinessInformationScreenState();
}

class _BusinessInformationScreenState extends State<BusinessInformationScreen> {
  bool _editing = false;

  final _idCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _bvnCtrl = TextEditingController();
  String? _selectedBank;

  final _banks = [
    'First Bank',
    'GTBank',
    'Access Bank',
    'UBA',
    'Zenith Bank',
    'Fidelity Bank',
    'Sterling Bank',
    'Others',
  ];

  @override
  void dispose() {
    _idCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _bvnCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Business information saved'),
        backgroundColor: AppColors.primary,
      ),
    );
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
          'Business Information',
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
              onPressed: () {
                if (_editing) {
                  _save();
                } else {
                  setState(() => _editing = true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _editing ? 'Save' : 'Edit',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // ID Number
          _label('ID Number'),
          const SizedBox(height: 8),
          _field(
            controller: _idCtrl,
            hint: 'Enter your store name',
            enabled: _editing,
          ),

          const SizedBox(height: 16),

          // Upload ID
          _label('Upload ID'),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(),
            enabled: _editing,
            readOnly: true,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your store description',
              hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: _editing ? AppColors.grey : AppColors.lightGrey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bank Name
          _label('Bank Name*'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedBank,
            onChanged: _editing
                ? (v) => setState(() => _selectedBank = v)
                : null,
            decoration: InputDecoration(
              hintText: 'Select Category',
              hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            items: _banks
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),

          const SizedBox(height: 16),

          // Account Name
          _label('Account Name*'),
          const SizedBox(height: 8),
          _field(
            controller: _accountNameCtrl,
            hint: 'Enter your store description',
            enabled: _editing,
          ),

          const SizedBox(height: 16),

          // Account Number
          _label('Account Number*'),
          const SizedBox(height: 8),
          _field(
            controller: _accountNumberCtrl,
            hint: 'Select Category',
            keyboardType: TextInputType.number,
            enabled: _editing,
          ),

          const SizedBox(height: 16),

          // BVN
          _label('BVN*'),
          const SizedBox(height: 8),
          _field(
            controller: _bvnCtrl,
            hint: 'Select Category',
            keyboardType: TextInputType.number,
            enabled: _editing,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
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
        disabledBorder: OutlineInputBorder(
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
}
