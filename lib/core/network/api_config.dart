class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://dev.uniben.azager.com/api/v2';

  // Auth endpoints
  static const String register = '/registration';
  static const String verifyOtp = '/verify-otp';
  static const String resendOtp = '/resend-otp';
  static const String login = '/login';
  static const String logout = '/logout';

  // Password endpoints
  static const String forgotPasswordSendOtp = '/forgot-password/send-otp';
  static const String forgotPasswordVerifyOtp = '/forgot-password/verify-otp';
  static const String forgotPasswordReset = '/forgot-password/reset-password';
  static const String changePassword = '/change-password';

  // Home & Splash
  static const String home = '/home';
  static const String splashScreens = '/splash-screens';

  // Products
  static const String products = '/products';
  static const String productDetails = '/product-details';
  static const String categoryProducts = '/category-products';
  static const String productReview = '/product-review';

  // Wishlist
  static const String wishlist = '/favorite-products';
  static const String toggleFavorite = '/favorite-add-or-remove';

  // Search
  static const String search = '/search';
  static const String searchSuggestions = '/search/suggestions';
  static const String recentSearches = '/recent-searches';

  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
