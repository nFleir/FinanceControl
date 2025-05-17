import 'package:flutter/material.dart';
import 'capital_widget.dart';
import 'add_capital_screen.dart';
import '../repositories/savings_repository.dart';

class CapitalScreen extends StatefulWidget {
  const CapitalScreen({super.key});

  @override
  State<CapitalScreen> createState() => _CapitalScreenState();
}

class _CapitalScreenState extends State<CapitalScreen> {
  Map<String, dynamic> _mainSavings = {};
  List<Map<String, dynamic>> _userSavings = [];
  final SavingsRepository _savingsRepository = SavingsRepository();

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    final mainSavings = await _savingsRepository.loadMainSavings();
    final userSavings = await _savingsRepository.loadUserSavings();
    setState(() {
      _mainSavings = mainSavings;
      _userSavings = userSavings;
    });
  }

  Future<void> _addNewSavings(Map<String, dynamic> newSavings) async {
    setState(() {
      _userSavings.add(newSavings);
    });
    await _savingsRepository.saveUserSavings(_userSavings);
  }

  Future<void> _editSavings(int index, Map<String, dynamic> updatedSavings) async {
    setState(() {
      if (index == 0) {
        return;
      }
      final userIndex = index - 1;
      _userSavings[userIndex] = {
        'title': updatedSavings['title'],
        'description': updatedSavings['description'],
        'amount': updatedSavings['amount'],
        'targetAmount': updatedSavings['targetAmount'],
        'isMain': _userSavings[userIndex]['isMain'] ?? false,
      };
    });
    await _savingsRepository.saveUserSavings(_userSavings);
  }

  Future<void> _deleteSavings(int index) async {
    if (index == 0) {
      return;
    }
    final userIndex = index - 1;
    setState(() {
      _userSavings.removeAt(userIndex);
    });
    await _savingsRepository.saveUserSavings(_userSavings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Счета'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final newSavings = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCapitalScreen()),
              );
              if (newSavings != null) {
                await _addNewSavings(newSavings);
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _buildSavingsList(context),
      ),
    );
  }

  Widget _buildSavingsList(BuildContext context) {
    if (_mainSavings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final allSavings = [_mainSavings, ..._userSavings];
    return ListView.builder(
      itemCount: allSavings.length,
      itemBuilder: (context, index) {
        final savings = allSavings[index];
        return CapitalCard(
          title: savings['title'],
          amount: savings['amount'].toDouble(),
          targetAmount: savings['targetAmount']?.toDouble(),
          isMain: savings['isMain'] ?? false,
          onTap: () {
            _showBottomMenu(context, index, savings);
          },
        );
      },
    );
  }

  void _showBottomMenu(BuildContext context, int index, Map<String, dynamic> savings) {
    final bool isCompleted = savings['targetAmount'] != null && savings['amount'] >= savings['targetAmount'];
    final double remainingAmount = savings['targetAmount'] != null ? (savings['targetAmount'] - savings['amount']).clamp(0, double.infinity) : 0.0;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  savings['title'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Сбережения: ${savings['amount'].toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Осталось: ${remainingAmount.toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCapitalScreen(
                                  initialSavings: savings,
                                ),
                              ),
                            );
                            if (result != null) {
                              if (result is Map<String, dynamic> && result['delete'] == true && index > 0) {
                                await _deleteSavings(index);
                              } else if (result is Map<String, dynamic>) {
                                await _editSavings(index, result);
                              }
                            }
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (index == 0) ? Colors.grey[300] : Colors.yellow[100],
                            ),
                            child: Icon(
                              Icons.edit,
                              color: (index == 0) ? Colors.grey : Colors.yellow[700],
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Изменить',
                          style: TextStyle(
                            fontSize: 12,
                            color: (index == 0) ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: (index == 0 || isCompleted)
                              ? null
                              : () {
                            Navigator.pop(context);
                            _showAddAmountDialog(context, index, savings, true);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (index == 0 || isCompleted) ? Colors.grey[300] : Colors.green[100],
                            ),
                            child: Icon(
                              Icons.arrow_downward,
                              color: (index == 0 || isCompleted) ? Colors.grey : Colors.green,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Пополнить',
                          style: TextStyle(
                            fontSize: 12,
                            color: (index == 0 || isCompleted) ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: (index == 0 || isCompleted)
                              ? null
                              : () {
                            Navigator.pop(context);
                            _showAddAmountDialog(context, index, savings, false);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (index == 0 || isCompleted) ? Colors.grey[300] : Colors.red[100],
                            ),
                            child: Icon(
                              Icons.arrow_upward,
                              color: (index == 0 || isCompleted) ? Colors.grey : Colors.red,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Списать',
                          style: TextStyle(
                            fontSize: 12,
                            color: (index == 0 || isCompleted) ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddAmountDialog(BuildContext context, int index, Map<String, dynamic> savings, bool isDeposit) {
    final TextEditingController _amountController = TextEditingController();
    final bool isMain = savings['isMain'] ?? false;

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
                    color: isMain ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: isMain ? Colors.white : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          savings['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isMain ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isDeposit ? 'Пополнение' : 'Списание',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
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
                  style: const TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(_amountController.text);
                    if (amount != null && amount > 0) {
                      if (isDeposit) {
                        // Проверка баланса главного счёта
                        if (_mainSavings['amount'] >= amount) {
                          // Проверка, не превышает ли пополнение целевую сумму
                          if (savings['targetAmount'] != null && (savings['amount'] + amount) > savings['targetAmount']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Пополнение превышает целевую сумму')),
                            );
                          } else {
                            savings['amount'] = (savings['amount'] as num) + amount;
                            _mainSavings['amount'] = (_mainSavings['amount'] as num) - amount;
                            await _updateAccount(index, savings);
                            await _savingsRepository.saveMainSavings(_mainSavings);
                            Navigator.pop(context);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Недостаточно средств на главном счёте')),
                          );
                        }
                      } else {
                        if (savings['amount'] >= amount) {
                          savings['amount'] = (savings['amount'] as num) - amount;
                          _mainSavings['amount'] = (_mainSavings['amount'] as num) + amount;
                          await _updateAccount(index, savings);
                          await _savingsRepository.saveMainSavings(_mainSavings);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Недостаточно средств на счёте')),
                          );
                        }
                      }
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

  Future<void> _updateAccount(int index, Map<String, dynamic> updatedSavings) async {
    setState(() {
      if (index == 0) {
        _mainSavings = updatedSavings;
      } else {
        final userIndex = index - 1;
        _userSavings[userIndex] = updatedSavings;
      }
    });
    await _savingsRepository.saveUserSavings(_userSavings);
  }
}


