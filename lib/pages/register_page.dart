import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/pages/home_page.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/providors.dart';
import '../theme.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key,});
  String pastGPA = "";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _gpaController = TextEditingController();
  UserData user = UserData();

  @override
  Widget build(BuildContext context) {
    UserData user = UserData(uid: '');
    user.gradYear = DateTime.now().year + 6;

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              SizedBox(width: 4,),
              Text("Register", style: title),
              Spacer(),
              CupertinoButton(
                child: Text("Create Account", style: smallTitle,),
                minSize: 0,
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () async{
                  showCupertinoDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => CupertinoAlertDialog(
                      title: Column(
                        children: [
                          CupertinoActivityIndicator(radius: 12,),
                          SizedBox(height: 8,),
                          Text("Creating Account", style: smallTitle,),
                        ],
                      ),
                      content: Text("Just a moment, we're setting up your account!", style: subTitle,),
                    )
                  );
                  await Firestore.registerUser(user);
                  context.read<UserProvidor>().setCurrentUser(user);
                  context.read<UserProvidor>().setIsAuthenticated(true);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (context) => HomePage())
                  );
                }
              ),
              SizedBox(width: 16,),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints){
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 102, right: 16, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2),
                    child: Text("First Name", style: subTitle,),
                  ),
                  CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (e){
                      user.firstName = e;
                    },
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: CupertinoTheme.of(context).barBackgroundColor
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoTheme.of(context).barBackgroundColor
                    ),
                    placeholder: "John",
                    style: smallTitle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                    child: Text("Last Name", style: subTitle,),
                  ),
                  CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (e){
                      user.lastName = e;
                    },
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: CupertinoTheme.of(context).barBackgroundColor
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoTheme.of(context).barBackgroundColor
                    ),
                    placeholder: "Doe",
                    style: smallTitle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                    child: Text("School", style: subTitle,),
                  ),
                  CupertinoTextField(
                    onTapOutside: (e){
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (e){
                      user.school = e;
                    },
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: CupertinoTheme.of(context).barBackgroundColor
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoTheme.of(context).barBackgroundColor
                    ),
                    placeholder: "Lafayette High School",
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
                    onChanged: (e){
                      user.volunteerHours = e != ""? double.parse(e) : 0;
                    },
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: CupertinoTheme.of(context).barBackgroundColor
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoTheme.of(context).barBackgroundColor
                    ),
                    placeholder: "85",
                    style: smallTitle,
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
                            color: CupertinoTheme.of(context).barBackgroundColor
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoTheme.of(context).barBackgroundColor
                    ),
                    placeholder: "3.87",
                    style: smallTitle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 8),
                    child: Text("Graduation Year", style: subTitle,),
                  ),
                  CustomPicker(
                      options: List.generate(200, (index) => (DateTime.now().year - index + 6).toString()),
                      onChange: (e){
                        user.gradYear = int.parse(e);
                      }
                  ),
                  SizedBox(height: 12,),
                  Text("Official Test Scores", style: smallTitle,),
                  SizedBox(height: 8,),

                  Row(
                    children: [
                      TestScorePicker(
                        test: "ACT",
                        initial: "N/A",
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
                        initial: "N/A",
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
                        initial: "N/A",
                        test: "SAT",
                        onChange: (e){
                          if(e == "N/A"){
                            user.sat = -1;
                          }else{
                            user.sat = int.parse(e);
                          }
                        },
                        options: ["N/A"] + List.generate(41, (index) => ((index+120)*10).toString()),
                      ),
                      SizedBox(width: 12,),
                      TestScorePicker(
                        initial: "N/A",
                        test: "PSAT",
                        onChange: (e){
                          if(e == "N/A"){
                            user.psat = -1;
                          }else{
                            user.psat = int.parse(e);
                          }
                        },
                        options: ["N/A"] + List.generate(31, (index) => ((index+120)*10).toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      )
    );
  }
}

class CustomPicker extends StatefulWidget {
  CustomPicker({super.key, required this.options, required this.onChange});
  final List<String> options;
  final void Function(String e) onChange;

  @override
  CustomPickerState createState() => CustomPickerState();
}

class CustomPickerState extends State<CustomPicker> {
  int _selected = 0;

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
                return Center(child: Text(widget.options[index], style: smallTitle.copyWith(fontSize: 24),));
              }),
            ),
          ),
          color: CupertinoTheme.of(context).barBackgroundColor,
          minSize: 0,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text("${widget.options[_selected]}", style: smallTitle.copyWith(color: Colors.white60),),
            ],
          ),
        ),
      ],
    );
  }
}

class TestScorePicker extends StatefulWidget {
  TestScorePicker({super.key, required this.options, required this.onChange, required this.test, required this.initial});
  final List<String> options;
  final void Function(String e) onChange;
  final String test;
  final String initial;

  @override
  TestScorePickerState createState() => TestScorePickerState();
}

class TestScorePickerState extends State<TestScorePicker> {
  int _selected = 0;

  void reset(){
    setState(() {
      _selected = 0;
    });
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup(context: context,
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
  void initState() {
    super.initState();
    _selected = widget.options.indexOf(widget.initial) > 0? widget.options.indexOf(widget.initial) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: CupertinoTheme.of(context).barBackgroundColor,
            borderRadius: BorderRadius.circular(12)
        ),
        child: CupertinoButton(
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
                return Center(child: Text(widget.options[index], style: smallTitle.copyWith(fontSize: 24),));
              }),
            ),
          ),
          // color: CupertinoTheme.of(context).barBackgroundColor,
          minSize: 0,
          padding: EdgeInsets.zero,
          child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0, top: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${widget.options[_selected]}", style: title.copyWith(color: Colors.white, fontSize: 38),),
                    Text(widget.test, style: subTitle,),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }
}