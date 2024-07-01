// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:fbla_nlc_2024/components/carousel.dart';
import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:fbla_nlc_2024/services/share/Share.dart';
import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes.dart';
import '../data/providors.dart';
import '../pages/comments_page.dart';
import '../utils.dart';

class Post extends StatefulWidget {
  Post({super.key, required this.postData, this.onDelete, required this.onCommentsUpdate, required this.isMine, required this.disableProfile});
  final PostData postData;
  final Function()? onDelete;
  final Function(List<CommentData> comments) onCommentsUpdate;
  final bool isMine;
  final bool disableProfile;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  bool _isExpanded = false;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.postData.likes.contains(context.read<UserProvidor>().currentUser.uid);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 16,),
            UserImage(user: widget.postData.user, disable: widget.isMine || widget.disableProfile,),
            SizedBox(width: 12,),
            Container(
              width: 290,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strutStyle: StrutStyle(forceStrutHeight: true),
                    widget.postData.title,
                    style: smallTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        widget.postData.type,
                        style: subTitle,
                      ),
                      SizedBox(width: 8,),
                      Container(
                        height: 4,
                        width: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(width: 8,),
                      Text(
                        formatDateTime(DateTime.fromMillisecondsSinceEpoch(widget.postData.date)),
                        style: subTitle,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8,),
        Carousel(urls: widget.postData.pics, disableDots: true, onIndexChange: (i){
          setState(() {
            _index = i;
          });
        },),
        SizedBox(height: 8,),
        Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: 32,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.postData.pics.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: widget.postData.pics.indexOf(item) == _index?
                          Colors.white60 :
                          Colors.white60.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  )).toList()
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 32,
              child: Row(
                children: [
                  SizedBox(width: 16,),
                  CupertinoButton(
                    onPressed: () {
                      isLiked? Firestore.unLikePost(widget.postData, context) : Firestore.likePost(widget.postData, context);
                      setState(() {
                        isLiked?
                        widget.postData.likes.removeWhere((uid) => uid == context.read<UserProvidor>().currentUser.uid) :
                        widget.postData.likes.add(context.read<UserProvidor>().currentUser.uid);
                      });
                    },
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        Icon(isLiked? CupertinoIcons.heart_fill : CupertinoIcons.heart, size: 22, color: isLiked? Colors.red : CupertinoTheme.of(context).primaryColor,),
                        SizedBox(width: 4,),
                        Text("${widget.postData.likes.length} Likes", style: smallTitle.copyWith(color: CupertinoTheme.of(context).primaryColor),),
                      ],
                    ),
                  ),
                  Spacer(),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (context) => CommentsPage(
                            post: widget.postData,
                            onCommentsUpdate: widget.onCommentsUpdate,
                          ))
                      );
                    },
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    minSize: 0,
                    child: Icon(CupertinoIcons.text_bubble, size: 22,),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      InstaShare.share(widget.postData);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    minSize: 0,
                    child: Icon(Icons.share_outlined, size: 22,),
                  ),
                  ...(widget.isMine? [
                    CupertinoButton(
                      onPressed: () async {
                        if(widget.onDelete != null){
                          widget.onDelete!();
                        }
                        await Firestore.deletePost(widget.postData);
                      },
                      minSize: 0,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(CupertinoIcons.trash, size: 22,),
                    ),
                  ] : []),
                  SizedBox(width: 8,),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: (){
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: RichText(
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: _isExpanded? 999 : 2,
              text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "${widget.postData.user.firstName} ${widget.postData.user.lastName}", style: smallTitle),
                    TextSpan(text: " ", style: Theme.of(context).textTheme.titleMedium),
                    TextSpan(text: widget.postData.description, style: subTitle,)
                  ]
              ),
            ),
          )
        )
      ],
    );
  }
}
