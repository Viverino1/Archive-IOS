// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'auth_page.dart';

class HeroPage extends StatelessWidget {
  const HeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 64,),
                Text(
                  "Portfoliator",
                  style: title.copyWith(
                    fontSize: 48,
                  ),
                ),
                SizedBox(height: 4,),
                Padding(
                  padding: const EdgeInsets.only(right: 126),
                  child: Text(
                    "Showcase your all your achievements and skills here to share them with the world.",
                    style: subTitle.copyWith(
                        letterSpacing: 1.5,
                        height: 2
                    ),
                  ),
                ),

                Spacer(),
                Row(
                  children: [
                    Spacer(),
                    CupertinoButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AuthPage())
                        );
                      },
                      borderRadius: BorderRadius.circular(64),
                      color: CupertinoTheme.of(context).primaryColor,
                      minSize: 0,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Row(
                        children: [
                          Text("Get Started"),
                          SizedBox(width: 8,),
                          Icon(CupertinoIcons.arrow_right, size: 18,)
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 32,)
              ],
            ),
            Phones()
          ],
        ),
      ),
    );
  }
}

class Phones extends StatefulWidget {
  const Phones({super.key});

  @override
  State<Phones> createState() => _PhonesState();
}

class _PhonesState extends State<Phones> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this,);
    animation = Tween<double>(begin: 50, end: -150).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOutCubic,
        )
    )..addListener(() {setState(() {});});
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.rotationZ(-3.14/4)..scale(1.75, 1.75)..translate(-280.0, 200.0),
      child: Row(
        children: [
          Transform(transform: Matrix4.rotationZ(3.14/2)..translate(0.0, animation.value), child: SizedBox(width: MediaQuery.of(context).size.width/2.5, child: Image.network("https://firebasestorage.googleapis.com/v0/b/fbla-mobile-app-2024.appspot.com/o/HeroPics%2FClass%20Details.png?alt=media&token=2ab43fd5-9bca-4aab-9109-8f7fe60028df")),),
          Transform(transform: Matrix4.rotationZ(0)..translate(0.0, animation.value + 150), child: SizedBox(width: MediaQuery.of(context).size.width/2.5, child: Image.network("https://firebasestorage.googleapis.com/v0/b/fbla-mobile-app-2024.appspot.com/o/HeroPics%2FProfile.png?alt=media&token=f4736666-b661-44bb-89b2-af6d6e6ec533")))
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
