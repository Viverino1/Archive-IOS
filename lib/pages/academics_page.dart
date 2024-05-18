// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../theme.dart';

class AcademicsPage extends StatelessWidget {
  const AcademicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Container(
            alignment: AlignmentDirectional.centerStart,
            child: Text("Your Academics", style: title),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints){
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 112,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Circle(label: "Pre-ACT", value: "31"),
                      SizedBox(width: 16,),
                      Circle(label: "Hours", value: "122"),
                      SizedBox(width: 16,),
                      Circle(label: "Pre-SAT", value: "1310"),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Circle(label: "ACT", value: "34"),
                      SizedBox(width: 16,),
                      Circle(label: "GPA", value: "3.8"),
                      SizedBox(width: 16,),
                      Circle(label: "SAT", value: "1440"),
                    ],
                  ),
                  SizedBox(height: 16,),
                  CupertinoListSection(
                    header: Row(
                      children: [
                        Text('Freshman Year (23-24)', style: title.copyWith(color: Colors.white),),
                        Spacer(),
                        PullDownButton(
                          itemBuilder: (context) => ["Rising Freshman", "Freshman", "Rising Sophomore", "Sophomore", "Rising Junior", "Junior", "Rising Senior", "Senior"].map((e) =>
                              PullDownMenuItem(
                                title: e,
                                onTap: () {},
                              ),
                          ).toList(),
                          buttonBuilder: (context, showMenu) => CupertinoButton(
                            onPressed: showMenu,
                            padding: EdgeInsets.zero,
                            child: const Icon(CupertinoIcons.ellipsis_circle),
                          ),
                        )
                      ],
                    ),
                    children: ["Honors Geometry", "ALARP 1", "Honors Biology", "Photography 1", "Intro to Programming", "Intro to Engineering", "Honors US History", "Spanish 1"].map((e) =>
                        CupertinoListTile(
                          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
                          title: Text(e, style: smallTitle.copyWith(color: Colors.white60),),
                          leading: Container(
                            width: 28,
                            height: 28,
                            
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color.alphaBlend(CupertinoColors.systemGreen.withOpacity(
                                e == "ALARP 1"? 0.4 : e == "Honors US History"? 0.55 : 1
                              ), CupertinoColors.systemRed),
                            ),
                          ),
                          trailing: CupertinoListTileChevron(),
                        )
                    ).toList(),
                  ),
                  SizedBox(height: 128,)
                ],
              ),
            );
          },
        )
    );
  }
}

class Circle extends StatelessWidget {
  const Circle({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: CupertinoTheme.of(context).primaryColor,
              width: 4
          ),
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 36,
              child: Text(value, style: title.copyWith(fontSize: 32),),
            ),
            Text(label, style: subTitle, textAlign: TextAlign.center,),
          ],
        )
    );
  }
}