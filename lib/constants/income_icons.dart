import 'package:flutter/material.dart';

class IncomeIcons{
  static IconData getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Зарплата':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }
}