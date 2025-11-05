import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive/hive.dart';

class AuthController extends GetxController {
  static const _storageKey = 'is_logged_in';
  final box = Hive.box('appBox');

  final _email = 'test@user.com';
  final _password = '123456';

  RxBool isLoggedIn = false.obs;
  RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = box.get(_storageKey, defaultValue: false);
    if (saved == true) {
      isLoggedIn.value = true;
      userEmail.value = box.get('user_email', defaultValue: _email);
    }
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 300));
    if (email.trim().toLowerCase() == _email && password == _password) {
      isLoggedIn.value = true;
      userEmail.value = email;
      box.put(_storageKey, true);
      box.put('user_email', email);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    userEmail.value = '';
    await box.delete(_storageKey);
    await box.delete('user_email');
  }
}
