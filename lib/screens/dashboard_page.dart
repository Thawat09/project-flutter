import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_flutter/helpers/theme_helper.dart';
import 'package:project_flutter/widgets/bottom_navigation.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

  Future<void> _deleteTransaction(
    BuildContext context,
    String transactionId,
  ) async {
    final bool confirmDelete = await _showConfirmDialog(context);
    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Transaction deleted successfully',
                style: TextStyle(
                  fontFamily: 'DynaPuff',
                  fontSize: 16,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to delete transaction',
                style: TextStyle(
                  fontFamily: 'DynaPuff',
                  fontSize: 16,
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text(
              'Dashboard',
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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: user?.uid)
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

            final transactions = snapshot.data!.docs;

            double incomeSum = 0;
            double expenseSum = 0;

            transactions.forEach((transaction) {
              double amount = transaction['amount'];
              String type = transaction['type'];

              if (type == 'income') {
                incomeSum += amount;
              } else if (type == 'expense') {
                expenseSum += amount;
              }
            });

            double totalSum = incomeSum - expenseSum;

            transactions.sort((a, b) {
              Timestamp timestampA = a['timestamp'];
              Timestamp timestampB = b['timestamp'];
              return timestampB.compareTo(timestampA);
            });

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final double amount = transaction['amount'];
                      final String category = transaction['category'];
                      final String type = transaction['type'];
                      final String transactionId = transaction.id;

                      Color amountColor =
                          type == 'income' ? Colors.green : Colors.red;
                      String sign = type == 'income' ? '+' : '-';

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Dismissible(
                          key: Key(transactionId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteTransaction(context, transactionId);
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Row(
                              children: [
                                Text(
                                  '$sign ${amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: amountColor,
                                    fontFamily: 'DynaPuff',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              category,
                              style: const TextStyle(
                                fontFamily: 'DynaPuff',
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: transaction,
                              );
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
                                      arguments: transaction.id,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => _deleteTransaction(
                                    context,
                                    transactionId,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontFamily: 'DynaPuff',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Income:',
                              style: TextStyle(
                                fontFamily: 'DynaPuff',
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${incomeSum.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'DynaPuff',
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Expenses:',
                              style: TextStyle(
                                fontFamily: 'DynaPuff',
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${expenseSum.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'DynaPuff',
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Balance:',
                              style: TextStyle(
                                fontFamily: 'DynaPuff',
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${totalSum.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'DynaPuff',
                                fontSize: 16,
                                color:
                                    totalSum >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: const BottomNavigationWidget(),
      ),
    );
  }
}
