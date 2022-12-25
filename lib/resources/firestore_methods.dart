import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app_socian/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload post image to firebase storage
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String profileImage,
    String username,
  ) async {
    String res = "Something went wrong";

    try {
      String uploadPhotoUrl =
          await StorageMethods().uploadImageToStorage("postImages", file, true);

      String postId = const Uuid().v1();
      Post post = Post(
          description: description,
          username: username,
          uid: uid,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: uploadPhotoUrl,
          profImage: profileImage,
          likes: []);

      _firestore.collection("posts").doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // post list from firebase
  Future<String> likePost(String uid, String postId, List likes) async {
    String res = "Something went wrong";
    try {
      if (likes.contains(uid)) {
        await _firestore.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection("posts").doc(uid).update({
          "likes": FieldValue.arrayUnion([postId])
        });
      }
      res = "success";
    } catch (err) {
      print(
        res = err.toString(),
      );
    }
    return res;
  }

  Future<void> postComment(
    String postId,
    String comment,
    String uid,
    String username,
    String profilePic,
  ) async {
    try {
      if (comment.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'username': username,
          'uid': uid,
          'comment': comment,
          "commentId": commentId,
          "datePublished": DateTime.now(),
        });
      } else {
        print('Comment is empty');
      }
    } catch (err) {
      print(err.toString());
    }
  }

  // delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection("posts").doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> followUser(String uid, String followID) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection("users").doc(uid).get();
      List followers = (snap.data()! as dynamic)['followers'];
      if (followers.contains(followID)) {
        await _firestore.collection("users").doc(followID).update({
          "followers": FieldValue.arrayRemove([uid])
        });

        await _firestore.collection("users").doc(uid).update({
          "followings": FieldValue.arrayRemove([followID])
        });
      } else {
        await _firestore.collection("users").doc(followID).update({
          "followers": FieldValue.arrayUnion([uid])
        });

        await _firestore.collection("users").doc(uid).update({
          "followings": FieldValue.arrayUnion([followID])
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (err) {
      print(err.toString());
    }
  }
}
