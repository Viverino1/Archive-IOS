import 'package:fbla_nlc_2024/data/providors.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:fbla_nlc_2024/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../classes.dart';

class AuthService{
  static  void resetPassword(String email, BuildContext context) {
    if(email == ""){
      showAlert("Enter Email", "Enter your email, and press \"Forgot Password\" again. We'll send you a password reset link.", context);
      return;
    }
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((e){
      showAlert("Check Email", "We've emailed a password reset link to you at ${email}.", context);
    }).catchError((e){
      if(e.code == "invalid-email"){
        showAlert("Invalid Email", "Please enter a valid email address and we'll send you a password reset link.", context);
        return;
      }
    });
  }

  static Future<UserData?> signUpWithEmail(String email, String pswrd, BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pswrd
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showAlert("Weak Password", "The password provided is too weak. Please choose a different password.", context);
      } else if (e.code == 'email-already-in-use') {
        showAlert("Email In Use", "An account already exists for the email ${email}. Try the log in button.", context);
      } else if (e.code == 'invalid-email') {
        showAlert("Invalid Email", "The email you have entered is not a valid email address.", context);
      }else {
        print(e.code);
      }
    } catch (e) {
      print(e);
    }

    if(FirebaseAuth.instance.currentUser != null){
      UserData? user = await context.read<UserProvidor>().getUser(FirebaseAuth.instance.currentUser!.uid);
      return user;
    }else{
      return null;
    }
  }

  static Future<UserData?> signInWithEmail(String email, String pswrd, BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pswrd
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAlert("Account Not Found", "We can't find an account linked to the email ${email}. Sign up to register one.", context);
      } else if (e.code == 'wrong-password') {
        showAlert("Incorrect Password", "That is not the correct password for the account linked to ${email}.", context);
      }else if(e.code == 'too-many-requests'){
        showAlert("Too Many Requests", "You've entered the wrong password too many times. Please try again later.", context);
      }else if(e.code == 'invalid-credential'){
        showAlert("Incorrect Credentials", "This username and password do not match an account.", context);
      }else {
        print(e.code);
      }
    } catch (e) {
      print(e);
    }

    if(FirebaseAuth.instance.currentUser != null){
      UserData? user = await context.read<UserProvidor>().getUser(FirebaseAuth.instance.currentUser!.uid);
      return user;
    }else{
      return null;
    }
  }

  static Future<UserData?> signInWithGoogle(BuildContext context) async{
    UserData? user = UserData();

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
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}