import 'package:flutter/material.dart';

class AddCapitalScreen extends StatefulWidget {
  final Map<String, dynamic>? initialSavings;

  const AddCapitalScreen({super.key, this.initialSavings});

  @override
  State<AddCapitalScreen> createState() => _AddCapitalScreenState();
}

class _AddCapitalScreenState extends State<AddCapitalScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSavings != null) {
      _titleController.text = widget.initialSavings!['title'] ?? '';
      _descriptionController.text = widget.initialSavings!['description'] ?? '';
      _targetAmountController.text = widget.initialSavings!['targetAmount']?.toString() ?? '';
      _amountController.text = widget.initialSavings!['amount']?.toString() ?? '0';

      final amount = widget.initialSavings!['amount']?.toDouble() ?? 0.0;
      final targetAmount = widget.initialSavings!['targetAmount']?.toDouble();
      _isCompleted = targetAmount != null && amount >= targetAmount;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveCapital() {
    final title = _titleController.text;
    final description = _descriptionController.text.isNotEmpty ? _descriptionController.text : null;
    final targetAmount = _targetAmountController.text.isNotEmpty ? double.tryParse(_targetAmountController.text) : null;
    final amount = _amountController.text.isNotEmpty ? double.tryParse(_amountController.text) : 0.0;

    if (title.isNotEmpty && amount != null) {
      final newSavings = {
        'title': title,
        'description': description,
        'amount': amount,
        'targetAmount': targetAmount,
        'isMain': widget.initialSavings?['isMain'] ?? false,
      };
      Navigator.pop(context, newSavings);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название и сумму')),
      );
    }
  }

  void _deleteCapital() {
    Navigator.pop(context, {'delete': true}); // Явный сигнал удаления
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.initialSavings == null ? 'Создание счёта' : 'Изменение счёта',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.white, size: 30),
              onPressed: _isCompleted ? null : _saveCapital,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Блок названия
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Название счёта',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                enabled: !_isCompleted,
              ),
            ),
            const SizedBox(height: 24),

            // Блок "Счёт"
            const Text(
              'Счёт',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Описание',
                labelStyle: TextStyle(
                  color: _isCompleted ? Colors.grey : Colors.black54,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isCompleted ? Colors.grey : Colors.black54,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              enabled: !_isCompleted,
            ),
            const SizedBox(height: 24),

            // Блок "Баланс"
            const Text(
              'Баланс',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Остаток на счёте',
                labelStyle: TextStyle(
                  color: _isCompleted ? Colors.grey : Colors.black54,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isCompleted ? Colors.grey : Colors.black54,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isCompleted,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetAmountController,
              decoration: InputDecoration(
                labelText: 'Цель',
                labelStyle: TextStyle(
                  color: _isCompleted ? Colors.grey : Colors.black54,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isCompleted ? Colors.grey : Colors.black54,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isCompleted,
            ),
            const SizedBox(height: 24),

            // Кнопка "Удалить счёт" (только при изменении)
            if (widget.initialSavings != null)
              Center(
                child: TextButton.icon(
                  onPressed: _deleteCapital,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 24,
                  ),
                  label: const Text(
                    'Удалить счёт',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}