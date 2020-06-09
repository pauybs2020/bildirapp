import 'package:bildirapp/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'login.dart';

const PrimaryColor = const Color(0xffffffff);

final String bildirlogo = 'assets/images/logo.svg';
final String newpic = 'assets/images/new_pic.svg';
final String bnewpiclight = 'assets/images/new_pic_light.svg';
final String edit = 'assets/images/edit.svg';

class Profile extends StatefulWidget {
  final String uid;

  Profile({this.uid});
  _ProfileState createState() => _ProfileState(uid: uid);
}

class _ProfileState extends State<Profile> {
  String uid;
  _ProfileState({this.uid});

  String fullname, phone, ppURL;
  File _image;

  TextEditingController newNameController = new TextEditingController();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      this.updatePP();
    });
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF2daedc),
        elevation: 0,
        actions: <Widget>[
          // Profile Button
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              updateFullName();
            },
          ),
          IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('Emin misin?'),
                        contentPadding: const EdgeInsets.all(16.0),
                        actions: <Widget>[
                          FlatButton(
                              child: Text('İPTAL'),
                              textColor: Color(0xFFB6B6B6),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          FlatButton(
                              child: Text('ÇIKIŞ'),
                              textColor: Color(0xFFFF9191),
                              onPressed: () {
                                AuthService().signOut();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                              })
                        ],
                      );
                    });
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius:
                              10.0, // has the effect of softening the shadow
                          spreadRadius:
                              1.0, // has the effect of extending the shadow
                          offset: Offset(
                            0.0, // horizontal, move right 10
                            3.0, // vertical, move down 10
                          ),
                        )
                      ],
                    ),
                    child: Container(
                      height: 220,
                      color: Color(0xFF2daedc),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Stack(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: getImage,
                                  child: (_image == null && ppURL == "null")
                                      ? SvgPicture.asset(
                                          newpic,
                                          height: 125.0,
                                          width: 125,
                                        )
                                      : (ppURL != "null" && _image == null)
                                          ? Stack(
                                              children: <Widget>[
                                                Container(
                                                    width: 125,
                                                    height: 125,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Color(0xFFF5F5F5),
                                                      backgroundImage:
                                                          NetworkImage(
                                                        "$ppURL",
                                                      ),
                                                    )),
                                              ],
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
                                Positioned(
                                  top: 85,
                                  left: 90,
                                  child: SvgPicture.asset(bnewpiclight,
                                      height: 35.0),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              "$fullname",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 9),
                            child: Opacity(
                              opacity: 0.6,
                              child: Text(
                                "$phone",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: uid)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> querySnapshot) {
                        if (querySnapshot.hasError) return Text('Some Error');
                        if (querySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Container(
                              child: Text(
                                "Yükleniyor...",
                                style: TextStyle(
                                  color: Color(0xFFCCCCCC),
                                ),
                              ),
                            ),
                          );
                        } else {
                          final list = querySnapshot.data.documents;

                          return list.isEmpty
                              ? Center(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(top: 50),
                                        child: Text(
                                          "HENÜZ ŞİKAYET PAYLAŞMADIN",
                                          style: TextStyle(
                                            color: Color(0xFFBBBBBB),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        padding:
                                            EdgeInsets.fromLTRB(0, 25, 0, 20),
                                        child: Text(
                                          "Geri dön ve sağ alttaki kamera butonundan şikayetini paylaş",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFFBBBBBB),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          height: 150,
                                          width: 150,
                                          child: Image.asset(
                                              'assets/images/kayityok.png')),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: list.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.only(top: 15),
                                      height: 225,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFFE6E6E6),
                                              blurRadius:
                                                  5.0, // has the effect of softening the shadow
                                              spreadRadius:
                                                  1.0, // has the effect of extending the shadow
                                              offset: Offset(
                                                0.0, // horizontal, move right 10
                                                1.0, // vertical, move down 10
                                              ),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      25, 25, 25, 10),
                                                  child: SvgPicture.asset(
                                                      'assets/images/pin.svg'),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 25, 25, 10),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.7,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    list[index]['state'],
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFFACACAC),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.all(15),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    child: FadeInImage.assetNetwork(
                                                        fit: BoxFit.cover,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        height: 60,
                                                        width: 60,
                                                        placeholder:
                                                            "assets/images/loading.gif",
                                                        image:
                                                            "${list[index]['image']}"),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.7,
                                                  child: Text(
                                                    list[index]['title'],
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              child: ButtonBar(
                                                children: <Widget>[
                                                  FlatButton(
                                                    child: Text('KALDIR'),
                                                    textColor:
                                                        Color(0xFFFF9191),
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              content: Text(
                                                                  'Emin misin?'),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      16.0),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                    child: Text(
                                                                        'İPTAL'),
                                                                    textColor:
                                                                        Color(
                                                                            0xFFB6B6B6),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    }),
                                                                FlatButton(
                                                                    child: Text(
                                                                        'KALDIR'),
                                                                    textColor:
                                                                        Color(
                                                                            0xFFFF9191),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      setState(
                                                                          () {
                                                                        Firestore
                                                                            .instance
                                                                            .collection("posts")
                                                                            .document("${list[index].documentID}")
                                                                            .delete();
                                                                      });
                                                                    })
                                                              ],
                                                            );
                                                          });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateFullName() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autofocus: true,
                    maxLength: 30,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    controller: newNameController,
                    decoration: InputDecoration(
                        labelText: 'Yeni İsim ve Soyisim',
                        hintText: 'Örn. Ahmet Yılmaz'),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text('İPTAL'),
                  textColor: Color(0xFFB6B6B6),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              FlatButton(
                  child: Text('GÜNCELLE'),
                  textColor: Color(0xFF2DAEDC),
                  onPressed: () {
                    setState(() {
                      if (newNameController.text.length == 0) {
                        print("enter fullname");
                        showError(context);
                      } else if (!RegExp(r'^[a-z A-Z ğüöçşıİĞÜŞÖÇ,.\-]+$')
                          .hasMatch(newNameController.text)) {
                        print("enter a valid fullname");
                        showError(context);
                      } else {
                        fullname = newNameController.text;
                        Firestore.instance
                            .collection('users')
                            .document(uid)
                            .updateData({"fullname": newNameController.text});
                        Navigator.pop(context);
                      }
                    });
                  })
            ],
          );
        });
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
          content: Text('Profil resmi güncelleniyor...'),
        );
      },
    );
  }

  void updatePP() async {
    String filePath = 'profiles/${DateTime.now()}';
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(filePath);
    loading2(context);
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        Firestore.instance
            .collection('users')
            .document(uid)
            .updateData({"ppURL": fileURL});
      });
    });
  }

  void getProfile() async {
    await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds['ppURL'] == "null") {
        setState(() {
          fullname = ds['fullname'];
          phone = ds['phone'];
          ppURL =
              "https://firebasestorage.googleapis.com/v0/b/bildir-30903.appspot.com/o/defaultpic.png?alt=media&token=fdcc7531-05cf-4249-9683-ee9b7278c318";
        });
      } else {
        setState(() {
          fullname = ds['fullname'];
          phone = ds['phone'];
          ppURL = ds['ppURL'];
        });
      }
    });
  }
}
