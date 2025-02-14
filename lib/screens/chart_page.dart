import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/helpers/theme_helper.dart'; // ไฟล์ helper สำหรับ Theme

class ChartPage extends StatefulWidget {
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
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late double incomeSum;
  late double expenseSum;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _calculateSums();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    bool storedTheme = await loadThemeFromLocalStorage();
    setState(() {
      _isDarkMode = storedTheme;
    });
  }

  void _calculateSums() {
    incomeSum = 0;
    expenseSum = 0;
    for (var transaction in widget.transactions) {
      double amount = transaction['amount'];
      String type = transaction['type'];
      if (type == 'income') {
        incomeSum += amount;
      } else if (type == 'expense') {
        expenseSum += amount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chart View',
            style: TextStyle(
                fontFamily: 'DynaPuff',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: widget.transactions.isEmpty
            ? const Center(
                child: Text(
                  'No data available for chart.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDateRange(context),
                        const SizedBox(height: 16),
                        _buildSummaryTable(),
                        const SizedBox(height: 20),
                        _buildPieChart(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDateRange(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'From: ${DateFormat('MMM dd, yyyy hh:mm a').format(widget.startDate)}\nTo: ${DateFormat('MMM dd, yyyy hh:mm a').format(widget.endDate)}',
        style: const TextStyle(
          fontFamily: 'DynaPuff',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Table(
      border: TableBorder.all(
          color: Colors.black38, style: BorderStyle.solid, width: 1),
      children: [
        TableRow(
          children: [
            _buildTableCell('Income', Colors.green),
            _buildTableCell('\$${incomeSum.toStringAsFixed(2)}', Colors.green),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell('Expenses', Colors.red),
            _buildTableCell(
                '\$-${expenseSum.abs().toStringAsFixed(2)}', Colors.red),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell('Total', Colors.blue),
            _buildTableCell('\$${(incomeSum - expenseSum).toStringAsFixed(2)}',
                Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DynaPuff',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: incomeSum,
              title: 'Income\n${incomeSum.toStringAsFixed(2)}',
              color: Colors.green,
              radius: 100,
              titleStyle: const TextStyle(
                fontFamily: 'DynaPuff',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: expenseSum,
              title: 'Expenses\n-${expenseSum.toStringAsFixed(2)}',
              color: Colors.red,
              radius: 100,
              titleStyle: const TextStyle(
                fontFamily: 'DynaPuff',
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
    );
  }
}
