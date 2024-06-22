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

class AddClassPage extends StatefulWidget {
  AddClassPage({super.key, required this.startYear, required this.startSem});
  final String startYear;
  final String startSem;

  String lastGrade = "";

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  String _year = "";
  String _sem = "";
  String _description = "";
  bool _generating = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _year = widget.startYear;
    _sem = widget.startSem;
  }

  @override
  Widget build(BuildContext context) {
    void submitName() async{
      setState(() {
        _descriptionController.text = "Generating a description...";
        _generating = true;
      });
      String? msg = _nameController.text == ""? "" : await Gemini.getResponse("Give me a description about the high school class ${_nameController.text} no longer than four sentences");
      setState(() {
        _descriptionController.text = msg;
        _generating = false;
        _description = msg;
      });
    }

    void addClass(){
      ClassData classData = ClassData();
      classData.name = _nameController.text;
      classData.description = _descriptionController.text;
      classData.grade = double.parse(_gradeController.text);

      UserData user = context.read<UserProvidor>().currentUser;
      user.classData[_year]?[_sem]?.add(classData);
      context.read<UserProvidor>().setCurrentUser(user);

      Navigator.pop(context);

      Firestore.addClass(classData, _year, _sem, context);
    }

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
              Text("Add Class", style: title),
              SizedBox(width: 8,),
              SchoolYearPicker(
                  options: context.read<UserProvidor>().currentUser.classData.keys.toList(),
                  startYear: widget.startYear,
                  onChange: (e){
                    setState(() {
                      _year = e;
                    });
                  }
              ),
              SizedBox(width: 8,),
              !_year.contains("rising")? SemPicker(
                options: context.read<UserProvidor>().currentUser.classData[_year]!.keys.toList(),
                startSem: widget.startSem,
                onChange: (e){
                  setState(() {
                    _sem = e;
                  });
              },
              ) : Container(),
              // Spacer(),
              // CupertinoButton(
              //   minSize: 0,
              //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //   color: CupertinoTheme.of(context).primaryColor,
              //   child: Text("Done"),
              //   onPressed: (){
              //
              //   }
              // ),
              // SizedBox(width: 8,),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints){
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 102, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2),
                    child: Text("Class Name", style: subTitle,),
                  ),
                  CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                      submitName();
                    },
                    onSubmitted: (e){
                      submitName();
                    },
                    controller: _nameController,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: CupertinoTheme.of(context).barBackgroundColor
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5)
                    ),
                    placeholder: "Honors US History",
                    style: smallTitle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                    child: Text("Class Grade", style: subTitle,),
                  ),
                  CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                    },
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: _gradeController,
                    onChanged: (e){
                      if(e.length > 6 || e.length > 3 && !e.contains(".") || (e.contains(".")? e.substring(e.indexOf(".")).length > 3 : false) || (e.length != 0? e.allMatches(".").length > 1 : false) || (e.contains(".")? e.substring(e.indexOf(".") + 1) .contains(".") : false)){
                        setState(() {
                          _gradeController.text = widget.lastGrade;
                        });
                      }else{
                        widget.lastGrade = e;
                      }
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
                    placeholder: "85.62",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                    child: Row(
                      children: [
                        Text("Class Description", style: subTitle,),
                        CupertinoButton(
                          minSize: 0,
                          padding: EdgeInsets.zero,
                          child: Icon(CupertinoIcons.sparkles, size: 16,),
                          onPressed: (){
                            showAlert("AI Enabled", "This description is auto generated for your convenience. Enter a class name to see it happen.", context);
                          }
                        )
                      ],
                    ),
                  ),
                  _generating? Container(
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoTheme.of(context).barBackgroundColor,
                        width: 2
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CupertinoActivityIndicator(),
                          SizedBox(width: 8,),
                          Text("Generating Description", style: subTitle,)
                        ],
                      ),
                    ),
                  ) : CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (e){
                      setState(() {
                        _description = e;
                      });
                    },

                    controller: _descriptionController,
                    maxLines: null,
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 2,
                          color: CupertinoTheme.of(context).barBackgroundColor
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
                    ),
                    placeholder: "Describe your class here...",
                    style: subTitle,
                  ),
                  SizedBox(height: 16,),
                  CupertinoButton(
                    onPressed: (){
                      if(_nameController.text == ""){
                        showAlert("Class Name", "The \"Class Name\" field is currently empty. Please fill this field to continue.", context);
                      }else if(_gradeController.text == ""){
                        showAlert("Class Grade", "The \"Class Grade\" field is currently empty. Please fill this field to continue.", context);
                      }else if(_descriptionController.text == ""){
                        showAlert("Class Description", "The \"Class Description\" field is currently empty. Please fill this field to continue.", context);
                      }else{
                        addClass();
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
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                            child: Text("Add Class", style: smallTitle.copyWith(color: Colors.white),),
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
