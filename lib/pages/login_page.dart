import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_feed/controller/authController.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController(text: 'test@user.com');
  final passwordController = TextEditingController(text: '123456');
  final auth = Get.find<AuthController>();

  void _tryLogin() async {
    final success =
        await auth.login(emailController.text, passwordController.text);
    if (!success) {
      Get.snackbar('Login failed', 'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: EdgeInsets.all(24),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mini Social Feed',
                    style: Theme.of(context).textTheme.headlineMedium),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email')),
                TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true),
                SizedBox(height: 12),
                ElevatedButton(onPressed: _tryLogin, child: Text('Login')),
                SizedBox(height: 8),
                Text('Email: test@user.com | Password: 123456',
                    style: TextStyle(fontSize: 12))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
