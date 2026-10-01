import 'package:flutter/material.dart';

class SendPage extends StatefulWidget {
  final VoidCallback onExit;

  const SendPage({
    super.key,
    required this.onExit,
  });

  @override
  State<SendPage> createState() => _SendPage();
}

class _SendPage extends State<SendPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            setState(() {

            });
          },
          icon: Icon(Icons.close_rounded, size: 24, fontWeight: FontWeight.bold),),
      ],
    );
  }
}
