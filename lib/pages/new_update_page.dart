// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:fbla_nlc_2024/services/firebase/firebase_messaging.dart';
import 'package:fbla_nlc_2024/utils.dart';
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
import 'package:http/http.dart' as http;

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

  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Container(
            alignment: AlignmentDirectional.centerStart,
            child: Text("Create New Experience", style: title),
          ),
          trailing: CupertinoButton(
            onPressed: () {
              if(_titleController.text.length < 1){
                showAlert("No Title", "Please give your post a title to create an experience.", context);
                return;
              }

              if(_descController.text.length < 1){
                showAlert("No Description", "Please give your post a description to create an experience.", context);
                return;
              }

              if(_files.length < 1){
                showAlert("No Images", "Please add at least one photo to create an experience.", context);
                return;
              }

              late BuildContext dialogContext;
              showCupertinoDialog(
                  context: context,
                  //barrierDismissible: true,
                  builder: (BuildContext context){
                    dialogContext = context;
                    return CupertinoAlertDialog(
                      title: Text("Creating Experience", style: smallTitle,),
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
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(10),
            minSize: 0,
            child: Container(
                decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoTheme.of(context).primaryColor,
                        spreadRadius: 0,
                        blurRadius: 12,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: CupertinoTheme.of(context).primaryColor.withOpacity(0.25),
                        width: 2
                    )
                ),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.5)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Text("Publish", style: subTitle.copyWith(color: Colors.white, fontSize: 16),),
                  ),
                )
            ),
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
                          padding: const EdgeInsets.only(top: 106, right: 12, left: 12),
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
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0, bottom: 2),
                                child: Text("Post Title", style: subTitle,),
                              ),
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
                                    color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5)
                                ),
                                placeholder: "2nd Place in FBLA Missouri SLC",
                                style: smallTitle,
                              ),
                              SizedBox(height: 16,),
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0, bottom: 2),
                                child: Text("Post Description", style: subTitle,),
                              ),
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
                                    color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5)
                                ),
                                style: subTitle,
                                placeholder: "In the Future Business Leaders of America (FBLA)...",
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
                  color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    width: 2
                  )
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