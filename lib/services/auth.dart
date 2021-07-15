import 'package:chat_app/models/constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel _userFromFirebaseUser(user){
    if (user != null) {
      return UserModel(userId: user.uid);
    } else {
      return null;
    }
  }

  // auth change user stream
  // jese hi user ki state change ho gi wo state map ho jaye gi _userFromFirebaseUser men
  // or ye stream data provide kr rahi he main class men StreamProvider ko
  Stream<UserModel> get user{
    return _auth.authStateChanges()
        .map((user) => _userFromFirebaseUser(user));
  }

  Future signInWithEmailAndPassword(String email, String pass) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      User firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String pass) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      User firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    }catch(e){
      print(e.toString());
    }
  }

  Future resetPass(String email) async{
    try{
      return await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      print(e.toString());
    }
  }

  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
    }
  }

}