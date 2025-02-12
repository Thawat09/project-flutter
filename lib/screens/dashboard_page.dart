import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_flutter/widgets/bottom_navigation.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _deleteTransaction(String transactionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      print("Error deleting transaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
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
                fontSize: 20,
              ),
            ));
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final double amount = transaction['amount'];
              final String category = transaction['category'];
              final String type = transaction['type'];
              final String transactionId = transaction.id;

              Color amountColor = type == 'income' ? Colors.green : Colors.red;
              String sign = type == 'income' ? '+' : '-';

              return Dismissible(
                key: Key(transactionId),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteTransaction(transactionId);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Transaction deleted'),
                  ));
                },
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
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        '$sign ${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: amountColor,
                          fontFamily: 'DynaPuff',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    category,
                    style: const TextStyle(
                      fontFamily: 'DynaPuff',
                      fontSize: 20,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/edit',
                      arguments: transaction.id,
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteTransaction(transactionId);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Transaction deleted'),
                      ));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
