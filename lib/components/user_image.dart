import 'package:fbla_nlc_2024/pages/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../classes.dart';
import '../data/providors.dart';
String placeholderpfp = "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/placeholderpfp.jpeg?alt=media&token=d0a3d4ca-0e18-4b03-8b8e-d54637ed0b3b";
class UserImage extends StatelessWidget {
  UserImage({super.key, required this.user, required this.disable, this.size = 25, this.spreadRadius = 1, this.blurRadius = 24});
  final UserData? user;
  final bool disable;
  final double size;
  final double spreadRadius;
  final double blurRadius;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: disable? (){

      } : (){
        if(user != null){
          Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(builder: (context) => ProfilePage(user: user!, isMine: user!.uid == context.read<UserProvidor>().currentUser.uid,))
          );
        }
      },
      padding: EdgeInsets.zero,
      minSize: 0,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: CupertinoTheme.of(context).primaryColor,
                width: 3
            ),
            borderRadius: BorderRadius.circular(size*2),
            boxShadow: [
              BoxShadow(
                color: CupertinoTheme.of(context).primaryColor,
                spreadRadius: spreadRadius,
                blurRadius: blurRadius,
              ),
            ]
        ),
        child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size*2),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  alignment: FractionalOffset.center,
                  image: NetworkImage(user != null? user!.photoUrl : placeholderpfp),
                ),
              ),
            )
        ),
      ),
    );
  }
}
