import 'package:chat_app/mapData/map.dart';
import 'package:chat_app/models/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class chatRoomTiles extends StatefulWidget {
  final String chatRoomId;
  final String chatRoomFriendEmail;
  final String lastMsg;
  String lastDate;
  final String lastSendBy;

  chatRoomTiles(
      this.chatRoomId,
      this.chatRoomFriendEmail,
      this.lastMsg,
      this.lastDate,
      this.lastSendBy
      );

  @override
  _chatRoomTilesState createState() => _chatRoomTilesState();
}

class _chatRoomTilesState extends State<chatRoomTiles> {
  DatabaseServices databseServices = new DatabaseServices();
  final _storage = FirebaseStorage.instance;
  QuerySnapshot snapshotName;
  String imagePath = "";
  String fname = "";

  loadImageInTile() async{
    DatabaseServices().getUserByUserEmail(widget.chatRoomFriendEmail).then((value){
      snapshotName = value;
      setState(() {
        fname = snapshotName.docs[0].data()["name"];
      });
    });
    var storageRef = _storage.ref().child("user/profile/${widget.chatRoomFriendEmail}");
    if(storageRef != null){
      String value =  await storageRef.getDownloadURL();
      if(value != null){
        setState(() {
          imagePath = value;
        });
      }
    }
  }

  @override
  void initState(){
    loadImageInTile();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            Mapscreen(widget.chatRoomId, fname, widget.chatRoomFriendEmail)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
              color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10),
          topRight: Radius.circular(10), bottomRight: Radius.circular(10),)),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              imagePath != "" ? GestureDetector(
                onTap: (){
                  showModalBottomSheet(
                      context: context,
                      builder: (context){
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                image: NetworkImage(imagePath.toString()),
                                  fit: BoxFit.cover
                              )
                          ),
                        );
                      });
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.yellow[700],
                  backgroundImage: NetworkImage(imagePath.toString()),
                ),
              ): CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black87,
                child: Icon(Icons.person, size: 25,color: Colors.yellow[700]),
              ),
              SizedBox(width: 15,),

              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("$fname", style: TextStyle(color: Colors.black, fontSize: 21, fontWeight: FontWeight.bold)),
                   Container(
                     width: 260.0,
                     child: Text("${widget.lastMsg}",
                         style: TextStyle(color: widget.lastSendBy == Constants.myName ? Colors.black: Colors.indigo, fontSize: 15,),
                         overflow: TextOverflow.ellipsis),
                   ),
                    Text("${widget.lastDate}",
                        style: TextStyle(color: widget.lastSendBy == Constants.myName ? Colors.black: Colors.indigo, fontSize: 12)),
                  ],),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
