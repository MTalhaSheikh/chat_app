import 'dart:async';
import 'dart:io';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/mapData/geolocator_services.dart';
import 'package:chat_app/models/constants.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatRoomTiles.dart';
import 'package:chat_app/views/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final AuthServices _auth = AuthServices();
  DatabaseServices databaseServices = new DatabaseServices();
  final _storage = FirebaseStorage.instance;
  final GeolocatorService geoService = GeolocatorService();

  String lastMsg="";
  String lastSendBy="";
  String lastDate="";
  String avartarUrl;
  final _picker = ImagePicker();
  PickedFile image;
  Timer _timer;
  Location location;

  loadimageInDrawer() async{
    var storageRef = _storage.ref().child("user/profile/${Constants.myEmail}");
    if(storageRef != null){
      String value =  await storageRef.getDownloadURL();
      if (value != null){
        setState(() {
          avartarUrl = value;
        });
      }
    }
  }

  Stream chatRoomsStream;
  Stream streamForMsgData;

  getUserInfo() async {
      Constants.myName = await HelperFunctions.getUserNameSharePrefrence();
      if(Constants.myEmail == " "){
        Constants.myEmail = await HelperFunctions.getUserEmailSharePrefrence();
      }
      if (databaseServices.getChatRooms(Constants.myEmail) != null) {
        setState(() {
          chatRoomsStream = databaseServices.getChatRooms(Constants.myEmail);
        });
      }
  }

  LocationData currentLocation;
  @override
  void initState() {
    super.initState();
    /// jese hi main screen open ho gi getUserInfo() call ho ga or getUserNameSharePrefrence() se name ko gey kre ga
     getUserInfo();
     location = new Location();
     location.onLocationChanged().listen((event) async {
       currentLocation = await location.getLocation();
       FirebaseFirestore.instance.collection("users").doc(Constants.myEmail).update(
           {"lati": currentLocation.latitude});
       FirebaseFirestore.instance.collection("users").doc(Constants.myEmail).update(
           {"long": currentLocation.longitude});
       if(this.mounted){
         loadimageInDrawer();
       }
     });
  }

  Widget ChatRoomList() {
    return chatRoomsStream != null
        ? StreamBuilder(
            stream: chatRoomsStream,
            builder: (BuildContext context, snapshot) {
              return snapshot.hasData ? ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index){
                        var chatRoomFriendEmail = snapshot.data.docs[index].data()["chatroomId"].toString()
                            .replaceAll("_", "").toString().replaceAll(Constants.myEmail, "");
                        var chatRoomID = snapshot.data.docs[index].data()["chatroomId"];
                        // var chatPartnername = snapshot.data.docs[index].data()["users"][0];
                        streamForMsgData = DatabaseServices().getConversationMessages(chatRoomID);
                          return streamForMsgData != null ?  StreamBuilder(
                            stream: streamForMsgData,
                            builder: (BuildContext context, snapshotMsg){
                              if(snapshotMsg.hasData){
                                var lastMsg = snapshotMsg.data.docs[0].data()["message"];
                                var lastDate = snapshotMsg.data.docs[0].data()["date"];
                                var dateTime = Timestamp(lastDate.seconds, lastDate.nanoseconds).toDate();
                                var lastSendBy = snapshotMsg.data.docs[0].data()["sendBy"];
                                return chatRoomTiles(chatRoomID, chatRoomFriendEmail, lastMsg, dateTime.toString(), lastSendBy);
                              }
                              return chatRoomTiles(chatRoomID, chatRoomFriendEmail, lastMsg, lastDate, lastSendBy);
                            }): Container();
                      })
                  : Container(child: Center(child: Text("Search your Friends", style: TextStyle(fontSize: 20),),),);
            })
        : Container(child: Center(child: Text("Search your Friends", style: TextStyle(fontSize: 20),),),);
  }

  getProfilePicture() async {
    //todo: check permission
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    // ager user ney permission di he to
    if(permissionStatus.isGranted){
      //todo: Select image
      image = await _picker.getImage(source: ImageSource.gallery);
      var file = File(image.path);
      if(image != null){
        //todo: upload to firebase
        var storageRef = _storage.ref().child("user/profile/${Constants.myEmail}").putFile(file);
        var completedTesk = await storageRef.snapshot;
        // save kren k bad osko pic ko phir se access kren gy
        String downloadUrl = await completedTesk.ref.getDownloadURL();
        setState(() {
          avartarUrl = downloadUrl;
        });
        loadimageInDrawer();
        // Navigator.of(context).pop();
      }else{
        print("No image path received");
      }
    }else{
      print("Grant permission and try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home Screen",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow[700],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[Colors.yellow[700], Colors.yellow[400]])
              ),
                child: Container(
                  child: Column(
                    children: [
                      avartarUrl == null ? CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.black87,
                        child: Icon(Icons.person, size: 100,color: Colors.yellow[700],),
                      ):CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(avartarUrl.toString()),
                      ),
                      SizedBox(height: 5),
                      // Text(Constants.myName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                    ],
                  ),
                )),
            CustomDrawerListTile(Icons.camera_alt, "Profile Picture", (){
              getProfilePicture();
            }),
            CustomDrawerListTile(Icons.logout, "Logout", () async {await _auth.signOut();}),
          ],
        ),
      ),
      body: ChatRoomList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.search,
          color: Colors.black,
          size: 28,
        ),
        backgroundColor: Colors.yellow[700],
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchScreen()));
        },
      ),
    );
  }
}

class CustomDrawerListTile extends StatefulWidget {

  IconData icon;
  String text;
  Function onTapp;
  CustomDrawerListTile(this.icon, this.text, this.onTapp);

  @override
  _CustomDrawerListTileState createState() => _CustomDrawerListTileState();
}

class _CustomDrawerListTileState extends State<CustomDrawerListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400))
        ),
        child: InkWell(
          splashColor: Colors.orangeAccent,
          onTap: widget.onTapp,
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.icon),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(widget.text, style: TextStyle(fontSize: 16.0),),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
