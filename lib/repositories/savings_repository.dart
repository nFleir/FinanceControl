import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SavingsRepository {
  final String _userSavingsFilePath = 'user_savings.json';
  final String _mainSavingsFilePath = 'user_main_savings.json';

  // Загрузка главного счета
  Future<Map<String, dynamic>> loadMainSavings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_mainSavingsFilePath');
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      // Если файла нет, возвращаем начальный главный счет
      return {
        'title': 'Главный',
        'amount': 0,
        'isMain': true,
      };
    } catch (e) {
      print('Error loading main savings: $e');
      return {
        'title': 'Главный',
        'amount': 0,
        'isMain': true,
      };
    }
  }

  // Сохранение главного счета
  Future<void> saveMainSavings(Map<String, dynamic> mainSavings) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_mainSavingsFilePath');
      await file.writeAsString(jsonEncode(mainSavings));
    } catch (e) {
      print('Error saving main savings: $e');
    }
  }

  // Загрузка пользовательских счетов
  Future<List<Map<String, dynamic>>> loadUserSavings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_userSavingsFilePath');
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        return (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error loading user savings: $e');
      return [];
    }
  }

  // Сохранение пользовательских счетов
  Future<void> saveUserSavings(List<Map<String, dynamic>> savings) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_userSavingsFilePath');
      await file.writeAsString(jsonEncode(savings));
    } catch (e) {
      print('Error saving user savings: $e');
    }
  }
}