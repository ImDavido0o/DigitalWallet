import 'dart:ui';
import 'package:digital_wallet/utils/card_cvv_formatter.dart';
import 'package:digital_wallet/widgets/bank_card.dart';
import 'package:flutter/material.dart';
import 'package:digital_wallet/widgets/add_card.dart';
import 'package:digital_wallet/utils/card_number_formatter.dart';
import 'package:flutter/services.dart';

final myCards = ['Standard', 'Business', 'Savings'];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool showMenu = false;

  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.99);
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
          showMenu = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _balanceController.dispose();
    _holderNameController.dispose();
    _expDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAddCard = _currentPage == myCards.length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 4,
                children: [
                  Icon(isAddCard ? Icons.add_card : Icons.wallet, size: 24),
                  Text(
                    isAddCard ? 'Add Card' : 'Digital Wallet',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 20),
              SizedBox(
                height: 221,
                child: PageView.builder(
                  clipBehavior: Clip.none,
                  controller: _pageController,
                  itemCount: myCards.length + 1,
                  itemBuilder: (context, index) {
                    final isAddCardItem = index == myCards.length;

                    if (isAddCardItem) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: AddCard(
                          onTap: () {
                            setState(() {
                              showMenu = !showMenu;
                            });
                          },
                          showMenu: showMenu,
                          cardName: _cardNameController.text,
                          cardNumber: _cardNumberController.text,
                          balance: _balanceController.text,
                          holderName: _holderNameController.text,
                          cvv: _cvvController.text,
                          expDate: _expDateController.text,
                        ),
                      );
                    }

                    final card = myCards[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BankCard(
                        cardName: card,
                        cardNumber: '12',
                        balance: '3,922.40',
                        holderName: 'James Carter',
                        expDate: '08/28',
                        cvv: "***",
                      ),
                    );
                  },
                ),
              ),

              if (showMenu) ...[
                const SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: _cardNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Card name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: _cardNumberController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CardNumberFormatter(),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'Card number',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: _balanceController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Balance'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: _holderNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Holder name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: _expDateController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Exp. Date'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: _cvvController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CardCvvFormatter(),
                      ],
                      decoration: const InputDecoration(hintText: 'CVV'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // tu neskôr pridáš logiku na uloženie karty
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
