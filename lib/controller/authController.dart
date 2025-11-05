import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthController extends GetxController {
  final _email = 'test@user.com';
  final _password = '123456';
  RxBool isLoggedIn = false.obs;
  RxString userEmail = ''.obs;

  late Box box;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box('appBox');
    final saved = box.get('isLoggedIn', defaultValue: false);
    isLoggedIn.value = saved;
    userEmail.value = box.get('userEmail', defaultValue: '');
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().toLowerCase() == _email && password == _password) {
      isLoggedIn.value = true;
      userEmail.value = email;
      await box.put('isLoggedIn', true);
      await box.put('userEmail', email);
      return true;
    }
    return false;
  }

  void logout() async {
    isLoggedIn.value = false;
    await box.put('isLoggedIn', false);
  }
}
