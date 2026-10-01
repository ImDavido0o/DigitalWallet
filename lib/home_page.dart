import 'dart:math';
import 'dart:ui';

import 'package:digital_wallet/widgets/send_page.dart';
import 'package:digital_wallet/widgets/transfers_card.dart';
import 'package:intl/intl.dart';

import 'package:digital_wallet/utils/card_cvv_formatter.dart';
import 'package:digital_wallet/utils/card_expdate_formatter.dart';
import 'package:digital_wallet/widgets/bank_card.dart';
import 'package:digital_wallet/widgets/tyled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:digital_wallet/widgets/add_card.dart';
import 'package:digital_wallet/utils/card_number_formatter.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:digital_wallet/widgets/action_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BankCard> myCards = [];

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = myCards.map((card) => card.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString('saved_cards', jsonString);
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('saved_cards');

    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      setState(() {
        myCards = jsonList.map((json) => BankCard.fromJson(json)).toList();
      });
    }
  }

  late final PageController _pageController;
  int _currentPage = 0;
  bool showMenu = false;
  bool _showCvv = false;

  bool showSendPage = false;

  // test
  final now = DateTime.now();

  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCards();
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

  bool canAddCard() {
    return _cardNameController.text.isNotEmpty &&
        _cardNumberController.text.length >= 19 &&
        _holderNameController.text.isNotEmpty &&
        _expDateController.text.length >= 5 &&
        _cvvController.text.length >= 3;
  }

  String generateRandomBalance({int min = 100, int max = 5000}) {
    final random = Random();
    final euros = min + random.nextInt(max - min);
    final cents = random.nextInt(100);

    return '$euros.${cents.toString().padLeft(2, '0')}';
  }

  String setTitle(bool b, bool isAddCard) {
    String title = isAddCard ? 'Add Card' : 'Digital Wallet';
    if (b) {
      title = "Send";
    }

    return title;
  }

  IconData setIcon(bool b, bool isAddCard) {
    IconData icon = isAddCard ? Icons.add_card : Icons.wallet;
    if (b) {
      icon = Icons.arrow_upward_rounded;
    }

    return icon;
  }

  @override
  Widget build(BuildContext context) {
    final isAddCard = _currentPage == myCards.length;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 4,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: [
                          Icon(setIcon(showSendPage, isAddCard), size: 24),
                          Text(
                            setTitle(showSendPage, isAddCard),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          setState(() {
                            showMenu = false;
                          });
                        },
                        child: Icon(
                          showMenu ? Icons.close_rounded : Icons.settings,
                          size: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    height: 221,
                    child: PageView.builder(
                      clipBehavior: Clip.none,
                      controller: _pageController,
                      itemCount: showSendPage
                          ? myCards.length
                          : myCards.length + 1,
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
                            cardName: card.cardName,
                            cardNumber: card.cardNumber,
                            balance: card.balance,
                            holderName: card.holderName,
                            expDate: card.expDate,
                            cvv: card.cvv,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      showSendPage ? myCards.length : myCards.length + 1,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.blue
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  if (!isAddCard && !showSendPage)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ActionButton(
                              icon: Icons.arrow_upward_rounded,
                              label: 'Send',
                              onTap: () {
                                setState(() {
                                  showSendPage = !showSendPage;
                                });
                              },
                            ),
                            ActionButton(
                              icon: Icons.arrow_downward_rounded,
                              label: 'Request',
                              onTap: () {
                                // logika
                              },
                            ),
                            ActionButton(
                              icon: Icons.add_rounded,
                              label: 'Top Up',
                              onTap: () {
                                // logika
                              },
                            ),
                            ActionButton(
                              icon: Icons.more_horiz_rounded,
                              label: 'More',
                              onTap: () {
                                // logika
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Recent Transfers",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "View all",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                spacing: 8,
                                children: [
                                  TransfersCard(
                                    name: 'George Miler',
                                    amount: 1000,
                                    balance: 3187.23,
                                    plus: true,
                                    date: DateTime.now(),
                                  ),
                                  TransfersCard(
                                    name: 'George Miler',
                                    amount: 150,
                                    balance: 3037.23,
                                    plus: false,
                                    date: DateTime.now(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  if (showSendPage)
                    SendPage(
                      onExit: () {
                        setState(() {
                          showSendPage = false;
                        });
                      },
                    ),

                  if (showMenu) ...[
                    SizedBox(height: 30),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StyledTextField(
                          prefixIcon: Icon(Icons.label_outline),
                          controller: _cardNameController,
                          hintText: 'Card name',
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 8),
                        StyledTextField(
                          prefixIcon: Icon(Icons.credit_card),
                          controller: _cardNumberController,
                          hintText: 'Card number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CardNumberFormatter(),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 8),
                        StyledTextField(
                          prefixIcon: Icon(Icons.person),
                          controller: _holderNameController,
                          hintText: 'Holder Name',
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: StyledTextField(
                                prefixIcon: Icon(Icons.calendar_month),
                                controller: _expDateController,
                                keyboardType: TextInputType.number,
                                hintText: 'Exp. Date',
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CardExpdateFormatter(),
                                ],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: StyledTextField(
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: _cvvController.text.isNotEmpty
                                    ? GestureDetector(
                                        onLongPressStart: (_) {
                                          setState(() {
                                            _showCvv = true;
                                          });
                                        },
                                        onLongPressEnd: (_) {
                                          setState(() {
                                            _showCvv = false;
                                          });
                                        },
                                        child: Icon(
                                          _showCvv
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white70,
                                        ),
                                      )
                                    : null,
                                controller: _cvvController,
                                hintText: 'CVV',
                                keyboardType: TextInputType.number,
                                obscureText: !_showCvv,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CardCvvFormatter(),
                                ],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAddCard()
                                ? Colors.blue
                                : Colors.blue.withOpacity(0.2),
                            foregroundColor: canAddCard()
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            overlayColor: canAddCard()
                                ? Colors.white
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (canAddCard()) {
                              setState(() {
                                myCards.add(
                                  BankCard(
                                    cardName: _cardNameController.text,
                                    cardNumber: _cardNumberController.text,
                                    balance: generateRandomBalance(),
                                    holderName: _holderNameController.text,
                                    expDate: _expDateController.text,
                                    cvv: _cvvController.text,
                                  ),
                                );
                                showMenu = false;

                                _cardNameController.clear();
                                _cardNumberController.clear();
                                _balanceController.clear();
                                _holderNameController.clear();
                                _expDateController.clear();
                                _cvvController.clear();
                              });
                              _saveCards();
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Icon(Icons.add_card, size: 20),
                              Text(
                                'Add card',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
