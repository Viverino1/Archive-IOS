import 'dart:ui';

import 'package:fbla_nlc_2024/data/providors.dart';
import 'package:fbla_nlc_2024/pages/new_update_page.dart';
import 'package:fbla_nlc_2024/pages/profile_page.dart';
import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'feed_page.dart';
import 'network_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  var _pageList = [FeedPage(), NetworkPage(), NewUpdatePage()];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color.fromARGB(255, 34, 34, 34),
        child: Stack(
          children: [
            _currentIndex != 3? _pageList.elementAt(_currentIndex) : ProfilePage(user: context.watch<UserProvidor>().currentUser),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                  height: 84,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
                    child: Row(
                      children: [
                        NavBarItem(
                          icon: CupertinoIcons.home,
                          label: "Home",
                          currentIndex: _currentIndex,
                          index: 0,
                          onPressed: () => setState(() {_currentIndex = 0;}),
                        ),
                        Spacer(),
                        NavBarItem(
                          icon: CupertinoIcons.person_2,
                          label: "Network",
                          currentIndex: _currentIndex,
                          index: 1,
                          onPressed: () => setState(() {_currentIndex = 1;}),
                        ),
                        Spacer(),
                        NavBarItem(
                          icon: CupertinoIcons.add,
                          label: "New",
                          currentIndex: _currentIndex,
                          index: 2,
                          onPressed: () => setState(() {_currentIndex = 2;}),
                        ),
                        Spacer(),
                        NavBarItem(
                          icon: CupertinoIcons.person_crop_circle,
                          label: "Profile",
                          currentIndex: _currentIndex,
                          index: 3,
                          onPressed: () => setState(() {_currentIndex = 3;}),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  const NavBarItem({super.key, required this.icon, required this.label, required this.currentIndex, required this.index, required this.onPressed});
  final IconData icon;
  final String label;
  final int currentIndex;
  final int index;
  final void Function() onPressed;


  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: 60,
        child: Column(
          children: [
            Icon(icon, size: 24, color: index == currentIndex? CupertinoTheme.of(context).primaryColor : Colors.white38),
            Text(label, style: subTitle.copyWith(color: index == currentIndex? CupertinoTheme.of(context).primaryColor : Colors.white38),),
          ],
        ),
      ),
    );
  }
}
