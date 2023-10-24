import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordInputField extends StatefulWidget {
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String hintText;
  final Icon prefixIcon;

  // final String validateText;
  final FormFieldValidator<String> validator;
  final TextInputFormatter inputFormatter;

  PasswordInputField({
    Key? key,
    required this.keyboardType,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    //  required this.validateText,
    required this.validator,
    required this.inputFormatter,
  }) : super(key: key);

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        cursorColor: Colors.blue,
        decoration: InputDecoration(
          hintText: widget.hintText,
          fillColor: const Color(0xfff8F9FA),
          hintStyle: TextStyle(
              fontFamily: 'Rubik Regular', fontSize: screenWidth * 0.036),
          filled: true,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon.icon,
                  color: Colors.blue,
                  size: screenWidth * 0.06,
                )
              : null,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.blue,
                size: screenWidth * 0.06,
              ),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.lightBlue,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.lightBlue,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
        ),
        validator: widget.validator,
        obscureText: !isPasswordVisible,
      ),
    );
  }
}
