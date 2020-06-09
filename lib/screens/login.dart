import 'dart:async';
import 'dart:io';
import 'package:bildirapp/screens/verify.dart';
import 'package:bildirapp/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'verify.dart';
import 'package:imagebutton/imagebutton.dart';
import 'package:geolocator/geolocator.dart';

final String bildirlogo = 'assets/images/logo.svg';
final String newpic = 'assets/images/new_pic.svg';
final String edit = 'assets/images/edit.svg';

final String loginbg = 'assets/images/loginbackgroundmd.jpg';
final String _button = "assets/images/Button.png";

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final textController = TextEditingController();
  bool validate = true;
  bool codeSent = false;
  String number, fullNumber, value, verificationId;

  final FirebaseMessaging _messaging = FirebaseMessaging();

  @override
  void initState() {
    if (Platform.isIOS) {
      _messaging.requestNotificationPermissions(IosNotificationSettings());
    }
   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(loginbg),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(30, 100, 30, 0),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 35),
                      alignment: Alignment.bottomLeft,
                      child: SvgPicture.asset(
                        bildirlogo,
                        height: 45.0,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 25),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Yaşadığın çevreyi daha iyi bir yer haline getir!',
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Color(0xffffffff),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 100),
                      child: Text(
                        'Çevrendeki sorunları vurgulayarak doğru kişilere ulaşmasına yardımcı olabilirsin.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xffffffff),
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 25),
                      child: Text(
                        'Devam etmek için numaranı gir!',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xffffffff),
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 285,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: validate == true
                            ? null
                            : Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            height: 40,
                            width: 40,
                            child: SvgPicture.asset('assets/images/turkey.svg'),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              "+90",
                              style: TextStyle(
                                color: Color(0xFF2F2E2E),
                                fontSize: 18,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Expanded(
                              child: TextField(
                                controller: textController,
                                maxLength: 10,
                                style: TextStyle(
                                  color: Color(0xFF2F2E2E),
                                  fontSize: 18,
                                ),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                    hintText: 'Telefon Numarası',
                                    hintStyle:
                                        TextStyle(color: Color(0xFFD8D8D8))),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    button("Devam")
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
      padding: EdgeInsets.only(top: 10),
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
        onTap: () async {
          number = textController.text;
          validate = number.length == 10 ? true : false;
          if (validate == true) {
            loading(context);
            print('validate = $validate');
            fullNumber = "+90$number";
            value = number;
            await verifyPhone(fullNumber);
            await waitWhile(() => codeSent);
            // Navigator.push(context,MaterialPageRoute(builder: (context) => Verify(value : value, verIdValue : verificationId)));
            if (codeSent == true) {
              print('verificationId = $verificationId');
              print('codeSend = $codeSent');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Verify(value: value, verIdValue: verificationId)));
            } else {
              print('codeSend = $codeSent');
              print('verificationId = $verificationId');
              print('Telefon numarası doğrulanamadı.');
            }
          } else {
            print('codeSend = $codeSent');
            print('validate = $validate');
          }
        },
      ),
    );
  }

  Future<void> verifyPhone(fullNumber) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
      print('authResult = $authResult');
      print('verification completed');
      print('codeSend = $codeSent');
    };

    final PhoneVerificationFailed verificationfailed =
        (AuthException authException) {
      print('${authException.message}');
      print('verification failed');
      showError2(context);
      print('codeSend = $codeSent');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
      print('AUTO TIMEOUT verificationId = $verificationId');
      print('codeSend = $codeSent');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  Future waitWhile(bool test(), [Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (test()) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }

  showError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Lütfen numaranızı kontrol edin.'),
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

  showError2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Telefon numarası doğrulanamadı.'),
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
}
