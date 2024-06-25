// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/pages/add_class_page.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:fbla_nlc_2024/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../data/providors.dart';
import '../theme.dart';

class AcademicsPage extends StatefulWidget {
  const AcademicsPage({super.key, required this.user, required this.isMine});
  final UserData user;
  final bool isMine;

  @override
  State<AcademicsPage> createState() => _AcademicsPageState();
}

class _AcademicsPageState extends State<AcademicsPage> {
  String _year = "freshman";
  String _sem = "sem1";
  List<PostData>? _posts = null;

  @override
  void initState() {
    super.initState();
    Firestore.getUserPosts(widget.user).then((data) => setState(() {
      _posts = data;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          leading: Container(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  child: const Icon(Icons.chevron_left_rounded, size: 36, color: Colors.white,),
                ),
                Text("${widget.user.firstName}'s Portfolio", style: title),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 86),
          child: CupertinoRefresh(
            physics: AlwaysScrollableScrollPhysics(),
            onRefresh: (){

            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Circle(label: "Pre-ACT", value: widget.user.preact.toString()),
                    SizedBox(width: 16,),
                    Circle(label: "Service\nHours", value: widget.user.volunteerHours.toInt().toString()),
                    SizedBox(width: 16,),
                    Circle(label: "Pre-SAT", value: widget.user.psat.toString()),
                  ],
                ),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Circle(label: "ACT", value: widget.user.act.toString()),
                    SizedBox(width: 16,),
                    Circle(label: "GPA", value: widget.user.gpa.toString()),
                    SizedBox(width: 16,),
                    Circle(label: "SAT", value: widget.user.sat.toString()),
                  ],
                ),
                SizedBox(height: 16,),
                CupertinoListSection(
                  header: Row(
                    children: [
                      Text("Classes", style: title.copyWith(color: Colors.white),),
                      SizedBox(width: 8,),
                      SchoolYearPicker(
                          options: widget.user.classData.keys.toList(),
                          startYear: _year,
                          onChange: (String e) {
                            setState(() {
                              _year = e;
                            });
                          }
                      ),
                      SizedBox(width: 8,),
                      !_year.contains("rising")? SemPicker(
                        options: widget.user.classData[_year]!.keys.toList(),
                        startSem: _sem,
                        onChange: (String e) {
                          setState(() {
                            _sem = e;
                          });
                        },
                      ) : Container(),
                      Spacer(),
                      ...(widget.isMine? [
                        CupertinoButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => AddClassPage(
                                  startSem: _sem,
                                  startYear: _year,
                                ))
                            );
                          },
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(10),
                          minSize: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CupertinoTheme.of(context).primaryColor,
                                      spreadRadius: 0,
                                      blurRadius: 12,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: CupertinoTheme.of(context).primaryColor.withOpacity(0.25),
                                      width: 2
                                  )
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.5)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4, right: 8, top: 1, bottom: 1),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.add, size: 22, color: Colors.white,),
                                      SizedBox(width: 2,),
                                      Text("Add", style: subTitle.copyWith(color: Colors.white, fontSize: 16),),
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ),
                      ] : [])
                    ],
                  ),
                  children: widget.user.classData[_year]?[_sem]?.map((e) =>
                      CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                            context: context,
                            barrierColor: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                            backgroundColor: CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
                            builder: (context) => Container(
                              height: MediaQuery.of(context).size.height - 200,
                              child: Stack(
                                children: [
                                  Container(
                                    alignment: Alignment.topRight,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: CupertinoButton(
                                        padding: EdgeInsets.all(8),
                                        borderRadius: BorderRadius.circular(200),
                                        color: Colors.white30,
                                        minSize: 0,
                                        onPressed: (){
                                          setState(() {
                                            widget.user.classData[_year]?[_sem]?.remove(e);
                                          });
                                          Navigator.pop(context);
                                          Firestore.deleteClass(e, _year, _sem, context);
                                        },
                                        child: Icon(CupertinoIcons.trash, size: 22, color: Colors.white60),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 12,),
                                        Transform.translate(
                                            offset: Offset(0, 4),
                                            child: Text((_year.toLowerCase().contains("rising")? "Summer Break" : "Semester ${_sem == "sem1"? "1" : "2"}"), style: subTitle,)
                                        ),
                                        Text(e.name, style: title,),
                                        SizedBox(height: 8,),
                                        Text("Details", style: smallTitle,),
                                        RichText(
                                            text: TextSpan(
                                                children: [
                                                  TextSpan(text: "${widget.user.firstName} ${widget.user.lastName} earned a grade of ", style: subTitle),
                                                  TextSpan(text: "${e.grade}%", style: smallTitle),
                                                  TextSpan(text: " in the class ${e.name} during the ${_year.toLowerCase().contains("rising")? "summer before" : _sem == "sem1"? "first semester of" : "second semester of"} their ", style: subTitle),
                                                  TextSpan(text: "${formatYear(_year).replaceAll("Rising ", "")}", style: smallTitle),
                                                  TextSpan(text: " year of High School.", style: subTitle),
                                                ]
                                            )
                                        ),
                                        // Text("${e.grade}%", style: smallTitle,),
                                        SizedBox(height: 12,),
                                        Text("Description", style: smallTitle,),
                                        SizedBox(height: 3,),
                                        Text(e.description, style: subTitle,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: CupertinoListTile(
                          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
                          title: Text(e.name, style: smallTitle),
                          subtitle: Text("Grade: ${e.grade}%", style: subTitle.copyWith(fontSize: 12),),
                          leadingSize: 32,
                          leadingToTitle: 12,
                          leading: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                                border: Border.all(
                                    color: CupertinoTheme.of(context).primaryColor,
                                    width: 2
                                )
                              // color: Color.alphaBlend(CupertinoTheme.of(context).primaryColor.withOpacity(
                              //   pow(e.grade/100, 4).toDouble()
                              // ), CupertinoColors.systemRed),
                            ),
                            child: Text(gradeToLetter(e.grade), style: smallTitle.copyWith(color: Colors.white),),
                          ),
                          trailing: CupertinoListTileChevron(),
                        ),
                      )
                  ).toList(),
                ),
                ...((widget.user.classData[_year]?[_sem]?.length != null && widget.user.classData[_year]![_sem]!.length > 0)? [] : [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("${widget.isMine? "You have" : "This user has"} not added any classes taken as a${_year.contains("rising")? "" : _sem == "sem1"? " first semester" : " second semester"} ${formatYear(_year).toLowerCase()}.${widget.isMine? " Press the \"Add\" button above to add one.": ""}", style: subTitle,),
                  ),
                ]),
                CupertinoListSection(
                  header: Row(
                    children: [
                      Text("Updates", style: title.copyWith(color: Colors.white),),
                      SizedBox(width: 8,),
                      Spacer(),
                      ...(widget.isMine? [
                        CupertinoButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => AddClassPage(
                                  startSem: _sem,
                                  startYear: _year,
                                ))
                            );
                          },
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(10),
                          minSize: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CupertinoTheme.of(context).primaryColor,
                                      spreadRadius: 0,
                                      blurRadius: 12,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: CupertinoTheme.of(context).primaryColor.withOpacity(0.25),
                                      width: 2
                                  )
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.5)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4, right: 8, top: 1, bottom: 1),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.add, size: 22, color: Colors.white,),
                                      SizedBox(width: 2,),
                                      Text("Add", style: subTitle.copyWith(color: Colors.white, fontSize: 16),),
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ),
                      ] : [])
                    ],
                  ),
                  children: _posts?.map((e) =>
                      CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: CupertinoListTile(
                          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
                          title: Text(e.title, style: smallTitle),
                          subtitle: Text(e.description, style: subTitle.copyWith(fontSize: 12),),
                          leadingSize: 32,
                          trailing: CupertinoListTileChevron(),
                          leadingToTitle: 12,
                          // leading: Container(
                          //   width: 32,
                          //   height: 32,
                          //   alignment: Alignment.center,
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(8),
                          //       color: CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                          //       border: Border.all(
                          //           color: CupertinoTheme.of(context).primaryColor,
                          //           width: 2
                          //       )
                          //     // color: Color.alphaBlend(CupertinoTheme.of(context).primaryColor.withOpacity(
                          //     //   pow(e.grade/100, 4).toDouble()
                          //     // ), CupertinoColors.systemRed),
                          //   ),
                          //   child: Text(gradeToLetter(e.grade), style: smallTitle.copyWith(color: Colors.white),),
                          // ),
                        ),
                      )
                  ).toList(),
                ),
                ...((_posts != null && _posts!.length > 0) || _posts == null? [] : [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("${widget.isMine? "You have" : "This user has"} not created any updates. ${widget.isMine? " Press the \"Add\" button above to add one.": ""}", style: subTitle,),
                  ),
                ]),
                SizedBox(height: 128,)
              ],
            ),
          ),
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
              width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoTheme.of(context).primaryColor,
              spreadRadius: 0,
              blurRadius: 12,
            ),
          ],
        ),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.75),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 36,
                child: Text(value == "-1"? "N/A" : value, style: title.copyWith(fontSize: 32),),
              ),
              SizedBox(height: 4),
              Text(label, style: subTitle.copyWith(height: 0.85), textAlign: TextAlign.center,),
            ],
          ),
        )
    );
  }
}

