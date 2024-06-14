import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String defaultText;
  final bool obscureText;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.defaultText,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            textAlign: TextAlign.right,
            controller: widget.controller,
            obscureText: widget.obscureText,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ], // Accepts only integers
            keyboardType: TextInputType.number, // Show number keyboard
            decoration: InputDecoration(
              labelText: isFocused
                  ? null
                  : widget.hintText, // Use labelText instead of hintText
              hintStyle: TextStyle(
                color: Color.fromARGB(255, 81, 81, 81),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 94, 93, 93)),
              ),
              suffixText: widget.defaultText, // Add the currency as suffix text
              suffixStyle: TextStyle(
                color: Color.fromARGB(255, 94, 93,
                    93), // Customize the color of the currency text
              ),
            ),
            onChanged: (value) {
              setState(() {
                isFocused = value.isNotEmpty;
              });
            },
          ),
        ),
      ],
    );
  }
}
