import 'package:flutter/cupertino.dart';

import '../theme.dart';

class GenericTextField extends StatelessWidget {
  const GenericTextField({super.key, required this.placeholder, required this.onChange});
  final String placeholder;
  final void Function(String e) onChange;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      onTapOutside: (e){
        FocusScope.of(context).unfocus();
      },
      onChanged: (e) => onChange(e),
      decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: CupertinoTheme.of(context).barBackgroundColor
          ),
          borderRadius: BorderRadius.circular(12),
          color: CupertinoTheme.of(context).barBackgroundColor
      ),
      style: subTitle,
      placeholder: placeholder,
      maxLines: null,
    );
  }
}
