// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/components/post.dart';
import 'package:fbla_nlc_2024/pages/academics_page.dart';
import 'package:fbla_nlc_2024/pages/settings_page.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../classes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user, required this.isMine});
  final UserData user;
  final bool isMine;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin{
  static List<PostData> _posts = [];
  static String _lastUID = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Firestore.getUserPosts(widget.user).then((posts) => {
        setState(() {
          _posts = posts;
          _lastUID = widget.user.uid;
        })
      });
    });
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.user.uid != _lastUID){
      Firestore.getUserPosts(widget.user).then((posts) => {
        setState(() {
          _posts = posts;
          _lastUID = widget.user.uid;
        })
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_lastUID != widget.user.uid){
      setState(() {
        _posts = [];
      });
    }
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          leading: Container(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                ...(!widget.isMine? [CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  child: const Icon(Icons.chevron_left_rounded, size: 36, color: Colors.white,),
                )] : []),
                Text("Profile", style: title),
              ],
            ),
          ),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(builder: (context) => AcademicsPage(user: widget.user, isMine: widget.isMine,))
                  );
                },
                padding: EdgeInsets.zero,
                child: Icon(Icons.school_outlined, size: 28,),
              ),
              CupertinoButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                child: Icon(Icons.share_outlined, size: 24,),
              ),
              ...(widget.isMine? [
                CupertinoButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => SettingsPage())
                    );
                  },
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.settings, size: 24,),
                ),
              ] : [])
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 86),
          child: CupertinoRefresh(
              physics: AlwaysScrollableScrollPhysics(),
              onRefresh: () async {
                List<PostData> newPosts = await Firestore.getUserPosts(widget.user);
                setState(() {
                  _posts = newPosts;
                });
                return true;
              },
              child: Column(
                children: [
                  SizedBox(height: 28,),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: CupertinoTheme.of(context).primaryColor,
                                    width: 4
                                ),
                                color: Colors.transparent,
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoTheme.of(context).primaryColor,
                                    spreadRadius: 1,
                                    blurRadius: 32,
                                  ),
                                ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                height: 128,
                                width: 128,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    image: DecorationImage(
                                      image: NetworkImage(widget.user.photoUrl),
                                      fit: BoxFit.cover,
                                      alignment: FractionalOffset.center,
                                    )
                                ),
                              ),
                            ),
                          ),
                          CupertinoButton(
                              padding: EdgeInsets.all(0),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                                  border: Border.all(
                                    width: 2,
                                    color: CupertinoTheme.of(context).primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(128),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                    child: Center(
                                        child: Text(
                                          "'" + widget.user.gradYear.toString().substring(2),
                                          style: GoogleFonts.dmSerifDisplay(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                              color: CupertinoTheme.of(context).textTheme.textStyle.color
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: (){}
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text("${widget.user.firstName} ${widget.user.lastName}", style: title),
                  Text("${widget.user.school}", style: subTitle),
                  Column(
                    children: _posts.map((e) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            height: 2,
                            color: CupertinoTheme.of(context).barBackgroundColor,
                          ),
                        ),
                        Post(
                          disableProfile: true,
                          isMine: widget.isMine,
                          postData: e,
                          onDelete: () {
                            setState(() {
                              _posts.remove(e);
                            });
                          },
                          onCommentsUpdate: (List<CommentData> comments) {
                            setState(() {
                              _posts.firstWhere((post) => post.id == e.id).comments = comments;
                            });
                          },
                        ),
                      ],
                    )).toList(),
                  ),
                  SizedBox(height: 128,)
                ],
              )
          ),
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}