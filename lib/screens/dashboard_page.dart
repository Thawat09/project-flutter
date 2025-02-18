import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_flutter/helpers/theme_helper.dart';
import 'package:project_flutter/widgets/bottom_navigation.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isDarkMode = false;
  bool _isSummaryVisible = true;
  bool _isFilterVisible = false;
  DateTime _startDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    1,
  ).subtract(Duration(milliseconds: 1));
  List<DocumentSnapshot> transactions = [];

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

  Future<void> _deleteTransaction(
      BuildContext context, String transactionId) async {
    final bool confirmDelete = await _showConfirmDialog(context);
    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _applyFilter();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete transaction'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _applyFilter() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DateTime startDateUtc = _startDate.add(Duration(hours: 7)).toUtc();
      DateTime endDateUtc = _endDate.add(Duration(hours: 7)).toUtc();
      Timestamp startTimestamp = Timestamp.fromDate(startDateUtc);
      Timestamp endTimestamp = Timestamp.fromDate(endDateUtc);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .get();

      setState(() {
        transactions = snapshot.docs;
      });
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: StackTrace.current,
        library: 'app',
        context: ErrorDescription('Error applying filter'),
      ));
    }
  }

  Future<void> _applyFilterAndNavigateToChart(BuildContext context) async {
    await _applyFilter();

    Navigator.pushNamed(
      context,
      '/chart',
      arguments: {
        'transactions': transactions,
        'startDate': _startDate,
        'endDate': _endDate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(
              fontFamily: 'DynaPuff',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: user?.uid)
              .where('timestamp',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
              .where('timestamp',
                  isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No transactions yet.',
                  style: TextStyle(
                    fontFamily: 'DynaPuff',
                    fontSize: 16,
                  ),
                ),
              );
            }

            transactions = snapshot.data!.docs;

            double incomeSum = 0;
            double expenseSum = 0;

            for (var transaction in transactions) {
              double amount = (transaction['amount'] as num).toDouble();
              String type = transaction['type'];

              if (type == 'income') {
                incomeSum += amount;
              } else if (type == 'expense') {
                expenseSum += amount;
              }
            }

            transactions.sort((a, b) {
              Timestamp timestampA = a['timestamp'];
              Timestamp timestampB = b['timestamp'];
              return timestampB.compareTo(timestampA);
            });

            return Column(
              children: [
                _buildFilterSection(),
                _buildTransactionList(transactions),
                _buildSummarySection(incomeSum, expenseSum),
              ],
            );
          },
        ),
        bottomNavigationBar: const BottomNavigationWidget(),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isFilterVisible = !_isFilterVisible;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Date',
                    style: TextStyle(
                      fontFamily: 'DynaPuff',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    _isFilterVisible ? Icons.expand_less : Icons.expand_more,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            ),
            if (_isFilterVisible) ...[
              const SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateFilterRow(
                          'Start Date',
                          _startDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDateFilterRow(
                          'End Date',
                          _endDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _applyFilter,
                        child: const Text(
                          'Apply Filter',
                          style: TextStyle(
                            fontFamily: 'DynaPuff',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _applyFilterAndNavigateToChart(context);
                        },
                        child: const Text(
                          'View Chart',
                          style: TextStyle(
                            fontFamily: 'DynaPuff',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterRow(String label, DateTime date) {
    return TextFormField(
      controller:
          TextEditingController(text: DateFormat.yMd().add_jm().format(date)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'DynaPuff',
          fontSize: 16,
        ),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
        hintText: 'Select Date & Time',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null && mounted) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(date),
          );
          if (pickedTime != null) {
            setState(() {
              if (label == 'Start Date') {
                _startDate = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              } else if (label == 'End Date') {
                _endDate = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              }
            });
          }
        }
      },
    );
  }

  Widget _buildTransactionList(List<DocumentSnapshot> transactions) {
    return Expanded(
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final double amount = (transaction['amount'] as num).toDouble();
          final String category = transaction['category'];
          final String type = transaction['type'];
          final String transactionId = transaction.id;

          Color amountColor = type == 'income' ? Colors.green : Colors.red;
          String sign = type == 'income' ? '+' : '-';

          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                '$sign${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: amountColor,
                  fontFamily: 'DynaPuff',
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                category,
                style: const TextStyle(
                  fontFamily: 'DynaPuff',
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/detail', arguments: transaction);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.yellow[700],
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/edit',
                        arguments: transactionId,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTransaction(context, transactionId),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(double incomeSum, double expenseSum) {
    double totalSum = incomeSum - expenseSum;
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isSummaryVisible = !_isSummaryVisible;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Summary',
                      style: TextStyle(
                        fontFamily: 'DynaPuff',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  Icon(
                      _isSummaryVisible ? Icons.expand_less : Icons.expand_more,
                      color: Colors.deepPurple),
                ],
              ),
            ),
            if (_isSummaryVisible) ...[
              _buildSummaryRow('Total Income:', incomeSum, Colors.green),
              _buildSummaryRow('Total Expenses:', expenseSum, Colors.red),
              _buildSummaryRow('Net Balance:', totalSum,
                  totalSum >= 0 ? Colors.green : Colors.red),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DynaPuff',
            fontSize: 16,
          ),
        ),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            color: color,
            fontFamily: 'DynaPuff',
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
