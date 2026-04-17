class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ApiValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ApiValidationException({required super.message, this.errors})
    : super(statusCode: 422);

  /// Returns the first error message for a given field, or null.
  String? fieldError(String field) {
    final msgs = errors?[field];
    return (msgs != null && msgs.isNotEmpty) ? msgs.first : null;
  }
}
