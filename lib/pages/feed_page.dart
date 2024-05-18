import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/post.dart';
import '../data/providors.dart';
import '../theme.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text("Home", style: title),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints){
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 112.0),
              child: Column(
                children: context.watch<PostDataProvidor>().feedPosts.map((e) => Column(
                  children: [
                    Post(postData: e,),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        height: 2,
                        color: CupertinoTheme.of(context).barBackgroundColor,
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
          );
        }
      ),
    );
  }
}