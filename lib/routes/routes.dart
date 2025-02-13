import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/screens/change_password_page.dart';
import 'package:project_flutter/screens/chart_page.dart';
import 'package:project_flutter/screens/dashboard_page.dart';
import 'package:project_flutter/screens/add_page.dart';
import 'package:project_flutter/screens/detail_page.dart';
import 'package:project_flutter/screens/edit_page.dart';
import 'package:project_flutter/screens/login_page.dart';
import 'package:project_flutter/screens/register_page.dart';
import 'package:project_flutter/screens/settings_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        );
      case '/add':
        return MaterialPageRoute(
          builder: (_) => const AddPage(),
        );
      case '/edit':
        return MaterialPageRoute(
          builder: (_) => EditPage(itemId: settings.arguments as String),
        );
      case '/detail':
        final transaction =
            settings.arguments as QueryDocumentSnapshot<Object?>;
        return MaterialPageRoute(
          builder: (_) => DetailPage(transaction: transaction),
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
      case '/changepassword':
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordPage(),
        );
      case '/chart':
        final arguments = settings.arguments as Map<String, dynamic>;
        final List<DocumentSnapshot> transactions = arguments['transactions'];
        final DateTime startDate = arguments['startDate'];
        final DateTime endDate = arguments['endDate'];

        return MaterialPageRoute(
          builder: (_) => ChartPage(
            transactions: transactions,
            startDate: startDate,
            endDate: endDate,
          ),
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );
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
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Text(
            'Error: Route not found!',
            style: TextStyle(
              fontFamily: 'DynaPuff',
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
