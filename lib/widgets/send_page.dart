import 'package:flutter/material.dart';

class SendPage extends StatefulWidget {
  final VoidCallback onExit;

  const SendPage({super.key, required this.onExit});

  @override
  State<SendPage> createState() => _SendPage();
}

class _SendPage extends State<SendPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Send money",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onExit();
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
