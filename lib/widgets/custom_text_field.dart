import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final Function(String) onSaved;
  final String regEx;
  final String hintText;
  final bool obscureText;
  final Color bgColor;
  final Color textColor;
  final String validationMsg;

  const CustomTextFormField(
      {Key? key,
      required this.onSaved,
      required this.regEx,
      required this.hintText,
      required this.validationMsg,
      required this.obscureText,
      required this.bgColor,
      required this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: (_value) {
        onSaved(_value!);
      },
      cursorColor: textColor,
      style: TextStyle(color: textColor),
      obscureText: obscureText,
      validator: (_value) {
        return RegExp(regEx).hasMatch(_value!)  ? null : validationMsg;
      },
      decoration: InputDecoration(
          hintText: hintText,isDense: true,
          // label: Text(hintText),

          // labelStyle:  TextStyle(color: Colors.white54),
          hintStyle: TextStyle(color:textColor
          ),
          filled: true,
          fillColor:bgColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none)),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final Function(String) onEditingComplete;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  IconData? icon;

  CustomTextField(
      {Key? key,
      required this.onEditingComplete,
      required this.hintText,
      required this.obscureText,
      required this.controller,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        onChanged: (_) => onEditingComplete(controller.text),
        style: TextStyle(color: Colors.black),
        cursorColor: Colors.black54,

        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: TextStyle(color: Colors.black54),

          prefixIcon: Icon(icon, color: Colors.black),
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ));
  }
}
