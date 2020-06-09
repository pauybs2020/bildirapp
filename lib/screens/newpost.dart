import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagebutton/imagebutton.dart';
import 'dart:async';
import 'dart:io';
import 'homepage.dart';

final String addPhoto = "assets/images/sikayetaddphoto.svg";
final String _button = "assets/images/Button.png";
final String bnewpic = 'assets/images/new_pic_button.svg';

class NewPost extends StatefulWidget {
  final String placeName, street, uid;
  final double lat, lon;
  NewPost({this.placeName, this.lat, this.lon, this.uid, this.street});
  _NewPostState createState() => _NewPostState(
      placeName: placeName, street: street, lat: lat, lon: lon, uid: uid);
}

class _NewPostState extends State<NewPost> {
  String placeName, street, uid;
  double lat, lon;
  _NewPostState({this.placeName, this.lat, this.lon, this.uid, this.street});

  File _image;

  final databaseReference = Firestore.instance;
  String imageURL;
  TextEditingController titleController = new TextEditingController();
  TextEditingController descController = new TextEditingController();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text(
          "Yeni Şikayet",
          style: TextStyle(color: Color(0xFF646464)),
        ),
        iconTheme: IconThemeData(color: Color(0xFF646464)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 0),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: getImage,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              width: 325,
                              height: 153,
                              child: _image == null
                                  ? SvgPicture.asset(
                                      addPhoto,
                                    )
                                  : Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Image.asset(
                                            "assets/images/loading.gif",
                                          ),
                                        ),
                                        Container(
                                          width: 325,
                                          height: 153,
                                          child: Image.file(
                                            _image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            Positioned(
                              top: 105,
                              right: 15,
                              child: SvgPicture.asset(bnewpic, height: 35.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 40),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Başlık",
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(fontSize: 17, color: Color(0xff2daedc)),
                      ),
                    ),
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: titleController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Örn. Sokağımdaki çöpler toplanmıyor.'),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Şikayet Detayı",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xff2daedc),
                        ),
                      ),
                    ),
                    Container(
                      child: TextField(
                        maxLength: 140,
                        maxLines: 3,
                        keyboardType: TextInputType.text,
                        controller: descController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Örn. Tüm mahallemiz çöp kokmaya başladı. Yetkililerin bu çöpleri almasını ve koku için önlem alınmasını istiyoruz.'),
                      ),
                    ),
                    button("Paylaş")
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createRecord() async {
    String filePath = 'images/${DateTime.now()}';
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(filePath);
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        imageURL = fileURL;
        writeData();
      });
    });
  }

  void getUid() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      uid = user.uid;
    });
  }

  void writeData() async {
    DocumentReference ref = await databaseReference.collection("posts").add({
      'uid': uid,
      'title': titleController.text,
      'description': descController.text,
      'state': placeName.toString(),
      'lat': lat,
      'lon': lon,
      'street': street,
      'image': imageURL.toString(),
    });
    print(ref.documentID);
  }

  Widget button(String _text) {
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: ImageButton(
        children: <Widget>[
          Text(
            _text,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
        width: 285,
        height: 44,
        paddingTop: 20,
        pressedImage: Image.asset(
          _button,
        ),
        unpressedImage: Image.asset(_button),
        onTap: () {
          if (_image == null ||
              titleController.text == "" ||
              descController.text == "") {
            showError(context);
          } else {
            showAlert(context);
          }
        },
      ),
    );
  }

  showError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Lütfen eksik bilgileri doldurun.'),
          actions: <Widget>[
            FlatButton(
              textColor: Color(0xFF2daedc),
              child: Text("TAMAM"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              'Şu anki konumunuz, şikayetin konumu olarak paylaşılacaktır.'),
          actions: <Widget>[
            FlatButton(
              textColor: Color(0xFFB6B6B6),
              child: Text("İPTAL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              textColor: Color(0xFF2daedc),
              child: Text("DEVAM"),
              onPressed: () {
                Navigator.of(context).pop();
                createRecord();
                loadingPost(context);
              },
            ),
          ],
        );
      },
    );
  }
  loadingPost(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 5), () {
           Navigator.of(context).pop(true);
           Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
        });
        return AlertDialog(
          content: Text('Şikayet paylaşılıyor...'),
        );
      },
    );
  }
}
