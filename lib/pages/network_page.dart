// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fbla_nlc_2024/components/sliding_segment.dart';
import 'package:fbla_nlc_2024/components/user_image.dart';
import 'package:fbla_nlc_2024/data/providors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class NetworkPage extends StatelessWidget {
  const NetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Container(
            alignment: AlignmentDirectional.centerStart,
            child: Text("Your Network", style: title),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 112, right: 16, left: 16),
          child: Column(
            children: [
              SlidingSegment(selected: 0, options: [
                "Followers",
                "Following",
                "Everyone"
              ],),
              SizedBox(height: 16,),
              CupertinoSearchTextField(
                backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              ),
              SizedBox(height: 16,),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      UserCard()
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoTheme.of(context).barBackgroundColor,
            width: 2
          ),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              UserImage(user: context.read<UserProvidor>().currentUser),
              SizedBox(width: 8,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Vivek Maddineni", style: smallTitle,),
                  Text("Lafayette High School", style: subTitle,),
                ],
              ),
              Spacer(),
              CupertinoButton(
                onPressed: (){},
                //color: CupertinoTheme.of(context).primaryColor,
                padding: EdgeInsets.all(6),
                minSize: 0,
                borderRadius: BorderRadius.circular(90),
                child: Icon(CupertinoIcons.add,),
              )
            ],
          ),
        ),
      ),
    );
  }
}