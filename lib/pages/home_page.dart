import 'package:fbla_nlc_2024/data/providors.dart';
import 'package:fbla_nlc_2024/pages/new_update_page.dart';
import 'package:fbla_nlc_2024/pages/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'feed_page.dart';
import 'network_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: Color.fromARGB(255, 34, 34, 34),
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.transparent.withOpacity(0.75),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Icon(CupertinoIcons.home, size: 24,),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Icon(CupertinoIcons.person_2, size: 24,),
              ),
              label: 'Network',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Icon(CupertinoIcons.add, size: 24,),
              ),
              label: 'new',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Icon(CupertinoIcons.person_crop_circle, size: 24,),
              ),
              label: 'Profile',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index){
          return CupertinoTabView(
            builder: (BuildContext context) {
              switch(index){
                case 3: return ProfilePage(user: context.watch<UserProvidor>().currentUser,);
                case 2: return NewUpdatePage();
                case 1: return NetworkPage();
                case 0: return FeedPage();
                default: return CupertinoPageScaffold(child: Container());
              }
            },
          );
        }
    );
  }
}
