// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/components/sliding_segment.dart';
import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:fbla_nlc_2024/data/providors.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes.dart';
import '../theme.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});
  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  String _selected = "Everyone";
  List<UserData>? _users = null;
  List<String> _followers = [];
  String _search = "";

  List<UserData> filter(){
    List<UserData> users = [];
    users.addAll(_users!);

    if(_selected == "Followers"){
      users.removeWhere((u) => !_followers.contains(u.uid));
    }else if(_selected == "Following"){
      users.removeWhere((u) => !context.watch<UserProvidor>().currentUser.following.contains(u.uid));
    }
    
    if(_search != ""){
      users.removeWhere((e) => !(e.firstName.toLowerCase().contains(_search) || e.lastName.toLowerCase().contains(_search) || e.school.toLowerCase().contains(_search)));
    }

    return users;
  }

  @override
  void initState() {
    super.initState();
    Firestore.getFollowers(context).then((followers){
      Firestore.getAllUsersExceptFollowers(context, followers).then((usersExceptFollowers){
        var allUsers = followers + usersExceptFollowers;
        allUsers.sort((a,b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));
        setState(() {
          _users = allUsers;
          _followers = followers.map((f) => f.uid).toList();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CustomNavBar(
          height: 192,
          onChange: (e){
            setState(() {
              _selected = e;
            });
          },
          onSearch: (String s) {
            setState(() {
              _search = s.toLowerCase();
            });
          }
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 192-8, right: 12, left: 12),
          child: CupertinoRefresh(
            physics: _users == null? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
            onRefresh: (){
              Firestore.refreshUser(context);
              Firestore.getFollowers(context).then((followers){
                Firestore.getAllUsersExceptFollowers(context, followers).then((usersExceptFollowers){
                  var allUsers = followers + usersExceptFollowers;
                  allUsers.sort((a,b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));

                  setState(() {
                    _users = allUsers;
                    _followers = followers.map((f) => f.uid).toList();
                  });
                });
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 28.0),
              child: Column(
                children: _users == null? [
                  CupertinoActivityIndicator(radius: 16,),
                  Text("Loading Users", style: subTitle,)
                ] : filter().map((u) => UserCard(
                  user: u,
                  isFollowing: context.read<UserProvidor>().currentUser.following.contains(u.uid),
                  follow: (){
                    Firestore.followUser(u, context);
                    UserData user = context.read<UserProvidor>().currentUser;
                    user.following.add(u.uid);
                    context.read<UserProvidor>().setCurrentUser(user);
                  },
                  unFollow: (){
                    Firestore.unFollowUser(u, context);
                    UserData user = context.read<UserProvidor>().currentUser;
                    user.following.remove(u.uid);
                    context.read<UserProvidor>().setCurrentUser(user);
                  },
                )).toList(),
              ),
            ),
          ),
        )
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user, required this.isFollowing, required this.follow, required this.unFollow});
  final UserData user;
  final bool isFollowing;
  final void Function() follow;
  final void Function() unFollow;

  @override
  Widget build(BuildContext context) {
    void _openDialog(String title, String content, void Function() onYes, void Function() onNo, UserData user){
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Column(
              children: [
                UserImage(user: user, disable: true, size: 50,),
                SizedBox(height: 4),
                Text(title, style: smallTitle,),
              ],
            ),
            content: Text(content, style: subTitle,),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  onYes();
                },
                child: Text('Continue', style: subTitle,),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  onNo();
                },
                child: Text('Cancel', style: subTitle.copyWith(color: Colors.red),),
              ),
            ],
          )
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoTheme.of(context).barBackgroundColor,
            width: 2
          ),
          color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              UserImage(user: user, disable: user.uid == context.read<UserProvidor>().currentUser.uid,),
              SizedBox(width: 8,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${user.firstName} ${user.lastName}", style: smallTitle,),
                  Text(user.school, style: subTitle,),
                ],
              ),
              Spacer(),
              CupertinoButton(
                onPressed: (){
                  if(isFollowing){
                    _openDialog(
                        "Unfollow ${user.firstName}?",
                        "You are about to unfollow ${user.firstName} ${user.lastName}.",
                            (){
                          unFollow();
                        },
                            (){

                        },
                      user
                    );
                  }else{
                    _openDialog(
                        "Follow ${user.firstName}?",
                        "You are about to follow ${user.firstName} ${user.lastName}.",
                            (){
                          follow();
                        },
                            (){

                        },
                      user
                    );
                  }
                },
                //color: CupertinoTheme.of(context).primaryColor,
                padding: EdgeInsets.all(6),
                minSize: 0,
                borderRadius: BorderRadius.circular(90),
                child: Icon(isFollowing? CupertinoIcons.checkmark_alt : CupertinoIcons.add,),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomNavBar extends StatefulWidget implements ObstructingPreferredSizeWidget{
  const CustomNavBar({super.key, required this.height, required this.onChange, required this.onSearch});
  final double height;
  final Function(String selected) onChange;
  final Function(String s) onSearch;

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();

  @override
  bool shouldFullyObstruct(BuildContext context) {
    final Color backgroundColor = CupertinoDynamicColor.maybeResolve(CupertinoTheme.of(context).barBackgroundColor, context)
        ?? CupertinoTheme.of(context).barBackgroundColor;
    return backgroundColor.alpha == 0xFF;
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }
}

class _CustomNavBarState extends State<CustomNavBar> {
  String _selected = "Everyone";

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: Container(
          alignment: AlignmentDirectional.bottomStart,
          color: Colors.transparent,
          height: widget.height,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 12, left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text("Network", style: title,),
                    ),
                    SlidingSegment(
                      selected: _selected == "Followers"? 2 : _selected == "Following"? 1 : 0,
                      onChange: (e){
                        widget.onChange(e);
                        setState(() {
                          _selected = e;
                        });
                      },
                      options: [
                        "Everyone",
                        "Following",
                        "Followers",
                      ],),
                    SizedBox(height: 8,),
                    CupertinoSearchTextField(
                      style: smallTitle,
                      onChanged: widget.onSearch,
                      placeholder: _selected == "Everyone"? "Find more users." : "Search",
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
                        border: Border.all(
                          color: CupertinoTheme.of(context).barBackgroundColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}