import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/models/constants.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>{

final _storage = FirebaseStorage.instance;
String avartarUrl;
final _picker = ImagePicker();
PickedFile image;
QuerySnapshot imageSnapshot;

  loadimage() async{
    var storageRef = _storage.ref().child("user/profile/${Constants.myEmail}");
    String value =  await storageRef.getDownloadURL();
    setState(() {
      avartarUrl = value;
    });
  }

  @override
  void initState() {
    loadimage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //todo: i changed
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            avartarUrl == null ? CircleAvatar(
              radius: 90,
              backgroundColor: Colors.yellow[700],
              child: Icon(Icons.person, size: 160,color: Colors.white,),
            ): GestureDetector(
              onTap: (){
                showModalBottomSheet(
                    context: context,
                    builder: (context){
                  return Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: NetworkImage(avartarUrl.toString()),
                          fit: BoxFit.cover
                        )
                      ),
                  );
                });
              },
              child: CircleAvatar(
                radius: 90,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(avartarUrl.toString()),
              ),
            ),
            // SizedBox(
            //   height: 70,
            // ),
            Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () async{
                    //todo: check permission
                    await Permission.photos.request();
                    // ager user ney permission di he to
                    var permissionStatus = await Permission.photos.status;
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
                            print("$avartarUrl");
                          });
                          loadimage();
                        }else{
                          print("No image path received");
                        }
                    }else{
                      print("Grant permission and try again");
                    }
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.black,
                    size: 28,
                  ),
                  backgroundColor: Colors.yellow[700],
                )),

            SizedBox(height: 10,),
            Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {},
                  child: Icon(
                    Icons.delete_forever,
                    color: Colors.black,
                    size: 28,
                  ),
                  backgroundColor: Colors.yellow[700],
                )),
          ],
        ),
      ),
    );
  }
}