class SchoolYearPicker extends StatefulWidget {
  SchoolYearPicker({super.key, required this.options, required this.onChange, required this.startYear});
  final List<String> options;
  final void Function(String e) onChange;
  final String startYear;

  @override
  State<SchoolYearPicker> createState() => SchoolYearPickerState();
}

class SchoolYearPickerState extends State<SchoolYearPicker> {
  int _selected = 1;

  @override
  void initState() {
    super.initState();
    _selected = context.read<UserProvidor>().currentUser.classData.keys.toList().indexOf(widget.startYear);
  }

  void reset(){
    setState(() {
      _selected = 0;
    });
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoButton(
          onPressed: () => _showDialog(
            CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              // This sets the initial item.
              scrollController: FixedExtentScrollController(
                initialItem: _selected,
              ),
              // This is called when selected item is changed.
              onSelectedItemChanged: (int selectedItem) {
                setState(() {
                  _selected = selectedItem;
                  widget.onChange(widget.options[selectedItem]);
                });
              },
              children:
              List<Widget>.generate(widget.options.length, (int index) {
                return Center(child: Text(formatYear(widget.options[index])));
              }),
            ),
          ),
          color: CupertinoTheme.of(context).barBackgroundColor,
          minSize: 0,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text("${formatYear(widget.options[_selected])}", style: subTitle.copyWith(color: Colors.white60),),
            ],
          ),
        ),
      ],
    );
  }
}

