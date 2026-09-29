import 'package:flutter/services.dart';

class CardCvvFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue
      ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    final limitedDigits = digitsOnly.length > 3 
        ? digitsOnly.substring(0, 3)
        : digitsOnly;

    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      buffer.write(limitedDigits[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
        
  }
}