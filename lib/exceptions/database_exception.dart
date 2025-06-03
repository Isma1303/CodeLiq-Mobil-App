class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  DatabaseException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'DatabaseException: $message (Original error: $originalError)';
    }
    return 'DatabaseException: $message';
  }
}

