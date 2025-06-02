import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Configuración',
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Perfil'),
              subtitle: const Text('Gestionar información de usuario'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navegar a pantalla de perfil (implementar)
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Notificaciones'),
              subtitle: const Text('Configurar notificaciones'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navegar a configuración de notificaciones (implementar)
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.security_outlined,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Seguridad'),
              subtitle: const Text('Cambiar contraseña'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navegar a cambio de contraseña (implementar)
              },
            ),
          ),
        ],
      ),
    );
  }
}
