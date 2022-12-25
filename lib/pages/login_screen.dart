import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_app_socian/pages/sign_up_screen.dart';
import 'package:social_app_socian/resources/auth_methods.dart';
import 'package:social_app_socian/utils/colors.dart';
import 'package:social_app_socian/widgets/input_text_field.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // loading state
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (res != "success") {
      showSnackBar(res, context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void navigateToSignUpScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      padding: MediaQuery.of(context).size.width > 600
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 4,
            )
          : const EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(flex: 2, child: Container()),
          (SvgPicture.asset(
            "assests/images/socian.svg",
            height: 264,
            color: primaryColor,
          )), // svg picture
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
              loginUser();
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
                      ),
                    )
                  : const Text("Login"),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(flex: 2, child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: const Text("Don't have an account?"),
              ),
              GestureDetector(
                onTap: () {
                  navigateToSignUpScreen();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    )));
  }
}
