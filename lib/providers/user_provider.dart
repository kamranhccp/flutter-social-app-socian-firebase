import 'package:flutter/material.dart';
import 'package:social_app_socian/models/post.dart';
import 'package:social_app_socian/models/user.dart';
import 'package:social_app_socian/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser {
    if (_user != null) {
      return _user;
    } else {
      return null;
    }
  }

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

  Post? _post;

  Post? get getPost {
    if (_post != null) {
      return _post!;
    } else {
      return null;
    }
  }
}
