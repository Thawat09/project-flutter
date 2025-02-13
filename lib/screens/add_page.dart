import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/helpers/theme_helper.dart';
import 'package:project_flutter/widgets/bottom_navigation.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _transactionType = 'income';
  bool _isAmountValid = false;
  bool _isCategoryValid = false;
  bool _isFormValid = false;
  bool _isLoading = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    bool storedTheme = await loadThemeFromLocalStorage();
    setState(() {
      _isDarkMode = storedTheme;
    });
  }

  void _checkFormValidity() {
    setState(() {
      _isAmountValid = _amountController.text.isNotEmpty &&
          double.tryParse(_amountController.text) != null;
      _isCategoryValid = _categoryController.text.isNotEmpty;
      _isFormValid = _isAmountValid && _isCategoryValid;
    });
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _addTransaction() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DateTime transactionDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ).toUtc();

        await FirebaseFirestore.instance.collection('transactions').add({
          'amount': double.parse(_amountController.text),
          'category': _categoryController.text,
          'userId': user.uid,
          'timestamp': Timestamp.fromDate(transactionDateTime),
          'type': _transactionType,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Transaction added successfully!',
                style: TextStyle(
                  fontFamily: 'DynaPuff',
                  fontSize: 16,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to add transaction. Please try again.',
              style: TextStyle(
                fontFamily: 'DynaPuff',
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text(
              'Add Item',
              style: TextStyle(
                fontFamily: 'DynaPuff',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
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
                    fontSize: 16,
                  ),
                ),
                onChanged: (value) => _checkFormValidity(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(
                    fontFamily: 'DynaPuff',
                    fontSize: 16,
                  ),
                ),
                onChanged: (value) => _checkFormValidity(),
              ),
              const SizedBox(height: 40),
              DropdownButtonFormField<String>(
                value: _transactionType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  labelStyle: TextStyle(
                    fontFamily: 'DynaPuff',
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _transactionType = newValue;
                  });
                },
                items: <String>['income', 'expense']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'income' ? 'Income' : 'Expense'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        labelStyle: TextStyle(
                          fontFamily: 'DynaPuff',
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null && mounted) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        labelStyle: TextStyle(
                          fontFamily: 'DynaPuff',
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: _selectedTime.format(context),
                      ),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isFormValid ? _addTransaction : null,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Add Transaction',
                        style: TextStyle(
                          fontFamily: 'DynaPuff',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigationWidget(),
      ),
    );
  }
}