class SemPicker extends StatefulWidget {
  SemPicker({super.key, required this.options, required this.onChange, required this.startSem});
  final List<String> options;
  final void Function(String e) onChange;
  final String startSem;

  @override
  State<SemPicker> createState() => SemPickerState();
}

class SemPickerState extends State<SemPicker> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _selected = ["sem1", "sem2"].indexOf(widget.startSem);
  }

  void reset(){
    setState(() {
      _selected = 0;
    });
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoButton(
          onPressed: () => _showDialog(
            CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              // This sets the initial item.
              scrollController: FixedExtentScrollController(
                initialItem: _selected,
              ),
              // This is called when selected item is changed.
              onSelectedItemChanged: (int selectedItem) {
                setState(() {
                  _selected = selectedItem;
                  widget.onChange(widget.options[selectedItem]);
                });
              },
              children:
              List<Widget>.generate(widget.options.length, (int index) {
                return Center(child: Text(widget.options[index] == "sem1"? "Sem 1" : "Sem 2"));
              }),
            ),
          ),
          color: CupertinoTheme.of(context).barBackgroundColor,
          minSize: 0,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text("${widget.options[_selected] == "sem1"? "Sem 1" : "Sem 2"}", style: subTitle.copyWith(color: Colors.white60),),
            ],
          ),
        ),
      ],
    );
  }
}
