import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/widgets/bottom_navigation.dart';

class EditPage extends StatefulWidget {
  final String itemId;

  const EditPage({super.key, required this.itemId});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
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
    _loadThemeFromFirestore();
    _loadTransactionData();
  }

  Future<void> _loadThemeFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _isDarkMode = userDoc['isDarkMode'] ?? false;
        });
      }
    }
  }

  Future<void> _loadTransactionData() async {
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot transactionDoc = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.itemId)
          .get();

      if (transactionDoc.exists) {
        var data = transactionDoc.data() as Map<String, dynamic>;
        setState(() {
          _amountController.text = data['amount'].toString();
          _categoryController.text = data['category'];
          _selectedDate = (data['timestamp'] as Timestamp).toDate();
          _transactionType = data['type'];
          _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load transaction data. Please try again.',
            style: TextStyle(
              fontFamily: 'DynaPuff',
              fontSize: 16,
            ),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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

  Future<void> _updateTransaction() async {
    setState(() => _isLoading = true);
    try {
      DateTime transactionDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.itemId)
          .update({
        'amount': double.parse(_amountController.text),
        'category': _categoryController.text,
        'timestamp': Timestamp.fromDate(transactionDateTime),
        'type': _transactionType,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Transaction updated successfully!',
              style: TextStyle(
                fontFamily: 'DynaPuff',
                fontSize: 16,
              ),
            ),
          ),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to update transaction. Please try again.',
              style: TextStyle(
                fontFamily: 'DynaPuff',
                fontSize: 16,
              ),
            ),
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
              'Edit Item',
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                        labelStyle:
                            TextStyle(fontFamily: 'DynaPuff', fontSize: 16),
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
                              text: DateFormat('yyyy-MM-dd')
                                  .format(_selectedDate),
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
                      onPressed: _isFormValid ? _updateTransaction : null,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Update Transaction',
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
