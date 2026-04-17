class AuthUser {
  final int id;
  final String name;
  final String phone;
  final bool phoneVerified;
  final String email;
  final bool emailVerified;
  final bool isActive;
  final String profilePhoto;
  final String? gender;
  final String? dateOfBirth;
  final String? country;
  final String phoneCode;
  final bool accountVerified;
  final bool lastOnline;

  AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.phoneVerified,
    required this.email,
    required this.emailVerified,
    required this.isActive,
    required this.profilePhoto,
    this.gender,
    this.dateOfBirth,
    this.country,
    required this.phoneCode,
    required this.accountVerified,
    required this.lastOnline,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      phoneVerified: json['phone_verified'] as bool,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool,
      isActive: json['is_active'] as bool,
      profilePhoto: json['profile_photo'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      country: json['country'] as String?,
      phoneCode: json['phone_code'] as String,
      accountVerified: json['account_verified'] as bool,
      lastOnline: json['last_online'] as bool,
    );
  }
}

class AuthAccess {
  final String authType;
  final String token;
  final String expiresAt;

  AuthAccess({
    required this.authType,
    required this.token,
    required this.expiresAt,
  });

  factory AuthAccess.fromJson(Map<String, dynamic> json) {
    return AuthAccess(
      authType: json['auth_type'] as String,
      token: json['token'] as String,
      expiresAt: json['expires_at'] as String,
    );
  }
}

class RegisterResponse {
  final bool success;
  final String message;
  final AuthUser user;
  final AuthAccess access;
  final String otpSentTo;
  final String otpMethod;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.access,
    required this.otpSentTo,
    required this.otpMethod,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
      access: AuthAccess.fromJson(data['access'] as Map<String, dynamic>),
      otpSentTo: data['otp_sent_to'] as String,
      otpMethod: data['otp_method'] as String,
    );
  }
}

class VerifyOtpResponse {
  final bool success;
  final String message;
  final AuthUser user;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return VerifyOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}

class ResendOtpResponse {
  final bool success;
  final String message;
  final String otpSentTo;
  final String otpMethod;

  ResendOtpResponse({
    required this.success,
    required this.message,
    required this.otpSentTo,
    required this.otpMethod,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ResendOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      otpSentTo: data['otp_sent_to'] as String,
      otpMethod: data['otp_method'] as String,
    );
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final AuthUser user;
  final AuthAccess access;

  LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.access,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
      access: AuthAccess.fromJson(data['access'] as Map<String, dynamic>),
    );
  }
}

class ForgotPasswordSendOtpResponse {
  final bool success;
  final String message;
  final String email;

  ForgotPasswordSendOtpResponse({
    required this.success,
    required this.message,
    required this.email,
  });

  factory ForgotPasswordSendOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ForgotPasswordSendOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      email: data['email'] as String,
    );
  }
}

class ForgotPasswordVerifyOtpResponse {
  final bool success;
  final String message;
  final String token;

  ForgotPasswordVerifyOtpResponse({
    required this.success,
    required this.message,
    required this.token,
  });

  factory ForgotPasswordVerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ForgotPasswordVerifyOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: data['token'] as String,
    );
  }
}

class SimpleApiResponse {
  final bool success;
  final String message;

  SimpleApiResponse({required this.success, required this.message});

  factory SimpleApiResponse.fromJson(Map<String, dynamic> json) {
    return SimpleApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}
