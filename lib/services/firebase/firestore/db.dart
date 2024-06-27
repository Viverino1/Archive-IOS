import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/services/gemini/gemini.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_input/image_input.dart';
import 'package:provider/provider.dart';
import 'package:random_name_generator/random_name_generator.dart';
import 'package:uuid/uuid.dart';

import '../../../data/providors.dart';

class TestUser{
  String firstName = "";
}

class Firestore{
  static final db = FirebaseFirestore.instance;

  static Future<UserData?> getUser(String uid, [DocumentSnapshot<Map<String, dynamic>>? snap]) async {
    UserData user = UserData();

    final docRef = db.collection("users").doc(uid);
    final docSnap = snap?? await docRef.get();

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
    user.gpa = data?["gpa"].toDouble();;
    user.psat = data?["psat"];
    user.preact = data?["preact"];
    user.school = data?["school"];
    user.volunteerHours = data?["volunteerHours"].toDouble();
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

    for(var year in data?["awards"]?.keys?.toList()){
      for(var award in data?["awards"]?[year].keys.toList()){
        AwardData awardData = new AwardData();
        awardData.title = award;
        awardData.description = data?["awards"]?[year]?[award]?["description"];
        awardData.place = data?["awards"]?[year]?[award]?["place"].toInt();
        user.awards[year]?.add(awardData);
      }
    }

    for(var year in data?["clubs"]?.keys?.toList()){
      for(var club in data?["clubs"]?[year].keys.toList()){
        ClubData clubData = new ClubData();
        clubData.name = club;
        clubData.description = data?["clubs"]?[year]?[club]?["description"];
        clubData.position = data?["clubs"]?[year]?[club]?["position"];

        user.clubs[year]?.add(clubData);
      }
    }

    return user;
  }

