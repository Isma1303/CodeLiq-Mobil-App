import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static String get host {
    final value = dotenv.env['DB_HOST'];
    if (value == null || value.isEmpty) {
      throw Exception('DB_HOST is not set in .env file');
    }
    return value;
  }

  static int get port {
    final value = dotenv.env['DB_PORT'];
    if (value == null || value.isEmpty) {
      throw Exception('DB_PORT is not set in .env file');
    }
    return int.parse(value);
  }

  static String get database {
    final value = dotenv.env['DB_NAME'];
    if (value == null || value.isEmpty) {
      throw Exception('DB_NAME is not set in .env file');
    }
    return value;
  }

  static String get username {
    final value = dotenv.env['DB_USER'];
    if (value == null || value.isEmpty) {
      throw Exception('DB_USER is not set in .env file');
    }
    return value;
  }

  static String get password {
    final value = dotenv.env['DB_PASSWORD'];
    if (value == null || value.isEmpty) {
      throw Exception('DB_PASSWORD is not set in .env file');
    }
    return value;
  }

  static bool get useSSL {
    final value = dotenv.env['DB_USE_SSL'];
    if (value == null) {
      return true; // Default value if not specified
    }
    return value.toLowerCase() == 'true';
  }
}
