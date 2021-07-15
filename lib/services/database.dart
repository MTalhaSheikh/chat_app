import 'package:chat_app/models/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseServices{
  final String userId;
  DatabaseServices({this.userId});

  getUserByUserEmail(String email) async{
    return await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: email).get();
  }

  uploadUserInfo(userInfoMap){
    FirebaseFirestore.instance.collection("users").doc(Constants.myEmail).set(userInfoMap);
  }

  Future uploadUserImagePath(String avartarUrl) async{
    return await FirebaseFirestore.instance.collection("users").doc(Constants.myEmail).update({"userImage": avartarUrl});
  }

  createChatRoom(String chatRoomId, chatRoomMap){
   FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).set(chatRoomMap).catchError((e){
     print(e.toString());
   });
  }

  addConversationMessages(String chatRoomId, messageMap){
    /// ChatRoom > chatRoomId > chats >
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).collection("chats").add(messageMap).catchError((e){
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId){
    return FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).collection("chats").orderBy("time",descending: true).snapshots();
  }

  getChatRooms(String myEmail){
    return FirebaseFirestore.instance.collection("ChatRoom").where("users", arrayContains: myEmail).snapshots();
  }

}

// DocumentSnapshot  ds = await FirebaseFirestore.instance.collection("ChatRoom").doc(widget.chatRoomFriendEmail).get();
// var long = ds.data()["long"];