import 'dart:ffi';

import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:uuid/uuid.dart';

import '../data/providors.dart';
import '../theme.dart';
import 'academics_page.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key, required this.post, required this.onPageRefresh});
  final PostData post;
  final Future<List<CommentData>> Function() onPageRefresh;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  bool _isTextFieldActive = false;
  @override
  Widget build(BuildContext context) {
    CommentData dummyComment = CommentData();
    dummyComment.content = "You've got some great pics!";
    dummyComment.uid = "RbS0EHckGDfEoXIGHaTmchW5kTj2";
    dummyComment.id = "id1";
    dummyComment.time = 1717822800000;
    dummyComment.likes = [];
    dummyComment.replies = [];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Row(
          children: [
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.zero,
              child: const Icon(Icons.chevron_left_rounded, size: 36, color: Colors.white,),
            ),
            Container(
              alignment: AlignmentDirectional.centerStart,
              child: Text("Comments", style: title),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.only(top:78),
        child: Stack(
          children: [
            CupertinoRefresh(
              physics: const AlwaysScrollableScrollPhysics(),
              onRefresh: () async {
                final comments = await widget.onPageRefresh();
                setState(() {
                  widget.post.comments = comments;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: widget.post.comments.map((e) => Comment(comment: e, post: widget.post,)).toList(),
                ),
              ),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextField(
                    placeholder: "Add a Comment",
                    onChange: (String text){},
                    onFocusChange: (bool isActive){
                      setState(() {
                        _isTextFieldActive = isActive;
                      });
                    },

                    onSubmit: (e) async{
                      CommentData comment = CommentData();

                      comment.content = e;
                      comment.time = DateTime.now().millisecondsSinceEpoch;
                      comment.uid = context.read<UserProvidor>().currentUser.uid;
                      comment.likes = [];
                      comment.id = Uuid().v4();

                      setState(() {
                        _isTextFieldActive = false;
                        widget.post.comments.add(comment);
                      });

                      await Firestore.addComment(comment, widget.post);
                      await widget.onPageRefresh();
                    },
                  ),
                  AnimatedSize(
                    curve: Curves.easeInOut,
                    duration: Duration(milliseconds: 250),
                    child: SizedBox(height: _isTextFieldActive? 16 : 86,),
                  )
                ]
            )
          ],
        )
      ),

    );
  }
}

class TextField extends StatelessWidget {
  TextField({super.key, required this.placeholder, required this.onChange, this.onFocusChange, this.onSubmit});
  final String placeholder;
  final void Function(String e) onChange;
  final void Function(bool isFocused)? onFocusChange;
  final void Function(String text)? onSubmit;
  
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CupertinoTextField(
        suffix: Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: Container(
            height: 28,
            width: 28,
            child: CupertinoButton(
                child: Center(child: Icon(Icons.arrow_upward_rounded, size: 20,)),
                color: CupertinoTheme.of(context).primaryColor,
                minSize: 10,
                borderRadius: BorderRadius.circular(100),
                padding: EdgeInsets.zero,
                onPressed: (){
                  if(onSubmit != null){
                    onSubmit!(controller.value.text);
                  }
                  FocusScope.of(context).unfocus();
                }
            ),
          ),
        ),
        controller: controller,
        textInputAction: TextInputAction.go,
        onSubmitted: (String e){
          if(onFocusChange != null){
            onFocusChange!(false);
          }
          if(onSubmit != null){
            onSubmit!(e);
          }
        },
        onTapOutside: (e){
          FocusScope.of(context).unfocus();
          if(onFocusChange != null){
            onFocusChange!(false);
          }
        },
        onTap: (){
          if(onFocusChange != null){
            onFocusChange!(true);
          }
        },
        onChanged: (e){
          onChange(e);
        },
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: CupertinoTheme.of(context).barBackgroundColor
          ),
          borderRadius: BorderRadius.circular(100),
          color: CupertinoTheme.of(context).barBackgroundColor,
        ),
        style: subTitle,
        placeholder: placeholder,
        maxLines: null,
      ),
    );
  }
}

class Comment extends StatelessWidget {
  const Comment({super.key, required this.comment, required this.post});
  final CommentData comment;
  final PostData post;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
        future: context.read<UserProvidor>().getUser(comment.uid),
        builder: (BuildContext context, AsyncSnapshot<UserData?> snapshot){
          if(snapshot.data != null){
            UserData user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0, right: 16, left: 16),
              child: Row(children: [
                UserImage(user: user),
                SizedBox(width: 8,),
                Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: Offset(0, 0),
                          child: Row(
                            children: [
                              Text("${user.firstName} ${user.lastName}", style: subTitle,),
                              SizedBox(width: 8,),
                              CupertinoButton(
                                onPressed: () {  },
                                minSize: 0,
                                padding: EdgeInsets.symmetric(vertical: 1),
                                // color: CupertinoTheme.of(context).primaryColor,
                                child: Row(children: [
                                  Icon(CupertinoIcons.heart, size: 14),
                                  SizedBox(width: 4),
                                  Text("0 likes", style: subTitle.copyWith(color: CupertinoTheme.of(context).primaryColor))
                                ],),
                              ),
                              SizedBox(width: 8,),
                              PullDownButton(
                                onCanceled: (){
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                  itemBuilder: (context) => <PullDownMenuEntry>[
                                    PullDownMenuItem(
                                      onTap: (){},
                                      title: "Reply",
                                      icon: Icons.reply,
                                      itemTheme: PullDownMenuItemTheme(
                                          textStyle: smallTitle
                                      ),
                                    ),
                                    PullDownMenuItem(
                                      onTap: (){},
                                      title: "Delete",
                                      icon: CupertinoIcons.delete,
                                      itemTheme: PullDownMenuItemTheme(
                                        textStyle: smallTitle.copyWith(color: Colors.red)
                                      ),
                                    ),
                                  ],
                                  buttonBuilder: (context, showMenu) => CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    onPressed: showMenu,
                                    child: Icon(Icons.more_horiz_rounded, size: 20),
                                  )
                              )
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -2),
                          child: Text(comment.content, style: smallTitle, maxLines: 1, overflow: TextOverflow.ellipsis,)
                        ),
                      ],
                    ),
                  ),
              ],),
            );
          }else{
            return const Row(children: []);
          }
        }
    );
  }
}

