import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/views/chat_room_screen.dart';
import 'package:chat_app/views/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Wrapper() StreamProvider k ander use hoa he main class men is liye user ka data idher access kr sakte hen
    final user = Provider.of<UserModel>(context);

    // return either home or authenticate
    if (user == null){
      return Authenticate();
    } else {
      // ager hum home screen per logout ko press kren gy to user k pass null aa jaye ga or wo yahan oper update ho jaye ga
      return ChatRoom();
    }

  }
}
