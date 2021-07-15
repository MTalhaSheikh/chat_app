import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/models/constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/loading_screen.dart';
import 'package:chat_app/views/chat_room_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthServices _auth = AuthServices();
  DatabaseServices databaseServices = new DatabaseServices();
  final formKey = GlobalKey<FormState>();

  String email = " ";
  String name = " ";
  String password = " ";
  String error = " ";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              backgroundColor: Colors.yellow[700],
              title: Text(
                "Sign Up",
                style: TextStyle(color: Colors.black),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/unnamed.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                  validator: (val) => val.isEmpty
                                      ? "Please Enter your name"
                                      : null,
                                  onChanged: (val) {
                                    setState(() {
                                      name = val;
                                    });
                                  },
                                  // controller: userNameTxtController,
                                  decoration: textFieldInpurDecoration()
                                      .copyWith(hintText: 'Name'),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
                              TextFormField(
                                  validator: (val) {
                                    /// jo value hum enter kren gy agr wo is RegExp k format k motabik ho gi to "null" return kre ga
                                    return RegExp(
                                        r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                            .hasMatch(val)
                                        ? null
                                        : "Please enter correct Email";
                                  },
                                  onChanged: (val) {
                                    setState(() {
                                      email = val;
                                    });
                                  },
                                  decoration: textFieldInpurDecoration()
                                      .copyWith(hintText: 'Email'),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
                              TextFormField(
                                validator: (val) => val.length < 6
                                    ? "Enter password grater then 6"
                                    : null,
                                onChanged: (val) {
                                  setState(() {
                                    password = val;
                                  });
                                },
                                // controller: passwordTxtController,
                                decoration: textFieldInpurDecoration()
                                    .copyWith(hintText: "any Password"),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "$error",
                            style: TextStyle(color: Colors.black54, fontSize: 15),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (formKey.currentState.validate()) {
                              setState(() {
                                loading = true;
                              });
                              dynamic result = await _auth.signUpWithEmailAndPassword(email, password);
                              if (result != null) {
                                /// Map<key, value>
                                Map<String, String> userInfoMap = {
                                  "name": name,
                                  "email": email,
                                  "lati": "",
                                  "long": "",
                                  "password": password,
                                };
                                HelperFunctions.saveUserEmailSharePrefrence(email);
                                HelperFunctions.saveUserNameSharePrefrence(name);
                                Constants.myName = await HelperFunctions.getUserNameSharePrefrence();
                                Constants.myEmail = await HelperFunctions.getUserEmailSharePrefrence();
                                DatabaseServices().uploadUserInfo(userInfoMap);
                                // jb user logged-in ho jaye ga or data Map ho jaye ga tb save kren gy "saveUserLoggedInSharePrefrence" ko
                                // HelperFunctions.saveUserLoggedInSharePrefrence(true);
                              }
                              if (result != null) {
                                /// pushReplacement() use to replace a screen with new screen
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatRoom()));
                              }
                              if (result == null) {
                                setState(() {
                                  loading = false;
                                  error =
                                      "Could not sign In with these credentials";
                                });
                              }
                            }
                          },
                          /// Button
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                                color: Colors.yellow[700],
                                borderRadius: BorderRadius.circular(30)),
                            child: Text("Sign Up",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20)),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have account ?  ",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.toggle();
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "SignIn now",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
