class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'Error [$statusCode]: $message';
    }
    return message;
  }
}

class NetworkException extends AppException {
  NetworkException(String message, {int? statusCode}) : super(message, statusCode: statusCode);
}

class AuthException extends AppException {
  AuthException(String message) : super(message, statusCode: 401);
}
