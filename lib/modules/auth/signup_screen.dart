import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/services/auth_service.dart';
import 'package:azager/core/network/api_exception.dart';
import 'package:azager/modules/auth/login_screen.dart';
import 'package:azager/modules/auth/otp_screen.dart';
// import 'package:azager/modules/shared/widgets/social_login_row.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _agreeTerms = false;
  // String _selectedGender = 'Male';
  // DateTime? _selectedDob;
  bool _isLoading = false;
  String _selectedPhoneCode = '+234';
  String _selectedCountryFlag = '🇳🇬';

  static const List<Map<String, String>> _countryCodes = [
    {'code': '+93', 'country': 'Afghanistan', 'flag': '🇦🇫'},
    {'code': '+355', 'country': 'Albania', 'flag': '🇦🇱'},
    {'code': '+213', 'country': 'Algeria', 'flag': '🇩🇿'},
    {'code': '+376', 'country': 'Andorra', 'flag': '🇦🇩'},
    {'code': '+244', 'country': 'Angola', 'flag': '🇦🇴'},
    {'code': '+1268', 'country': 'Antigua & Barbuda', 'flag': '🇦🇬'},
    {'code': '+54', 'country': 'Argentina', 'flag': '🇦🇷'},
    {'code': '+374', 'country': 'Armenia', 'flag': '🇦🇲'},
    {'code': '+61', 'country': 'Australia', 'flag': '🇦🇺'},
    {'code': '+43', 'country': 'Austria', 'flag': '🇦🇹'},
    {'code': '+994', 'country': 'Azerbaijan', 'flag': '🇦🇿'},
    {'code': '+1242', 'country': 'Bahamas', 'flag': '🇧🇸'},
    {'code': '+973', 'country': 'Bahrain', 'flag': '🇧🇭'},
    {'code': '+880', 'country': 'Bangladesh', 'flag': '🇧🇩'},
    {'code': '+1246', 'country': 'Barbados', 'flag': '🇧🇧'},
    {'code': '+375', 'country': 'Belarus', 'flag': '🇧🇾'},
    {'code': '+32', 'country': 'Belgium', 'flag': '🇧🇪'},
    {'code': '+501', 'country': 'Belize', 'flag': '🇧🇿'},
    {'code': '+229', 'country': 'Benin', 'flag': '🇧🇯'},
    {'code': '+975', 'country': 'Bhutan', 'flag': '🇧🇹'},
    {'code': '+591', 'country': 'Bolivia', 'flag': '🇧🇴'},
    {'code': '+387', 'country': 'Bosnia & Herzegovina', 'flag': '🇧🇦'},
    {'code': '+267', 'country': 'Botswana', 'flag': '🇧🇼'},
    {'code': '+55', 'country': 'Brazil', 'flag': '🇧🇷'},
    {'code': '+673', 'country': 'Brunei', 'flag': '🇧🇳'},
    {'code': '+359', 'country': 'Bulgaria', 'flag': '🇧🇬'},
    {'code': '+226', 'country': 'Burkina Faso', 'flag': '🇧🇫'},
    {'code': '+257', 'country': 'Burundi', 'flag': '🇧🇮'},
    {'code': '+855', 'country': 'Cambodia', 'flag': '🇰🇭'},
    {'code': '+237', 'country': 'Cameroon', 'flag': '🇨🇲'},
    {'code': '+1', 'country': 'Canada', 'flag': '🇨🇦'},
    {'code': '+238', 'country': 'Cape Verde', 'flag': '🇨🇻'},
    {'code': '+236', 'country': 'Central African Republic', 'flag': '🇨🇫'},
    {'code': '+235', 'country': 'Chad', 'flag': '🇹🇩'},
    {'code': '+56', 'country': 'Chile', 'flag': '🇨🇱'},
    {'code': '+86', 'country': 'China', 'flag': '🇨🇳'},
    {'code': '+57', 'country': 'Colombia', 'flag': '🇨🇴'},
    {'code': '+269', 'country': 'Comoros', 'flag': '🇰🇲'},
    {'code': '+242', 'country': 'Congo', 'flag': '🇨🇬'},
    {'code': '+506', 'country': 'Costa Rica', 'flag': '🇨🇷'},
    {'code': '+385', 'country': 'Croatia', 'flag': '🇭🇷'},
    {'code': '+53', 'country': 'Cuba', 'flag': '🇨🇺'},
    {'code': '+357', 'country': 'Cyprus', 'flag': '🇨🇾'},
    {'code': '+420', 'country': 'Czech Republic', 'flag': '🇨🇿'},
    {'code': '+45', 'country': 'Denmark', 'flag': '🇩🇰'},
    {'code': '+253', 'country': 'Djibouti', 'flag': '🇩🇯'},
    {'code': '+1767', 'country': 'Dominica', 'flag': '🇩🇲'},
    {'code': '+1809', 'country': 'Dominican Republic', 'flag': '🇩🇴'},
    {'code': '+243', 'country': 'DR Congo', 'flag': '🇨🇩'},
    {'code': '+593', 'country': 'Ecuador', 'flag': '🇪🇨'},
    {'code': '+20', 'country': 'Egypt', 'flag': '🇪🇬'},
    {'code': '+503', 'country': 'El Salvador', 'flag': '🇸🇻'},
    {'code': '+240', 'country': 'Equatorial Guinea', 'flag': '🇬🇶'},
    {'code': '+291', 'country': 'Eritrea', 'flag': '🇪🇷'},
    {'code': '+372', 'country': 'Estonia', 'flag': '🇪🇪'},
    {'code': '+268', 'country': 'Eswatini', 'flag': '🇸🇿'},
    {'code': '+251', 'country': 'Ethiopia', 'flag': '🇪🇹'},
    {'code': '+679', 'country': 'Fiji', 'flag': '🇫🇯'},
    {'code': '+358', 'country': 'Finland', 'flag': '🇫🇮'},
    {'code': '+33', 'country': 'France', 'flag': '🇫🇷'},
    {'code': '+241', 'country': 'Gabon', 'flag': '🇬🇦'},
    {'code': '+220', 'country': 'Gambia', 'flag': '🇬🇲'},
    {'code': '+995', 'country': 'Georgia', 'flag': '🇬🇪'},
    {'code': '+49', 'country': 'Germany', 'flag': '🇩🇪'},
    {'code': '+233', 'country': 'Ghana', 'flag': '🇬🇭'},
    {'code': '+30', 'country': 'Greece', 'flag': '🇬🇷'},
    {'code': '+1473', 'country': 'Grenada', 'flag': '🇬🇩'},
    {'code': '+502', 'country': 'Guatemala', 'flag': '🇬🇹'},
    {'code': '+224', 'country': 'Guinea', 'flag': '🇬🇳'},
    {'code': '+245', 'country': 'Guinea-Bissau', 'flag': '🇬🇼'},
    {'code': '+592', 'country': 'Guyana', 'flag': '🇬🇾'},
    {'code': '+509', 'country': 'Haiti', 'flag': '🇭🇹'},
    {'code': '+504', 'country': 'Honduras', 'flag': '🇭🇳'},
    {'code': '+36', 'country': 'Hungary', 'flag': '🇭🇺'},
    {'code': '+354', 'country': 'Iceland', 'flag': '🇮🇸'},
    {'code': '+91', 'country': 'India', 'flag': '🇮🇳'},
    {'code': '+62', 'country': 'Indonesia', 'flag': '🇮🇩'},
    {'code': '+98', 'country': 'Iran', 'flag': '🇮🇷'},
    {'code': '+964', 'country': 'Iraq', 'flag': '🇮🇶'},
    {'code': '+353', 'country': 'Ireland', 'flag': '🇮🇪'},
    {'code': '+972', 'country': 'Israel', 'flag': '🇮🇱'},
    {'code': '+39', 'country': 'Italy', 'flag': '🇮🇹'},
    {'code': '+225', 'country': 'Ivory Coast', 'flag': '🇨🇮'},
    {'code': '+1876', 'country': 'Jamaica', 'flag': '🇯🇲'},
    {'code': '+81', 'country': 'Japan', 'flag': '🇯🇵'},
    {'code': '+962', 'country': 'Jordan', 'flag': '🇯🇴'},
    {'code': '+7', 'country': 'Kazakhstan', 'flag': '🇰🇿'},
    {'code': '+254', 'country': 'Kenya', 'flag': '🇰🇪'},
    {'code': '+686', 'country': 'Kiribati', 'flag': '🇰🇮'},
    {'code': '+965', 'country': 'Kuwait', 'flag': '🇰🇼'},
    {'code': '+996', 'country': 'Kyrgyzstan', 'flag': '🇰🇬'},
    {'code': '+856', 'country': 'Laos', 'flag': '🇱🇦'},
    {'code': '+371', 'country': 'Latvia', 'flag': '🇱🇻'},
    {'code': '+961', 'country': 'Lebanon', 'flag': '🇱🇧'},
    {'code': '+266', 'country': 'Lesotho', 'flag': '🇱🇸'},
    {'code': '+231', 'country': 'Liberia', 'flag': '🇱🇷'},
    {'code': '+218', 'country': 'Libya', 'flag': '🇱🇾'},
    {'code': '+423', 'country': 'Liechtenstein', 'flag': '🇱🇮'},
    {'code': '+370', 'country': 'Lithuania', 'flag': '🇱🇹'},
    {'code': '+352', 'country': 'Luxembourg', 'flag': '🇱🇺'},
    {'code': '+261', 'country': 'Madagascar', 'flag': '🇲🇬'},
    {'code': '+265', 'country': 'Malawi', 'flag': '🇲🇼'},
    {'code': '+60', 'country': 'Malaysia', 'flag': '🇲🇾'},
    {'code': '+960', 'country': 'Maldives', 'flag': '🇲🇻'},
    {'code': '+223', 'country': 'Mali', 'flag': '🇲🇱'},
    {'code': '+356', 'country': 'Malta', 'flag': '🇲🇹'},
    {'code': '+692', 'country': 'Marshall Islands', 'flag': '🇲🇭'},
    {'code': '+222', 'country': 'Mauritania', 'flag': '🇲🇷'},
    {'code': '+230', 'country': 'Mauritius', 'flag': '🇲🇺'},
    {'code': '+52', 'country': 'Mexico', 'flag': '🇲🇽'},
    {'code': '+691', 'country': 'Micronesia', 'flag': '🇫🇲'},
    {'code': '+373', 'country': 'Moldova', 'flag': '🇲🇩'},
    {'code': '+377', 'country': 'Monaco', 'flag': '🇲🇨'},
    {'code': '+976', 'country': 'Mongolia', 'flag': '🇲🇳'},
    {'code': '+382', 'country': 'Montenegro', 'flag': '🇲🇪'},
    {'code': '+212', 'country': 'Morocco', 'flag': '🇲🇦'},
    {'code': '+258', 'country': 'Mozambique', 'flag': '🇲🇿'},
    {'code': '+95', 'country': 'Myanmar', 'flag': '🇲🇲'},
    {'code': '+264', 'country': 'Namibia', 'flag': '🇳🇦'},
    {'code': '+674', 'country': 'Nauru', 'flag': '🇳🇷'},
    {'code': '+977', 'country': 'Nepal', 'flag': '🇳🇵'},
    {'code': '+31', 'country': 'Netherlands', 'flag': '🇳🇱'},
    {'code': '+64', 'country': 'New Zealand', 'flag': '🇳🇿'},
    {'code': '+505', 'country': 'Nicaragua', 'flag': '🇳🇮'},
    {'code': '+227', 'country': 'Niger', 'flag': '🇳🇪'},
    {'code': '+234', 'country': 'Nigeria', 'flag': '🇳🇬'},
    {'code': '+850', 'country': 'North Korea', 'flag': '🇰🇵'},
    {'code': '+389', 'country': 'North Macedonia', 'flag': '🇲🇰'},
    {'code': '+47', 'country': 'Norway', 'flag': '🇳🇴'},
    {'code': '+968', 'country': 'Oman', 'flag': '🇴🇲'},
    {'code': '+92', 'country': 'Pakistan', 'flag': '🇵🇰'},
    {'code': '+680', 'country': 'Palau', 'flag': '🇵🇼'},
    {'code': '+507', 'country': 'Panama', 'flag': '🇵🇦'},
    {'code': '+675', 'country': 'Papua New Guinea', 'flag': '🇵🇬'},
    {'code': '+595', 'country': 'Paraguay', 'flag': '🇵🇾'},
    {'code': '+51', 'country': 'Peru', 'flag': '🇵🇪'},
    {'code': '+63', 'country': 'Philippines', 'flag': '🇵🇭'},
    {'code': '+48', 'country': 'Poland', 'flag': '🇵🇱'},
    {'code': '+351', 'country': 'Portugal', 'flag': '🇵🇹'},
    {'code': '+974', 'country': 'Qatar', 'flag': '🇶🇦'},
    {'code': '+40', 'country': 'Romania', 'flag': '🇷🇴'},
    {'code': '+7', 'country': 'Russia', 'flag': '🇷🇺'},
    {'code': '+250', 'country': 'Rwanda', 'flag': '🇷🇼'},
    {'code': '+1869', 'country': 'Saint Kitts & Nevis', 'flag': '🇰🇳'},
    {'code': '+1758', 'country': 'Saint Lucia', 'flag': '🇱🇨'},
    {'code': '+1784', 'country': 'Saint Vincent', 'flag': '🇻🇨'},
    {'code': '+685', 'country': 'Samoa', 'flag': '🇼🇸'},
    {'code': '+378', 'country': 'San Marino', 'flag': '🇸🇲'},
    {'code': '+239', 'country': 'São Tomé & Príncipe', 'flag': '🇸🇹'},
    {'code': '+966', 'country': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'code': '+221', 'country': 'Senegal', 'flag': '🇸🇳'},
    {'code': '+381', 'country': 'Serbia', 'flag': '🇷🇸'},
    {'code': '+248', 'country': 'Seychelles', 'flag': '🇸🇨'},
    {'code': '+232', 'country': 'Sierra Leone', 'flag': '🇸🇱'},
    {'code': '+65', 'country': 'Singapore', 'flag': '🇸🇬'},
    {'code': '+421', 'country': 'Slovakia', 'flag': '🇸🇰'},
    {'code': '+386', 'country': 'Slovenia', 'flag': '🇸🇮'},
    {'code': '+677', 'country': 'Solomon Islands', 'flag': '🇸🇧'},
    {'code': '+252', 'country': 'Somalia', 'flag': '🇸🇴'},
    {'code': '+27', 'country': 'South Africa', 'flag': '🇿🇦'},
    {'code': '+82', 'country': 'South Korea', 'flag': '🇰🇷'},
    {'code': '+211', 'country': 'South Sudan', 'flag': '🇸🇸'},
    {'code': '+34', 'country': 'Spain', 'flag': '🇪🇸'},
    {'code': '+94', 'country': 'Sri Lanka', 'flag': '🇱🇰'},
    {'code': '+249', 'country': 'Sudan', 'flag': '🇸🇩'},
    {'code': '+597', 'country': 'Suriname', 'flag': '🇸🇷'},
    {'code': '+46', 'country': 'Sweden', 'flag': '🇸🇪'},
    {'code': '+41', 'country': 'Switzerland', 'flag': '🇨🇭'},
    {'code': '+963', 'country': 'Syria', 'flag': '🇸🇾'},
    {'code': '+886', 'country': 'Taiwan', 'flag': '🇹🇼'},
    {'code': '+992', 'country': 'Tajikistan', 'flag': '🇹🇯'},
    {'code': '+255', 'country': 'Tanzania', 'flag': '🇹🇿'},
    {'code': '+66', 'country': 'Thailand', 'flag': '🇹🇭'},
    {'code': '+670', 'country': 'Timor-Leste', 'flag': '🇹🇱'},
    {'code': '+228', 'country': 'Togo', 'flag': '🇹🇬'},
    {'code': '+676', 'country': 'Tonga', 'flag': '🇹🇴'},
    {'code': '+1868', 'country': 'Trinidad & Tobago', 'flag': '🇹🇹'},
    {'code': '+216', 'country': 'Tunisia', 'flag': '🇹🇳'},
    {'code': '+90', 'country': 'Turkey', 'flag': '🇹🇷'},
    {'code': '+993', 'country': 'Turkmenistan', 'flag': '🇹🇲'},
    {'code': '+688', 'country': 'Tuvalu', 'flag': '🇹🇻'},
    {'code': '+971', 'country': 'UAE', 'flag': '🇦🇪'},
    {'code': '+256', 'country': 'Uganda', 'flag': '🇺🇬'},
    {'code': '+380', 'country': 'Ukraine', 'flag': '🇺🇦'},
    {'code': '+44', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': '+1', 'country': 'United States', 'flag': '🇺🇸'},
    {'code': '+598', 'country': 'Uruguay', 'flag': '🇺🇾'},
    {'code': '+998', 'country': 'Uzbekistan', 'flag': '🇺🇿'},
    {'code': '+678', 'country': 'Vanuatu', 'flag': '🇻🇺'},
    {'code': '+58', 'country': 'Venezuela', 'flag': '🇻🇪'},
    {'code': '+84', 'country': 'Vietnam', 'flag': '🇻🇳'},
    {'code': '+967', 'country': 'Yemen', 'flag': '🇾🇪'},
    {'code': '+260', 'country': 'Zambia', 'flag': '🇿🇲'},
    {'code': '+263', 'country': 'Zimbabwe', 'flag': '🇿🇼'},
  ];

  // Field-level error messages from API
  Map<String, String> _fieldErrors = {};

  // Gender and DOB removed from registration
  // Future<void> _pickDate() async { ... }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _countryCodes.where((c) {
              final q = query.toLowerCase();
              return c['country']!.toLowerCase().contains(q) ||
                  c['code']!.contains(q);
            }).toList();
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.85,
              minChildSize: 0.4,
              expand: false,
              builder: (_, scrollController) => Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select Country Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.fieldBorder,
                          ),
                        ),
                      ),
                      onChanged: (v) => setSheetState(() => query = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        final isSelected = item['code'] == _selectedPhoneCode;
                        return ListTile(
                          leading: Text(
                            item['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(item['country']!),
                          trailing: Text(
                            item['code']!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedPhoneCode = item['code']!;
                              _selectedCountryFlag = item['flag']!;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    // Clear previous API errors
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree with the Terms & Conditions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneCode: _selectedPhoneCode,
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpScreen(email: response.otpSentTo)),
      );
    } on ApiValidationException catch (e) {
      setState(() {
        if (e.errors != null) {
          _fieldErrors = e.errors!.map(
            (key, msgs) => MapEntry(key, msgs.first),
          );
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your details to create your account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Name
                _fieldLabel('Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    'Enter your name',
                  ).copyWith(errorText: _fieldErrors['name']),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),

                const SizedBox(height: 18),

                // Email
                _fieldLabel('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    'Enter your email',
                  ).copyWith(errorText: _fieldErrors['email']),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Phone Number
                _fieldLabel('Phone Number*'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('29793770').copyWith(
                    counterText: '',
                    errorText: _fieldErrors['phone'],
                    prefixIcon: GestureDetector(
                      onTap: _showCountryCodePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountryFlag,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _selectedPhoneCode,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: AppColors.fieldBorder,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  maxLength: 14,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(14),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) {
                      return 'Phone number must be at least 10 digits';
                    }
                    return null;
                  },
                ),

                // Gender field removed
                // Date of Birth field removed
                const SizedBox(height: 18),

                // Password
                _fieldLabel('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration('Enter your password').copyWith(
                    errorText: _fieldErrors['password'],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Confirm Password
                _fieldLabel('Confirm Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration('Confirm your password'),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Terms checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeTerms,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (v) =>
                            setState(() => _agreeTerms = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Agree with ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: open terms
                      },
                      child: const Text(
                        'Terms & conditions',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Sign Up button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                // TODO: Re-enable social login
                // const SocialLoginRow(label: 'or sign up with'),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
