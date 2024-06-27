import 'package:fbla_nlc_2024/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                child: const Icon(Icons.chevron_left_rounded, size: 36, color: Colors.white,),
              ),
              Text("Support", style: title),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 120.0, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact", style: smallTitle,),
            SizedBox(height: 2,),
            Text("The archive team can be contacted at any of the following emails or phone numbers.", style: subTitle,),
            SizedBox(height: 8,),
            Text("Vivek Maddineni", style: smallTitle,),
            Text("vivekmaddineni@gmail.com", style: subTitle,),
            Text("636-333-1447", style: subTitle,),
            SizedBox(height: 8,),
            Text("Timothy Zheng", style: smallTitle,),
            Text("timzheng08@gmail.com", style: subTitle,),
            Text("636-484-6189", style: subTitle,),

            SizedBox(height: 8,),

            CupertinoButton(minSize: 0, padding: EdgeInsets.zero, child: Row(children: [
              Text("Privacy Policy", style: smallTitle.copyWith(color: CupertinoTheme.of(context).primaryColor),),
              SizedBox(width: 2,),
              Icon(CupertinoIcons.link, size: 18,)
            ],), onPressed: (){
              launchPrivacy();
            }),

            SizedBox(height: 8,),

            CupertinoButton(minSize: 0, padding: EdgeInsets.zero, child: Row(children: [
              Text("Terms of Service", style: smallTitle.copyWith(color: CupertinoTheme.of(context).primaryColor),),
              SizedBox(width: 2,),
              Icon(CupertinoIcons.link, size: 18,)
            ],), onPressed: (){
              launchTerms();
            })
          ],
        ),
      ),
    );
  }
}
