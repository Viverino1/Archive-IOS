import 'package:cached_network_image/cached_network_image.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/pages/home_page.dart';
import 'package:fbla_nlc_2024/pages/register_page.dart';
import 'package:fbla_nlc_2024/services/firebase/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/providors.dart';
import '../theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pswrdController = TextEditingController();

  bool _isLogin = false;
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Column(
            children: _isActive? [] : [
              Spacer(),
              Transform.translate(offset: Offset(0, 32), child: CachedNetworkImage(width: 100, imageUrl: "https://firebasestorage.googleapis.com/v0/b/portfoliator-2024.appspot.com/o/ArchiveLogo.png?alt=media&token=f2947b63-9ab4-40dd-96d8-8b1372cb02d5")),
              Text("Archive", style: title.copyWith(letterSpacing: 1, fontSize: 70, color: CupertinoTheme.of(context).primaryColor)),
              Transform.translate(
                  offset: Offset(0, -8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CupertinoButton(
                          minSize: 0,
                          padding: EdgeInsets.zero,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: CupertinoTheme.of(context).primaryColor
                                  ),
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3),
                                child: Text("Log In", style: smallTitle.copyWith(fontSize: 14, color: CupertinoTheme.of(context).primaryColor, letterSpacing: 1),),
                              )
                          ),
                          onPressed: (){
                            setState(() {
                              _isLogin = true;
                            });
                          }
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("or", style: subTitle.copyWith(letterSpacing: 1),),
                      ),
                      CupertinoButton(
                          minSize: 0,
                          padding: EdgeInsets.zero,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: CupertinoTheme.of(context).primaryColor
                                  ),
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
                                child: Text("Sign Up", style: smallTitle.copyWith(fontSize: 14, color: CupertinoTheme.of(context).primaryColor, letterSpacing: 1),),
                              )
                          ),
                          onPressed: (){
                            setState(() {
                              _isLogin = false;
                            });
                          }
                      ),
                    ],
                  )
              ),
              Spacer(),
              Spacer(),
              Spacer(),
            ],
          ),
          Column(
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 2),
                      child: Text("Email Address", style: subTitle,),
                    ),
                    CupertinoTextField(
                      onTapOutside: (e){
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isActive = false;
                        });
                      },
                      onTap: (){
                        setState(() {
                          _isActive = true;
                        });
                      },
                      controller: _emailController,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 2,
                              color: CupertinoTheme.of(context).barBackgroundColor
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5)
                      ),
                      placeholder: "johndoe@example.com",
                      style: smallTitle,
                    ),
                    SizedBox(height: 8,),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 2),
                      child: Text("Password", style: subTitle,),
                    ),
                    CupertinoTextField(
                      onTapOutside: (e){
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isActive = false;
                        });
                      },
                      onTap: (){
                        setState(() {
                          _isActive = true;
                        });
                      },
                      onChanged: (e){

                      },
                      controller: _pswrdController,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 2,
                              color: CupertinoTheme.of(context).barBackgroundColor
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5)
                      ),
                      placeholder: "secret-password123",
                      style: smallTitle,
                    ),

                    SizedBox(height: 16,),

                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                              minSize: 0,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              color: CupertinoTheme.of(context).primaryColor,
                              child: Text(_isLogin? "Log In" : "Sign Up", style: smallTitle,),

                              onPressed: () async {
                                UserData? u = _isLogin?
                                  await AuthService.signInWithEmail(_emailController.text, _pswrdController.text, context) :
                                  await AuthService.signUpWithEmail(_emailController.text, _pswrdController.text, context);

                                  if(u == null && FirebaseAuth.instance.currentUser != null){
                                    Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(builder: (context) => RegisterPage())
                                    );
                                  }else{
                                    context.read<UserProvidor>().setCurrentUser(u!);
                                    context.read<UserProvidor>().setIsAuthenticated(true);
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => HomePage()));
                                  }
                              }
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),
                    CupertinoButton(
                      onPressed: (){
                        AuthService.resetPassword(_emailController.text, context);
                      },
                        minSize: 0,
                        padding: EdgeInsets.zero,
                      child: Text(_isLogin? "Forgot Password" : "", style: subTitle,)
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white30,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("or", style: subTitle.copyWith(letterSpacing: 1),),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white30,
                        height: 1,
                      ),
                    )
                  ],
                ),
              ),

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
        ],
      ),
    );
  }
}
