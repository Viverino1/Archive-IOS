import 'package:fbla_nlc_2024/pages/profile_page.dart';
import 'package:flutter/cupertino.dart';

import '../classes.dart';
String placeholderpfp = "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/placeholderpfp.jpeg?alt=media&token=d0a3d4ca-0e18-4b03-8b8e-d54637ed0b3b";
class UserImage extends StatelessWidget {
  const UserImage({super.key, required this.user});
  final UserData? user;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: (){
        if(user != null){
          Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => ProfilePage(user: user!,))
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
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: CupertinoTheme.of(context).primaryColor,
                spreadRadius: 1,
                blurRadius: 24,
              ),
            ]
        ),
        child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
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
