import 'package:flutter/material.dart';

class AddCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool showMenu;
  final String cardName;
  final String cardNumber;
  final String balance;
  final String holderName;
  final String cvv;
  final String expDate;

  const AddCard({
    super.key,
    required this.onTap,
    this.showMenu = false,
    this.cardName = '',
    this.cardNumber = '',
    this.balance = '',
    this.holderName = '',
    this.cvv = '',
    this.expDate = '',
  });

  String maskCardNumber(String number) {
    final digitsOnly = number.replaceAll(' ', '');
    if (digitsOnly.length < 4) return number;

    final maskedLength = digitsOnly.length - 4;
    final masked = '*' * maskedLength;
    final lastFour = digitsOnly.substring(digitsOnly.length - 4);
    final combined = masked + lastFour;

    final buffer = StringBuffer();

    for (int i = 0; i < combined.length; i++) {
      buffer.write(combined[i]);
      if ((i + 1) % 4 == 0 && i + 1 != combined.length) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  String maskCvv(String number) {
    final digitsOnly = number.replaceAll(' ', '');
    final masked = "*" * digitsOnly.length;
    return masked;
  }
  
  @override
  Widget build(BuildContext context) {
    if (!showMenu) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 6),
        ),
        padding: const EdgeInsets.all(22),
        child: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardName,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                maskCardNumber(cardNumber),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Balance",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Row(
                children: [
                  const Icon(Icons.euro, size: 32, color: Colors.white),
                  Text(
                    "0.00",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Name",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    holderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 32,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "CVV",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        maskCvv(cvv),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Exp. Date",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        expDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
