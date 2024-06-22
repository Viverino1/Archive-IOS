import 'package:cupertino_refresh/cupertino_refresh.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../components/comment.dart';
import '../data/providors.dart';
import '../theme.dart';
class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key, required this.post, required this.onCommentsUpdate});
  final PostData post;
  final void Function(List<CommentData> comments) onCommentsUpdate;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  bool _isTextFieldActive = false;
  UserData? _replyToUser = null;
  CommentData? _replyToComment = null;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    void submit(){
      FocusScope.of(context).unfocus();

      if(_replyToUser == null){
        CommentData comment = CommentData();
        comment.content = controller.value.text;
        comment.time = DateTime.now().millisecondsSinceEpoch;
        comment.uid = context.read<UserProvidor>().currentUser.uid;
        comment.id = Uuid().v4();

        setState(() {
          _isTextFieldActive = false;
          widget.post.comments.add(comment);
        });

        Firestore.addComment(comment, widget.post);
      }else{
        ReplyData reply = ReplyData();
        reply.content = controller.value.text;
        reply.time = DateTime.now().millisecondsSinceEpoch;
        reply.uid = context.read<UserProvidor>().currentUser.uid;
        reply.likes = [];
        reply.id = Uuid().v4();

        Firestore.addReply(reply, _replyToComment!, widget.post);

        setState(() {
          _isTextFieldActive = false;
          widget.post.comments.firstWhere((c) => c.id == _replyToComment!.id).replies.add(reply);
          _replyToComment = null;
          _replyToUser = null;
        });
      }

      widget.onCommentsUpdate(widget.post.comments);
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Row(
          children: [
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.zero,
              child: const Icon(Icons.chevron_left_rounded, size: 36, color: Colors.white,),
            ),
            Container(
              alignment: AlignmentDirectional.centerStart,
              child: Text("Comments", style: title),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.only(top:78),
        child: Stack(
          children: [
            CupertinoRefresh(
              physics: const AlwaysScrollableScrollPhysics(),
              onRefresh: () async {
                //final comments = await widget.onCommentsRefresh();
                final comments = await Firestore.getComments(widget.post);
                setState(() {
                  widget.post.comments = comments;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: widget.post.comments.map((c) => Comment(
                    comment: c,
                    post: widget.post,
                    onDelete: (){
                      setState(() {
                        widget.post.comments.removeWhere((p) => p.id == c.id);
                      });
                      widget.onCommentsUpdate(widget.post.comments);
                      Firestore.deleteComment(c, widget.post);
                    },
                    onReply: (u){
                      setState(() {
                        _replyToUser = u;
                        _replyToComment = c;
                      });
                    },
                    onRepliesUpdate: widget.onCommentsUpdate,
                    onLike: (){
                      setState(() {
                        if(!widget.post.comments.firstWhere((e) => e.id == c.id).likes.contains(context.read<UserProvidor>().currentUser.uid)){
                          widget.post.comments.firstWhere((e) => e.id == c.id).likes.add(context.read<UserProvidor>().currentUser.uid);
                          Firestore.likeComment(c, widget.post, context);
                        }else{
                          widget.post.comments.firstWhere((e) => e.id == c.id).likes.remove(context.read<UserProvidor>().currentUser.uid);
                          Firestore.unLikeComment(c, widget.post, context);
                        }
                      });
                      widget.onCommentsUpdate(widget.post.comments);
                    },
                  )).toList(),
                ),
              ),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._replyToUser != null? [
                          Row(children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: CupertinoButton(
                                  color: CupertinoTheme.of(context).primaryColor,
                                  minSize: 10,
                                  borderRadius: BorderRadius.circular(100),
                                  padding: EdgeInsets.zero,
                                  onPressed: (){
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _replyToUser = null;
                                      _replyToComment = null;
                                    });
                                  },
                                  child: const Center(child: Icon(CupertinoIcons.xmark, size: 16,))
                              ),
                            ),
                            SizedBox(width: 8,),
                            Text("Replying to ${_replyToUser?.firstName} ${_replyToUser?.lastName}", style: subTitle,),
                          ],),
                          SizedBox(height: 8,),
                        ] : [],
                        CupertinoTextField(
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 3.0),
                            child: SizedBox(
                              height: 28,
                              width: 28,
                              child: CupertinoButton(
                                  color: CupertinoTheme.of(context).primaryColor,
                                  minSize: 10,
                                  borderRadius: BorderRadius.circular(100),
                                  padding: EdgeInsets.zero,
                                  onPressed: submit,
                                  child: const Center(child: Icon(Icons.arrow_upward_rounded, size: 20,))
                              ),
                            ),
                          ),
                          controller: controller,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (e) => submit(),
                          onTapOutside: (e){
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isTextFieldActive = false;
                            });
                          },
                          onTap: (){
                            setState(() {
                              _isTextFieldActive = true;
                            });
                          },
                          onChanged: (e){

                          },
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 2,
                                color: CupertinoTheme.of(context).barBackgroundColor
                            ),
                            borderRadius: BorderRadius.circular(100),
                            color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.5),
                          ),
                          style: subTitle,
                          placeholder: "Add a Comment",
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    curve: Curves.easeInOut,
                    duration: Duration(milliseconds: 250),
                    child: SizedBox(height: _isTextFieldActive? 16 : 32,),
                  )
                ]
            )
          ],
        )
      ),

    );
  }
}