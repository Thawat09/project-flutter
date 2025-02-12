import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_flutter/widgets/bottom_navigation.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isAmountValid = false;
  bool _isCategoryValid = false;
  bool _isFormValid = false;

  void _checkFormValidity() {
    setState(() {
      _isAmountValid = _amountController.text.isNotEmpty &&
          double.tryParse(_amountController.text) != null;
      _isCategoryValid = _categoryController.text.isNotEmpty;
      _isFormValid = _isAmountValid && _isCategoryValid;
    });
  }

  void _addTransaction() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print("user : $user");
      if (user != null) {
        await FirebaseFirestore.instance.collection('transactions').add({
          'amount': double.parse(_amountController.text),
          'category': _categoryController.text,
          'userId': user.uid,
          'timestamp': Timestamp.now(),
        });

        // แสดง SnackBar เมื่อบันทึกข้อมูลสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Transaction added successfully!',
            style: TextStyle(
              fontFamily: 'DynaPuff',
              fontSize: 20,
            ),
          )),
        );

        // นำทางไปยังหน้าจอ Dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      print('Error adding transaction: $e');

      // แสดง SnackBar เมื่อเกิดข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'Failed to add transaction. Please try again.',
          style: TextStyle(
            fontFamily: 'DynaPuff',
            fontSize: 20,
          ),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Item',
          style: TextStyle(
            fontFamily: 'DynaPuff',
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(
                  fontFamily: 'DynaPuff',
                  fontSize: 20,
                ),
              ),
              onChanged: (value) {
                _checkFormValidity();
                if (value.isNotEmpty && double.tryParse(value) == null) {
                  setState(() {
                    _isAmountValid = false;
                  });
                }
              },
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(
                  fontFamily: 'DynaPuff',
                  fontSize: 20,
                ),
              ),
              onChanged: (value) {
                _checkFormValidity();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isFormValid ? _addTransaction : null,
              child: const Text(
                'Add Transaction',
                style: TextStyle(
                  fontFamily: 'DynaPuff',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
