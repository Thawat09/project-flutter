import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartPage extends StatelessWidget {
  final List<DocumentSnapshot> transactions;
  final DateTime startDate;
  final DateTime endDate;

  const ChartPage({
    Key? key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double incomeSum = 0;
    double expenseSum = 0;

    for (var transaction in transactions) {
      double amount = transaction['amount'];
      String type = transaction['type'];

      if (type == 'income') {
        incomeSum += amount;
      } else if (type == 'expense') {
        expenseSum += amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chart View',
          style: TextStyle(
            fontFamily: 'DynaPuff',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: (transactions.isEmpty)
          ? const Center(
              child: Text(
                'No data available for chart.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Display the selected date range
                      Text(
                        'From: ${startDate.toLocal()} To: ${endDate.toLocal()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Income and Expenses Text
                      Text(
                        'Income: \$${incomeSum.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Expenses: \$${expenseSum.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // PieChart
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: incomeSum,
                                title:
                                    'Income\n${incomeSum.toStringAsFixed(2)}',
                                color: Colors.green,
                                radius: 100,
                                titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: expenseSum,
                                title:
                                    'Expenses\n${expenseSum.toStringAsFixed(2)}',
                                color: Colors.red,
                                radius: 100,
                                titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                            centerSpaceRadius: 50,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
