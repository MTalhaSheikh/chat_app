// import 'dart:io';
//
// import 'package:chat_app/helper/helperFunctions.dart';
// import 'package:chat_app/models/constants.dart';
// import 'package:chat_app/models/user_model.dart';
// import 'package:chat_app/services/auth.dart';
// import 'package:chat_app/views/chat_room_screen.dart';
// import 'package:chat_app/views/wrapper.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class NotificationHandler extends StatefulWidget {
//   @override
//   _NotificationHandlerState createState() => _NotificationHandlerState();
// }
//
// class _NotificationHandlerState extends State<NotificationHandler> {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseMessaging _fcm = FirebaseMessaging();
//
//   notificationCheck(){
//     _fcm.configure(
//       // this will show notification when user is running app
//         onMessage: (Map<String, dynamic> message) async{
//           print("onMessage: $message");
//           // final snackbar = SnackBar(
//           //     content: Platform.isAndroid ? Text(message['notification']['title']): Text(message['aps']['alert']),
//           //   action: SnackBarAction(
//           //     label: "Go",
//           //     onPressed: () => Navigator.of(context).pop(),
//           //   ),
//           // );
//           // Scaffold.of(context).showSnackBar(snackbar);
//         },
//         //todo: this will show message when app is running on background
//         onResume: (Map<String, dynamic> message) async{
//           print("onResume: $message");
//         },
//         //todo: this will show message when app is closed
//         onLaunch: (Map<String, dynamic> message) async{
//           Navigator.push(context, MaterialPageRoute(builder: (context) => Wrapper()));
//         });
//
//     _fcm.getToken().then((token) async {
//       print("token: $token");
//       Constants.myEmail = await HelperFunctions.getUserEmailSharePrefrence();
//       print(Constants.myEmail);
//       await _db.collection("users").doc(Constants.myEmail).update({'pushToken': token});
//     }).catchError((error){
//       print(error.toString()+"--------------------------------------------");
//     });
//
//   }
//
//   @override
//   void initState() {
//     notificationCheck();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // StreamProvider auth_service se data ly gi or sub classes men user ka data pohnchaye gi
//     return ChatRoom();
//   }
// }
