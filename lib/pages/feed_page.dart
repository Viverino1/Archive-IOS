import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/post.dart';
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
      Firestore.getFeedPosts(context).then((posts) => {
        setState(() {
          _posts = posts;
        }),
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text("Home", style: title),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 78.0),
        child: CupertinoRefresh(
          physics: AlwaysScrollableScrollPhysics(),
          onRefresh: () async{
            List<PostData> newPosts = await Firestore.getFeedPosts(context);
            //print(newPosts.length);
            setState(() {
              _posts = newPosts;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Column(
              children: _posts.map((post) => Column(children: [
                Post(
                    postData: post,
                    onDelete: (){
                      setState(() {
                        _posts.remove(post);
                      });
                    },
                    onCommentsUpdate: (comments){
                      setState(() {
                        _posts.firstWhere((p) => p.id == post.id).comments = comments;
                      });
                    }
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    height: 2,
                    color: CupertinoTheme.of(context).barBackgroundColor,
                  ),
                ),
              ])).toList(),
            ),
          ),
        ),
      ),
    );
  }
}