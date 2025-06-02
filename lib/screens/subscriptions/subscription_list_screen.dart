import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../services/subscription_database_service.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  final SubscriptionDatabaseService _subscriptionDb =
      SubscriptionDatabaseService();
  List<Map<String, dynamic>> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      final subscriptions = await _subscriptionDb
          .getAllSubscriptionsWithDetails();
      if (mounted) {
        setState(() {
          _subscriptions = subscriptions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar suscripciones: $e')),
        );
      }
    }
  }

  Future<void> _cancelSubscription(int id) async {
    try {
      final success = await _subscriptionDb.cancelSubscription(id);
      if (success) {
        await _loadSubscriptions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Suscripción cancelada con éxito')),
          );
        }
      } else {
        throw Exception('No se pudo cancelar la suscripción');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cancelar suscripción: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Suscripciones'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSubscriptions,
              child: ListView.builder(
                itemCount: _subscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = _subscriptions[index];
                  final startDate = DateTime.parse(subscription['start_date']);
                  final endDate = DateTime.parse(subscription['end_date']);
                  final status = subscription['status'] as String;
                  final id = subscription['id'] as int;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        subscription['client_name'] ?? 'Cliente no encontrado',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Servicio: ${subscription['service_name'] ?? 'No disponible'}',
                          ),
                          Text(
                            'Fecha: ${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
                          ),
                          Text(
                            'Total: \$${(subscription['total_amount'] as num).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Estado: ${status.toUpperCase()}',
                            style: TextStyle(
                              color: status == 'active'
                                  ? Colors.green
                                  : status == 'pending'
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      trailing: status == 'active'
                          ? IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar cancelación'),
                                  content: const Text(
                                    '¿Desea cancelar esta suscripción?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _cancelSubscription(id);
                                      },
                                      child: const Text('Sí'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/subscriptions/details',
                          arguments: id,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/subscriptions/create').then((created) {
            if (created == true) {
              _loadSubscriptions();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
