import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';

class StoreBrandingViewScreen extends StatefulWidget {
  const StoreBrandingViewScreen({super.key});

  @override
  State<StoreBrandingViewScreen> createState() =>
      _StoreBrandingViewScreenState();
}

class _StoreBrandingViewScreenState extends State<StoreBrandingViewScreen> {
  bool _editing = false;

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
          'Store Branding',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Store branding saved'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  setState(() => _editing = false);
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          // Upload Store Logo
          _UploadCard(
            title: 'Upload Store Logo',
            description:
                'Upload your store logo here, this would be used as\n'
                'your store profile.',
            icon: Icons.image_outlined,
            enabled: _editing,
          ),

          const SizedBox(height: 20),

          // Upload Cover Photo
          _UploadCard(
            title: 'Upload Cover Photo',
            description:
                'Upload your store cover photo here, this would be used\n'
                'as your store banner.',
            icon: Icons.photo_size_select_actual_outlined,
            enabled: _editing,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool enabled;

  const _UploadCard({
    required this.title,
    required this.description,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: enabled ? AppColors.grey : AppColors.lightGrey,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: enabled
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: enabled ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.lightGrey,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Upload',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
