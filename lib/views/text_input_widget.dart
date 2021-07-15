import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {

  final Function(String) callback;
  TextInputWidget(this.callback);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}
class _TextInputWidgetState extends State<TextInputWidget> {

  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.black, fontSize: 18, ),
      cursorColor: Colors.black,
      controller: this.controller,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.message, color: Colors.lime[900]),
        labelText: "Type Message", labelStyle: TextStyle(color: Colors.lime[900]),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.lime[900])),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.lime[900])),
        suffixIcon: IconButton(
          icon: Icon(Icons.send, color: Colors.lime[900]),
          splashColor: Colors.lime[700],
          tooltip: "Post Message",
          onPressed: (){
            widget.callback(controller.text);
            controller.clear();
            // FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }
}
