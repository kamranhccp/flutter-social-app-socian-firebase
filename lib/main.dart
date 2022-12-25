import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app_socian/pages/login_screen.dart';
import 'package:social_app_socian/providers/user_provider.dart';
import 'package:social_app_socian/responsive/mobile_screen_layout.dart';
import 'package:social_app_socian/responsive/responsive_layout_screen.dart';
import 'package:social_app_socian/responsive/web_screen_layout.dart';
import 'package:social_app_socian/utils/colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyA1AAlKAZ6-Ni2UkijQ2vjt7AVtt1YSrGk',
        messagingSenderId: "26043856556",
        projectId: "social-app-socian",
        storageBucket: "social-app-socian.appspot.com",
        appId: '1:26043856556:web:7f3f3181a65805e1a7d109',

          // <== | FOR LATER USE | ==>
          // authDomain: "social-app-socian.firebaseapp.com",
          // measurementId: "G-CPEH8JXSRW"
      ),
    );
  }else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Socian',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor
        ),

        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            } else if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.hasData){
                return const ResponsiveLayout(
                  webScreenLayout: WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout(),
                );
              } else if(snapshot.hasError){
                return Center(
                  child: Text("Error${snapshot.error}"),
                );
              }
            }

            return const LoginScreen();
          },
        )
      ),
    );
  }
}
