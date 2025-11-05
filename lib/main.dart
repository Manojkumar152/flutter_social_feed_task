import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

import 'package:social_feed/controller/authController.dart';
import 'package:social_feed/controller/feedController.dart';
import 'package:social_feed/pages/home_page.dart';
import 'package:social_feed/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('appBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final FeedController feedController = Get.put(FeedController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Social Feed',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Obx(() {
        return authController.isLoggedIn.value ? HomePage() : LoginPage();
      }),
    );
  }
}
