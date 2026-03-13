import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/view_manager/home_manager/home_view_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kindergarten_user/view/home/home_view.dart';
import 'package:kindergarten_user/view/login/login.dart';
import 'package:kindergarten_user/view/program/program.dart';
import 'package:kindergarten_user/model/home_model.dart';
import 'firebase_options.dart';
import 'package:kindergarten_user/view_manager/users_page.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sharePref = await SharedPreferences.getInstance();

  // تهيئة الكونترولر لإدارة البيانات الأولية
  // Get.put(DataInitializationController()); // تم حذفه لأنه خاص بالبيانات التجريبية

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  runApp(MyApp());
}
SharedPreferences? sharePref;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Locale("ar"),
      debugShowCheckedModeBanner: false,
      title: 'تطبيق الروضة',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF667EEA),
        scaffoldBackgroundColor: Color(0xFFF8FAFF),
        // Use system default font for better Arabic rendering
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF667EEA),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            // use default font
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF667EEA),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
        ),
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? "/login"
          : ((sharePref?.getBool("isManager") ?? false)
                ? "/manager_home"
                : "/home"),
      getPages: [
        GetPage(name: "/login", page: () => Login()),
        GetPage(name: "/home", page: () => Home()),
        GetPage(name: "/manager_home", page: () => HomeViewManager()),
        GetPage(
          name: "/program",
          page: () {
            try {
              final child = Get.arguments as Child;
              return ProgramPage(child: child);
            } catch (e) {
              print('Error in program route: $e');
              return Scaffold(
                appBar: AppBar(title: Text('خطأ'), backgroundColor: Colors.red),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'حدث خطأ في تحميل بيانات البرنامج',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        child: Text('العودة'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        GetPage(name: "/users", page: () => UsersPage()),
      ],
    );
  }
}
