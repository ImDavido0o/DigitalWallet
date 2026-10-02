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

import 'models/contact.dart';
import 'models/transaction.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BankCard> myCards = [];
  List<Transaction> _currentTransactions = [];

  // Save and Load Cards
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

  // Save and Load Transactions
  Future<void> _initTransactionsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasInitialized = prefs.getBool('transactions_initialized') ?? false;

    if (!hasInitialized) {
      final jsonString = await rootBundle.loadString(
        "/Users/mac/Desktop/DigitalWallet/lib/assets/transactions.json",
      );
      await prefs.setString('all_transactions', jsonString);
      await prefs.setBool('transactions_initialized', true);
    }
  }

  Future<void> _loadTransactionsForCard(String cardNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('all_transactions') ?? '{}';
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    final cleanCardNumber = cardNumber.replaceAll(' ', '');
    final cardTransactions = jsonMap[cleanCardNumber] as List? ?? [];

    setState(() {
      _currentTransactions = cardTransactions
          .map((json) => Transaction.fromJson(json))
          .toList();
    });
  }

  Future<void> _addTransactionForCard(
    String cardNumber,
    Transaction transaction,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('all_transactions') ?? '{}';
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    final cleanCardNumber = cardNumber.replaceAll(' ', '');
    final existing = (jsonMap[cleanCardNumber] as List?) ?? [];
    existing.insert(0, transaction.toJson());
    jsonMap[cleanCardNumber] = existing;

    await prefs.setString('all_transactions', jsonEncode(jsonMap));
  }

  void _sendMoney(Contact contact, double amount) {
    final currentCard = myCards[_currentPage];
    final currentBalance = double.parse(currentCard.balance);

    if (amount > currentBalance) {
      print('Nedostatok peňazí');
      return;
    }

    final newBalance = currentBalance - amount;
    final newTransaction = Transaction(
      name: contact.name,
      amount: amount,
      balance: newBalance,
      plus: false,
      date: DateTime.now(),
    );

    setState(() {
      myCards[_currentPage] = BankCard(
        cardName: currentCard.cardName,
        cardNumber: currentCard.cardNumber,
        balance: newBalance.toStringAsFixed(2),
        holderName: currentCard.holderName,
        expDate: currentCard.expDate,
        cvv: currentCard.cvv,
      );

      _currentTransactions.insert(0, newTransaction);
      showSendPage = false;
    });

    _saveCards();
    _addTransactionForCard(currentCard.cardNumber, newTransaction);
  }

  late final PageController _pageController;
  int _currentPage = 0;
  bool showMenu = false;
  bool _showCvv = false;

  bool showSendPage = false;
  bool showRequestPage = false;
  bool showTopUpPage = false;
  bool showMorePage = false;

  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCards().then((_) async {
      await _initTransactionsIfNeeded();
      if (myCards.isNotEmpty) {
        _loadTransactionsForCard(myCards[0].cardNumber);
      }
    });
    _pageController = PageController(viewportFraction: 0.99);
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
          showMenu = false;
        });

        if (newPage < myCards.length) {
          _loadTransactionsForCard(myCards[newPage].cardNumber);
        }
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
      //title = "Send";
    }

    return title;
  }

  IconData setIcon(bool b, bool isAddCard) {
    IconData icon = isAddCard ? Icons.add_card : Icons.wallet;
    if (b) {
      //icon = Icons.arrow_upward_rounded;
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ActionButton(
                              icon: Icons.arrow_upward_rounded,
                              label: 'Send',
                              onTap: () {
                                setState(() {
                                  showSendPage = true;
                                });
                              },
                            ),
                            ActionButton(
                              icon: Icons.arrow_downward_rounded,
                              label: 'Request',
                              onTap: () {},
                            ),
                            ActionButton(
                              icon: Icons.add_rounded,
                              label: 'Top Up',
                              onTap: () {},
                            ),
                            ActionButton(
                              icon: Icons.more_horiz_rounded,
                              label: 'More',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Transfers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'View all',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                        Expanded(
                          child: Stack(
                            children: [
                              ListView.separated(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 20,
                                ),
                                itemCount: _currentTransactions.length > 6 ? _currentTransactions.take(6).length + 1 : _currentTransactions.take(6).length,
                                separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                                itemBuilder: (context, index) {


                                  final transactions = _currentTransactions.take(6).toList();
                                  if (index == transactions.length && _currentTransactions.length > 6) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        top: 0,
                                        bottom: 0,
                                      ),
                                      child: Center(
                                        child: TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            'View more',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }


                                  final t = _currentTransactions[index];

                                  return TransfersCard(
                                    name: t.name,
                                    amount: t.amount,
                                    balance: t.balance,
                                    plus: t.plus,
                                    date: t.date,
                                  );
                                },
                              ),

                              // TOP fade
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 30,
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFF121212),
                                          Color(0x00101010),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // BOTTOM fade
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 30,
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Color(0xFF121212),
                                          Color(0x00101010),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                if (showSendPage)
                  SendPage(
                    onExit: () {
                      setState(() {
                        showSendPage = false;
                      });
                    },
                    onSend: (contact, amount) {
                      _sendMoney(contact, amount);
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
    );
  }
}
