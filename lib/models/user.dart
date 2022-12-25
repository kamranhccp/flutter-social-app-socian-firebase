import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String username;
  final String email;
  final String password;
  final String uid;
  final String photoUrl;
  final List following;
  final List followers;

  const User({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.uid,
    required this.photoUrl,
    required this.following,
    required this.followers,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'uid': uid,
        'photoUrl': photoUrl,
        'following': following,
        'followers': followers,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      name: snapshot['name'],
      username: snapshot['username'],
      email: snapshot['email'],
      password: snapshot['password'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      following: snapshot['following'],
      followers: snapshot['followers'],
    );
  }
}
