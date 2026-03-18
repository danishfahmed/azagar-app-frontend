import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/theme/app_theme_controller.dart';
import 'package:azager/modules/customer/profile/change_password_screen.dart';
import 'package:azager/modules/seller/home/seller_shell.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _sellerMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final primaryText = theme.colorScheme.onSurface;
    final secondaryText = theme.colorScheme.onSurfaceVariant;
    final dividerColor = theme.dividerColor;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, themeMode, _) {
        final darkModeEnabled = themeMode == ThemeMode.dark;
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: primaryText,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              // ── Switch Mode (Fiverr-style) ───────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _sellerMode
                        ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                        : [AppColors.primary, const Color(0xFFFF8C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        _sellerMode
                            ? Icons.store_outlined
                            : Icons.shopping_bag_outlined,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sellerMode ? 'Seller Mode' : 'Buyer Mode',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _sellerMode
                                ? 'You are currently selling on Azager'
                                : 'Switch to start selling on Azager',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _sellerMode,
                      onChanged: (v) {
                        setState(() => _sellerMode = v);
                        if (v) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const SellerShell(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white30,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white30,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _sectionLabel('Notifications', cardColor, primaryText),

              _SwitchTile(
                icon: Icons.notifications_outlined,
                label: 'Push Notifications',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
                backgroundColor: cardColor,
                textColor: primaryText,
                iconColor: secondaryText,
                dividerColor: dividerColor,
              ),
              _SwitchTile(
                icon: Icons.local_shipping_outlined,
                label: 'Order Updates',
                value: _orderUpdates,
                onChanged: (v) => setState(() => _orderUpdates = v),
                isLast: false,
                backgroundColor: cardColor,
                textColor: primaryText,
                iconColor: secondaryText,
                dividerColor: dividerColor,
              ),
              _SwitchTile(
                icon: Icons.discount_outlined,
                label: 'Promotions & Offers',
                value: _promotions,
                onChanged: (v) => setState(() => _promotions = v),
                isLast: true,
                backgroundColor: cardColor,
                textColor: primaryText,
                iconColor: secondaryText,
                dividerColor: dividerColor,
              ),

              const SizedBox(height: 12),

              _sectionLabel('Appearance', cardColor, primaryText),

              _SwitchTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                value: darkModeEnabled,
                onChanged: (v) {
                  AppThemeController.setDarkMode(v);
                },
                isLast: true,
                backgroundColor: cardColor,
                textColor: primaryText,
                iconColor: secondaryText,
                dividerColor: dividerColor,
              ),

              const SizedBox(height: 12),

              _sectionLabel('Account', cardColor, primaryText),

              _ActionTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                ),
                backgroundColor: cardColor,
                textColor: primaryText,
                iconColor: secondaryText,
                dividerColor: dividerColor,
              ),
              _ActionTile(
                icon: Icons.language_outlined,
                label: 'Language',
                trailing: Text(
                  'English',
                  style: TextStyle(fontSize: 13, color: secondaryText),
                ),
                onTap: () {},
                backgroundColor: cardColor,
                textColor: primaryText,
                iconColor: secondaryText,
                dividerColor: dividerColor,
              ),
              _ActionTile(
                icon: Icons.delete_outline,
                label: 'Delete Account',
                labelColor: Colors.red,
                iconColor: Colors.red,
                isLast: true,
                onTap: () {},
                backgroundColor: cardColor,
                textColor: primaryText,
                dividerColor: dividerColor,
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label, Color backgroundColor, Color textColor) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color dividerColor;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.dividerColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, size: 22, color: iconColor),
            title: Text(
              label,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            trailing: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
            dense: true,
          ),
          if (!isLast) Divider(height: 1, indent: 52, color: dividerColor),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color labelColor;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final Color dividerColor;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    required this.dividerColor,
    this.labelColor = AppColors.textPrimary,
    this.iconColor = AppColors.textSecondary,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, size: 22, color: iconColor),
            title: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: labelColor == AppColors.textPrimary
                    ? textColor
                    : labelColor,
              ),
            ),
            trailing:
                trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.grey,
                ),
            onTap: onTap,
            dense: true,
          ),
          if (!isLast) Divider(height: 1, indent: 52, color: dividerColor),
        ],
      ),
    );
  }
}
