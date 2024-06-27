import 'package:fbla_nlc_2024/data/providors.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../classes.dart';

class AuthService{
  static Future<UserData?> signInWithGoogle(BuildContext context) async{
    UserData? user = UserData(uid: '');

    final gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    final fbuCred = await FirebaseAuth.instance.signInWithCredential(credential);
    final fbu = fbuCred.user;

    if(fbu == null) return null;

    final fsu = await Firestore.getUser(fbu.uid);

    if(fsu == null) return null;

    user = await context.read<UserProvidor>().getUser(fsu.uid);

    return user;
  }
  static Future signOut() async{
    GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}