// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fbla_nlc_2024/services/firebase/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes.dart';
import '../data/providors.dart';
import '../services/firebase/firestore/db.dart';
import '../theme.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 112),
        child: Column(
          children: [
            CupertinoButton(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onPressed: () async {
                await AuthService.signOut();
                context.read<UserProvidor>().setCurrentUser(UserData());
                context.read<UserProvidor>().setIsAuthenticated(false);
              },
              child: Text("Logout"),
            ),
            CupertinoButton(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onPressed: () {
                Firestore.testFunc();
              },
              child: Text("Test"),
            )
          ],
        ),
      ),
    );
  }
}
