import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_input/image_input.dart';
import 'package:provider/provider.dart';

import '../../../data/providors.dart';

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
    user.following = List.from(data?['following']);

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
      "following": user.following,
    });

    return user;
  }

  static Future<void> makePost(PostData post, List<XFile> files, UserData user) async{
    final docRef = db.collection("posts").doc();
    post.id = docRef.id;
    post.uid = user.uid;
    post.user = user;
    for(int i = 0; i < files.length; i++){
      File myFile = File(files[i].path);
      if(await myFile.exists()){
        final storageRef = FirebaseStorage.instance.ref().child("${post.id}/img${i}");
        print("putting file ${i}");
        await storageRef.putFile(myFile);
        print("getting file ${i}");
        final url = await storageRef.getDownloadURL();
        post.pics.add(url);
      }
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
  
  static Future<void> deletePost(PostData post)async {
    for(int i = 0; i < post.pics.length; i++){
      await FirebaseStorage.instance.ref().child("${post.id}/img${i}").delete();
    }
    await db.collection("posts").doc(post.id).delete();
  }

  static Future<List<PostData>> getFeedPosts(UserData user, BuildContext context) async{
    List<PostData> posts = [];

    // final querySnap = await db.collection("posts").where("uid", whereIn: [user.uid]).get();
    final querySnap = await db.collection("posts")
        .where("uid", isNotEqualTo: user.uid)
        //.orderBy("date", descending: true)
        .get();

    for(int i = 0; i < querySnap.docs.length; i++){
      final data = querySnap.docs[i].data();
      final post = PostData();
      post.uid = data['uid'];
      post.pics = List.from(data['pics']);
      post.comments = [];
      post.description = data['description'];
      post.title = data['title'];
      post.date = data['date'];
      post.type = data['type'];
      post.id = querySnap.docs[i].id;
      post.likes = List.from(data['likes']);

      UserData? postUser = await context.read<UserProvidor>().getUser(post.uid);

      if(postUser != null){
        post.user = postUser;
      }

      List<String> keys = data['comments'].keys.toList();
      keys.forEach((e) {
        CommentData comment = CommentData();
        comment.uid = data['comments'][e]['uid'];
        comment.content = data['comments'][e]['content'];
        comment.likes = List.from(data['comments'][e]['likes']);
        comment.time = data['comments'][e]['time'];
        comment.id = e;
        post.comments.add(comment);
      });

      posts.add(post);
    }

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
      post.description = data['description'];
      post.title = data['title'];
      post.date = data['date'];
      post.type = data['type'];
      post.id = doc.id;
      post.likes = List.from(data['likes']);
      post.user = user;

      List<String> keys = data['comments'].keys.toList();
      keys.forEach((e) {
        CommentData comment = CommentData();
        comment.uid = data['comments'][e]['uid'];
        comment.content = data['comments'][e]['content'];
        comment.likes = List.from(data['comments'][e]['likes']);
        comment.time = data['comments'][e]['time'];
        comment.id = e;
        post.comments.add(comment);
      });

      posts.add(post);
    });
    return posts;
  }

  static Future<List<CommentData>> getComments(PostData post) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);
    DocumentSnapshot docSnap = await docRef.get();
    if(!docSnap.exists){
      print("null");
      return post.comments;
    }

    final List<CommentData> comments = [];

    final Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;

    List<String> keys = data['comments'].keys.toList();
    keys.forEach((key) {
      if(comments.indexWhere((e) => e.id == key) < 0){
        CommentData comment = CommentData();
        comment.uid = data['comments'][key]['uid'];
        comment.content = data['comments'][key]['content'];
        comment.likes = List.from(data['comments'][key]['likes']);
        comment.time = data['comments'][key]['time'];
        comment.id = key;
        comments.add(comment);
      }
    });

    return comments;
  }

  static Future<void> addComment(CommentData comment, PostData post) async{
    DocumentReference docRef = db.collection("posts").doc(post.id);
    docRef.set({
      "comments": {
          comment.id: {
          "content": comment.content,
          "likes": comment.likes,
          "time": comment.time,
          "uid": comment.uid,
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> removeComment(CommentData comment, PostData post) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);
    docRef.update({
      "comments": {
        comment.id: FieldValue.delete()
      }
    });
  }

  static void testFunc() async{

  }
}