  static Future<UserData> updateUser(UserData user) async {
    await db.collection("users").doc(user.uid).set({
      "sat": user.sat,
      "act": user.act,
      "psat": user.psat,
      "preact": user.preact,
      "gpa": user.gpa,
      "volunteerHours": user.volunteerHours,
    }, SetOptions(merge: true));

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
      "classes": {},
      "clubs": {},
      "awards": {}
    });

    return user;
  }

  static Future<void> setUserImage(XFile img, BuildContext context) async {
    UserData user = context.read<UserProvidor>().currentUser;
    File myFile = File(img.path);
    if(await myFile.exists()){
      final storageRef = FirebaseStorage.instance.ref().child("${user.uid}/pfp");
      await storageRef.putFile(myFile);
      user.photoUrl = await storageRef.getDownloadURL();
      context.read<UserProvidor>().setCurrentUser(user);

      await db.collection("users").doc(user.uid).set({
        "photoUrl": user.photoUrl
      }, SetOptions(merge: true));
    }
  }

  static Future<void> makePost(PostData post, List<XFile> files, UserData user) async{
    final docRef = db.collection("posts").doc();
    post.id = docRef.id;
    post.uid = user.uid;
    post.user = user;
    for(int i = 0; i < files.length; i++){
      File myFile = File(files[i].path);
      if(await myFile.exists()){
        final storageRef = FirebaseStorage.instance.ref().child("${post.uid}/${post.id}/img${i}");
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
      await FirebaseStorage.instance.ref().child("${post.uid}/${post.id}/img${i}").delete();
    }
    await db.collection("posts").doc(post.id).delete();
  }

  static Future<List<PostData>> getFeedPosts(BuildContext context) async{
    List<PostData> posts = [];

    // final querySnap = await db.collection("posts").where("uid", whereIn: [user.uid]).get();
    final querySnap = await db.collection("posts")
        .where("uid", isNotEqualTo: context.read<UserProvidor>().currentUser.uid)
        .orderBy("date", descending: true)
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
        .orderBy("date", descending: true)
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

  static Future<void> addClub(ClubData club, String year, BuildContext context) async{
    UserData user = context.read<UserProvidor>().currentUser;
    DocumentReference docRef = db.collection("users").doc(user.uid);
    await docRef.set({
      "clubs": {
        year: {
          club.name: {
            "description": club.description,
            "position": club.position,
          }
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> addAward(AwardData award, String year, BuildContext context) async{
    UserData user = context.read<UserProvidor>().currentUser;
    DocumentReference docRef = db.collection("users").doc(user.uid);
    await docRef.set({
      "awards": {
        year: {
          award.title: {
            "description": award.description,
            "place": award.place,
          }
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<List<UserData>> getFollowers(BuildContext context) async{
    UserData user = context.read<UserProvidor>().currentUser;
    List<UserData> users = [];
    var snap = await db.collection("users").where("following", arrayContains: user.uid).get();
    for(var doc in snap.docs){
      UserData? follower = await context.read<UserProvidor>().getUser(doc.id, doc);
      if(follower != null){
        users.add(follower);
      }
    }
    return users;
  }

  static Future<List<UserData>> getFollowing(BuildContext context) async {
    UserData? user = await context.read<UserProvidor>().getUser(context.read<UserProvidor>().currentUser.uid);
    if(user != null){
      context.read<UserProvidor>().setCurrentUser(user);
    }
    List<UserData> users = [];
    for(var uid in user?.following?? <String>[]){
      UserData? following = await context.read<UserProvidor>().getUser(uid);
      if(following != null){
        users.add(following);
      }
    }
    return users;
  }

  static Future<void> refreshUser(BuildContext context) async{
    UserData? user = await getUser(context.read<UserProvidor>().currentUser.uid);
    if(user != null){
      context.read<UserProvidor>().setCurrentUser(user);
    }
  }
  
  static Future<List<UserData>> getAllUsersExceptFollowers(BuildContext context, List<UserData> followers) async{
    List<UserData> users = [];
    UserData currentUser = context.read<UserProvidor>().currentUser;

    var followerIDs = followers.map((e) => e.uid);
    var snap = await db.collection("users").where("uid", whereNotIn: [currentUser.uid, ...followerIDs]).get();

    for(var doc in snap.docs){
      UserData? user =  await context.read<UserProvidor>().getUser(doc.id, doc);
      if(user != null){
        users.add(user);
      }
    }
    
    return users;
  }

  static Future<void> followUser(UserData user, BuildContext context)async {
    UserData currentUser = context.read<UserProvidor>().currentUser;
    var docRef = db.collection("users").doc(currentUser.uid);
    docRef.set({
      "following": FieldValue.arrayUnion([user.uid]),
    }, SetOptions(merge: true));
  }

  static Future<void> unFollowUser(UserData user, BuildContext context)async {
    UserData currentUser = context.read<UserProvidor>().currentUser;
    var docRef = db.collection("users").doc(currentUser.uid);
    docRef.set({
      "following": FieldValue.arrayRemove([user.uid]),
    }, SetOptions(merge: true));
  }

  static Future<void> deleteClass(ClassData classData, String year, String sem, BuildContext context) async{
    UserData currentUser = context.read<UserProvidor>().currentUser;
    await db.collection("users").doc(currentUser.uid).set({
      "classes": {
        year: {
          sem: {
            classData.name: FieldValue.delete()
          }
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> deleteClub(ClubData clubData, String year, BuildContext context) async {
    UserData currentUser = context.read<UserProvidor>().currentUser;
    await db.collection("users").doc(currentUser.uid).set({
      "clubs": {
        year: {
          clubData.name: FieldValue.delete()
        }
      }
    }, SetOptions(merge: true));
  }

  static Future<void> deleteAward(AwardData awardData, String year, BuildContext context) async {
    UserData currentUser = context.read<UserProvidor>().currentUser;
    await db.collection("users").doc(currentUser.uid).set({
      "awards": {
        year: {
          awardData.title: FieldValue.delete()
        }
      }
    }, SetOptions(merge: true));
  }

  static void generateDummyUserAndPost() async{
    var randomNames = RandomNames();
    UserData user = UserData();
    user.firstName = randomNames.name();
    user.lastName = randomNames.surname();
    user.email = "${user.firstName}.${user.lastName}@example.com";
    user.uid = Uuid().v4();
    user.school = "${randomNames.surname()} High School";
    user.gradYear = Random().nextInt(3) + 2022;
    user.following.add("Z4TtJcO2Lde6SXehKVryJFmnlF72");

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
      "isFake": true,
      "classes": {}
    });


    final docRef = db.collection("posts").doc();
    PostData post = new PostData();
    post.uid = user.uid;
    post.id = docRef.id;
    post.title = (await Gemini.getResponse("Give me one academic post title of 5 words length")).replaceAll("*", "");
    post.description = (await Gemini.getResponse("Create a one sentance description for an academic post.")).replaceAll("*", "");
    post.type = "AI Generated";
    var pics = [
      "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/V29lbOnR6ZM0mquEAIWi%2Fimg0?alt=media&token=4b16ec74-caba-4abf-8342-ecc8aee07c1c",
      "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/V29lbOnR6ZM0mquEAIWi%2Fimg1?alt=media&token=4e123498-8dbd-4334-bcd1-8bcc54e009a8",
      "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/V29lbOnR6ZM0mquEAIWi%2Fimg2?alt=media&token=44611a3a-8c5d-48b2-baff-ba28279fef74",
      "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/V29lbOnR6ZM0mquEAIWi%2Fimg3?alt=media&token=7ca6dc8e-ab11-46ac-b6d2-d8ed9f6fbe66",
      "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/V29lbOnR6ZM0mquEAIWi%2Fimg4?alt=media&token=57012e71-3ec5-4a22-93f8-3402431d37b9",
      "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/V29lbOnR6ZM0mquEAIWi%2Fimg5?alt=media&token=328d812c-236e-402e-bf59-4eb5944a9ddf",
    ];

    post.pics = [pics[Random().nextInt(6)], pics[Random().nextInt(6)]];

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
  }

  static void deleteAllDummyData() async {
    for(var doc in (await db.collection("users").where("isFake", isEqualTo: true).get()).docs){
      doc.reference.delete();
    }
    for(var doc in (await db.collection("posts").where("type", isEqualTo: "AI Generated").get()).docs){
      doc.reference.delete();
    }
  }
}