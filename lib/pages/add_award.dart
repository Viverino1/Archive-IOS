import 'package:fbla_nlc_2024/pages/academics_page.dart';
import 'package:fbla_nlc_2024/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes.dart';
import '../data/providors.dart';
import '../services/firebase/firestore/db.dart';
import '../theme.dart';

class AddAwardPage extends StatefulWidget {
  AddAwardPage({super.key, required this.startYear});
  final String startYear;

  @override
  State<AddAwardPage> createState() => _AddAwardPageState();
}

class _AddAwardPageState extends State<AddAwardPage> {
  String _year = "";

  AwardData _award = AwardData();

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
              Text("Add Award", style: title),
              SizedBox(width: 8,),
              SchoolYearPicker(
                  options: context.read<UserProvidor>().currentUser.awards.keys.toList(),
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
                    child: Text("Award Name", style: subTitle,),
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
                        _award.title = e;
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
                    placeholder: "FBLA SLC Mobile App Development",
                    style: smallTitle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                    child: Text("Place awarded", style: subTitle,),
                  ),
                  SchoolYearPicker(
                    options: List.generate(11, (i) => i == 0? "N/A" : formatPlace(i)),
                    onChange: (e){
                      if(e == "N/A"){
                        _award.place = 0;
                      }else{
                        _award.place = int.parse(e
                            .replaceAll("st", "")
                            .replaceAll("nd", "")
                            .replaceAll("rd", "")
                            .replaceAll("th", "")
                        );
                      }
                    },
                    startYear: "N/A"
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
                        _award.description = e;
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
                    placeholder: "What did you do to earn this award?",
                    style: subTitle,
                  ),
                  SizedBox(height: 16,),
                  CupertinoButton(
                    onPressed: (){
                      if(_award.title == ""){
                        showAlert("Award Name", "The \"Award Name\" field is currently empty. Please fill this field to continue.", context);
                      }else if(_award.description == ""){
                        showAlert("Description", "The \"Description\" field is currently empty. Please fill this field to continue.", context);
                      }else{
                        UserData user = context.read<UserProvidor>().currentUser;
                        user.awards[_year]?.add(_award);
                        context.read<UserProvidor>().setCurrentUser(user);

                        Navigator.pop(context);

                        Firestore.addAward(_award, _year, context);
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
                            child: Text("Add Award", style: subTitle.copyWith(color: Colors.white, fontSize: 16),),
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