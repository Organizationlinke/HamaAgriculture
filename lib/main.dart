import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/HomePage.dart';
import 'package:inspection_app/tools/FarmFillter.dart';
import 'package:inspection_app/users/AddUser.dart';
import 'package:inspection_app/users/Login.dart';
import 'package:inspection_app/users/PoliciesApp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html';
import 'package:http/http.dart' as http;

void main()async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

   await Supabase.initialize(
     url: supabaseUrl, // قراءة URL
    anonKey: supabaseAnonKey, // قراءة المفتاح
    // url: 'https://qhfgwpnsjzqtxygbdgbb.supabase.co',
    // anonKey:
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFoZmd3cG5zanpxdHh5Z2JkZ2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIxODE0ODQsImV4cCI6MjA0Nzc1NzQ4NH0.e-UNyfg5k6bMTdQ4ZyDlWzjB_LSyZzvR8nZj3L1tH2c',
  );
  runApp(InspectionApp());


}


class InspectionApp extends StatefulWidget {
 
  @override
  State<InspectionApp> createState() => _InspectionAppState();
}

class _InspectionAppState extends State<InspectionApp> {
   void initState() {
    super.initState();
    checkForUpdates(); // التحقق عند بدء التطبيق
  }
  Future<void> checkForUpdates() async {
  try {
    // استبدل هذا الرابط بعنوان `version.txt` الخاص بتطبيقك
    final response = await http.get(Uri.parse('https://organizationlinke.github.io/HamaAgriculture/version.txt'));

    if (response.statusCode == 200) {
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        
        title: 'معاينات المزارع',
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/adduser': (context) => UserManagementScreen(),
          '/policiesapp': (context) => PoliciesApp(),
          '/home': (context) =>MainScreen(),
          '/farmscreen': (context) =>FarmScreen(is_finished: true,seasonid:0),
       
        },
      ),
    );
  }
}
