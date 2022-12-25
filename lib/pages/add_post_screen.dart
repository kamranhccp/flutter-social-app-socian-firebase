import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app_socian/models/user.dart' as model;
import 'package:social_app_socian/providers/user_provider.dart';
import 'package:social_app_socian/resources/firestore_methods.dart';
import 'package:social_app_socian/utils/colors.dart';
import 'package:social_app_socian/utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _image;
  TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void postImage(String uid, String username, String profileImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
          _descriptionController.text, _image!, uid, profileImage, username);
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        showSnackBar("Posted", context);
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(
                color: Colors.blueAccent,
                width: 1,
              ),
            ),
            titleTextStyle: const TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            title: const Text(
              "Create Post",
              style: TextStyle(
                color: mobileBackgroundColor,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            alignment: Alignment.center,
            children: [
              SimpleDialogOption(
                child: const Text(
                  "Gallery",
                  style: TextStyle(
                      color: mobileBackgroundColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List image = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() {
                    _image = image;
                  });
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  "Camera",
                  style: TextStyle(
                      color: mobileBackgroundColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List image = await pickImage(
                    ImageSource.camera,
                  );
                  setState(() {
                    _image = image;
                  });
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                      color: mobileBackgroundColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).getUser;
    return _image == null
        ? Center(
            child: IconButton(
              onPressed: () => _selectImage(context),
              icon: const Icon(Icons.upload_rounded),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: false,
              shadowColor: Colors.blueGrey[700],
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: clearImage,
                icon: const Icon(
                  Icons.arrow_back,
                  color: primaryColor,
                ),
              ),
              title: const Text(
                "Add Post",
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () =>
                        postImage(user!.uid, user.username, user.photoUrl),
                    child: const Text(
                      "Post",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.blueAccent),
                    ))
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoUrl),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: "Write a caption...",
                          hintStyle: TextStyle(),
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(_image!),
                              fit: BoxFit.cover,
                              alignment: FractionalOffset.topCenter,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
  }
}
