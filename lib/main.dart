import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/user_database_service.dart';
import 'exceptions/database_exception.dart';
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

// Global instance of the database service
final UserDatabaseService userDbService = UserDatabaseService();

void main() async {
  await initializeApp();
}

Future<void> initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();
    
    // Lock orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Test API connection
    print('\n=== Testing API Connection ===');
    await userDbService.connect();
    print('Successfully connected to API server!');
    print('=== End API Connection Test ===\n');

    // If connection is successful, run the app
    runApp(const MyApp());
  } on DatabaseException catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.red, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'No se pudo conectar al servidor',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Por favor, verifique su conexión y la configuración del servidor.\n\nDetalles: ${e.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => initializeApp(), // Retry connection
                    child: const Text('Reintentar Conexión'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text('Cerrar Aplicación'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  } catch (e) {
    print('❌ ERROR INESPERADO durante la inicialización: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'Error Inesperado',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ocurrió un error inesperado al iniciar la aplicación:\n\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => initializeApp(), // Retry initialization
                    child: const Text('Reintentar'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text('Cerrar Aplicación'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
