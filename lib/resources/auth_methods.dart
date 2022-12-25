import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app_socian/models/user.dart' as model;
import 'package:social_app_socian/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot documentSnapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return model.User.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
    required String username,
    required Uint8List image,
    }) async {
    String res = "Something went wrong";
    try{
      if(email.isNotEmpty || password.isNotEmpty || name.isNotEmpty || username.isNotEmpty){
        // Registered user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password
        );

        String photoURL = await StorageMethods().uploadImageToStorage("profileImage", image, false);

        model.User user = model.User(
          email: email,
          password: password,
          uid: userCredential.user!.uid,
          name: name,
          photoUrl: photoURL,
          username: username,
          followers: [],
          following: [],
        );
        // Add user to firestore/Database
        await _firestore.collection("users").doc(userCredential.user!.uid).set(user.toJson(),);

        // second method to add to firestore
        // await _firestore.collection("users").add({
        //   "name": name,
        //   "username": username,
        //   "email": email,
        //   "password": password,
        //   "following": [],
        //   "followers": [],
        //   "uid": userCredential.user!.uid,
        // });
        res = "success";
      }
    } on FirebaseAuthException catch(e){
      if(e.code == "weak-password"){
        res = "Password must be at least 6 characters";
      }else if(e.code == "email-already-in-use"){
        res = "The Account already exists with this Email";
      } else if(e.code == "invalid-email"){
        res = "This Email Address is not valid";
      } else if(e.code == "success"){
        res = "Account Created Successfully";
      }
    }

    catch (e) {
      res = e.toString();
    }
    return res;
  }

  // for login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Something went wrong";
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        // Registered user
        await _auth.signInWithEmailAndPassword(
            email: email,
            password: password
        );
        res = "success";
      }
    } on FirebaseAuthException catch(e){
      if(e.code == "user-not-found"){
        res = "No user found for this email";
      }else if(e.code == "wrong-password"){
        res = "Wrong Password";
      } else if(e.code == "invalid-email"){
        res = "This Email Address is not valid";
      } else if(e.code == "success"){
        res = "Account Created Successfully";
      }
    }

    catch (e) {
      res = e.toString();
    }
    return res;
  }
}