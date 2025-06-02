import 'package:mysql_client/mysql_client.dart';
import '../config/database_config.dart';
import '../models/client.dart';

class ClientDatabaseService {
  static MySQLConnection? _connection;

  static Future<MySQLConnection> get connection async {
    if (_connection == null || !_connection!.connected) {
      _connection = await MySQLConnection.createConnection(
        host: DatabaseConfig.host,
        port: DatabaseConfig.port,
        userName: DatabaseConfig.username,
        password: DatabaseConfig.password,
        databaseName: DatabaseConfig.database,
        secure: DatabaseConfig.useSSL,
      );
      await _connection!.connect();
    }
    return _connection!;
  }

  Future<List<Client>> getAllClients() async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT 
        id,
        name,
        email,
        phone,
        address,
        status,
        DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s.000Z') as created_at,
        DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%s.000Z') as updated_at
      FROM clients 
      ORDER BY created_at DESC
      ''');

    final List<Client> clients = [];
    for (final row in results.rows) {
      clients.add(
        Client.fromJson({
          'id': row.colByName('id'),
          'name': row.colByName('name'),
          'email': row.colByName('email'),
          'phone': row.colByName('phone'),
          'address': row.colByName('address'),
          'status': row.colByName('status'),
          'created_at': row.colByName('created_at'),
          'updated_at': row.colByName('updated_at'),
        }),
      );
    }
    return clients;
  }

  Future<Client?> getClientById(int id) async {
    final conn = await connection;
    final results = await conn.execute(
      '''
      SELECT 
        id,
        name,
        email,
        phone,
        address,
        status,
        DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s.000Z') as created_at,
        DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%s.000Z') as updated_at
      FROM clients 
      WHERE id = :id
      ''',
      {'id': id},
    );

    if (results.rows.isEmpty) return null;

    final row = results.rows.first;
    return Client.fromJson({
      'id': row.colByName('id'),
      'name': row.colByName('name'),
      'email': row.colByName('email'),
      'phone': row.colByName('phone'),
      'address': row.colByName('address'),
      'status': row.colByName('status'),
      'created_at': row.colByName('created_at'),
      'updated_at': row.colByName('updated_at'),
    });
  }

  Future<Client> createClient(Client client) async {
    final conn = await connection;
    final result = await conn.execute(
      '''
      INSERT INTO clients (name, email, phone, address)
      VALUES (:name, :email, :phone, :address)
      ''',
      {
        'name': client.name,
        'email': client.email,
        'phone': client.phone,
        'address': client.address,
      },
    );

    final id = result.lastInsertID.toInt();
    return client.copyWith(id: id);
  }

  Future<bool> updateClient(Client client) async {
    if (client.id == null) return false;

    final conn = await connection;
    final result = await conn.execute(
      '''
      UPDATE clients 
      SET name = :name, email = :email, phone = :phone, 
          address = :address
      WHERE id = :id
      ''',
      {
        'id': client.id,
        'name': client.name,
        'email': client.email,
        'phone': client.phone,
        'address': client.address,
      },
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<bool> deleteClient(int id) async {
    final conn = await connection;
    final result = await conn.execute(
      'UPDATE clients SET status = :status WHERE id = :id',
      {'id': id, 'status': 'inactive'},
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<List<Client>> searchClients(String query) async {
    final conn = await connection;
    final results = await conn.execute(
      '''
      SELECT * FROM clients 
      WHERE name LIKE :query OR email LIKE :query OR phone LIKE :query
      ORDER BY created_at DESC
      ''',
      {'query': '%$query%'},
    );

    final List<Client> clients = [];
    for (final row in results.rows) {
      clients.add(
        Client.fromJson({
          'id': row.colByName('id'),
          'name': row.colByName('name'),
          'email': row.colByName('email'),
          'phone': row.colByName('phone'),
          'address': row.colByName('address'),
          'status': row.colByName('status'),
          'created_at': row.colByName('created_at'),
          'updated_at': row.colByName('updated_at'),
        }),
      );
    }
    return clients;
  }

  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
