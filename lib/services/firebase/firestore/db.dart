import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_input/image_input.dart';

class TestUser{
  String firstName = "";
}

class Firestore{
  static final db = FirebaseFirestore.instance;

  static Future<UserData?> getUser(String uid) async {
    UserData user = UserData();

    final docRef = db.collection("users").doc(uid);
    final docSnap = await docRef.get();

    if(!docSnap.exists){
      return null;
    }

    final data = docSnap.data();

    user.email = data?["email"];
    user.photoUrl = data?["photoUrl"];
    user.firstName = data?["firstName"];
    user.lastName = data?["lastName"];
    user.uid = data?["uid"];
    user.sat = data?["sat"];
    user.act = data?["act"];
    user.psat = data?["psat"];
    user.preact = data?["preact"];
    user.school = data?["school"];
    user.volunteerHours = data?["volunteerHours"];
    user.gradYear = data?["gradYear"];

    return user;
  }

  static Future<UserData> registerUser(UserData user) async {
    final User fbu = FirebaseAuth.instance.currentUser!;
    user.email = fbu.email?? "";
    user.photoUrl = fbu.photoURL?? UserData().photoUrl;
    user.uid = fbu.uid;

    await db.collection("users").doc(user.uid).set({
      "email": user.email,
      "photoUrl": user.photoUrl,
      "firstName": user.firstName,
      "lastName": user.lastName,
      "uid": user.uid,
      "sat": user.sat,
      "act": user.act,
      "psat": user.psat,
      "preact": user.preact,
      "school": user.school,
      "volunteerHours": user.volunteerHours,
      "gradYear": user.gradYear,
    });

    return user;
  }



  static Future<void> makePost(PostData post, List<XFile> files, UserData user) async{
    final docRef = db.collection("posts").doc();
    post.id = docRef.id;
    post.uid = user.uid;
    post.user = user;

    print(files.length);

    for(int i = 0; i < files.length; i++){
      File myFile = File(files[i].path);
      final storageRef = FirebaseStorage.instance.ref().child("${post.id}/${myFile.path.replaceAll(myFile.parent.path + "/", "")}");
      print("putting file ${i}");
      await storageRef.putFile(myFile);
      print("getting file ${i}");
      final url = await storageRef.getDownloadURL();
      post.pics.add(url);
    }

    print("Setting postData");

    await docRef.set({
      "description": post.description,
      "likes": post.likes,
      "date": post.date,
      "title": post.title,
      "type": post.type,
      "uid": post.uid,
      "pics": post.pics,
      "comments": {},
    });

    print("Finished!");

    return;
  }

  static Future<List<PostData>> getFeedPosts(UserData user) async{
    List<PostData> posts = [];

    // final querySnap = await db.collection("posts").where("uid", whereIn: [user.uid]).get();
    final querySnap = await db.collection("posts")
        .where("uid", isNotEqualTo: user.uid)
        //.orderBy("date", descending: true)
        .get();

    querySnap.docs.forEach((doc) async{
      final data = doc.data();
      final post = PostData();
      post.uid = user.uid;
      post.pics = List.from(data['pics']);
      post.comments = [];
      post.description = data['description'];
      post.title = data['title'];
      post.date = data['date'];
      post.type = data['type'];
      post.id = doc.id;
      post.likes = List.from(data['likes']);
      post.user = user;

      posts.add(post);
    });

    return posts;
  }
  
  static Future<List<PostData>> getUserPosts(UserData user) async{
    List<PostData> posts = [];
    
    final querySnap = await db.collection("posts")
        .where("uid", isEqualTo: user.uid)
        //.orderBy("date", descending: true)
        .get();

    querySnap.docs.forEach((doc) async{
      final data = doc.data();
      final post = PostData();
      post.uid = user.uid;
      post.pics = List.from(data['pics']);
      post.comments = [];
      post.description = data['description'];
      post.title = data['title'];
      post.date = data['date'];
      post.type = data['type'];
      post.id = doc.id;
      post.likes = List.from(data['likes']);
      post.user = user;

      posts.add(post);
    });

    return posts;
  }

  static void testFunc() async{

  }
}