import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/components/post.dart';
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
    user.gpa = data?["gpa"];
    user.psat = data?["psat"];
    user.preact = data?["preact"];
    user.school = data?["school"];
    user.volunteerHours = data?["volunteerHours"];
    user.gradYear = data?["gradYear"];
    user.following = List.from(data?['following']);

    for(var year in data?["classes"].keys.toList()){
      for(var sem in data?["classes"][year].keys.toList()){
        for(var className in data?["classes"][year][sem].keys.toList()){
          Map<String, dynamic> classData = data?["classes"][year][sem][className];
          ClassData classDataObj = ClassData();

          classDataObj.name = className;
          classDataObj.grade = classData["grade"];
          classDataObj.description = classData["description"];

          user.classData[year]?[sem]?.add(classDataObj);
        }
      }
    }

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
      "gpa": user.gpa,
      "volunteerHours": user.volunteerHours,
      "gradYear": user.gradYear,
      "following": user.following,
      "classes": {

      }
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

  static Future<List<PostData>> getFeedPosts(BuildContext context) async{
    List<PostData> posts = [];

    // final querySnap = await db.collection("posts").where("uid", whereIn: [user.uid]).get();
    final querySnap = await db.collection("posts")
        .where("uid", isNotEqualTo: context.read<UserProvidor>().currentUser.uid)
        //.orderBy("date", descending: true)
        .get();

    for(var doc in querySnap.docs){
      final data = doc.data();
      final post = PostData();
      post.uid = data['uid'];
      post.pics = List.from(data['pics']);
      post.description = data['description'];
      post.title = data['title'];
      post.date = data['date'];
      post.type = data['type'];
      post.id = doc.id;
      post.likes = List.from(data['likes']);
      post.user = (await context.read<UserProvidor>().getUser(post.uid))?? UserData();

      List<String> commentIDs = data['comments'].keys.toList();
      for (var cID in commentIDs) {
        CommentData comment = CommentData();
        comment.uid = data['comments'][cID]['uid'];
        comment.content = data['comments'][cID]['content'];
        comment.likes = List.from(data['comments'][cID]['likes']);
        comment.time = data['comments'][cID]['time'];
        comment.id = cID;

        List<String> replyIDs = data['comments'][cID]['replies'].keys.toList();
        for(var rID in replyIDs){
          ReplyData reply = ReplyData();
          reply.uid = data['comments'][cID]['replies'][rID]['uid'];
          reply.content = data['comments'][cID]['replies'][rID]['content'];
          reply.likes = List.from(data['comments'][cID]['replies'][rID]['likes']);
          reply.time = data['comments'][cID]['replies'][rID]['time'];
          reply.id = rID;

          comment.replies.add(reply);
        }

        post.comments.add(comment);
      }

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

      List<String> commentIDs = data['comments'].keys.toList();
      for (var cID in commentIDs) {
        CommentData comment = CommentData();
        comment.uid = data['comments'][cID]['uid'];
        comment.content = data['comments'][cID]['content'];
        comment.likes = List.from(data['comments'][cID]['likes']);
        comment.time = data['comments'][cID]['time'];
        comment.id = cID;

        List<String> replyIDs = data['comments'][cID]['replies'].keys.toList();
        for(var rID in replyIDs){
          ReplyData reply = ReplyData();
          reply.uid = data['comments'][cID]['replies'][rID]['uid'];
          reply.content = data['comments'][cID]['replies'][rID]['content'];
          reply.likes = List.from(data['comments'][cID]['replies'][rID]['likes']);
          reply.time = data['comments'][cID]['replies'][rID]['time'];
          reply.id = rID;

          comment.replies.add(reply);
        }

        post.comments.add(comment);
      }

      posts.add(post);
    });
    return posts;
  }

  static Future<void> likePost(PostData post, BuildContext context) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);

    await docRef.set({
      "likes": FieldValue.arrayUnion([context.read<UserProvidor>().currentUser.uid])
    }, SetOptions(merge: true));
  }

  static Future<void> unLikePost(PostData post, BuildContext context) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);

    await docRef.set({
      "likes": FieldValue.arrayRemove([context.read<UserProvidor>().currentUser.uid])
    }, SetOptions(merge: true));
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

    List<String> commentIDs = data['comments'].keys.toList();
    for (var cID in commentIDs) {
      CommentData comment = CommentData();
      comment.uid = data['comments'][cID]['uid'];
      comment.content = data['comments'][cID]['content'];
      comment.likes = List.from(data['comments'][cID]['likes']);
      comment.time = data['comments'][cID]['time'];
      comment.id = cID;

      List<String> replyIDs = data['comments'][cID]['replies'].keys.toList();
      for(var rID in replyIDs){
        ReplyData reply = ReplyData();
        reply.uid = data['comments'][cID]['replies'][rID]['uid'];
        reply.content = data['comments'][cID]['replies'][rID]['content'];
        reply.likes = List.from(data['comments'][cID]['replies'][rID]['likes']);
        reply.time = data['comments'][cID]['replies'][rID]['time'];
        reply.id = rID;

        comment.replies.add(reply);
      }

      comments.add(comment);
    }

    return comments;
  }

  static Future<void> addComment(CommentData comment, PostData post) async{
    DocumentReference docRef = db.collection("posts").doc(post.id);
    await docRef.set({
      "comments": {
          comment.id: {
          "content": comment.content,
          "likes": [],
          "time": comment.time,
          "uid": comment.uid,
          "replies": {},
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> deleteComment(CommentData comment, PostData post) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);
    await docRef.set({
      "comments": {
        comment.id: FieldValue.delete()
      }
    }, SetOptions(merge: true));
  }

  static Future<void> likeComment(CommentData comment, PostData post, BuildContext context) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);

    await docRef.set({
      "comments": {
        comment.id: {
          "likes": FieldValue.arrayUnion([context.read<UserProvidor>().currentUser.uid])
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> unLikeComment(CommentData comment, PostData post, BuildContext context) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);

    await docRef.set({
      "comments": {
        comment.id: {
          "likes": FieldValue.arrayRemove([context.read<UserProvidor>().currentUser.uid])
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> addReply(ReplyData reply, CommentData comment, PostData post) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);
    await docRef.set({
      "comments": {
        comment.id: {
          "replies": {
            reply.id: {
              "content": reply.content,
              "likes": reply.likes,
              "time": reply.time,
              "uid": reply.uid,
            }
          }
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> deleteReply(ReplyData reply, CommentData comment, PostData post) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);
    await docRef.set({
      "comments": {
        comment.id: {
          "replies": {
            reply.id: FieldValue.delete()
          }
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> likeReply(ReplyData reply, CommentData comment, PostData post, BuildContext context) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);

    await docRef.set({
      "comments": {
        comment.id: {
          "replies": {
            reply.id: {
              "likes": FieldValue.arrayUnion([context.read<UserProvidor>().currentUser.uid])
            }
          }
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> unLikeReply(ReplyData reply, CommentData comment, PostData post, BuildContext context) async {
    DocumentReference docRef = db.collection("posts").doc(post.id);

    await docRef.set({
      "comments": {
        comment.id: {
          "replies": {
            reply.id: {
              "likes": FieldValue.arrayRemove([context.read<UserProvidor>().currentUser.uid])
            }
          }
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> addClass(ClassData classData, String year, String sem, BuildContext context) async{
    UserData user = context.read<UserProvidor>().currentUser;
    DocumentReference docRef = db.collection("users").doc(user.uid);
    await docRef.set({
      "classes": {
        year: {
          sem: {
            classData.name: {
              "description": classData.description,
              "grade": classData.grade,
            }
          }
        }
      }
    }, SetOptions(merge: true));
  }

  static void testFunc() async{

  }
}