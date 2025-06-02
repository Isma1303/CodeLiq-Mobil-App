import 'package:mysql_client/mysql_client.dart';
import '../config/database_config.dart';
import '../models/user.dart';

class DatabaseException implements Exception {
  final String message;
  final dynamic error;

  DatabaseException(this.message, [this.error]);

  @override
  String toString() =>
      'DatabaseException: $message${error != null ? ' ($error)' : ''}';
}

class UserDatabaseService {
  late final MySQLConnection _connection;
  bool _isConnected = false;

  Future<void> connect() async {
    if (!_isConnected) {
      try {
        _connection = await MySQLConnection.createConnection(
          host: DatabaseConfig.host,
          port: DatabaseConfig.port,
          userName: DatabaseConfig.username,
          password: DatabaseConfig.password,
          databaseName: DatabaseConfig.database,
          secure: true,
        );
        await _connection.connect();
        _isConnected = true;
      } catch (e) {
        throw DatabaseException('Error al conectar con la base de datos', e);
      }
    }
  }

  Future<List<User>> getUsers() async {
    await connect();
    final results = await _connection.execute(
      'SELECT id, name, email, role, created_at FROM users ORDER BY created_at DESC',
    );
    return results.rows.map((row) {
      return User(
        id: row.colByName('id')?.toString() ?? '',
        name: row.colByName('name')?.toString() ?? '',
        email: row.colByName('email')?.toString() ?? '',
        role: row.colByName('role')?.toString() ?? '',
        createdAt: row.colByName('created_at') is DateTime
            ? row.colByName('created_at') as DateTime
            : DateTime.parse(row.colByName('created_at').toString()),
      );
    }).toList();
  }

  Future<User?> authenticate(String email, String password) async {
    await connect();
    final results = await _connection.execute(
      'SELECT id, name, email, role, created_at, password FROM users WHERE email = :email',
      {'email': email},
    );
    if (results.rows.isEmpty) return null;

    final row = results.rows.first;
    // Aquí deberías comparar el hash de la contraseña
    // Por simplicidad, se compara texto plano (NO recomendado en producción)
    if (row.colByName('password') == password) {
      return User(
        id: row.colByName('id')?.toString() ?? '',
        name: row.colByName('name')?.toString() ?? '',
        email: row.colByName('email')?.toString() ?? '',
        role: row.colByName('role')?.toString() ?? '',
        createdAt: row.colByName('created_at') is DateTime
            ? row.colByName('created_at') as DateTime
            : DateTime.parse(row.colByName('created_at').toString()),
      );
    }
    return null;
  }

  Future<bool> deleteUser(String id) async {
    try {
      await connect();
      final result = await _connection.execute(
        'UPDATE users SET status = :status WHERE id = :id',
        {'status': 'inactive', 'id': id},
      );
      return result.affectedRows.toInt() > 0;
    } catch (e) {
      throw DatabaseException('Error al eliminar el usuario', e);
    }
  }

  Future<void> close() async {
    if (_isConnected) {
      await _connection.close();
      _isConnected = false;
    }
  }
}
