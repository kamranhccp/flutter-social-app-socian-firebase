import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app_socian/pages/login_screen.dart';
import 'package:social_app_socian/resources/auth_methods.dart';
import 'package:social_app_socian/utils/colors.dart';
import 'package:social_app_socian/utils/utils.dart';
import 'package:social_app_socian/widgets/input_text_field.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false; // loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      name: _nameController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      image: _image!,
    );

    setState(() {
      _isLoading = false;
    });
    if (res != "success") {
      showSnackBar(res, context);
    } else{
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
      );
    }
  }

  void navigateToLoginScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                      flex: 2,
                      child: Container()
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    child: (SvgPicture.asset("assests/images/socian.svg",
                      color: primaryColor,)
                    ),
                  ), // svg picture
                  const SizedBox(height: 20),
                  Stack(
                    children:  [
                        _image != null
                      ? CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_image!),
                      )
                      : const CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage("https://www.kindpng.com/picc/m/21-214439_free-high-quality-person-icon-default-profile-picture.png"),
                      ),

                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: () {
                            selectImage();
                          },
                          icon: const Icon(
                              Icons.add_a_photo,),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InputTextField(
                    textEditingController: _nameController,
                    hintText: "Name",
                    textInputType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),
                  InputTextField(
                    textEditingController: _usernameController,
                    hintText: "Username",
                    textInputType: TextInputType.text
                  ),
                  const SizedBox(height: 20),
                  InputTextField(
                    textEditingController: _emailController,
                    hintText: "Email",
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  InputTextField(
                    textEditingController: _passwordController,
                    hintText: "Password",
                    textInputType: TextInputType.text,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      signUpUser();
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Colors.blue,
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),)
                          : const Text("Signup"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(flex: 2, child: Container()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: const  Text("Already have an account?"),
                      ),
                      GestureDetector(
                        onTap: () {
                          navigateToLoginScreen();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: const  Text("Login",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],)
                ],
              ),
            )
        )
    );
  }
}
