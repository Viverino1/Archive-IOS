// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/pages/add_class_page.dart';
import 'package:fbla_nlc_2024/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/providors.dart';
import '../theme.dart';

class AcademicsPage extends StatefulWidget {
  const AcademicsPage({super.key, required this.user});
  final UserData user;

  @override
  State<AcademicsPage> createState() => _AcademicsPageState();
}

class _AcademicsPageState extends State<AcademicsPage> {
  String _year = "freshman";
  String _sem = "sem1";

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
                Text("${widget.user.firstName}'s Academics", style: title),
              ],
            ),
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
                        CupertinoButton(
                            child: Icon(CupertinoIcons.add),
                            minSize: 0,
                            padding: EdgeInsets.all(1),
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => AddClassPage(
                                    startSem: _sem,
                                    startYear: _year,
                                  ))
                              );
                            }
                        )
                      ],
                    ),
                    children: widget.user.classData[_year]?[_sem]?.map((e) =>
                        CupertinoListTile(
                          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
                          title: Text(e.name, style: smallTitle),
                          subtitle: Text("Grade: ${e.grade}%", style: subTitle.copyWith(fontSize: 12),),
                          leadingSize: 32,
                          leadingToTitle: 12,
                          leading: CupertinoButton(
                            minSize: 0,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                             showAlert(e.name, "Vivek Maddineni earned a ${e.grade}% in this class.", context);
                            },
                            child: Container(
                              width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.alphaBlend(CupertinoColors.systemGreen.withOpacity(
                                    pow(e.grade/100, 5).toDouble()
                                  ), CupertinoColors.systemRed),
                                ),
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
              child: Text(value == "-1"? "N/A" : value, style: title.copyWith(fontSize: 32),),
            ),
            SizedBox(height: 4),
            Text(label, style: subTitle.copyWith(height: 0.85), textAlign: TextAlign.center,),
          ],
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
