import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app_socian/pages/add_post_screen.dart';
import 'package:social_app_socian/pages/search_screen.dart';

import '../pages/feed_screen.dart';
import '../pages/profile_screen.dart';

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Text("Notifications Page"),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
