import '../models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../exceptions/database_exception.dart';
import 'package:mysql_client/mysql_client.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Import your database config
import '../config/database_config.dart';

class UserDatabaseService {
  MySQLConnection? _connection;
  bool _isConnected = false;

  UserDatabaseService();

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (!_isConnected) {
      try {
        print('Attempting to connect to MySQL database:');
        print('Host: ${DatabaseConfig.host}');
        print('Port: ${DatabaseConfig.port}');
        print('Database: ${DatabaseConfig.database}');
        print('User: ${DatabaseConfig.username}');
        print('SSL Enabled: ${DatabaseConfig.useSSL}');

        // Create mysql_client connection
        final conn = await MySQLConnection.createConnection(
          host: DatabaseConfig.host,
          port: DatabaseConfig.port,
          userName: DatabaseConfig.username,
          password: DatabaseConfig.password,
          databaseName: DatabaseConfig.database,
          secure: DatabaseConfig.useSSL,
        );

        // Establish connection
        await conn.connect();
        _connection = conn;
        _isConnected = true;
        print('Successfully connected to MySQL database!');
      } catch (e) {
        print('MySQL connection error details: $e');
        throw DatabaseException(
          'Error connecting to database: ${e.toString()}',
          e,
        );
      }
    }
  }

  Future<List<User>> getUsers() async {
    if (!_isConnected || _connection == null) {
      await connect();
    }

    try {
      final results = await _connection!.execute('SELECT * FROM users');
      final users = <User>[];

      for (final row in results.rows) {
        users.add(
          User(
            id: row.colByName('id')!.toString(),
            name: row.colByName('name')!.toString(),
            email: row.colByName('email')!.toString(),
            role: row.colByName('role')?.toString() ?? 'user',
            createdAt: DateTime.parse(row.colByName('created_at')!.toString()),
          ),
        );
      }
      return users;
    } catch (e) {
      print('Failed to fetch users: $e');
      throw DatabaseException('Error al obtener la lista de usuarios', e);
    }
  }

  Future<User?> authenticate(String email, String password) async {
    if (!_isConnected || _connection == null) {
      await connect();
    }

    try {
      // Important security note: In a real application, passwords should be hashed
      // and not compared directly in the query. This is a simplified example.
      final results = await _connection!.execute(
        'SELECT * FROM users WHERE email = :email AND password = :password',
        {'email': email, 'password': password},
      );

      if (results.rows.isNotEmpty) {
        final row = results.rows.first;
        return User(
          id: row.colByName('id')!.toString(),
          name: row.colByName('name')!.toString(),
          email: row.colByName('email')!.toString(),
          role: row.colByName('role')?.toString() ?? 'user',
          createdAt: DateTime.parse(row.colByName('created_at')!.toString()),
        );
      }
      return null;
    } catch (e) {
      print('Authentication failed: $e');
      throw DatabaseException('Error durante la autenticación', e);
    }
  }

  Future<bool> deleteUser(String id) async {
    if (!_isConnected || _connection == null) {
      await connect();
    }

    try {
      final result = await _connection!.execute(
        'DELETE FROM users WHERE id = :id',
        {'id': id},
      );
      return result.affectedRows.toInt() > 0;
    } catch (e) {
      print('Failed to delete user: $e');
      throw DatabaseException('Error al eliminar el usuario', e);
    }
  }

  Future<User> createUser(User user) async {
    if (!_isConnected || _connection == null) {
      await connect();
    }

    try {
      final result = await _connection!.execute(
        'INSERT INTO users (name, email, password, role, created_at) VALUES (:name, :email, :password, :role, :created_at)',
        {
          'name': user.name,
          'email': user.email,
          'password': user.password ?? '', // Handle null password
          'role': user.role,
          'created_at': user.createdAt.toIso8601String(),
        },
      );

      if (result.lastInsertID.toInt() > 0) {
        final insertId = result.lastInsertID;
        // Retrieve the newly created user to get all fields
        final newUserResults = await _connection!.execute(
          'SELECT * FROM users WHERE id = :id',
          {'id': insertId},
        );

        if (newUserResults.rows.isNotEmpty) {
          final row = newUserResults.rows.first;
          return User(
            id: row.colByName('id')!.toString(),
            name: row.colByName('name')!.toString(),
            email: row.colByName('email')!.toString(),
            role: row.colByName('role')?.toString() ?? 'user',
            createdAt: DateTime.parse(row.colByName('created_at')!.toString()),
          );
        }
      }
      throw DatabaseException(
        'Failed to create user: Could not retrieve created user',
      );
    } catch (e) {
      throw DatabaseException('Failed to create user: ${e.toString()}', e);
    }
  }

  Future<User> updateUser(String id, Map<String, dynamic> updates) async {
    if (!_isConnected || _connection == null) {
      await connect();
    }

    try {
      // Build SQL SET clause dynamically from updates map
      final setClause = updates.keys.map((key) => '$key = :$key').join(', ');

      // Create parameters map with id
      final params = <String, dynamic>{...updates, 'id': id};

      final result = await _connection!.execute(
        'UPDATE users SET $setClause WHERE id = :id',
        params,
      );

      if (result.affectedRows.toInt() > 0) {
        // Fetch updated user
        final updatedUserResults = await _connection!.execute(
          'SELECT * FROM users WHERE id = :id',
          {'id': id},
        );

        if (updatedUserResults.rows.isNotEmpty) {
          final row = updatedUserResults.rows.first;
          return User(
            id: row.colByName('id')!.toString(),
            name: row.colByName('name')!.toString(),
            email: row.colByName('email')!.toString(),
            role: row.colByName('role')?.toString() ?? 'user',
            createdAt: DateTime.parse(row.colByName('created_at')!.toString()),
          );
        }
      }
      throw DatabaseException(
        'Failed to update user: Could not retrieve updated user',
      );
    } catch (e) {
      throw DatabaseException('Failed to update user: ${e.toString()}', e);
    }
  }

  // Properly close the MySQL connection
  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
    _isConnected = false;
  }
}
