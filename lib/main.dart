//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'features/app/splash_screen/splash.dart'; // Adjusted the import path

const SAVE_KEY_NAME = '_userLoggedIn'; // Consider moving to a constants file

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAJ6IlMqLidoV8dzprFtRPJt4wfXW1k7Y8",
            appId: "1:814761519101:web:8f645ef7a1dc03528f9b94",
            messagingSenderId: "814761519101",
            projectId: "choreo-flutter"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:
          const Size(360, 690), // Set design size based on your UI design
      minTextAdapt: true, // Ensures text adapts properly
      splitScreenMode: true, // Support for split screen
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ChoreoScope....',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: MySplash(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0), // Disables system text scaling
              child: child!,
            );
          },
        );
      },
    );
  }
}
