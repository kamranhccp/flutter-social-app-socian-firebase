import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app_socian/pages/profile_screen.dart';
import 'package:social_app_socian/pages/single_post_screen.dart';
import 'package:social_app_socian/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isShowUser = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        primary: true,
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: mobileSearchColor),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: mobileSearchColor),
            ),
            hintText: "Search for a user",
            hintStyle: TextStyle(color: Colors.white),
          ),
          onFieldSubmitted: (String _) {
            setState(
              () {
                isShowUser = true;
              },
            );
          },
        ),
      ),
      body: isShowUser
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: _searchController.text,
                  )
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: snapshot.data!.docs[index]['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            snapshot.data!.docs[index]['photoUrl'],
                          ),
                        ),
                        title: Text(
                          snapshot.data!.docs[index]['username'],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection("posts").get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return MediaQuery.of(context).size.width > 600
                    ? GridView.count(
                        padding: const EdgeInsets.all(6),
                        crossAxisCount: 4,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        physics: const BouncingScrollPhysics(),
                        children: List.generate(
                          (snapshot.data! as dynamic).docs.length,
                          (index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SinglePostScreen(
                                      snap: snapshot.data!.docs[index].data(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                // margin: width > 600
                                //     ? const EdgeInsets.only(left: 100, right: 100)
                                //     : const EdgeInsets.all(0),
                                color: Colors.grey[800],
                                child: Image.network(
                                  snapshot.data!.docs[index]['postUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : GridView.count(
                        padding: const EdgeInsets.all(6),
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        physics: const BouncingScrollPhysics(),
                        children: List.generate(
                          snapshot.data!.docs.length,
                          (index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SinglePostScreen(
                                      snap: snapshot.data!.docs[index].data(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                // margin: width > 600
                                //     ? const EdgeInsets.only(left: 100, right: 100)
                                //     : const EdgeInsets.all(0),
                                color: Colors.grey[800],
                                child: Image.network(
                                  snapshot.data!.docs[index]['postUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      );
              },
            ),
    );
  }
}
