import 'package:flutter/material.dart';
import 'package:project_flutter/screens/dashboard_page.dart';
import 'package:project_flutter/screens/add_page.dart';
import 'package:project_flutter/screens/edit_page.dart';
import 'package:project_flutter/screens/login_page.dart';
import 'package:project_flutter/screens/register_page.dart';
import 'package:project_flutter/screens/settings_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case '/add':
        return MaterialPageRoute(builder: (_) => const AddPage());
      case '/edit':
        return MaterialPageRoute(
          builder: (_) => EditPage(itemId: settings.arguments as String),
        );
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text(
              'Error',
              style: TextStyle(
                fontFamily: 'DynaPuff',
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
          ),
          backgroundColor: Colors.deepPurple,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Error: Route not found!',
            style: TextStyle(
              fontFamily: 'DynaPuff',
              fontSize: 30,
            ),
          ),
        ),
      ),
    );
  }
}
