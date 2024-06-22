import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/post.dart';
import '../services/firebase/firestore/db.dart';
import '../theme.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.navigateToNetworkPage});
  final void Function() navigateToNetworkPage;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<PostData> _posts = [];
  List<UserData> _following = [];

  @override
  void initState() {
    super.initState();
    Firestore.getFeedPosts(context).then((posts){
      Firestore.getFollowing(context).then((following){
        setState(() {
          _posts = posts;
          _following = following;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text("Portfoliator", style: title),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 78.0),
        child: CupertinoRefresh(
          physics: AlwaysScrollableScrollPhysics(),
          onRefresh: () async{
            var posts = await Firestore.getFeedPosts(context);
            var following = await Firestore.getFollowing(context);

            setState(() {
              _posts = posts;
              _following = following;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 102),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[SizedBox(width: 16,)] + _following.map((u) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              UserImage(
                                user: u,
                                size: 72,
                                disable: false,
                              ),
                              SizedBox(height: 2,),
                              Text(u.firstName, style: subTitle,)
                            ],
                          ),
                        )).toList() + [
                          Column(
                            children: [
                              CupertinoButton(
                                minSize: 0,
                                padding: EdgeInsets.zero,
                                child: Container(
                                  height: 72+6+8,
                                  width: 72+6+8,
                                  decoration: BoxDecoration(
                                    color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
                                    border: Border.all(
                                      color: CupertinoTheme.of(context).barBackgroundColor,
                                      width: 2
                                    ),
                                    borderRadius: BorderRadius.circular(100)
                                  ),
                                  child: Icon(CupertinoIcons.add, size: 24, color: Colors.white60,),
                                ),
                                onPressed: (){
                                  widget.navigateToNetworkPage();
                                }
                              ),
                              SizedBox(height: 2,),
                              Text("Add", style: subTitle,)
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: Container(
                    width: double.infinity,
                    height: 2,
                    color: CupertinoTheme.of(context).barBackgroundColor,
                  ),
                ),
                SizedBox(height: 12,),
              ] + _posts.map((post) => Column(children: [
                Post(
                    postData: post,
                    isMine: false,
                    disableProfile: false,
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