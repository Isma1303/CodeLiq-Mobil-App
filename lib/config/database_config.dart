import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static String get host => dotenv.get('DB_HOST'); // Database host from .env
  static int get port => int.parse(dotenv.get('DB_PORT')); // Database port from .env
  static String get database => dotenv.get('DB_NAME'); // Database name from .env
  static String get username => dotenv.get('DB_USER'); // Database username from .env
  static String get password => dotenv.get('DB_PASSWORD'); // Database password from .env
  static bool get useSSL => dotenv.get('DB_USE_SSL') == 'true'; // SSL setting from .env
}
