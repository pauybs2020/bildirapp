import 'dart:io';
import 'package:bildirapp/screens/details.dart';
import 'package:bildirapp/screens/newpost.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:system_settings/system_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'newpost.dart';
import 'profile.dart';
import 'details.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Image appLogo = Image(
      image: ExactAssetImage("assets/images/logo.png"),
      height: 25.0,
      width: 74.0,
      alignment: FractionalOffset.center);

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  String myUid;
  String placeName;
  String street;
  Position position;
  Widget _child;
  bool clientsToggle = false;
  List<Marker> markers = [];
  BitmapDescriptor markerImage;

  @override
  void initState() {
    super.initState();
    getMyUid();
    if (Platform.isIOS) {
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(40, 40)), 'assets/images/pin.png')
          .then((onValue) {
        markerImage = onValue;
      });
    } else {
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(80, 80)),
              'assets/images/pinandroid.png')
          .then((onValue) {
        markerImage = onValue;
      });
    }

    getCurrentLocation();
  }

  bool _progressBarActive = true;
  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    final coordinates = new Coordinates(res.latitude, res.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    await Firestore.instance
        .collection('posts')
        .where('state', isEqualTo: "${first.subAdminArea}, ${first.adminArea}")
        .getDocuments()
        .then((docs) {
      setState(() {
        placeName = "${first.subAdminArea}, ${first.adminArea}";
        street = "${first.thoroughfare}";
        position = res;
        clientsToggle = true;
        for (int i = 0; i < docs.documents.length; ++i) {
          markers.add(Marker(
              markerId: MarkerId("${docs.documents[i].documentID}"),
              draggable: false,
              onTap: () {
                print('PARENT DEBUG POINT');
              },
              infoWindow: InfoWindow(
                  title: "${docs.documents[i]['street']}",
                  snippet: "${docs.documents[i]['title']}",
                  onTap: () {
                    print('INFOWINDOW DEBUG POINT');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Details(
                                  postId: "${docs.documents[i].documentID}",
                                  title: "${docs.documents[i]['title']}",
                                  desc: "${docs.documents[i]['description']}",
                                  uid: "${docs.documents[i]['uid']}",
                                  imageURL: "${docs.documents[i]['image']}",
                                  myUid: myUid,
                                )));
                  }),
              icon: markerImage,
              position:
                  LatLng(docs.documents[i]['lat'], docs.documents[i]['lon'])));
        }

        _child = mapWidget();
        _progressBarActive = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: appLogo,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
            ),
            // Near Me Button
            IconButton(
              icon: Icon(Icons.near_me),
              onPressed: () {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      bearing: 0,
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 17.0,
                    ),
                  ),
                );
              },
            ),
            // Profile Button
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                _progressBarActive == true
                    ? print("Processign")
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profile(uid: myUid)));
              },
            ),
          ],
        ),
        body: _progressBarActive == true
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 35),
                    ),
                    Center(
                      child: Image.asset(
                        "assets/images/loading.gif",
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              "Yüklenme uzun sürüyorsa, yenile butonuna tıklayın.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFBBBBBB),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Text(
                              "Haritanın yüklenmesi için konum servislerinin açık olması gerekiyor.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFBBBBBB),
                              ),
                            ),
                          ),
                          FlatButton(
                            child: Text('AYARLAR'),
                            textColor: Color(0xFF2DAEDC),
                            onPressed: () => SystemSettings.location(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : _child,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _progressBarActive == true
                ? print("Processign")
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewPost(
                            placeName: "$placeName",
                            street: "$street",
                            lat: position.latitude,
                            lon: position.longitude,
                            uid: myUid)));
          },
          tooltip: 'Yeni Şikayet',
          child: Icon(Icons.photo_camera),
          backgroundColor: Color(0xFF2daedc),
        ),
      ),
    );
  }

  Widget mapWidget() {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17.0,
          ),
          markers: Set.from(markers),
          myLocationEnabled: true,
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              height: 35,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFBFBFBF),
                    blurRadius: 5.0, // has the effect of softening the shadow
                    spreadRadius: 1.0, // has the effect of extending the shadow
                    offset: Offset(
                      0.0, // horizontal, move right 10
                      1.0, // vertical, move down 10
                    ),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  "$placeName",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF2DAEDC)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void refresh() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  void getMyUid() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      myUid = user.uid;
    });
  }
}
