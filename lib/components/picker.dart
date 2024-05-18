import 'package:fbla_nlc_2024/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Picker extends StatefulWidget {
  Picker({super.key, required this.options, required this.onChange, this.placeHolder});
  final List<String> options;
  final void Function(String e) onChange;
  String? placeHolder = null;

  @override
  State<Picker> createState() => PickerState();
}

class PickerState extends State<Picker> {
  int _selected = 0;

  void reset(){
    setState(() {
      _selected = 0;
    });
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoButton(
          onPressed: () => _showDialog(
            CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              // This sets the initial item.
              scrollController: FixedExtentScrollController(
                initialItem: _selected,
              ),
              // This is called when selected item is changed.
              onSelectedItemChanged: (int selectedItem) {
                setState(() {
                  _selected = selectedItem;
                  widget.onChange(widget.options[selectedItem]);
                });
              },
              children:
              List<Widget>.generate(widget.options.length, (int index) {
                return Center(child: Text(widget.options[index]));
              }),
            ),
          ),
          color: CupertinoTheme.of(context).barBackgroundColor,
          minSize: 0,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              widget.placeHolder != null? Text("${widget.placeHolder}: ${widget.options[_selected]}", style: smallTitle.copyWith(color: Colors.white60),) :
              Text("${widget.options[_selected]}", style: smallTitle.copyWith(color: Colors.white60),),
              SizedBox(width: 8,),
              Icon(Icons.edit_rounded, color: Colors.white60, size: 18,),
            ],
          ),
        ),
      ],
    );
  }
}
