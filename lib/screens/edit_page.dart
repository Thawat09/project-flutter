import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/helpers/theme_helper.dart';
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
    _loadTheme();
    _loadTransactionData();
  }

  Future<void> _loadTheme() async {
    bool storedTheme = await loadThemeFromLocalStorage();
    setState(() {
      _isDarkMode = storedTheme;
    });
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
          _selectedDate = (data['timestamp'] as Timestamp).toDate().toUtc();
          _transactionType = data['type'];
          _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load transaction data. Please try again.',
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
      ).toUtc();

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
            backgroundColor: Colors.green,
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
                    AnimatedOpacity(
                      opacity: _isLoading ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: TextField(
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
                    ),
                    const SizedBox(height: 10),
                    AnimatedOpacity(
                      opacity: _isLoading ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: TextField(
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
                    ),
                    const SizedBox(height: 40),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_transactionType),
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
                            child:
                                Text(value == 'income' ? 'Income' : 'Expense'),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.deepPurple,
                                ),
                              ),
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                                style: const TextStyle(
                                  fontFamily: 'DynaPuff',
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: _selectTime,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.deepPurple,
                                ),
                              ),
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(
                                  fontFamily: 'DynaPuff',
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: _isLoading ? 0.95 : 1.0,
                      child: ElevatedButton(
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
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: const BottomNavigationWidget(),
      ),
    );
  }
}
