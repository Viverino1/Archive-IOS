import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';

String formatDateTime(DateTime epoch){
  return epoch.month.toString() + "/" + epoch.day.toString() + "/" + epoch.year.toString();
}

String formatYear(String raw){
  String output = raw.capitalize();
  if(output.contains("Rising")){
    return "Rising ${output.substring(6)}";
  }
  return output;
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
            },
            child: Text('Ok', style: smallTitle.copyWith(color: CupertinoTheme.of(context).primaryColor),),
          ),
      ],
    )
  );
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}