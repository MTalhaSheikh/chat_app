import 'dart:async';

import 'package:chat_app/mapData/geolocator_services.dart';
import 'package:chat_app/models/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Mapscreen extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String chatRoomFriendEmail;

  Mapscreen(this.chatRoomId, this.userName, this.chatRoomFriendEmail);

  @override
  _MapscreenState createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  DatabaseServices databaseServices = new DatabaseServices();
  final _storage = FirebaseStorage.instance;
  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  BitmapDescriptor pinLocationIcon;
  Timer _timer;

  String femail;
  String myemail;
  bool showMapToFriend = false;

  String imagePath = "";
  Location location;
  LocationData myLocation;
  var long, lati;

  //todo: Track between two points
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints ;

  //todo: single line between two points
  final Set<Polyline> _polyline ={};
  List<LatLng> latlng = List();

  LoadingImageInConversation() async {
    var storageRef =
        _storage.ref().child("user/profile/${widget.chatRoomFriendEmail}");
    //todo: working here
    if(storageRef != null){
      String value = await storageRef.getDownloadURL();
      if (value != null) {
        setState(() {
          imagePath = value;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setValuesForLocationIcon();
    setCustomMapPin();
    LoadingImageInConversation();

    //todo: Track between two points
    polylinePoints = PolylinePoints();

    //todo: ye position ko get kre ga or map k liye coordinates ko set kre ga
    const oneSec = const Duration(seconds: 10);
    _timer = new Timer.periodic(oneSec, (Timer timer) async {
      location = new Location();
      myLocation = await location.getLocation();
      DocumentSnapshot  ds = await FirebaseFirestore.instance.collection("users").doc(widget.chatRoomFriendEmail).get();
      //todo: (this.mounted) check kre ga ager isi screen per ho ga to setState() chale ga nahi to nahi chale ga
      if(this.mounted){
        setState(() {
          lati = ds.data()["lati"];
          long = ds.data()["long"];
        });
      }

      //todo: single line between two points
      latlng.clear();
      LatLng friendPosition = LatLng(lati, long);
      LatLng myPosition = LatLng(myLocation.latitude, myLocation.longitude);
      latlng.add(friendPosition);
      latlng.add(myPosition);
      _polyline.add(Polyline(
        polylineId: PolylineId("poly"),
        visible: true,
        width: 1,
        points: latlng,
        color: Colors.black54,
      ));

      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId("sourcePin"),
          position: LatLng(lati, long),
          icon: pinLocationIcon
        ));
      // setPolylines();
      });

  }

  //todo: database men location ki state ko set krne k liye keys ko set kr rahen hen jahan per value save kren gy
  setValuesForLocationIcon() async {
    DocumentSnapshot  ds = await FirebaseFirestore.instance.collection("ChatRoom").doc(widget.chatRoomId).get();
    setState(() {
      femail = widget.chatRoomFriendEmail.toString().replaceAll(".", "").toString().replaceAll("com", "");
      myemail = Constants.myEmail.toString().replaceAll(".", "").toString().replaceAll("com", "");
      showMapToFriend = ds.data()["$myemail"];
    });
  }
  //todo: is ki base per location on off ho gi
  Future<void> toggleView() async {
    setState(() {
      showMapToFriend = !showMapToFriend;
    });
    await FirebaseFirestore.instance.collection("ChatRoom").doc(widget.chatRoomId)
        .update({"$myemail": showMapToFriend});
  }

  //todo: ye map per Location pin set kren k liye he
  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/mappin.png');
  }

  Widget showMap(){
    return long != null ? Center(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lati, long),
                zoom: 17.0,
                  // tilt: 45.0,
                  // bearing: 90.0
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              markers: _markers,
              // polylines: _polylines,
              polylines: _polyline,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: true,
              onMapCreated: (GoogleMapController controller) async {
                _controller.complete(controller);
                  setState(() {
                    _markers.add(Marker(
                        markerId: MarkerId("<markerId>"),
                        position: LatLng(lati, long),
                        icon: pinLocationIcon));
                  });
                  //todo: map ki position marker point per set krne k liye
                // const oneSec = const Duration(seconds: 10);
                // _timer = new Timer.periodic(oneSec, (Timer timer) async {
                  // CameraPosition cPosition = CameraPosition(
                  //   zoom: 17,
                  //   target: LatLng(snapshot.data.data()["lati"],
                  //       snapshot.data.data()["long"]),
                  // );
                  // final GoogleMapController controller = await _controller.future;
                  // controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
                // });

              },
            )
    ): Center(child: CircularProgressIndicator());
  }

  //todo: Track between two points
  setPolylines() async{
    location = new Location();
    myLocation = await location.getLocation();

    PolylineResult  result = await polylinePoints.getRouteBetweenCoordinates("AIzaSyBrXKldoy4t4Ia6BtFbIo4cvNLphtoj3gM",
        PointLatLng(myLocation.latitude, myLocation.longitude), PointLatLng(lati, long), travelMode: TravelMode.driving);

    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(
            LatLng(point.latitude,point.longitude)
        );
      });
      if(this.mounted){
        setState(() {
          _polylines.add(Polyline(
              width: 5, // set the width of the polylines
              polylineId: PolylineId("poly"),
              visible: true,
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinates,
              // geodesic: true
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 52,
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
                    backgroundColor: Colors.yellow[400],
                    backgroundImage: NetworkImage(imagePath.toString()),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.yellow[700],
                    ),
                  ),
            SizedBox(width: 5),
            Text(
              "${widget.userName}",
              style: TextStyle(color: Colors.black),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: GestureDetector(
                onTap: (){
                  toggleView();
                },
                child: Icon(Icons.location_on, size: 30.0, color: showMapToFriend ? Colors.deepPurple[700] : Colors.white,),
               ),
            ),
          ],
        ),
        // centerTitle: true,
      ),
      body:StreamBuilder(
        stream: FirebaseFirestore.instance.collection("ChatRoom").doc(widget.chatRoomId).snapshots(),
        builder: (BuildContext context, snapshot){
          return snapshot.data.data()["$femail"] == true ? showMap():
          Container(child: Center(child: Text("Ask friend for Allow location ", style: TextStyle(fontSize: 20),)),);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.message,
          color: Colors.black,
          size: 28,
        ),
        backgroundColor: Colors.yellow[700],
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConversationScreen(widget.chatRoomId, widget.userName, widget.chatRoomFriendEmail)));
        },
      ),
    );
  }

}
