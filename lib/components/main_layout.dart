import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: NavigationDrawer(
        backgroundColor: Colors.white,
        elevation: 2,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Panel Administrativo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.dashboard_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          ListTile(
            leading: const Icon(
              Icons.people_outline,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Usuarios'),
            onTap: () => Navigator.pushNamed(context, '/users'),
          ),
          ListTile(
            leading: const Icon(
              Icons.business_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Clientes'),
            onTap: () => Navigator.pushNamed(context, '/clients'),
          ),
          ListTile(
            leading: const Icon(
              Icons.miscellaneous_services_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Servicios'),
            onTap: () => Navigator.pushNamed(context, '/services'),
          ),
          ListTile(
            leading: const Icon(
              Icons.card_membership_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Suscripciones'),
            onTap: () => Navigator.pushNamed(context, '/subscriptions'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Configuración'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
    );
  }
}
