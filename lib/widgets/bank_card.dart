import 'package:flutter/material.dart';

class BankCard extends StatefulWidget {
  final String cardName;
  final String cardNumber;
  final String balance;
  final String holderName;
  final String expDate;
  final String cvv;

  const BankCard({
    super.key,
    required this.cardName,
    required this.cardNumber,
    required this.balance,
    required this.holderName,
    required this.expDate,
    required this.cvv,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardName': cardName,
      'cardNumber': cardNumber,
      'balance': balance,
      'holderName': holderName,
      'expDate': expDate,
      'cvv': cvv,
    };
  }

  factory BankCard.fromJson(Map<String, dynamic> json) {
    return BankCard(
      cardName: json['cardName'],
      cardNumber: json['cardNumber'],
      balance: json['balance'],
      holderName: json['holderName'],
      expDate: json['expDate'],
      cvv: json['cvv'],
    );
  }

  @override
  State<BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<BankCard> {
  bool _showCardNumber = false;
  bool _showCvv = false;

  String maskCardNumber(String number) {
    final digitsOnly = number.replaceAll(' ', '');
    if (digitsOnly.length < 4) return number;

    final lastFour = digitsOnly.substring(digitsOnly.length - 4);
    return '**** **** **** $lastFour';
  }

  String maskCvv(String number) {
    final digitsOnly = number.replaceAll(' ', '');
    final masked = "*" * digitsOnly.length;
    return masked;
  }

  @override
  Widget build(BuildContext context) {
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
                widget.cardName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 4),
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _showCardNumber = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _showCardNumber = false;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _showCardNumber = false;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      _showCardNumber ? widget.cardNumber : maskCardNumber(widget.cardNumber),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _showCardNumber ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Balance",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.euro, size: 32, fontWeight: FontWeight.bold),
                  Text(
                    widget.balance,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    widget.holderName,
                    style: TextStyle(
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
                      Text(
                        "CVV",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            _showCvv = true;
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            _showCvv = false;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            _showCvv = false;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [

                            Text(
                              _showCvv ? widget.cvv : maskCvv(widget.cvv),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              _showCvv ? Icons.visibility_off : Icons.visibility,
                              size: 16,
                              color: Colors.white70,

                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Exp. Date",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        widget.expDate,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
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
