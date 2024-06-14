// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ffi';
import 'dart:ui';

import 'package:fbla_nlc_2024/components/carousel.dart';
import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../classes.dart';
import '../pages/comments_page.dart';
import '../utils.dart';

class Post extends StatefulWidget {
  Post({super.key, required this.postData, this.onDelete, required this.onCommentsRefresh});
  final PostData postData;
  final Function()? onDelete;
  final Future<List<CommentData>> Function() onCommentsRefresh;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 16,),
            UserImage(user: widget.postData.user),
            SizedBox(width: 12,),
            Container(
              width: 290,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
        Carousel(urls: widget.postData.pics),
        Row(
          children: [
            SizedBox(width: 16,),
            CupertinoButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Icon(Icons.favorite_border, size: 24,),
                  SizedBox(width: 8,),
                  Text("${widget.postData.likes.length} Likes"),
                ],
              ),
            ),
            Spacer(),
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CommentsPage(
                      post: widget.postData,
                      onPageRefresh: widget.onCommentsRefresh,
                    ))
                );
              },
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.text_bubble, size: 24,),
            ),
            CupertinoButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              child: Icon(Icons.share_outlined, size: 24,),
            ),
            CupertinoButton(
              onPressed: () async {
                if(widget.onDelete != null){
                  widget.onDelete!();
                }
                await Firestore.deletePost(widget.postData);
              },
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.trash, size: 24,),
            ),
            SizedBox(width: 8,),
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
