import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _page = 0;
  late PageController pageController = PageController();

  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTab(int page) {
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: const Text(
          "Socian",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto",
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => navigationTab(0),
            icon: Icon(
              color: _page == 0 ? primaryColor : secondaryColor,
              Icons.home,
            ),
          ),
          IconButton(
            onPressed: () => navigationTab(1),
            icon: Icon(
              color: _page == 1 ? primaryColor : secondaryColor,
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () => navigationTab(2),
            icon: Icon(
              color: _page == 2 ? primaryColor : secondaryColor,
              Icons.add_a_photo,
            ),
          ),
          IconButton(
            onPressed: () => navigationTab(3),
            icon: Icon(
              color: _page == 3 ? primaryColor : secondaryColor,
              Icons.favorite_border,
            ),
          ),
          IconButton(
            onPressed: () => navigationTab(4),
            icon: Icon(
              color: _page == 4 ? primaryColor : secondaryColor,
              Icons.account_circle,
            ),
          ),
        ],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
    );
  }
}
