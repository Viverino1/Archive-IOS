import 'dart:ui';

import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../components/post.dart';
import '../data/providors.dart';
import '../services/firebase/firestore/db.dart';
import '../theme.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<PostData> _posts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      List<PostData> posts = await Firestore.getFeedPosts(context.read<UserProvidor>().currentUser, context);
      setState(() {
        _posts = posts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text("Home", style: title),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Container(),
    );
  }
}