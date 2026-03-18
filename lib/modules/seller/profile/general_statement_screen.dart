import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';

class GeneralStatementScreen extends StatefulWidget {
  const GeneralStatementScreen({super.key});

  @override
  State<GeneralStatementScreen> createState() => _GeneralStatementScreenState();
}

class _GeneralStatementScreenState extends State<GeneralStatementScreen> {
  bool _businessExpanded = true;
  bool _storeExpanded = false;
  bool _bankExpanded = false;
  bool _editing = false;

  final _idCtrl = TextEditingController(text: 'ID-2026-009');
  final _businessBankCtrl = TextEditingController(text: 'GTBank');
  final _accountNameCtrl = TextEditingController(text: 'Azager Store');
  final _accountNumberCtrl = TextEditingController(text: '0123456789');
  final _bvnCtrl = TextEditingController(text: '22334455667');
  final _storeNameCtrl = TextEditingController(text: 'Azager Store');
  final _aboutCtrl = TextEditingController(
    text: 'Campus products and essentials for students.',
  );
  final _addressCtrl = TextEditingController(text: 'Main Campus Road, Uniben');
  final _cityCtrl = TextEditingController(text: 'Benin City');
  final _categoryCtrl = TextEditingController(text: 'Fashion & Apparel');
  final _storeLogoCtrl = TextEditingController(text: 'logo.png');
  final _coverPhotoCtrl = TextEditingController(text: 'banner.png');
  final _bankNameCtrl = TextEditingController(text: 'GTBank');
  final _bankAccountNameCtrl = TextEditingController(text: 'Azager Store');
  final _bankAccountNumberCtrl = TextEditingController(text: '0123456789');
  final _bankBvnCtrl = TextEditingController(text: '22334455667');

  @override
  void dispose() {
    _idCtrl.dispose();
    _businessBankCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _bvnCtrl.dispose();
    _storeNameCtrl.dispose();
    _aboutCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _categoryCtrl.dispose();
    _storeLogoCtrl.dispose();
    _coverPhotoCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankAccountNameCtrl.dispose();
    _bankAccountNumberCtrl.dispose();
    _bankBvnCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('General statement updated'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
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
          'General Statement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSection(
              title: 'Business Information',
              expanded: _businessExpanded,
              onChanged: (value) => setState(() => _businessExpanded = value),
              child: Column(
                children: [
                  _field('ID Number', _idCtrl),
                  const SizedBox(height: 14),
                  _field('Bank Name', _businessBankCtrl),
                  const SizedBox(height: 14),
                  _field('Account Name', _accountNameCtrl),
                  const SizedBox(height: 14),
                  _field(
                    'Account Number',
                    _accountNumberCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _field('BVN', _bvnCtrl, keyboardType: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: 'Store Information',
              expanded: _storeExpanded,
              onChanged: (value) => setState(() => _storeExpanded = value),
              child: Column(
                children: [
                  _field('Store Name', _storeNameCtrl),
                  const SizedBox(height: 14),
                  _field('About Store', _aboutCtrl, maxLines: 4),
                  const SizedBox(height: 14),
                  _field('Category', _categoryCtrl),
                  const SizedBox(height: 14),
                  _field('Store Address', _addressCtrl),
                  const SizedBox(height: 14),
                  _field('City', _cityCtrl),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Store Branding',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    'Store Logo',
                    _storeLogoCtrl,
                    suffixIcon: Icons.image_outlined,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    'Cover Photo',
                    _coverPhotoCtrl,
                    suffixIcon: Icons.photo_size_select_actual_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: 'Bank Account',
              expanded: _bankExpanded,
              onChanged: (value) => setState(() => _bankExpanded = value),
              child: Column(
                children: [
                  _field('Account Name', _bankAccountNameCtrl),
                  const SizedBox(height: 14),
                  _field(
                    'Account Number',
                    _bankAccountNumberCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _field('Bank Name', _bankNameCtrl),
                  const SizedBox(height: 14),
                  _field(
                    'BVN',
                    _bankBvnCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool expanded,
    required ValueChanged<bool> onChanged,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>(title),
          initiallyExpanded: expanded,
          onExpansionChanged: onChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            expanded ? Icons.expand_less : Icons.chevron_right,
            color: AppColors.grey,
          ),
          children: [child],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _editing,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            suffixIcon: suffixIcon == null
                ? null
                : Icon(
                    suffixIcon,
                    color: _editing ? AppColors.grey : AppColors.lightGrey,
                    size: 20,
                  ),
            filled: true,
            fillColor: _editing ? Colors.white : const Color(0xFFF9F9F9),
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
      ],
    );
  }
}
