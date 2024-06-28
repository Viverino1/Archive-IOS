import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

String formatDateTime(DateTime epoch){
  return epoch.month.toString() + "/" + epoch.day.toString() + "/" + epoch.year.toString();
}

String removeRising(String s){
  return s.toLowerCase().replaceAll("rising", "");
}

String formatYear(String raw){
  String output = raw.capitalize();
  if(output.contains("Rising")){
    return "Rising ${output.substring(6)}";
  }
  return output;
}

launchPrivacy() async {
  const url = 'https://docs.google.com/document/d/1MF3WFO3UC6GO1BYzDLiPGMSdH8HkiTMt-3JCYrLvUcY/edit?usp=sharing';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

launchTerms() async {
  const url = 'https://docs.google.com/document/d/14FcrzIHSLZq20kGOw10Y2-VMGb8rLyE4KuCGoR3m1m8/edit?usp=sharing';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

String formatPlace(int place){
  if(place == 1){
    return "1st";
  }else if(place == 2){
    return "2nd";
  }else if(place == 3){
    return "3rd";
  }else{
    return "${place}th";
  }
}

void showAlert(String title, String content, BuildContext context){
  showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(

        title: Text(title, style: smallTitle,),
        content: Text(content, style: subTitle,),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
            child: Text('Ok', style: smallTitle.copyWith(color: CupertinoTheme.of(context).primaryColor),),
          ),
      ],
    )
  );
}

String gradeToLetter(double grade){
  if(grade > 97){
    return "A+";
  }else if(grade >= 93){
    return "A";
  }else if(grade >= 90){
    return "A-";
  }else if(grade >= 87){
    return "B+";
  }else if(grade >= 83){
    return "B";
  }else if(grade >= 80){
    return "B-";
  }else if(grade >= 77){
    return "C+";
  }else if(grade >= 73){
    return "C";
  }else if(grade >= 70){
    return "C-";
  }else if(grade >= 67){
    return "D+";
  }else if(grade >= 63){
    return "D";
  }else if(grade >= 60){
    return "D-";
  }else{
    return "F";
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}