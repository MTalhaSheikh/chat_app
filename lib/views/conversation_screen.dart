import 'package:chat_app/models/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/loading_screen.dart';
import 'package:chat_app/views/text_input_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String chatRoomFriendEmail;

  ConversationScreen(this.chatRoomId, this.userName, this.chatRoomFriendEmail);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseServices databaseServices = new DatabaseServices();
  final _storage = FirebaseStorage.instance;
  String imagePath = "";
  String sendMsg = "";
  DateTime date;

  void changeText(String text) {
    setState(() {
      sendMsg = text;
      date = DateTime.now();
      sendMessage();
    });
  }

  sendMessage() {
    if (sendMsg.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": sendMsg,
        "sendBy": Constants.myName,
        "date": date,
        "time": date.microsecondsSinceEpoch
      };
      databaseServices.addConversationMessages(widget.chatRoomId, messageMap);
    }
  }

  Stream chatMessageStream;

  @override
  void initState() {
    setState(() {
      if (databaseServices.getConversationMessages(widget.chatRoomId) != null) {
        chatMessageStream = databaseServices.getConversationMessages(widget.chatRoomId);
      }
    });
    LoadingImageInConversation();
    super.initState();
  }

  LoadingImageInConversation() async {
    var storageRef =
        _storage.ref().child("user/profile/${widget.chatRoomFriendEmail}");
    String value = await storageRef.getDownloadURL();
    if (value != null) {
      setState(() {
        imagePath = value;
      });
    }
  }

  /// ye function stream ko ListView builder men set kre ga
  Widget ChatMessageList() {
    return chatMessageStream != null
        ? StreamBuilder(
            stream: chatMessageStream,
            builder: (BuildContext context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      // this will reverse the List
                      reverse: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        var messages = snapshot.data.docs[index].data()["message"];
                        var _date = snapshot.data.docs[index].data()["date"];
                        var _sendBy = snapshot.data.docs[index].data()["sendBy"];
                        // is k through data ki type set kr rahe hen
                        var dateTime = Timestamp(_date.seconds, _date.nanoseconds).toDate();
                        return Column(
                          children: [
                            MessageTile(messages, _sendBy == Constants.myName),
                            Container(
                              alignment: _sendBy == Constants.myName
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding: _sendBy == Constants.myName
                                    ? const EdgeInsets.only(right: 15)
                                    : const EdgeInsets.only(left: 15),
                                child: Text(
                                  "$dateTime",
                                  style: TextStyle(
                                      color: _sendBy == Constants.myName
                                          ? Colors.black
                                          : Colors.black),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Container();
            })
        : Container(color: Colors.yellow[700]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        leading: BackButton(
          color: Colors.black,
        ),
        titleSpacing: -12,
        title: Row(
          children: [
            imagePath != ""
                ? CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.lime[700],
                    backgroundImage: NetworkImage(imagePath.toString()),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.lime[700],
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
            SizedBox(width: 5),
            Text(
              "${widget.userName}",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        // centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: ChatMessageList()),
          Container(
              decoration: BoxDecoration(color: Colors.black12),child: TextInputWidget(this.changeText)),
        ],
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;

  /// ager oper function me pass ki hoi condition true ho gi to isSendByMe k pass "true" a jaye ga
  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMe ? 90 : 12, right: isSendByMe ? 12 : 90),
      margin: EdgeInsets.symmetric(vertical: 5),
      // jitna message ka size ho ga otni container ki width ho jaye gi
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: isSendByMe ? Colors.lime[900] : Colors.black12,
            borderRadius: isSendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23))),
        child: Text(message,
            style: isSendByMe
                ? TextStyle(fontSize: 20.0, color: Colors.yellow[600])
                : TextStyle(fontSize: 20.0, color: Colors.black)),
      ),
    );
  }
}

/*
    if (Platform.isIOS) {
      return _stamp.toDate();
    } else {
      return Timestamp(_stamp.seconds, _stamp.nanoseconds).toDate();
    }
*/
