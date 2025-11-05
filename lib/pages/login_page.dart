import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_feed/controller/authController.dart';

class LoginPage extends StatelessWidget {
  final auth = Get.find<AuthController>();
  final emailController = TextEditingController(text: 'test@user.com');
  final passwordController = TextEditingController(text: '123456');

  void _login() async {
    final success =
        await auth.login(emailController.text, passwordController.text);
    if (!success) {
      Get.snackbar('Login Failed', 'Invalid credentials');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mini Social Feed',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email')),
                TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _login, child: const Text('Login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
