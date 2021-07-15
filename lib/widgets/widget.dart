import 'package:flutter/material.dart';

InputDecoration textFieldInpurDecoration() {
  return InputDecoration(
      hintStyle: TextStyle(color: Colors.black38),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black38)));
}
