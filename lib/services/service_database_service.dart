import 'package:mysql_client/mysql_client.dart';
import '../config/database_config.dart';
import '../models/service.dart';

class ServiceDatabaseService {
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

  Future<List<Service>> getAllServices() async {
    final conn = await connection;
    final results = await conn.execute(
      'SELECT * FROM services ORDER BY created_at DESC',
    );

    final List<Service> services = [];
    for (final row in results.rows) {
      services.add(
        Service.fromJson({
          'id': row.colByName('id'),
          'name': row.colByName('name'),
          'description': row.colByName('description'),
          'price': row.colByName('price'),
          'duration': row.colByName('duration'),
          'status': row.colByName('status'),
          'created_at': row.colByName('created_at'),
          'updated_at': row.colByName('updated_at'),
        }),
      );
    }
    return services;
  }

  Future<Service?> getServiceById(int id) async {
    final conn = await connection;
    final results = await conn.execute(
      'SELECT * FROM services WHERE id = :id',
      {'id': id},
    );

    if (results.rows.isEmpty) return null;

    final row = results.rows.first;
    return Service.fromJson({
      'id': row.colByName('id'),
      'name': row.colByName('name'),
      'description': row.colByName('description'),
      'price': row.colByName('price'),
      'duration': row.colByName('duration'),
      'status': row.colByName('status'),
      'created_at': row.colByName('created_at'),
      'updated_at': row.colByName('updated_at'),
    });
  }

  Future<Service> createService(Service service) async {
    final conn = await connection;
    final result = await conn.execute(
      '''
      INSERT INTO services (name, description, price, duration, status)
      VALUES (:name, :description, :price, :duration, :status)
      ''',
      {
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'duration': service.duration,
        'status': service.status,
      },
    );

    final id = result.lastInsertID.toInt();
    return service.copyWith(id: id);
  }

  Future<bool> updateService(Service service) async {
    if (service.id == null) {
      throw Exception('No se puede actualizar un servicio sin ID');
    }

    final conn = await connection;
    final result = await conn.execute(
      '''
      UPDATE services
      SET name = :name,
          description = :description,
          price = :price,
          duration = :duration,
          status = :status,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = :id
      ''',
      {
        'id': service.id,
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'duration': service.duration,
        'status': service.status,
      },
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<bool> deleteService(int id) async {
    final conn = await connection;
    final result = await conn.execute(
      'UPDATE services SET status = :status WHERE id = :id',
      {'id': id, 'status': 'inactive'},
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<List<Service>> searchServices(String query) async {
    final conn = await connection;
    final results = await conn.execute(
      '''
      SELECT * FROM services 
      WHERE name LIKE :query OR description LIKE :query
      ORDER BY created_at DESC
      ''',
      {'query': '%$query%'},
    );

    final List<Service> services = [];
    for (final row in results.rows) {
      services.add(
        Service.fromJson({
          'id': row.colByName('id'),
          'name': row.colByName('name'),
          'description': row.colByName('description'),
          'price': row.colByName('price'),
          'duration': row.colByName('duration'),
          'status': row.colByName('status'),
          'created_at': row.colByName('created_at'),
          'updated_at': row.colByName('updated_at'),
        }),
      );
    }
    return services;
  }

  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
