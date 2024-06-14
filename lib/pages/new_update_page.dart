// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_input/image_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../classes.dart';
import '../components/carousel.dart';
import '../components/date-picker.dart';
import '../components/picker.dart';
import '../data/providors.dart';
import '../services/firebase/firestore/db.dart';
import '../theme.dart';

class NewUpdatePage extends StatefulWidget {
  const NewUpdatePage({super.key});

  @override
  State<NewUpdatePage> createState() => _NewUpdatePageState();
}

class _NewUpdatePageState extends State<NewUpdatePage> {
  static PostData _post = PostData();
  static List<XFile> _files = [];

  final GlobalKey<PickerState> _pickerKey = GlobalKey();
  final GlobalKey<DatePickerState> _datePickerKey = GlobalKey();
  final GlobalKey<MyCarouselState> _carouselKey = GlobalKey();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Container(
            alignment: AlignmentDirectional.centerStart,
            child: Text("Create New Update", style: title),
          ),
          trailing: CupertinoButton(
            onPressed: () {
              late BuildContext dialogContext;
              showCupertinoDialog(
                  context: context,
                  //barrierDismissible: true,
                  builder: (BuildContext context){
                    dialogContext = context;
                    return CupertinoAlertDialog(
                      title: Text("Creating Update", style: smallTitle,),
                      content: Column(
                        children: [
                          SizedBox(height: 8,),
                          CupertinoActivityIndicator(radius: 16,),
                        ],
                      ),
                    );
                  }
              ).then((value) => setState(() {
                _post = PostData();
                _files = [];
              }));
              Firestore.makePost(_post, _files, context.read<UserProvidor>().currentUser).then((value) {
                Navigator.pop(dialogContext);
                _pickerKey.currentState?.reset();
                _datePickerKey.currentState?.reset();
                _carouselKey.currentState?.reset();
                _titleController.clear();
                _descController.clear();
                setState(() {
                  _files = [];
                  _post = PostData();
                });
              });

            },
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minSize: 0,
            color: CupertinoTheme.of(context).primaryColor,
            child: Text("Publish", style: smallTitle,),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 112, right: 16, left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Picker(
                                    onChange: (e){
                                      _post.type = e;
                                    },
                                    key: _pickerKey,
                                    options: ["Competition", "Extracurricular", "Volunteering", "Athletic", "Academic", "Performing Arts"],
                                  ),
                                  SizedBox(width: 16,),
                                  DatePicker(
                                    onChange: (e) {
                                      _post.date = e;
                                    },
                                    key: _datePickerKey,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16,),
                              CupertinoTextField(
                                onTapOutside: (e){
                                  FocusScope.of(context).unfocus();
                                },
                                onChanged: (e){
                                  _post.title = e;
                                },
                                controller: _titleController,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2,
                                        color: CupertinoTheme.of(context).barBackgroundColor
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: CupertinoTheme.of(context).barBackgroundColor
                                ),
                                placeholder: "Title",
                                style: smallTitle,
                              ),
                              SizedBox(height: 16,),
                              CupertinoTextField(
                                onTapOutside: (e){
                                  FocusScope.of(context).unfocus();
                                },
                                onChanged: (e){
                                  _post.description = e;
                                },
                                controller: _descController,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2,
                                        color: CupertinoTheme.of(context).barBackgroundColor
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: CupertinoTheme.of(context).barBackgroundColor
                                ),
                                style: subTitle,
                                placeholder: "Description",
                                maxLines: null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16,),
                        SizedBox(height: 4,),
                        MyCarousel(
                          onChange: (e){
                            _files = e;
                          },
                          key: _carouselKey,
                        ),
                        SizedBox(height: 112,),
                      ],
                    ),
                  )
              );
            }
        )
    );
  }
}

class MyCarousel extends StatefulWidget {
  List<Widget>? children = [];
  final Function (List<XFile> files) onChange;
  MyCarousel({super.key, this.children, required this.onChange});

  @override
  State<MyCarousel> createState() => MyCarouselState();
}

class MyCarouselState extends State<MyCarousel> {
  int _index = 0;
  List<XFile> _files = [];

  void reset(){
    setState(() {
      _index = 0;
      _files = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: <Widget>[
            CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                List<XFile> images = await picker.pickMultiImage();
                setState(() {
                  _files += images.map((e) => e).toList();
                  widget.onChange(_files);
                });
              },
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.camera, size: 32,),
                        SizedBox(height: 4,),
                        Text("Add Photo", style: subTitle,)
                      ],
                    )
                ),
              ),
            ),
          ] + (widget.children?? []) + List.generate(_files.length, (index) => MyFileImage(
            file: _files[index],
            delete: (file){
              setState(() {
                _files.remove(file);
              });
            },
          ) as Widget),
          options: CarouselOptions(
            autoPlay: false, // Enable auto-play
            enlargeCenterPage: true, // Increase the size of the center item
            enableInfiniteScroll: false, // Enable infinite scroll
            onPageChanged: (index, reason) {
              setState(() {
                _index = index;
              });
            },
          ),
        ),
        SizedBox(height: 12,),
        Stack(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _files.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: _files.indexOf(item) == (_index - 1 - (widget.children != null? widget.children!.length : 0))?
                        Colors.white60 :
                        Colors.white60.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                )).toList()
            ),
          ],
        ),
      ],
    );
  }
}

class MyFileImage extends StatelessWidget {
  final XFile file;
  final void Function(XFile file) delete;
  const MyFileImage({super.key, required this.file, required this.delete});

  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image(
            height: 200,
            width: 300,
            fit: BoxFit.cover,
            image: XFileImage(file)
          )
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Spacer(),
              CupertinoButton(
                borderRadius: BorderRadius.circular(24),
                onPressed: (){
                  delete(file);
                },
                minSize: 0,
                padding: EdgeInsets.all(8),
                color: CupertinoTheme.of(context).primaryColor,
                child: Icon(CupertinoIcons.delete),
              ),
            ],
          ),
        ),
      ],
    );
  }
}