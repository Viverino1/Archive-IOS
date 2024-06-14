import 'package:fbla_nlc_2024/components/reply.dart';
import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../classes.dart';
import '../data/providors.dart';
import '../theme.dart';

class Comment extends StatefulWidget {
  const Comment({super.key, required this.comment, required this.post, required this.onDelete, required this.onReply, required this.onLike, required this.onRepliesUpdate});
  final CommentData comment;
  final PostData post;
  final void Function() onDelete;
  final void Function(UserData user) onReply;
  final void Function() onLike;
  final void Function(List<CommentData> comments) onRepliesUpdate;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> with TickerProviderStateMixin{
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.comment.likes.contains(context.read<UserProvidor>().currentUser.uid);
    return FutureBuilder<UserData?>(
        future: context.read<UserProvidor>().getUser(widget.comment.uid),
        builder: (BuildContext context, AsyncSnapshot<UserData?> snapshot){
          UserData? user = snapshot.data;
          return GestureDetector(
            onTap: (){
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 16),
              child: Column(
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                user != null? Text("${user.firstName} ${user.lastName}", style: subTitle,) :
                                Container(
                                  height: 12,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white38,
                                    borderRadius: BorderRadius.circular(4)
                                  ),
                                ),
                                PullDownButton(
                                    onCanceled: (){
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    },
                                    itemBuilder: (context) => <PullDownMenuEntry>[
                                      PullDownMenuItem(
                                        onTap: (){
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          if(user != null){
                                            widget.onReply(user);
                                          }
                                        },
                                        title: "Reply",
                                        icon: Icons.reply,
                                        itemTheme: PullDownMenuItemTheme(
                                            textStyle: smallTitle
                                        ),
                                      ),
                                      PullDownMenuItem(
                                        onTap: (){
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          widget.onDelete();
                                        },
                                        enabled: widget.comment.uid == context.read<UserProvidor>().currentUser.uid || widget.post.uid == context.read<UserProvidor>().currentUser.uid,
                                        title: "Delete",
                                        icon: CupertinoIcons.delete,
                                        itemTheme: PullDownMenuItemTheme(
                                          textStyle: smallTitle.copyWith(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                    buttonBuilder: (context, showMenu) => CupertinoButton(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      minSize: 0,
                                      onPressed: showMenu,
                                      child: const Icon(Icons.more_horiz_rounded, size: 20),
                                    )
                                )
                              ],
                            ),
                          ),
                          Transform.translate(
                              offset: const Offset(0, -2),
                              child: Text(widget.comment.content, style: smallTitle, maxLines: _isExpanded? 999 : 1, overflow: TextOverflow.ellipsis,)
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.only(right: 16, left: 8, top: 4,),
                        child: Column(
                          children: [
                            Icon(isLiked? CupertinoIcons.heart_fill : CupertinoIcons.heart, size: 18, color: isLiked? Colors.red : CupertinoTheme.of(context).primaryColor,),
                            Text(widget.comment.likes.length > 0? widget.comment.likes.length.toString() : "", style: subTitle.copyWith(fontSize: 14, color: CupertinoTheme.of(context).primaryColor),)
                          ],
                        ),
                        onPressed: (){
                          widget.onLike();
                        }
                    )
                  ],),
                  ...widget.comment.replies.map((reply) => Reply(
                    reply: reply,
                    post: widget.post,
                    onDelete: (){
                      setState(() {
                        widget.post.comments.firstWhere((e) => e.id == widget.comment.id).replies.removeWhere((e) => e.id == reply.id);
                      });
                      widget.onRepliesUpdate(widget.post.comments);
                      Firestore.deleteReply(reply, widget.comment, widget.post);
                    },
                    onLike: (){
                      setState(() {
                        if(widget.post.comments.firstWhere((e) => e.id == widget.comment.id).replies.firstWhere((e) => e.id == reply.id).likes.contains(context.read<UserProvidor>().currentUser.uid)){
                          widget.post.comments.firstWhere((e) => e.id == widget.comment.id).replies.firstWhere((e) => e.id == reply.id).likes.remove(context.read<UserProvidor>().currentUser.uid);
                          Firestore.unLikeReply(reply, widget.comment, widget.post, context);
                        }else{
                          widget.post.comments.firstWhere((e) => e.id == widget.comment.id).replies.firstWhere((e) => e.id == reply.id).likes.add(context.read<UserProvidor>().currentUser.uid);
                          Firestore.likeReply(reply, widget.comment, widget.post, context);
                        }
                      });
                      widget.onRepliesUpdate(widget.post.comments);
                    },
                  )).toList()
                ],
              ),
            ),
          );
        }
    );
  }
}