import 'package:flutter/material.dart';

class AddEditPage extends StatelessWidget {
  const AddEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-edit');
        },
        child: const Text('Add New Transaction'),
      ),
    );
  }
}
