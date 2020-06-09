import 'package:bildirapp/screens/newprofile.dart';
import 'package:bildirapp/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:imagebutton/imagebutton.dart';

import 'homepage.dart';

const PrimaryColor = const Color(0xffffffff);

final String bildirlogo = 'assets/images/logo.svg';
final String newpic = 'assets/images/new_pic.svg';
final String bnewpic = 'assets/images/new_pic_button.svg';
final String edit = 'assets/images/edit.svg';
final String _button = "assets/images/Button.png";

class Verify extends StatefulWidget {
  final String value, verIdValue;
  Verify({this.value, this.verIdValue});

  _VerifyState createState() => _VerifyState(value, verIdValue);
}

class _VerifyState extends State<Verify> {
  String value, verIdValue;
  _VerifyState(this.value, this.verIdValue);

  final pinController = TextEditingController();
  String smsCode;
  bool validate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text(
          "SMS Doğrulama",
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
                padding: EdgeInsets.fromLTRB(30, 50, 30, 0),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Lütfen aşağıdaki numaraya gönderilen 6 haneli kodu giriniz:',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Color.fromRGBO(100, 100, 100, 1.0),
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 60),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '+90 $value',
                        style: TextStyle(
                            fontSize: 22.0,
                            color: Color.fromRGBO(45, 174, 220, 1.0),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      child: PinInputTextField(
                        controller: pinController,
                        pinLength: 6,
                        autoFocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmit: (pin) {
                          debugPrint('submit pin:$pin');
                          print(pin);
                        },
                      ),
                    ),
                    button("Devam"),
                    /*Text(
                      'Doğrulama kodu almadınız mı ?',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color.fromRGBO(100, 100, 100, 1.0),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.only(top: 25),
                      onPressed: () {},
                      child: Text(
                        "Yeniden Gönder",
                      ),
                    )*/
                  ],
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
      padding: EdgeInsets.fromLTRB(0, 100, 0, 100),
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
          setState(() async {
            //Sisteme kayıtlı mıyım değil miyim?
            smsCode = pinController.text;
            validate = smsCode.length == 6 ? true : false;
            if (validate == true) {
              loading(context);
              print(validate);
              print(smsCode);
              await AuthService().signInWithOTP(smsCode, verIdValue);
              await isSignedIn();
            } else {
              print('invalid code format');
            }
          });
        },
      ),
    );
  }

  loading(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Yükleniyor...'),
        );
      },
    );
  }

  isSignedIn() async {
    if (await FirebaseAuth.instance.currentUser() != null) {
      print('Şuanki user: ${FirebaseAuth.instance.currentUser()}');
      await userNav();
    } else {
      print('invalid code');
    }
  }

  Future<bool> doesPhoneExist(String phone) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    print("Döküman sayısı= ${documents.length}");
    return documents.length == 1;
  }

  userNav() async {
    if (await doesPhoneExist('+90$value') == true) {
      setState(() {
        print("does phone exist: ${doesPhoneExist('+90$value')}");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
      });
    } else {
      setState(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewProfile()));
      });
    }
  }
}
