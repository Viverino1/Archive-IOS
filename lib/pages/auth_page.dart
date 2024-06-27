import 'package:cached_network_image/cached_network_image.dart';
import 'package:fbla_nlc_2024/pages/home_page.dart';
import 'package:fbla_nlc_2024/pages/register_page.dart';
import 'package:fbla_nlc_2024/services/firebase/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/providors.dart';
import '../theme.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          SizedBox(height: 78,),
          Spacer(),

          Transform.translate(offset: Offset(0, 32), child: CachedNetworkImage(width: 100, imageUrl: "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/ArchiveLogo.png?alt=media&token=f2947b63-9ab4-40dd-96d8-8b1372cb02d5")),
          Text("Archive", style: title.copyWith(letterSpacing: 1, fontSize: 70, color: CupertinoTheme.of(context).primaryColor)),
          Transform.translate(offset: Offset(0, -16), child: CupertinoButton(
            padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: (){
                AuthService.signInWithGoogle(context).then((user){
                  if(user == null){
                    Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => RegisterPage())
                    );
                  }else{
                    context.read<UserProvidor>().setCurrentUser(user);
                    context.read<UserProvidor>().setIsAuthenticated(true);
                    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => HomePage()));
                  }
                });
              },
              child: Text("Login", style: subTitle.copyWith(fontSize: 18, letterSpacing: 2),
              ))),

          Spacer(),

          Text("First time here?", style: title.copyWith(fontSize: 20),),
          Text("Clock below to register", style: subTitle,),

          SizedBox(height: 8,),

          Padding(
            padding: const EdgeInsets.only(right: 32, left: 32, bottom: 32),
            child: CupertinoButton(
              onPressed: (){
                AuthService.signInWithGoogle(context).then((user){
                  if(user == null){
                    Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => RegisterPage())
                    );
                  }else{
                    context.read<UserProvidor>().setCurrentUser(user);
                    context.read<UserProvidor>().setIsAuthenticated(true);
                    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => HomePage()));
                  }

                });
              },
              minSize: 0,
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoTheme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(100)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(height: 32, width: 32, child: Image.network("https://firebasestorage.googleapis.com/v0/b/fbla-mobile-app-2024.appspot.com/o/Google%20G%20Logo.png?alt=media&token=37ac5b8c-9112-4ce4-8e83-2aefc30f0be0")),
                      Spacer(),
                      Text("Continue with Google", style: smallTitle.copyWith(fontSize: 20),),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
