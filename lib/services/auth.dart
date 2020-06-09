import 'package:bildirapp/screens/homepage.dart';
import 'package:bildirapp/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthService {
  // auth
  handleAuth() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          print('snapshot has data');
          return MyHomePage();
        } else {
          print('snapshot doesn\'t have data');
          return LoginPage();
        }
      },
    );
  }

  // sign in
  signIn(AuthCredential authCreds) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(authCreds);
    } on PlatformException {
      print('SI');
    }
  }

  // sign out
  signOut() {
    FirebaseAuth.instance.signOut();
    print('signing off');
  }

  // verification of sms code
  signInWithOTP(smsCode, verId) async {
    try {
      AuthCredential authCreds = PhoneAuthProvider.getCredential(
          verificationId: verId, smsCode: smsCode);
      await signIn(authCreds);
      print('signinwithotp');
    } on PlatformException {
      print('SIWOTP');
    }
  }
}
