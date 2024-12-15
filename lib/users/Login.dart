import 'package:flutter/material.dart';
import 'package:inspection_app/tools/global.dart';
import 'dart:html';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String test='';

  void initState() {
    super.initState();
    checkForUpdates(); // التحقق عند بدء التطبيق
  }
  Future<void> checkForUpdates() async {
  try {
    // استبدل هذا الرابط بعنوان `version.txt` الخاص بتطبيقك
    final response = await http.get(Uri.parse('https://github.com/Organizationlinke/HamaAgriculture/blob/main/version.txt'));

    if (response.statusCode == 200) {
      test='نسخة جديده';
      final serverVersion = response.body.trim(); // النسخة الجديدة
      const currentVersion = '1.0.0'; // النسخة الحالية للتطبيق

      if (serverVersion != currentVersion) {
        // إذا كانت النسخة مختلفة، يتم تحديث الصفحة
        reloadPage();
      }
    }
  } catch (e) {
    print('خطأ أثناء التحقق من التحديثات: $e');
  }
}
  void reloadPage() {
  window.location.reload();
}

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال اسم المستخدم وكلمة المرور')),
      );
      return;
    }

    // قم بالتحقق من بيانات المستخدم عبر قاعدة البيانات أو API
    if (username == "admin" && password == "1234") {
      userid='1';
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بيانات تسجيل الدخول غير صحيحة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(test),
                  Text('شاشة تسجيل الدخول',style: TextStyle(fontSize: 25),),
                  SizedBox(height: 50),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'اسم المستخدم',icon: Icon(Icons.person,color: Colors.green,)),
              
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'كلمة المرور',icon: Icon(Icons.lock,color: Colors.blue,)),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:ColorTablebackHedar,
                      foregroundColor: ColorTableForeHedar
                    ),
                    onPressed: _login,
                    child: Text('تسجيل الدخول'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
