import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_category_screen.dart';
import '../constants/income_icons.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/savings_repository.dart';

class IncomesScreen extends StatefulWidget {
  const IncomesScreen({super.key});

  @override
  State<IncomesScreen> createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  List<Map<String, dynamic>> _categories = [];
  final TransactionsRepository _transactionsRepository = TransactionsRepository();
  final SavingsRepository _savingsRepository = SavingsRepository();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didUpdateWidget(IncomesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final transactions = await _transactionsRepository.loadTransactions();
    setState(() {
      _categories = List<Map<String, dynamic>>.from(transactions['incomes']);
      _categories = _categories.map((category) {
        return {
          'name': category['name'],
          'amount': category['amount'],
          'color': Color(int.parse(category['color'])),
        };
      }).toList();
    });
  }

  Future<void> _addNewCategory(Map<String, dynamic> newCategory) async {
    setState(() {
      _categories.add(newCategory);
    });
    await _saveCategories();
    await _loadCategories();
  }

  Future<void> _updateCategoryAmount(int index, double amount) async {
    setState(() {
      _categories[index]['amount'] = (_categories[index]['amount'] as num) + amount;
    });

    final mainSavings = await _savingsRepository.loadMainSavings();
    mainSavings['amount'] = (mainSavings['amount'] as num) + amount;
    await _savingsRepository.saveMainSavings(mainSavings);

    await _saveCategories();
  }

  Future<void> _saveCategories() async {
    final transactions = await _transactionsRepository.loadTransactions();
    transactions['incomes'] = _categories.map((category) {
      return {
        'name': category['name'],
        'amount': category['amount'],
        'color': '0x${category['color'].value.toRadixString(16)}',
      };
    }).toList();
    await _transactionsRepository.saveTransactions(transactions);
  }

  double _calculateTotalIncomes() {
    return _categories.fold(0, (sum, category) => sum + category['amount']);
  }

  void _showAddAmountDialog(int index) {
    final category = _categories[index];
    final TextEditingController _amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: category['color'],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IncomeIcons.getCategoryIcon(category['name']),
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Доход',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0 ₽',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(_amountController.text);
                    if (amount != null && amount > 0) {
                      await _updateCategoryAmount(index, amount);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Введите корректную сумму')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16.0),
                    backgroundColor: Colors.green,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Доходы ${_calculateTotalIncomes().toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () async {
                    final newCategory = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddCategoryScreen(isExpense: true)),
                    );
                    if (newCategory != null) {
                      await _addNewCategory(newCategory);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 64),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: _categories
                          .asMap()
                          .entries
                          .map((entry) {
                        final category = entry.value;
                        return PieChartSectionData(
                          color: category['color'],
                          value: category['amount'].toDouble(),
                          title: '',
                          radius: 50,
                        );
                      })
                          .toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 100,
                    ),
                  ),
                  Text(
                    'Доходы\n${_calculateTotalIncomes().toStringAsFixed(2)} ₽',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 64),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              padding: const EdgeInsets.all(16.0),
              children: _categories
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final category = entry.value;
                return GestureDetector(
                  onTap: () => _showAddAmountDialog(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: category['color'].withOpacity(0.2),
                        child: Icon(
                          IncomeIcons.getCategoryIcon(category['name']),
                          color: category['color'],
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          category['name'],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        '${category['amount'].toStringAsFixed(2)} ₽',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}