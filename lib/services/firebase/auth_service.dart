import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../classes.dart';

class AuthService{
  static Future<UserData?> signInWithGoogle() async{
    UserData user = UserData();

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

    user.email = fsu.email;
    user.photoUrl = fsu.photoUrl;
    user.firstName = fsu.firstName;
    user.lastName = fsu.lastName;
    user.school = fsu.school;

    return user;
  }
  static Future signOut() async{
    GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}