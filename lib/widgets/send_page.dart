import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/contact.dart';

class SendPage extends StatefulWidget {
  final VoidCallback onExit;
  final Function(Contact contact, double amount) onSend;

  const SendPage({super.key, required this.onExit, required this.onSend});

  @override
  State<SendPage> createState() => _SendPage();
}

class _SendPage extends State<SendPage> {
  List<Contact> _contacts = [];
  Contact? _selectedContact;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final jsonString = await rootBundle.loadString(
      '/Users/mac/Desktop/DigitalWallet/lib/assets/contacts.json',
    );
    final jsonList = jsonDecode(jsonString) as List;
    setState(() {
      _contacts = jsonList.map((json) => Contact.fromJson(json)).toList();
    });
  }

  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool canSendMoney() {
    return _selectedContact != null && _amountController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 4,
                children: [
                  Icon(Icons.arrow_upward_rounded, fontWeight: FontWeight.bold),
                  Text(
                    "Send Money",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  widget.onExit();
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 24,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 6,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      Text(
                        "Add New",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  for (final contact in _contacts)
                    SizedBox(
                      width: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 6,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {setState(() {
                              if (_selectedContact == contact) return _selectedContact = null;
                              _selectedContact = contact;
                            });},
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _selectedContact == contact ? Colors.blue : Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                contact.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            contact.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),

                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: const Align(
                      alignment: Alignment.center,
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Icon(Icons.euro, color: Colors.white, size: 32),
                    ),

                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                    suffixIcon: const SizedBox(width: 48),
                    suffixIconConstraints: const BoxConstraints(minWidth: 48),

                    hintText: '0.00',
                    hintStyle: const TextStyle(color: Colors.white24),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                Text(
                  'Enter amount',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                SizedBox(height: 40,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSendMoney()
                        ? Colors.blue
                        : Colors.blue.withOpacity(0.2),
                    foregroundColor: canSendMoney()
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    overlayColor: canSendMoney()
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
                      if (canSendMoney()) {
                        final amount = double.parse(_amountController.text);
                        widget.onSend(_selectedContact!, amount);
                      }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.payment_rounded, size: 20),
                      Text(
                        'Send money',
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
          ),
        ],
      ),
    );
  }
}
