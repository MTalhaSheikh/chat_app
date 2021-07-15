import 'package:chat_app/models/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_room_screen.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _email = "";
  String imagePath = "";
  DatabaseServices databaseServices = new DatabaseServices();
  final _storage = FirebaseStorage.instance;
  QuerySnapshot searchSnapshot;

  /// liye alag se create kr k do jaghon per call kraya he
  initiateSearch() async {
    databaseServices.getUserByUserEmail(_email).then((val){
      setState((){
        if(Constants.myEmail != _email){
          setState(() {
            searchSnapshot = val;
          });
        }else{
          searchSnapshot = null;
        }
      });
    });
    if(Constants.myEmail != _email){
      var storageRef = _storage.ref().child("user/profile/$_email");
      if(storageRef != null){
        String value =  await storageRef.getDownloadURL();
        if(value != null){
          setState(() {
            imagePath = value;
            storageRef = null;
          });
        }else{
          setState(() {
            imagePath = "";
          });
        }
      }
    }
  }

  Widget searchList(){
    /// ager searchSnapshot k pass data ho ga to List dekhaye ga nahi to Container show kre ga
    return searchSnapshot != null ? ListView.builder(
        itemCount: searchSnapshot.docs.length,
        // ager ap List ko column k ander show kren gy to shrinkWrap ko use kren gy
        shrinkWrap: true,
        itemBuilder: (context, index){
          // Tile ko stateless class men nichy create kiya he yahan se values pass ki hen
          return SearchTile(
            // name or email wo hen jo database me key store ki hoi hen
            userName: searchSnapshot.docs[index].data()["name"],
            userEmail: searchSnapshot.docs[index].data()["email"],
          );
        }): Container();
  }

  //todo: Card
  Widget SearchTile({String userName, String userEmail}){
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            imagePath != "" ? GestureDetector(
              onTap: (){
                showModalBottomSheet(
                    context: context,
                    builder: (context){
                      return Container(
                        height: 300,
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            image: DecorationImage(
                              image: NetworkImage(imagePath.toString()),
                            )
                        ),
                      );
                    });
              },
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.lime[700],
                backgroundImage: NetworkImage(imagePath.toString()),
              ),
            ): CircleAvatar(
              radius: 35,
              backgroundColor: Colors.lime[700],
              child: Icon(Icons.person, size: 25,color: Colors.white,),
            ),
            SizedBox(width: 15,),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
                Text(userEmail, style: TextStyle(color: Colors.black)),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                ///  user k liye conversation create kren gy
                String chatRoomId =  getChatRoomId(userEmail, Constants.myEmail);
                List<String> users = [userEmail, Constants.myEmail];

                //todo: at the time of update the "." dot in the email makes issue their for change the shape
                // we usr these values for location allow
                var myemail = Constants.myEmail.toString().replaceAll(".", "").toString().replaceAll("com", "");
                var femail = userEmail.toString().replaceAll(".", "").toString().replaceAll("com", "");

                // Map<key, value>
                Map<String, dynamic> chatRoomMap = {
                  "users": users,
                  "chatroomId": chatRoomId,
                  /// we will use these for allow user to show map or not
                  "$femail": false,
                  "$myemail": false,
                };
                DatabaseServices().createChatRoom(chatRoomId, chatRoomMap);
                Map<String, dynamic> messageMap = {
                  "message": "Hey I am ${Constants.myName}",
                  "sendBy": Constants.myName,
                  "date": DateTime.now(),
                  "time": DateTime.now().microsecondsSinceEpoch
                };
                databaseServices.addConversationMessages(chatRoomId, messageMap);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom()));
                FocusScope.of(context).unfocus();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Message"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        leading: BackButton(color: Colors.black,),
        title: Text("Find Friends", style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                height: 75,
                color: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          decoration: InputDecoration(
                            hintText: "Search by Email....",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _email = val;
                            });
                          },
                          cursorColor: Colors.black,
                        ),
                      ),
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.search, size: 28,color: Colors.yellow[700],),
                          splashColor: Colors.yellow[200],
                          tooltip: "Find Friend",
                          onPressed: (){
                            initiateSearch();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}


/// chatroom men jitne user hon gy onko "id" is function k through den gy jese "Talha _ Arslan" ye eik id bn jaye gi
///  ye function strings ko compare kre ga
getChatRoomId(String a, String b){
  if(a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)){
    return "$b\_$a";
  }else{
    return "$a\_$b";
  }
}