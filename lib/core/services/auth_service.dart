import 'package:azager/core/models/auth_models.dart';
import 'package:azager/core/network/api_client.dart';
import 'package:azager/core/network/api_config.dart';
import 'package:azager/core/services/session_manager.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String phoneCode,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.register,
      body: {
        'name': name,
        'email': email,
        'phone_code': phoneCode,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return RegisterResponse.fromJson(response);
  }

  Future<VerifyOtpResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.verifyOtp,
      body: {'email': email, 'otp': otp},
    );
    return VerifyOtpResponse.fromJson(response);
  }

  Future<ResendOtpResponse> resendOtp({required String email}) async {
    final response = await _apiClient.post(
      ApiConfig.resendOtp,
      body: {'email': email},
    );
    return ResendOtpResponse.fromJson(response);
  }

  Future<LoginResponse> login({
    required String login,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.login,
      body: {'login': login, 'password': password},
    );
    final loginResponse = LoginResponse.fromJson(response);

    // Save session
    await SessionManager.saveSession(
      userId: loginResponse.user.id,
      email: loginResponse.user.email,
      token: loginResponse.access.token,
    );

    return loginResponse;
  }

  Future<SimpleApiResponse> logout() async {
    final token = SessionManager.token;
    final response = await _apiClient.post(
      ApiConfig.logout,
      headers: token != null ? ApiConfig.authHeaders(token) : null,
    );
    await SessionManager.clearSession();
    return SimpleApiResponse.fromJson(response);
  }

  // ── Forgot Password flow ─────────────────────────────

  Future<ForgotPasswordSendOtpResponse> forgotPasswordSendOtp({
    required String email,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.forgotPasswordSendOtp,
      body: {'email': email},
    );
    return ForgotPasswordSendOtpResponse.fromJson(response);
  }

  Future<ForgotPasswordVerifyOtpResponse> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.forgotPasswordVerifyOtp,
      body: {'email': email, 'otp': otp},
    );
    return ForgotPasswordVerifyOtpResponse.fromJson(response);
  }

  Future<SimpleApiResponse> forgotPasswordReset({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.forgotPasswordReset,
      body: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return SimpleApiResponse.fromJson(response);
  }

  // ── Change Password ──────────────────────────────────

  Future<SimpleApiResponse> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final token = SessionManager.token;
    final response = await _apiClient.post(
      ApiConfig.changePassword,
      headers: token != null ? ApiConfig.authHeaders(token) : null,
      body: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return SimpleApiResponse.fromJson(response);
  }

  void dispose() {
    _apiClient.dispose();
  }
}
