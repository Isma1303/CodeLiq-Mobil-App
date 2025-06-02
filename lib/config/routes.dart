import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/users/user_list_screen.dart';
import '../screens/clients/client_list_screen.dart';
import '../screens/services/service_list_screen.dart';
import '../screens/subscriptions/subscription_list_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String clients = '/clients';
  static const String services = '/services';
  static const String subscriptions = '/subscriptions';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    users: (context) => const UserListScreen(),
    clients: (context) => const ClientListScreen(),
    services: (context) => const ServiceListScreen(),
    subscriptions: (context) => const SubscriptionListScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
