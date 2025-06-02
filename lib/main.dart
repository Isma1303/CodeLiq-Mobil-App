import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/user.dart';
import 'models/service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/users/user_list_screen.dart';
import 'screens/users/user_form_screen.dart';
import 'screens/clients/client_list_screen.dart';
import 'screens/services/service_list_screen.dart';
import 'screens/services/service_form_screen.dart';
import 'screens/subscriptions/subscription_list_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codeliq Admin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/users':
            return MaterialPageRoute(builder: (_) => const UserListScreen());
          case '/users/create':
            return MaterialPageRoute(builder: (_) => const UserFormScreen());
          case '/users/edit':
            return MaterialPageRoute(
              builder: (_) => UserFormScreen(user: settings.arguments as User?),
            );
          case '/clients':
            return MaterialPageRoute(builder: (_) => const ClientListScreen());
          case '/services':
            return MaterialPageRoute(builder: (_) => const ServiceListScreen());
          case '/services/create':
            return MaterialPageRoute(builder: (_) => const ServiceFormScreen());
          case '/services/edit':
            return MaterialPageRoute(
              builder: (_) =>
                  ServiceFormScreen(service: settings.arguments as Service?),
            );
          case '/subscriptions':
            return MaterialPageRoute(
              builder: (_) => const SubscriptionListScreen(),
            );
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
