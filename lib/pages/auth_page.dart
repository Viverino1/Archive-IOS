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
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text("Login", style: title),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Column(
        children: [
          SizedBox(height: 112,),
          Spacer(),
          Container(
            height: 256,
            width: 256,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1028),
              //color: CupertinoTheme.of(context).primaryColor,
              image: DecorationImage(
                fit: BoxFit.cover,
                alignment: FractionalOffset.center,
                image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/PortfoliatorLogo.png?alt=media&token=e47b03b2-8864-405c-b18f-ea9b8b2f4114"),
              ),
            ),
          ),
          SizedBox(height: 16,),
          Text("Welcome to Portfoliator!", style: title.copyWith(fontSize: 28),),

          Spacer(),

          Text("First time here?", style: title.copyWith(fontSize: 20),),
          Text("Clock below to register", style: subTitle,),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 2,
              width: double.infinity,
              color: CupertinoTheme.of(context).barBackgroundColor,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 32, left: 32, bottom: 32),
            child: CupertinoButton(
              onPressed: (){
                AuthService.signInWithGoogle().then((user){
                  if(user == null){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage())
                    );
                  }else{
                    context.read<UserProvidor>().setCurrentUser(user);
                    context.read<UserProvidor>().setIsAuthenticated(true);
                    Navigator.pop(context);
                  }

                });
              },
              minSize: 0,
              padding: EdgeInsets.all(12),
              color: CupertinoTheme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(500),
              child: Row(
                children: [
                  SizedBox(height: 32, width: 32, child: Image.network("https://firebasestorage.googleapis.com/v0/b/fbla-mobile-app-2024.appspot.com/o/Google%20G%20Logo.png?alt=media&token=37ac5b8c-9112-4ce4-8e83-2aefc30f0be0")),
                  Spacer(),
                  Text("Continue with Google", style: smallTitle.copyWith(fontSize: 20),),
                  Spacer(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
