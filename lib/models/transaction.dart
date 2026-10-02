class Transaction {
  final String name;
  final double amount;
  final double balance;
  final bool plus;
  final DateTime date;

  Transaction({
    required this.name,
    required this.amount,
    required this.balance,
    required this.plus,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      plus: json['plus'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'balance': balance,
      'plus': plus,
      'date': date.toIso8601String(),
    };
  }
}