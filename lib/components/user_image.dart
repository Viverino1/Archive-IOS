import 'package:flutter/cupertino.dart';

import '../classes.dart';

class UserImage extends StatelessWidget {
  const UserImage({super.key, required this.user});
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: (){},
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
                  image: NetworkImage(user.photoUrl),
                ),
              ),
            )
        ),
      ),
    );
  }
}
