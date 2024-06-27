// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/components/picker.dart';
import 'package:fbla_nlc_2024/pages/add_award.dart';
import 'package:fbla_nlc_2024/pages/add_class_page.dart';
import 'package:fbla_nlc_2024/pages/add_club.dart';
import 'package:fbla_nlc_2024/pages/register_page.dart';
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
  AcademicsPage({super.key, required this.user, required this.isMine, required this.navigateToNewPage});
  UserData user;
  final bool isMine;
  final Function() navigateToNewPage;

  String pastGPA = "";

  @override
  State<AcademicsPage> createState() => _AcademicsPageState();
}

class _AcademicsPageState extends State<AcademicsPage> {
  String _year = "freshman";
  String _clubsYear = "freshman";
  String _awardsYear = "freshman";
  String _sem = "sem1";
  List<PostData>? _posts = null;

  TextEditingController _gpaController = TextEditingController();
  TextEditingController _hoursController = TextEditingController();

  void _editStats(UserData user){
    if(context.read<UserProvidor>().currentUser.uid != user.uid){
      return;
    }

    _gpaController.text = user.gpa.toString();
    _hoursController.text = user.volunteerHours.toInt().toString();

    showCupertinoModalBottomSheet(
      context: context,
      barrierColor: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
      backgroundColor: CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height - 200,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Edit Stats", style: title,),
                  Spacer(),
                  CupertinoButton(
                    color: CupertinoTheme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      minSize: 0,
                      child: Row(
                        children: [
                          Icon(Icons.save, size: 16,),
                          SizedBox(width: 4,),
                          Text("Save", style: smallTitle,),
                        ],
                      ),
                      onPressed: (){
                        UserData currentUser = context.read<UserProvidor>().currentUser;
                        currentUser.act = user.act;
                        currentUser.preact = user.preact;
                        currentUser.sat = user.sat;
                        currentUser.psat = user.psat;
                        currentUser.gpa = user.gpa;
                        currentUser.volunteerHours = user.volunteerHours;
                        context.read<UserProvidor>().setCurrentUser(currentUser);

                        widget.user = user;

                        Navigator.pop(context);

                        Firestore.updateUser(user);
                      }
                  )
                ],
              ),
              SizedBox(height: 12,),
              Row(
                children: [
                  TestScorePicker(
                    test: "ACT",
                    initial: user.act > 0? user.act.toString() : "N/A",
                    onChange: (e){
                      if(e == "N/A"){
                        user.act = -1;
                      }else{
                        user.act = int.parse(e);
                      }
                    },
                    options: ["N/A"] + List.generate(36, (index) => (36 - index).toString()),
                  ),
                  SizedBox(width: 12,),
                  TestScorePicker(
                    initial: user.preact > 0? user.preact.toString() : "N/A",
                    test: "Pre-ACT",
                    onChange: (e){
                      if(e == "N/A"){
                        user.preact = -1;
                      }else{
                        user.preact = int.parse(e);
                      }
                    },
                    options: ["N/A"] + List.generate(36, (index) => (35 - index).toString()),
                  ),
                ],
              ),
              SizedBox(height: 12,),
              Row(
                children: [
                  TestScorePicker(
                    initial: user.sat > 0? user.sat.toString() : "N/A",
                    test: "SAT",
                    onChange: (e){
                      if(e == "N/A"){
                        user.sat = -1;
                      }else{
                        user.sat = int.parse(e);
                      }
                    },
                    options: ["N/A"] + List.generate(121, (index) => ((index+40)*10).toString()),
                  ),
                  SizedBox(width: 12,),
                  TestScorePicker(
                    initial: user.psat > 0? user.psat.toString() : "N/A",
                    test: "PSAT",
                    onChange: (e){
                      if(e == "N/A"){
                        user.psat = -1;
                      }else{
                        user.psat = int.parse(e);
                      }
                    },
                    options: ["N/A"] + List.generate(111, (index) => ((index+40)*10).toString()),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                child: Text("Unweighted Cumulative GPA", style: subTitle,),
              ),
              CupertinoTextField(
                onTapOutside: (e){
                  FocusScope.of(context).unfocus();
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _gpaController,
                onChanged: (e){
                  if(e.length > 4|| (e.substring(e.indexOf(".")+1).contains(".")) || (!e.contains(".") && e.length > 1) ||(e != ""? double.parse(e) > 4 : false)){
                    setState(() {
                      _gpaController.text = widget.pastGPA;
                    });
                  }else{
                    user.gpa = e != ""? double.parse(e) : 0;
                    widget.pastGPA = e;
                  }
                },
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: Colors.white10
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white10
                ),
                placeholder: "3.87",
                style: smallTitle,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                child: Text("Total Service Hours", style: subTitle,),
              ),
              CupertinoTextField(
                keyboardType: TextInputType.number,
                onTapOutside: (e){
                  FocusScope.of(context).unfocus();
                },
                controller: _hoursController,
                onChanged: (e){
                  user.volunteerHours = e != ""? double.parse(e) : 0;
                },
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: Colors.white10
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white10
                ),
                placeholder: "85",
                style: smallTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                SizedBox(height: 48,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Circle(isMine: widget.isMine, label: "Pre-ACT", value: widget.user.preact.toString(), onClick: () => _editStats(widget.user),),
                    SizedBox(width: 16,),
                    Circle(isMine: widget.isMine, label: "Service\nHours", value: widget.user.volunteerHours.toInt().toString(), onClick: () => _editStats(widget.user),),
                    SizedBox(width: 16,),
                    Circle(isMine: widget.isMine, label: "Pre-SAT", value: widget.user.psat.toString(), onClick: () => _editStats(widget.user)),
                  ],
                ),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Circle(isMine: widget.isMine, label: "ACT", value: widget.user.act.toString(), onClick: () => _editStats(widget.user)),
                    SizedBox(width: 16,),
                    Circle(isMine: widget.isMine, label: "GPA", value: widget.user.gpa.toString(), onClick: () => _editStats(widget.user)),
                    SizedBox(width: 16,),
                    Circle(isMine: widget.isMine, label: "SAT", value: widget.user.sat.toString(), onClick: () => _editStats(widget.user)),
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
                                  padding: EdgeInsets.all(2),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.add, size: 22, color: Colors.white,),
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

