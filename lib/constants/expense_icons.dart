import 'package:flutter/material.dart';

class ExpenseIcons{
  static IconData getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Продукты':
        return Icons.shopping_cart;
      case 'Кафе':
        return Icons.local_dining;
      case 'Досуг':
        return Icons.movie;
      case 'Транспорт':
        return Icons.directions_bus;
      case 'Здоровье':
        return Icons.local_hospital;
      case 'Подарки':
        return Icons.card_giftcard;
      case 'Семья':
        return Icons.family_restroom;
      case 'Покупки':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}