import 'package:chat_app/mapData/map.dart';
import 'package:chat_app/splashScreen.dart';
import 'package:chat_app/views/notification_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/views/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'FreeTracker',
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primarySwatch: Colors.orange,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return StreamProvider<UserModel>.value(
     value: AuthServices().user,
     child: MaterialApp(
       debugShowCheckedModeBanner: false,
       title: 'FreeTracker',
       theme: ThemeData(
         scaffoldBackgroundColor: Colors.white,
         primarySwatch: Colors.orange,
         visualDensity: VisualDensity.adaptivePlatformDensity,
       ),
       home: Wrapper(),
     ),
   );
  }
}



