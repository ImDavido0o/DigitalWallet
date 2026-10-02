class Contact {
  final String id;
  final String name;
  final String initials;
  final String accountNumber;

  Contact({
    required this.id,
    required this.name,
    required this.initials,
    required this.accountNumber,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      initials: json['initials'],
      accountNumber: json['accountNumber'],
    );
  }
}