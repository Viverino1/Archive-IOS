// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/components/generic_text_field.dart';
import 'package:fbla_nlc_2024/components/picker.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/providors.dart';
import '../theme.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key,});

  @override
  Widget build(BuildContext context) {
    UserData user = UserData();
    user.gradYear = DateTime.now().year + 6;
    bool isValidVolunteerHours = false;
    bool isValidGPA = false;

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text("Register", style: title),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 112, right: 16, left: 16),
        child: Column(
          children: [
            Row(children: [Text("Basic Info", style: smallTitle,),],),
            SizedBox(height: 8,),
            GenericTextField(
                placeholder: "First Name",
                onChange: (e){
                  user.firstName = e;
                }
            ),
            SizedBox(height: 8,),
            GenericTextField(
                placeholder: "Last Name",
                onChange: (e){
                  user.lastName = e;
                }
            ),
            SizedBox(height: 8,),
            GenericTextField(
                placeholder: "School",
                onChange: (e){
                  user.school = e;
                }
            ),
            SizedBox(height: 8,),
            GenericTextField(
                placeholder: "Volunteer Hours",
                onChange: (e){
                  try{
                    double d = double.parse(e);
                    if(d >= 0){
                      isValidVolunteerHours = true;
                      user.volunteerHours = d;
                    }else{
                      user.volunteerHours = 0;
                      isValidVolunteerHours = false;
                    }
                  }catch (e){
                    user.volunteerHours = 0;
                    isValidVolunteerHours = false;
                  }
                }
            ),
            SizedBox(height: 8,),
            GenericTextField(
                placeholder: "Unweighted GPA",
                onChange: (e){
                  try{
                    double d = double.parse(e);
                    if(d >= 0.0 && d <= 4.0){
                      isValidGPA = true;
                      user.gpa = d;
                    }else{
                      user.gpa = 0;
                      isValidGPA = false;
                    }
                  }catch (e){
                    user.gpa = 0;
                    isValidGPA = false;
                  }
                }
            ),
            SizedBox(height: 8,),
            Picker(
                options: List.generate(200, (index) => (DateTime.now().year - index + 6).toString()),
                placeHolder: "Graduation Year",
                onChange: (e){
                  user.gradYear = int.parse(e);
                }
            ),
            SizedBox(height: 24,),
            Row(children: [Text("Test Scores", style: smallTitle,),],),
            SizedBox(height: 4,),
            Picker(
              onChange: (e){
                try{
                  final score = int.parse(e);
                  user.act = score;
                }catch (err){
                  if(e == "I prefer not to say."){
                    user.act = -2;
                  }else if(e == "Untested"){
                    user.act = -1;
                  }
                }
              },
              placeHolder: "ACT",
              options: ["I prefer not to say.", "Untested"] + List.generate(36, (index) => (36 - index).toString()),
            ),
            SizedBox(height: 8,),
            Picker(
              onChange: (e){
                try{
                  final score = int.parse(e);
                  user.preact = score;
                }catch (err){
                  if(e == "I prefer not to say."){
                    user.preact = -2;
                  }else if(e == "Untested"){
                    user.preact = -1;
                  }
                }
              },
              placeHolder: "Pre-ACT",
              options: ["I prefer not to say.", "Untested"] + List.generate(35, (index) => (36 - index).toString()),
            ),
            SizedBox(height: 8,),
            Picker(
              onChange: (e){
                try{
                  final score = int.parse(e);
                  user.sat = score;
                }catch (err){
                  if(e == "I prefer not to say."){
                    user.sat = -2;
                  }else if(e == "Untested"){
                    user.sat = -1;
                  }
                }
              },
              placeHolder: "SAT",
              options: ["I prefer not to say.", "Untested"] + List.generate(1201, (index) => (1200 - index + 400).toString()),
            ),
            SizedBox(height: 8,),
            Picker(
              onChange: (e){
                try{
                  final score = int.parse(e);
                  user.psat = score;
                }catch (err){
                  if(e == "I prefer not to say."){
                    user.psat = -2;
                  }else if(e == "Untested"){
                    user.psat = -1;
                  }
                }
              },
              placeHolder: "PSAT",
              options: ["I prefer not to say.", "Untested"] + List.generate(1101, (index) => (1200 - index + 400).toString()),
            ),
            Spacer(),
            CupertinoButton(
              onPressed: (){
                if(isValidGPA && isValidVolunteerHours){
                  Firestore.registerUser(user)
                      .then((value) async {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        context.read<UserProvidor>().setCurrentUser(user);
                        context.read<UserProvidor>().setIsAuthenticated(true);
                        context.read<PostDataProvidor>().setUserPosts([]);
                        final userPosts = await Firestore.getUserPosts(user);
                        context.read<PostDataProvidor>().setUserPosts(userPosts);
                  });

                  showCupertinoDialog(
                      context: context,
                      //barrierDismissible: true,
                      builder: (_) => CupertinoAlertDialog(
                        title: Text("Creating Account", style: smallTitle,),
                        content: Column(
                          children: [
                            SizedBox(height: 8,),
                            CupertinoActivityIndicator(radius: 16,),
                          ],
                        ),
                      )
                  );

                }else if(!isValidVolunteerHours){
                  showCupertinoDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => CupertinoAlertDialog(
                        title: Text("Invalid Volunteer Hours", style: smallTitle,),
                        content: Column(
                          children: [
                            SizedBox(height: 8,),
                            Text("Volunteer hours must be inputted as a positive whole number.", style: subTitle,),
                          ],
                        ),
                        actions: [
                          CupertinoButton(child: Text("Ok"), onPressed: (){
                            Navigator.pop(context);
                          })
                        ],
                      )
                  );
                }else if(!isValidGPA){
                  showCupertinoDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => CupertinoAlertDialog(
                        title: Text("Invalid GPA", style: smallTitle,),
                        content: Column(
                          children: [
                            SizedBox(height: 8,),
                            Text("Unweighted GPA must be inputted as a positive number between 0.0 and 4.0.", style: subTitle,),
                          ],
                        ),
                        actions: [
                          CupertinoButton(child: Text("Ok"), onPressed: (){
                            Navigator.pop(context);
                          })
                        ],
                      )
                  );
                }
              },
              color: CupertinoTheme.of(context).primaryColor,
              child: Text("Register"),
            ),
            Spacer(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
