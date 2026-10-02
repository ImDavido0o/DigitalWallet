import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransfersCard extends StatelessWidget {
  final String name;
  final double amount;
  final double balance;
  final bool plus;
  final DateTime date;

  const TransfersCard({
    super.key,
    required this.name,
    required this.amount,
    required this.balance,
    required this.plus,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = plus ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF121212),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    DateFormat('HH:mm • d MMMM yyyy').format(date),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    plus
                        ? Icons.add_rounded
                        : Icons.remove_rounded,
                    color: amountColor,
                    size: 16,
                  ),

                  Text(
                    amount.toStringAsFixed(2),
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 3),

                  Icon(
                    Icons.euro,
                    color: amountColor,
                    size: 16,
                  ),
                ],
              ),

              Row(
                children: [
                  const Icon(
                    Icons.euro,
                    color: Colors.white70,
                    size: 12,
                  ),

                  Text(
                    balance.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
