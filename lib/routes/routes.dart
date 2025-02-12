import 'package:flutter/material.dart';
import 'package:project_flutter/screens/login_page.dart';
import 'package:project_flutter/screens/add_edit_page.dart';
import 'package:project_flutter/screens/dashboard_content.dart';
import 'package:project_flutter/screens/register_page.dart';
import 'package:project_flutter/screens/settings_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardContent());
      case '/add-edit':
        return MaterialPageRoute(builder: (_) => const AddEditPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Error: Route not found!'),
        ),
      ),
    );
  }
}
