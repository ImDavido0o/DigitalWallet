import 'package:flutter/services.dart';

class CardExpdateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue
      ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    final limitedDigits = digitsOnly.length > 4
        ? digitsOnly.substring(0, 4)
        : digitsOnly;

    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      buffer.write(limitedDigits[i]);
      if (buffer.length == 2 && i != limitedDigits.length - 1) {
        buffer.write("/");
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

  }
}