                SizedBox(height: 16,),

                CupertinoListSection(
                  header: Row(
                    children: [
                      Text("Awards", style: title.copyWith(color: Colors.white),),
                      SizedBox(width: 8,),
                      SchoolYearPicker(
                          options: widget.user.awards.keys.toList(),
                          startYear: _awardsYear,
                          onChange: (String e) {
                            setState(() {
                              _awardsYear = e;
                            });
                          }
                      ),
                      Spacer(),
                      ...(widget.isMine? [
                        CupertinoButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => AddAwardPage(
                                  startYear: _awardsYear,
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
                                  padding: EdgeInsets.all(2),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.add, size: 22, color: Colors.white,),
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ),
                      ] : [])
                    ],
                  ),
                  children: widget.user.awards[_awardsYear]?.map((e) =>
                      CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                            context: context,
                            barrierColor: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                            backgroundColor: CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
                            builder: (context) => Container(
                              height: MediaQuery.of(context).size.height - 400,
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
                                          Navigator.pop(context);
                                          setState(() {
                                            widget.user.awards[_awardsYear]?.remove(e);
                                          });
                                          Firestore.deleteAward(e, _year, context);
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
                                        ...(e.place == 0? [
                                          SizedBox(height: 8,),
                                        ] : [
                                          Text(formatPlace(e.place) + " Place", style: subTitle,),
                                        ]),
                                        SizedBox(height: 2,),
                                        Text(e.title, style: title.copyWith(height: 1),),
                                        SizedBox(height: 8,),
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
                          title: Text(e.title, style: smallTitle),
                          subtitle: Text(e.description, style: subTitle.copyWith(fontSize: 12),),
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
                            child: e.place == 0? Icon(Icons.star, color: Colors.white, size: 20,) : Text(formatPlace(e.place), style: smallTitle.copyWith(color: Colors.white, fontSize: 12),),
                          ),
                          trailing: CupertinoListTileChevron(),
                        ),
                      )
                  ).toList(),
                ),
                ...((widget.user.awards[_awardsYear]?.length != null && widget.user.awards[_awardsYear]!.length > 0)? [] : [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("${widget.isMine? "You have" : "This user has"} not added any awards received as a ${_awardsYear}.${widget.isMine? " Press the \"Add\" button above to add one.": ""}", style: subTitle,),
                  ),
                ]),

                SizedBox(height: 16,),

                CupertinoListSection(
                  header: Row(
                    children: [
                      Text("Clubs", style: title.copyWith(color: Colors.white),),
                      SizedBox(width: 8,),
                      SchoolYearPicker(
                          options: widget.user.clubs.keys.toList(),
                          startYear: _clubsYear,
                          onChange: (String e) {
                            setState(() {
                              _clubsYear = e;
                            });
                          }
                      ),
                      Spacer(),
                      ...(widget.isMine? [
                        CupertinoButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => AddClubPage(
                                  startYear: _clubsYear,
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
                                  padding: EdgeInsets.all(2),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.add, size: 22, color: Colors.white,),
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ),
                      ] : [])
                    ],
                  ),
                  children: widget.user.clubs[_clubsYear]?.map((e) =>
                      CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                            context: context,
                            barrierColor: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                            backgroundColor: CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
                            builder: (context) => Container(
                              height: MediaQuery.of(context).size.height - 400,
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
                                            widget.user.clubs[_year]?.remove(e);
                                          });
                                          Navigator.pop(context);
                                          Firestore.deleteClub(e, _year, context);
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
                                            child: Text(e.position, style: subTitle,)
                                        ),
                                        Text(e.name, style: title,),
                                        SizedBox(height: 8,),
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
                          subtitle: Text(e.position, style: subTitle.copyWith(fontSize: 12),),
                          leadingSize: 32,
                          leadingToTitle: 12,
                          trailing: CupertinoListTileChevron(),
                        ),
                      )
                  ).toList(),
                ),
                ...((widget.user.clubs[_clubsYear]?.length != null && widget.user.clubs[_clubsYear]!.length > 0)? [] : [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("${widget.isMine? "You have" : "This user has"} not added any clubs participated in as a ${_clubsYear}.${widget.isMine? " Press the \"Add\" button above to add one.": ""}", style: subTitle,),
                  ),
                ]),

                SizedBox(height: 16,),

                CupertinoListSection(
                  header: Row(
                    children: [
                      Text("Experiences", style: title.copyWith(color: Colors.white),),
                      SizedBox(width: 8,),
                      Spacer(),
                      ...(widget.isMine? [
                        CupertinoButton(
                          onPressed: (){
                            widget.navigateToNewPage();
                            Navigator.pop(context);
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
                                  padding: EdgeInsets.all(2),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.add, size: 22, color: Colors.white,),
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
  const Circle({super.key, required this.label, required this.value, required this.isMine, required this.onClick});
  final String label;
  final String value;
  final bool isMine;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onClick,
      padding: EdgeInsets.zero,
      minSize: 0,
      child: Container(
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
                  child: Text(value == "-1"? "N/A" : value, style: title.copyWith(fontSize: 32, color: Colors.white),),
                ),
                SizedBox(height: 4),
                Text(label, style: subTitle.copyWith(height: 0.85), textAlign: TextAlign.center,),
              ],
            ),
          )
      ),
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
    _selected = widget.options.indexOf(widget.startYear);
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
          padding: EdgeInsets.only(left: 12, right: 4, top: 3, bottom: 3),
          child: Row(
            children: [
              Text("${formatYear(widget.options[_selected])}", style: subTitle.copyWith(color: Colors.white60),),
              Icon(Icons.arrow_drop_down, color: Colors.white60, size: 20,)
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
          padding: EdgeInsets.only(left: 12, right: 4, top: 3, bottom: 3),
          child: Row(
            children: [
              Text("${widget.options[_selected] == "sem1"? "Sem 1" : "Sem 2"}", style: subTitle.copyWith(color: Colors.white60),),
              Icon(Icons.arrow_drop_down, color: Colors.white60, size: 20,)
            ],
          ),
        ),
      ],
    );
  }
}
