
import 'package:flutter/material.dart';

class CapitalCard extends StatelessWidget {
  final String title;
  final double amount;
  final double? targetAmount;
  final bool isMain;
  final VoidCallback onTap;

  const CapitalCard({
    super.key,
    required this.title,
    required this.amount,
    this.targetAmount,
    required this.isMain,
    required this.onTap,
  });

  bool get isCompleted => targetAmount != null && amount >= targetAmount!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isMain ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isMain ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: isMain ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (targetAmount != null)
                      Text(
                        'Цель: ${targetAmount!.toStringAsFixed(2)} ₽',
                        style: TextStyle(
                          fontSize: 14,
                          color: isCompleted ? Colors.green[700] : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (isCompleted)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              )
            else
              Text(
                '${amount.toStringAsFixed(2)} ₽',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4CAF50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}