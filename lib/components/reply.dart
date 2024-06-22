import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import '../classes.dart';
import '../data/providors.dart';
import '../theme.dart';

class Reply extends StatefulWidget {
  const Reply({super.key, required this.reply, required this.onDelete, required this.post, required this.onLike});
  final ReplyData reply;
  final PostData post;
  final void Function() onDelete;
  final void Function() onLike;

  @override
  State<Reply> createState() => _ReplyState();
}

class _ReplyState extends State<Reply> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.reply.likes.contains(context.read<UserProvidor>().currentUser.uid);
    return FutureBuilder<UserData?>(
        future: context.read<UserProvidor>().getUser(widget.reply.uid),
        builder: (BuildContext context, AsyncSnapshot<UserData?> snapshot){
          UserData? user = snapshot.data;
          return GestureDetector(
            onTap: (){
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 32),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                UserImage(user: user, disable: user?.uid == context.read<UserProvidor>().currentUser.uid,),
                SizedBox(width: 8,),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: Offset(0, 0),
                        child: Row(
                          children: [
                            user != null? Text("${user!.firstName} ${user!.lastName}", style: subTitle,) :
                            Container(
                              height: 12,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(4)
                              ),
                            ),
                            (widget.reply.uid == context.read<UserProvidor>().currentUser.uid || widget.post.uid == context.read<UserProvidor>().currentUser.uid)?
                            PullDownButton(
                                onCanceled: (){
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                itemBuilder: (context) => <PullDownMenuEntry>[
                                  PullDownMenuItem(
                                    onTap: (){
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      widget.onDelete();
                                    },
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
                            ) : Container()
                          ],
                        ),
                      ),
                      Transform.translate(
                          offset: const Offset(0, -2),
                          child: Text(widget.reply.content, style: smallTitle, maxLines: _isExpanded? 999 : 1, overflow: TextOverflow.ellipsis,)
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
                        Text(widget.reply.likes.length > 0? widget.reply.likes.length.toString() : "", style: subTitle.copyWith(fontSize: 14, color: CupertinoTheme.of(context).primaryColor),)
                      ],
                    ),
                    onPressed: (){
                      widget.onLike();
                    }
                )
              ],),
            ),
          );
        }
    );
  }
}