import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:bildirapp/screens/homepage.dart';
import 'package:imagebutton/imagebutton.dart';
import 'package:flutter/services.dart';

final String bildirlogo = 'assets/images/logo.svg';
final String newpic = 'assets/images/new_pic.svg';
final String bnewpic = 'assets/images/new_pic_button.svg';
final String edit = 'assets/images/edit.svg';
final String loginbg = 'assets/images/loginbackgroundmd.jpg';
final String _button = "assets/images/Button.png";

class NewProfile extends StatefulWidget {
  _NewProfileState createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> {
  File _image;
  final textController = TextEditingController();
  String fullName, imageURL;
  bool validate = true;

  final databaseReference = Firestore.instance;
  // static String pattern = r'^[a-z A-Z,.\-]+$';
  // RegExp regExp = new RegExp(pattern);

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      ppStore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text(
          "Yeni Profil",
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
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            child: GestureDetector(
                              onTap: getImage,
                              child: _image == null
                                  ? SvgPicture.asset(
                                      newpic,
                                      height: 125.0,
                                      width: 125,
                                    )
                                  : ClipOval(
                                      child: Image.file(
                                        _image,
                                        height: 125,
                                        width: 125,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 85,
                            left: 90,
                            child: SvgPicture.asset(bnewpic, height: 35.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Adınızı ve soyadınızı girin",
                          textAlign: TextAlign.left,
                          style:
                              TextStyle(fontSize: 17, color: Color(0xff2daedc)),
                        ),
                      ),
                      Container(
                        child: TextField(
                          maxLength: 30,
                          controller: textController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          decoration:
                              InputDecoration(hintText: 'Örn. Ahmet Yılmaz'),
                        ),
                      ),
                      button("Devam")
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget button(String _text) {
    return Container(
      padding: EdgeInsets.only(top: 40),
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
          setState(() {
            fullName = textController.text;
            if (fullName.length == 0) {
              print("enter fullname");
              showError(context);
            } else if (!RegExp(r'^[a-z A-Z ğüöçşıİĞÜŞÖÇ,.\-]+$')
                .hasMatch(fullName)) {
              print("enter a valid fullname");
              showError(context);
            } else {
              print("valid fullname");

              createUser();
              loadingProfile(context);
            }
          });
        },
      ),
    );
  }

  ppStore() async {
    loading2(context);
    String filePath = 'profiles/${DateTime.now()}';
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(filePath);
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    await storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        imageURL = fileURL;
        // writeData();
      });
      print('File URL: $fileURL');
    });
    print('Image URL: $imageURL');
  }

  void createUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final String defaultPPURL =
        "https://firebasestorage.googleapis.com/v0/b/bildir-30903.appspot.com/o/defaultpic.png?alt=media&token=fdcc7531-05cf-4249-9683-ee9b7278c318";
    final identifier = user.phoneNumber;
    if (_image != null) {
      await databaseReference.collection("users").document(uid).setData(
          {'fullname': fullName, 'phone': identifier, 'ppURL': imageURL});
      print("USER SAVED");
    } else {
      await databaseReference.collection("users").document(uid).setData(
          {'fullname': fullName, 'phone': identifier, 'ppURL': defaultPPURL});
      print("USER SAVED");
    }
  }

  showError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Lütfen adınızı kontrol edin.'),
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

  loading2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 4), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          content: Text('Profil resmi yükleniyor...'),
        );
      },
    );
  }

  loadingProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 4), () {
          Navigator.of(context).pop(true);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyHomePage()));
        });
        return AlertDialog(
          content: Text('Profil oluşturuluyor...'),
        );
      },
    );
  }
}
