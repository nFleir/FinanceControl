import 'package:flutter/material.dart';
import 'expense_screen.dart';
import 'income_screen.dart';
import 'capital_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Контроль личных финансов',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Opacity(
          opacity: 0.1,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.blue[700],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Накопления'),
            Tab(text: 'Расходы'),
            Tab(text: 'Доходы'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CapitalScreen(),
          ExpensesScreen(),
          IncomesScreen(),
        ],
      ),
    );
  }
}