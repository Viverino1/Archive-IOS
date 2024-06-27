// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fbla_nlc_2024/services/firebase/auth_service.dart';
import 'package:fbla_nlc_2024/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../classes.dart';
import '../data/providors.dart';
import '../services/firebase/firestore/db.dart';
import '../theme.dart';
import 'auth_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text("Settings", style: title),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 90),
        child: CupertinoListSection(
          children: [
            CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: () async {
                XFile? newPFP = await ImagePicker().pickImage(source: ImageSource.gallery);
                if(newPFP != null){
                  late BuildContext dialogContext;
                  showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        dialogContext = context;
                        return CupertinoAlertDialog(
                          title: CupertinoActivityIndicator(radius: 16,),
                          content: Text("Updating Image", style: subTitle,),
                        );
                      }
                  );
                  Firestore.setUserImage(newPFP, context).then((e){
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  });
                }
              },
              child: CupertinoListTile(
                leadingSize: 0,
                leadingToTitle: 0,
                title: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 16,),
                    Text("Change Profile Image", style: subTitle,),
                  ],
                ),
              ),
            ),
            CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: () async {
                await AuthService.signOut();
                context.read<UserProvidor>().setCurrentUser(UserData(uid: ''));
                context.read<UserProvidor>().setIsAuthenticated(false);
                Navigator.pushNamedAndRemoveUntil(context,'/',(_) => false);
              },
              child: CupertinoListTile(
                leadingSize: 0,
                leadingToTitle: 0,
                title: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 16,),
                    Text("Logout", style: subTitle,),
                  ],
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
