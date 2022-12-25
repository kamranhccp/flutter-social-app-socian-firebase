import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:social_app_socian/models/user.dart' as model;
import 'package:social_app_socian/pages/profile_screen.dart';
import 'package:social_app_socian/providers/user_provider.dart';
import 'package:social_app_socian/utils/colors.dart';
import 'package:social_app_socian/utils/utils.dart';
import 'package:social_app_socian/widgets/like_animation.dart';

import '../pages/comment_screen.dart';
import '../resources/firestore_methods.dart';
import '../utils/dimensions.dart';

class PostCard extends StatefulWidget {
  final snap;

  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        err.toString(),
        context,
      );
    }
    setState(() {
      commentLen = commentLen;
    });
  }

  deletePost(String postId) async {
    try {
      await FirestoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        err.toString(),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          uid: widget.snap['uid'].toString(),
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'].toString() == user!.uid
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map(
                                          (e) => InkWell(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () async {
                                                await FirestoreMethods()
                                                    .deletePost(widget
                                                        .snap['postId']
                                                        .toString());
                                                // remove the dialog box
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : Container(
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shrinkWrap: true,
                                      children: [
                                        'Delete',
                                      ]
                                          .map(
                                            (e) => InkWell(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                                  child: Text(e),
                                                ),
                                                onTap: () async {
                                                  await FirestoreMethods()
                                                      .deletePost(widget
                                                          .snap['postId']
                                                          .toString());
                                                  // remove the dialog box
                                                  Navigator.of(context).pop();
                                                }),
                                          )
                                          .toList()),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.more_vert),
                        ),
                      ),
              ],
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.snap['postId'].toString(),
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  // if isLikeAnimating is true then opacity is 1(showing)
                  // else 0 - not showing
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    isAnimating: isLikeAnimating,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(
                      widget.snap['postId'].toString(),
                      user.uid,
                      widget.snap['likes'],
                    );
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                        ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.comment_outlined,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(
                      // pass the post id to the comment screen
                      // snap: widget.snap['postId'],
                      postId: widget.snap['postId'].toString(),
                    ),
                  ),
                ),
              ),
              IconButton(
                  icon: const Icon(
                    Icons.send,
                  ),
                  onPressed: () {}),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      icon: const Icon(
                        Icons.bookmark_border,
                      ),
                      onPressed: () {}),
                ),
              ),
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyText2,
                    )),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.snap['description']}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all ${commentLen} comments',
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        postId: widget.snap['postId'].toString(),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Container(
// child: Column(
// children: [
// Container(
// // boundary needed for web
// decoration: BoxDecoration(
// border: Border.all(
// color: width > webScreenSize
// ? secondaryColor
//     : mobileBackgroundColor,
// ),
// color: mobileBackgroundColor,
// ),
// padding: const EdgeInsets.symmetric(
// vertical: 10,
// ),
// child: Column(
// children: [
// // HEADER SECTION OF THE POST
// Container(
// padding: const EdgeInsets.symmetric(
// vertical: 4,
// horizontal: 16,
// ).copyWith(right: 0),
// child: Row(
// children: <Widget>[
// CircleAvatar(
// radius: 16,
// backgroundImage: NetworkImage(
// widget.snap['profImage'],
// ),
// ),
// Expanded(
// child: Padding(
// padding: const EdgeInsets.only(
// left: 8,
// ),
// child: Column(
// mainAxisSize: MainAxisSize.min,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: <Widget>[
// Text(
// widget.snap['username'].toString(),
// style: const TextStyle(
// fontWeight: FontWeight.bold,
// ),
// ),
// ],
// ),
// ),
// ),
// widget.snap['uid'] == user!.uid
// ? IconButton(
// onPressed: () {
// showDialog(
// useRootNavigator: false,
// context: context,
// builder: (context) {
// return Dialog(
// child: ListView(
// padding: const EdgeInsets.symmetric(
// vertical: 16),
// shrinkWrap: true,
// children: [
// 'Delete',
// ]
//     .map(
// (e) => InkWell(
// child: Container(
// padding:
// const EdgeInsets
//     .symmetric(
// vertical: 12,
// horizontal: 16),
// child: Text(e),
// ),
// onTap: () async {
// await FirestoreMethods()
//     .deletePost(
// widget.snap[
// 'postId']);
// // remove the dialog box
// Navigator.of(context)
//     .pop();
// }),
// )
//     .toList()),
// );
// },
// );
// },
// icon: const Icon(Icons.more_vert),
// )
// : Container(
// child: IconButton(
// onPressed: () {
// showDialog(
// useRootNavigator: false,
// context: context,
// builder: (context) {
// return Dialog(
// child: ListView(
// padding:
// const EdgeInsets.symmetric(
// vertical: 16),
// shrinkWrap: true,
// children: [
// 'Delete',
// ]
//     .map(
// (e) => InkWell(
// child: Container(
// padding:
// const EdgeInsets
//     .symmetric(
// vertical: 12,
// horizontal:
// 16),
// child: Text(e),
// ),
// onTap: () async {
// await FirestoreMethods()
//     .deletePost(widget
//     .snap[
// 'postId']);
// // remove the dialog box
// Navigator.of(context)
//     .pop();
// }),
// )
//     .toList()),
// );
// },
// );
// },
// icon: const Icon(Icons.more_vert),
// ),
// ),
// ],
// ),
// ),
// // IMAGE SECTION OF THE POST
// GestureDetector(
// onDoubleTap: () async {
// await FirestoreMethods().likePost(
// widget.snap['postId'],
// user.uid,
// widget.snap['likes'],
// );
// setState(() {
// isLikeAnimating = true;
// });
// },
// child: Stack(
// alignment: Alignment.center,
// children: [
// SizedBox(
// height: MediaQuery.of(context).size.height * 0.35,
// width: double.infinity,
// child: Image.network(
// widget.snap['postUrl'],
// fit: BoxFit.cover,
// ),
// ),
// AnimatedOpacity(
// duration: const Duration(milliseconds: 200),
// // if isLikeAnimating is true then opacity is 1(showing)
// // else 0 - not showing
// opacity: isLikeAnimating ? 1 : 0,
// child: LikeAnimation(
// duration: const Duration(
// milliseconds: 400,
// ),
// onEnd: () {
// setState(() {
// isLikeAnimating = false;
// });
// },
// isAnimating: isLikeAnimating,
// child: const Icon(
// Icons.favorite,
// color: Colors.red,
// size: 100,
// ),
// ),
// ),
// ],
// ),
// ),
// // LIKE, COMMENT SECTION OF THE POST
// Row(
// children: <Widget>[
// LikeAnimation(
// isAnimating: widget.snap['likes'].contains(user.uid),
// smallLike: true,
// child: IconButton(
// onPressed: () async {
// await FirestoreMethods().likePost(
// widget.snap['postId'],
// user.uid,
// widget.snap['likes'],
// );
// },
// icon: widget.snap['likes'].contains(user.uid)
// ? const Icon(
// Icons.favorite,
// color: Colors.red,
// )
// : const Icon(
// Icons.favorite_border,
// ),
// ),
// ),
// IconButton(
// icon: const Icon(
// Icons.comment_outlined,
// ),
// onPressed: () => Navigator.of(context).push(
// MaterialPageRoute(
// builder: (context) => CommentScreen(
// // pass the post id to the comment screen
// // snap: widget.snap['postId'],
// snap: widget.snap,
// ),
// ),
// ),
// ),
// IconButton(
// icon: const Icon(
// Icons.send,
// ),
// onPressed: () {}),
// Expanded(
// child: Align(
// alignment: Alignment.bottomRight,
// child: IconButton(
// icon: const Icon(Icons.bookmark_border),
// onPressed: () {}),
// ))
// ],
// ),
// //DESCRIPTION AND NUMBER OF COMMENTS
// Container(
// padding: const EdgeInsets.symmetric(horizontal: 16),
// child: Column(
// mainAxisSize: MainAxisSize.min,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: <Widget>[
// DefaultTextStyle(
// style: Theme.of(context)
// .textTheme
//     .subtitle2!
// .copyWith(fontWeight: FontWeight.w800),
// child: Text(
// '${widget.snap['likes'].length} likes',
// style: Theme.of(context).textTheme.bodyText2,
// )),
// Container(
// width: double.infinity,
// padding: const EdgeInsets.only(
// top: 8,
// ),
// child: RichText(
// text: TextSpan(
// style: const TextStyle(color: primaryColor),
// children: [
// TextSpan(
// text: widget.snap['username'].toString(),
// style: const TextStyle(
// fontWeight: FontWeight.bold,
// ),
// ),
// TextSpan(
// text: ' ${widget.snap['description']}',
// ),
// ],
// ),
// ),
// ),
// InkWell(
// child: Container(
// padding: const EdgeInsets.symmetric(vertical: 4),
// child: Text(
// 'View all ${commentLen} comments',
// style: const TextStyle(
// fontSize: 16,
// color: secondaryColor,
// ),
// ),
// ),
// onTap: () => Navigator.of(context).push(
// MaterialPageRoute(
// builder: (context) => CommentScreen(
// snap: widget.snap['postId'].toString(),
// ),
// ),
// ),
// ),
// Container(
// padding: const EdgeInsets.symmetric(vertical: 4),
// child: Text(
// DateFormat.yMMMd()
// .format(widget.snap['datePublished'].toDate()),
// style: const TextStyle(
// color: secondaryColor,
// ),
// ),
// ),
// ],
// ),
// )
// ],
// ),
// ),
// ],
// ),
// ),
