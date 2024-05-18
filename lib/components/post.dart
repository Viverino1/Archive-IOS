// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fbla_nlc_2024/components/carousel.dart';
import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../classes.dart';
import '../utils.dart';

class Post extends StatelessWidget {
  const Post({super.key, required this.postData});
  final PostData postData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 16,),
            UserImage(user: postData.user),
            SizedBox(width: 12,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    postData.title,
                  style: smallTitle,
                ),
                Row(
                  children: [
                    Text(
                      postData.type,
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
                      formatDateTime(DateTime.fromMillisecondsSinceEpoch(postData.date)),
                      style: subTitle,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        SizedBox(height: 8,),
        Carousel(urls: postData.pics),
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
                  Text("${postData.likes.length} Likes"),
                ],
              ),
            ),
            Spacer(),
            CupertinoButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.text_bubble, size: 24,),
            ),
            CupertinoButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              child: Icon(Icons.share_outlined, size: 24,),
            ),
            CupertinoButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.trash, size: 24,),
            ),
            SizedBox(width: 8,),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 2,
              text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "${postData.user.firstName} ${postData.user.lastName}", style: smallTitle),
                    TextSpan(text: " ", style: Theme.of(context).textTheme.titleMedium),
                    TextSpan(text: postData.description, style: subTitle,)
                  ]
              ),
            ),
          ),
        )
      ],
    );
  }
}
