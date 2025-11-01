import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/screens/home_page.dart';
import 'package:ipcam/widgets/custom_notification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    print('LoginPage: initState called');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    print('LoginPage: dispose called');
    super.dispose();
  }

  void _login() async {
    print(
      'LoginPage: _login called with username: ${_usernameController.text}',
    );
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final user = await DatabaseHelper().authenticateUser(username, password);

    if (!mounted) {
      return;
    }

    if (user != null) {
      print('LoginPage: Login successful for user: ${user['username']}');
      CustomNotificationOverlay.show(context, 'مرحباً، ${user['name']}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: user)),
      );
    } else {
      print('LoginPage: Login failed for username: $username');
      CustomNotificationOverlay.show(
        context,
        'اسم المستخدم أو كلمة المرور غير صحيحة',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('LoginPage: build called');
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
