import 'package:mysql_client/mysql_client.dart';

import '../config/database_config.dart';
import '../models/subscription.dart';

class SubscriptionDatabaseService {
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

  Future<List<Map<String, dynamic>>> getAllSubscriptionsWithDetails() async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT 
        s.*,
        c.name as client_name,
        c.email as client_email,
        sv.name as service_name,
        sv.price as service_price
      FROM subscriptions s
      JOIN clients c ON s.client_id = c.id
      JOIN services sv ON s.service_id = sv.id

      ORDER BY s.created_at DESC
    ''');

    final List<Map<String, dynamic>> mappedResults = [];
    for (final row in results.rows) {
      mappedResults.add({
        'id': row.colByName('id'),
        'client_id': row.colByName('client_id'),
        'service_id': row.colByName('service_id'),
        'start_date': row.colByName('start_date'),
        'end_date': row.colByName('end_date'),
        'total_amount': row.colByName('total_amount'),
        'status': row.colByName('status'),
        'created_at': row.colByName('created_at'),
        'updated_at': row.colByName('updated_at'),
        'client_name': row.colByName('client_name'),
        'client_email': row.colByName('client_email'),
        'service_name': row.colByName('service_name'),
        'service_price': row.colByName('service_price'),
      });
    }
    return mappedResults;
  }

  Future<List<Subscription>> getAllSubscriptions() async {
    final conn = await connection;
    final results = await conn.execute(
      'SELECT * FROM subscriptions ORDER BY created_at DESC',
    );

    final List<Subscription> subscriptions = [];
    for (final row in results.rows) {
      subscriptions.add(
        Subscription.fromJson({
          'id': row.colByName('id'),
          'client_id': row.colByName('client_id'),
          'service_id': row.colByName('service_id'),
          'start_date': row.colByName('start_date'),
          'end_date': row.colByName('end_date'),
          'total_amount': row.colByName('total_amount'),
          'status': row.colByName('status'),
          'created_at': row.colByName('created_at'),
          'updated_at': row.colByName('updated_at'),
        }),
      );
    }
    return subscriptions;
  }

  Future<Subscription?> getSubscriptionById(int id) async {
    final conn = await connection;
    final results = await conn.execute(
      'SELECT * FROM subscriptions WHERE id = :id',
      {'id': id},
    );

    if (results.rows.isEmpty) return null;

    final row = results.rows.first;
    return Subscription.fromJson({
      'id': row.colByName('id'),
      'client_id': row.colByName('client_id'),
      'service_id': row.colByName('service_id'),
      'start_date': row.colByName('start_date'),
      'end_date': row.colByName('end_date'),
      'total_amount': row.colByName('total_amount'),
      'status': row.colByName('status'),
      'created_at': row.colByName('created_at'),
      'updated_at': row.colByName('updated_at'),
    });
  }

  Future<Map<String, dynamic>?> getSubscriptionDetails(int id) async {
    final conn = await connection;
    final results = await conn.execute(
      '''
      SELECT 
        s.*,
        c.name as client_name,
        c.email as client_email,
        sv.name as service_name,
        sv.price as service_price
      FROM subscriptions s
      JOIN clients c ON s.client_id = c.id
      JOIN services sv ON s.service_id = sv.id
      WHERE s.id = :id
    ''',
      {'id': id},
    );

    if (results.rows.isEmpty) return null;

    final row = results.rows.first;
    return {
      'id': row.colByName('id'),
      'client_id': row.colByName('client_id'),
      'service_id': row.colByName('service_id'),
      'start_date': row.colByName('start_date'),
      'end_date': row.colByName('end_date'),
      'total_amount': row.colByName('total_amount'),
      'status': row.colByName('status'),
      'created_at': row.colByName('created_at'),
      'updated_at': row.colByName('updated_at'),
      'client_name': row.colByName('client_name'),
      'client_email': row.colByName('client_email'),
      'service_name': row.colByName('service_name'),
      'service_price': row.colByName('service_price'),
    };
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    final conn = await connection;
    final result = await conn.execute(
      '''
      INSERT INTO subscriptions (
        client_id, service_id, start_date, end_date, 
        total_amount
      )
      VALUES (
        :client_id, :service_id, :start_date, :end_date, 
        :total_amount
      )
      ''',
      {
        'client_id': subscription.clientId,
        'service_id': subscription.serviceId,
        'start_date': subscription.startDate.toIso8601String(),
        'end_date': subscription.endDate.toIso8601String(),
        'total_amount': subscription.totalAmount,
      },
    );

    final id = result.lastInsertID.toInt();
    return subscription.copyWith(id: id);
  }

  Future<bool> updateSubscription(Subscription subscription) async {
    if (subscription.id == null) return false;

    final conn = await connection;
    final result = await conn.execute(
      '''
      UPDATE subscriptions 
      SET client_id = :client_id, service_id = :service_id, 
          start_date = :start_date, end_date = :end_date,
          total_amount = :total_amount
      WHERE id = :id
      ''',
      {
        'id': subscription.id,
        'client_id': subscription.clientId,
        'service_id': subscription.serviceId,
        'start_date': subscription.startDate.toIso8601String(),
        'end_date': subscription.endDate.toIso8601String(),
        'total_amount': subscription.totalAmount,
      },
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<bool> cancelSubscription(int id) async {
    final conn = await connection;
    final result = await conn.execute(
      'UPDATE subscriptions SET status = :status WHERE id = :id',
      {'id': id, 'status': 'cancelled'},
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<List<Subscription>> getActiveSubscriptionsForClient(
    int clientId,
  ) async {
    final conn = await connection;
    final results = await conn.execute(
      '''
      SELECT * FROM subscriptions 
      WHERE client_id = :client_id 

      AND end_date >= CURDATE()
      ORDER BY start_date DESC
      ''',
      {'client_id': clientId},
    );

    final List<Subscription> subscriptions = [];
    for (final row in results.rows) {
      subscriptions.add(
        Subscription.fromJson({
          'id': row.colByName('id'),
          'client_id': row.colByName('client_id'),
          'service_id': row.colByName('service_id'),
          'start_date': row.colByName('start_date'),
          'end_date': row.colByName('end_date'),
          'total_amount': row.colByName('total_amount'),
          'status': row.colByName('status'),
          'created_at': row.colByName('created_at'),
          'updated_at': row.colByName('updated_at'),
        }),
      );
    }
    return subscriptions;
  }

  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
