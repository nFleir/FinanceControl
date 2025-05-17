import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TransactionsRepository {
  final String _localFilePath = 'user_transactions.json';

  Future<Map<String, dynamic>> loadTransactions() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_localFilePath');
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }

      final initialData = {
        'expenses': [
          {'name': 'Продукты', 'amount': 0, 'color': '0xFF2196F3'},
          {'name': 'Кафе', 'amount': 0, 'color': '0xFF3F51B5'},
          {'name': 'Досуг', 'amount': 0, 'color': '0xFFE91E63'},
          {'name': 'Транспорт', 'amount': 0, 'color': '0xFFFF9800'},
          {'name': 'Здоровье', 'amount': 0, 'color': '0xFF4CAF50'},
          {'name': 'Подарки', 'amount': 0, 'color': '0xFFF44336'},
          {'name': 'Семья', 'amount': 0, 'color': '0xFF9C27B0'},
          {'name': 'Покупки', 'amount': 0, 'color': '0xFF795548'},
        ],
        'incomes': [
          {'name': 'Зарплата', 'amount': 0, 'color': '0xFF4CAF50'},
        ],
      };
      await file.writeAsString(jsonEncode(initialData));
      return initialData;
    } catch (e) {
      print('Error loading transactions: $e');
      return {'expenses': [], 'incomes': []};
    }
  }

  Future<void> saveTransactions(Map<String, dynamic> transactions) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_localFilePath');
      await file.writeAsString(jsonEncode(transactions));
    } catch (e) {
      print('Error saving transactions: $e');
    }
  }
}