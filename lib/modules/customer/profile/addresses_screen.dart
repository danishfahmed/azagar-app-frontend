import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  int _selectedIndex = 0;

  final _addresses = [
    _Address(
      label: 'Home',
      name: 'John Doe',
      address: 'Block B, Room 14, Zik Hall\nZABIST University, Islamabad',
      phone: '+92 300 1234567',
    ),
    _Address(
      label: 'Office',
      name: 'John Doe',
      address: 'Suite 205, Tech Park\nBlue Area, Islamabad',
      phone: '+92 300 9876543',
    ),
  ];

  Future<_Address?> _showAddressDialog({_Address? initial}) async {
    final labelCtrl = TextEditingController(text: initial?.label ?? 'Home');
    final nameCtrl = TextEditingController(text: initial?.name ?? '');
    final addressCtrl = TextEditingController(text: initial?.address ?? '');
    final phoneCtrl = TextEditingController(text: initial?.phone ?? '');

    final result = await showDialog<_Address>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(initial == null ? 'Add Address' : 'Edit Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty ||
                  addressCtrl.text.trim().isEmpty ||
                  phoneCtrl.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(
                context,
                _Address(
                  label: labelCtrl.text.trim().isEmpty
                      ? 'Home'
                      : labelCtrl.text.trim(),
                  name: nameCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                ),
              );
            },
            child: Text(initial == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    labelCtrl.dispose();
    nameCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    return result;
  }

  void _deleteAddress(int index) {
    setState(() {
      _addresses.removeAt(index);
      if (_addresses.isEmpty) {
        _selectedIndex = 0;
      } else if (_selectedIndex >= _addresses.length) {
        _selectedIndex = _addresses.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Addresses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newAddress = await _showAddressDialog();
          if (newAddress == null) return;
          setState(() {
            _addresses.add(newAddress);
            _selectedIndex = _addresses.length - 1;
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final addr = _addresses[index];
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).dividerColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<int>(
                    value: index,
                    groupValue: _selectedIndex,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _selectedIndex = v!),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                addr.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          addr.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          addr.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          addr.phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final updated = await _showAddressDialog(
                                  initial: addr,
                                );
                                if (updated == null) return;
                                setState(() => _addresses[index] = updated);
                              },
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => _deleteAddress(index),
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Address {
  final String label;
  final String name;
  final String address;
  final String phone;
  const _Address({
    required this.label,
    required this.name,
    required this.address,
    required this.phone,
  });
}
