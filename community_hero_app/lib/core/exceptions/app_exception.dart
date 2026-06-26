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
  NetworkException(super.message, {super.statusCode});
}

class AuthException extends AppException {
  AuthException(super.message) : super(statusCode: 401);
}
