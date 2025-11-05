import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_feed/controller/authController.dart';
import 'package:social_feed/controller/feedController.dart';
import 'package:social_feed/pages/home_page.dart';
import 'package:social_feed/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('appBox');
  Get.put(AuthController());
  Get.put(FeedController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
      designSize: const Size(390, 844), // base on iPhone 13 or your UI reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mini Social Feed',
              themeMode: ThemeMode.system,
              theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
              darkTheme: ThemeData.dark(useMaterial3: true),
              home: auth.isLoggedIn.value ? HomePage() : LoginPage(),
            ));
      }
    );
  }
}
