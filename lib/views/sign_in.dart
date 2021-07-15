import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/models/constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/loading_screen.dart';
import 'package:chat_app/views/chat_room_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthServices _auth = AuthServices();
  DatabaseServices databaseServices = new DatabaseServices();
  final formKey = GlobalKey<FormState>();

  String emailSignIn = "";
  String password = "";
  String error = "";
  bool loading = false;
  QuerySnapshot snapshotInfo;


  @override
  Widget build(BuildContext context) {

    SnackBar snackbar =  SnackBar(
      content: Row(
        children: [
          Icon(Icons.email),
          SizedBox(width: 20,),
          Expanded(child: Text("$error")),
        ],
      ),
    );

    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              backgroundColor: Colors.yellow[700],
              title: Text(
                "Sign In",
                style: TextStyle(color: Colors.black),
              ),
            ),
            //todo: this builder use for the SnackBar
            body: Builder(builder: (context){
              return SingleChildScrollView(
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
                                    validator: (val) {
                                      /// jo value hum enter kren gy agr wo is RegExp k format k motabik ho gi to "null" return kre ga
                                      return RegExp(
                                          r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                          .hasMatch(val) ? null : "Please enter correct Email";
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                          emailSignIn = val;
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
                                  decoration: textFieldInpurDecoration()
                                      .copyWith(hintText: "Password"),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                  obscureText: true,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0),
                          GestureDetector(
                            onTap: (){
                              if(emailSignIn != ""){_auth.resetPass(emailSignIn);
                                setState(() {
                                  error = "Check your email";
                                });
                                //todo: working on SnackBar
                                Scaffold.of(context).showSnackBar(snackbar);
                              }
                            },
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Text(
                                    "Forgot Password ?",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(height: 20.0),
                          Text("$error", style: TextStyle(color: Colors.black54, fontSize: 15),),
                          GestureDetector(
                            onTap: () async {
                              if (formKey.currentState.validate()) {
                                setState(() {
                                  loading = true;
                                });
                                HelperFunctions.saveUserEmailSharePrefrence(emailSignIn);
                                Constants.myEmail = await HelperFunctions.getUserEmailSharePrefrence();
                                dynamic result = await _auth.signInWithEmailAndPassword(Constants.myEmail, password);
                                /// saveUserNameSharePrefrence is ko name pass krna tha name hmare pass is class men tha nahi to hmne getUserByUserEmail
                                /// k through get kiya or pass kr dia
                                if(result != null) {
                                  databaseServices.getUserByUserEmail(Constants.myEmail).then((val) async {
                                    snapshotInfo = val;
                                    /// eik email se search kiya he to eik hi document retun ho ga getUserByUserEmail is function se is liye list mese [0]
                                    /// ko get kiya he or os men se name ko get kiya he
                                    HelperFunctions.saveUserNameSharePrefrence(snapshotInfo.docs[0].data()["name"]);
                                  });
                                }
                                if (result == null) {
                                  setState(() {
                                    loading = false;
                                    error = "Could not sign In with these credentials";
                                  });
                                }
                                Scaffold.of(context).showSnackBar(snackbar);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                  color: Colors.yellow[700],
                                  borderRadius: BorderRadius.circular(30)),
                              child: Text("Sign In",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have account ?  ",
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
                                      "Register now",
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
              );
            }),
          );
  }
}

