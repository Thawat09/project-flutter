import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> transaction;

  const DetailPage({super.key, required this.transaction});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isDarkMode = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadThemeFromFirestore();
  }

  Future<void> _loadThemeFromFirestore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _isDarkMode = userDoc['isDarkMode'] ?? false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.transaction.data() as Map<String, dynamic>;
    final amount = data['amount'] ?? 0;
    final category = data['category'] ?? 'Unknown';
    final type = data['type'] ?? 'Unknown';
    final Timestamp? timestamp = data['timestamp'];
    String date = 'N/A';

    if (timestamp != null) {
      final DateTime dateTime = timestamp.toDate();
      date = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }

    Color amountColor = type == 'income' ? Colors.green : Colors.red;
    String sign = type == 'income' ? '+' : '-';
    String displayAmount = '$sign${amount.abs()}';

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text(
              'Transaction Details',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Amount:', displayAmount, amountColor),
              const SizedBox(height: 10),
              _buildDetailRow('Category:', category, Colors.blue),
              const SizedBox(height: 10),
              _buildDetailRow('Type:', type, Colors.orange),
              const SizedBox(height: 10),
              _buildDetailRow('Date:', date, Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              '$label ',
              style: TextStyle(
                fontFamily: 'DynaPuff',
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'DynaPuff',
                  fontSize: 16,
                  color: valueColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
