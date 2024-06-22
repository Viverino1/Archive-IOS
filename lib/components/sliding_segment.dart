// ignore_for_file: prefer_const_constructors

import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';

class SlidingSegment extends StatefulWidget {
  SlidingSegment({super.key, required this.selected, required this.options, required this.onChange});
  int selected;
  final List<String> options;
  final void Function(String option) onChange;

  @override
  State<SlidingSegment> createState() => _SlidingSegmentState();
}

class _SlidingSegmentState extends State<SlidingSegment> {
  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<String>(
      backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      thumbColor: CupertinoTheme.of(context).primaryColor,
      groupValue: widget.options[widget.selected],
      onValueChanged: (String? value) {
        if (value != null) {
          widget.onChange(value);
          setState(() {
            widget.selected = widget.options.indexOf(value);
          });
        }
      },
      children: makeMap(widget.options),
    );
  }
}

Map<String, Widget> makeMap(List<String> options){
  Map<String, Widget> map = {};

  for(int i = 0; i < options.length; i++){
    map[options[i]] = Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        options[i],
        style: smallTitle,
      ),
    );
  }

  return map;
}