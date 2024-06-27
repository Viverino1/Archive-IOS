import 'package:fbla_nlc_2024/pages/academics_page.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:fbla_nlc_2024/services/gemini/gemini.dart';
import 'package:fbla_nlc_2024/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes.dart';
import '../data/providors.dart';
import '../theme.dart';

class AddClubPage extends StatefulWidget {
  AddClubPage({super.key, required this.startYear});
  final String startYear;

  @override
  State<AddClubPage> createState() => _AddClubPageState();
}

class _AddClubPageState extends State<AddClubPage> {
  String _year = "";

  ClubData _club = ClubData();

  @override
  void initState() {
    super.initState();
    _year = widget.startYear;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
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
              Text("Add Club", style: title),
              SizedBox(width: 8,),
              SchoolYearPicker(
                  options: context.read<UserProvidor>().currentUser.clubs.keys.toList(),
                  startYear: widget.startYear,
                  onChange: (e){
                    setState(() {
                      _year = e;
                    });
                  }
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints){
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 102, left: 16, right: 16, bottom: 102),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2),
                    child: Text("Club Name", style: subTitle,),
                  ),
                  CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                    },
                    onSubmitted: (e){
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (e){
                      setState(() {
                        _club.name = e;
                      });
                    },
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: CupertinoTheme.of(context).barBackgroundColor
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5)
                    ),
                    placeholder: "Speech and Debate",
                    style: smallTitle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                    child: Text("Position in Club", style: subTitle,),
                  ),
                  CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (e){
                      setState(() {
                        _club.position = e;
                      });
                    },
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 2,
                          color: CupertinoTheme.of(context).barBackgroundColor
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
                    ),
                    style: smallTitle,
                    placeholder: "Vice President",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                    child: Text("Description", style: subTitle,),
                  ),
                  CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (e){
                      setState(() {
                        _club.description = e;
                      });
                    },
                    onSubmitted: (e){
                      FocusScope.of(context).unfocus();
                    },
                    maxLines: null,
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 2,
                          color: CupertinoTheme.of(context).barBackgroundColor
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
                    ),
                    placeholder: "What did you do in this club?",
                    style: subTitle,
                  ),
                  SizedBox(height: 16,),
                  CupertinoButton(
                    onPressed: (){
                      if(_club.name == ""){
                        showAlert("Club Name", "The \"Club Name\" field is currently empty. Please fill this field to continue.", context);
                      }else if(_club.position == ""){
                        showAlert("Position in Club", "The \"Position in Club\" field is currently empty. Please fill this field to continue.", context);
                      }else if(_club.description == ""){
                        showAlert("Description", "The \"Description\" field is currently empty. Please fill this field to continue.", context);
                      }else{
                        UserData user = context.read<UserProvidor>().currentUser;
                        user.clubs[_year]?.add(_club);
                        context.read<UserProvidor>().setCurrentUser(user);

                        Navigator.pop(context);

                        Firestore.addClub(_club, _year, context);
                      }
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
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3,),
                            child: Text("Add Club", style: subTitle.copyWith(color: Colors.white, fontSize: 16),),
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}