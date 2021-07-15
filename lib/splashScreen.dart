import 'dart:async';
import 'package:chat_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     // title: 'FreeTracker',
//     // theme: ThemeData(
//     //   scaffoldBackgroundColor: Colors.white,
//     //   primarySwatch: Colors.orange,
//     //   visualDensity: VisualDensity.adaptivePlatformDensity,
//     // ),
//     home: SplashScreen2(),
//   ));
// }

class SplashScreen2 extends StatefulWidget {
  @override
  _SplashScreen2State createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2>
    with SingleTickerProviderStateMixin {
  AnimationController animController;
  Animation<double> animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animController = AnimationController(duration: Duration(seconds: 5), vsync: this);
    // Tween automatically value ko change krta rahe ga di gai range men
    animation = Tween<double>(begin: 0, end: 2 * math.pi).chain(CurveTween(curve: Curves.bounceIn))
        .animate(animController)
          ..addListener(() {
            // setState men koi value dene ki zarort nahi he kiun k animation k ander pehle se value change ho rahi he
            // is setState se screen refresh hoti rahi gi
            setState(() {});
          })..addStatusListener((status) {
            // ye animController k status ko check kre ga or osko agy pichy move kraye ga
            if(status == AnimationStatus.completed){
              animController.reverse();
            } else{
              if(status == AnimationStatus.dismissed){
                animController.forward();
              }
            }
      });
    animController.forward();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: Column(
        children: [
          Spacer(),
          Transform.rotate(
            angle: animation.value,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(30),
              child: Image.asset("assets/images/circularlocation.png"),
            ),
          ),
          Text("Free Tracker", style: TextStyle(fontSize: 24),),
          Text("Loading....", style: TextStyle(fontSize: 17),),
          Spacer(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  Future<Timer> loadData() async {
    // 3 seconds k bd onDoneLoading ka function perform ho ga
    return new Timer(Duration(seconds: 8), onDoneLoading);
  }

  onDoneLoading() async {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));
  }
}
