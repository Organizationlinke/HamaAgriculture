import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/HomePage.dart';
import 'package:inspection_app/users/AddUser.dart';
import 'package:inspection_app/users/Login.dart';
import 'package:inspection_app/users/Permissions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main()async {

   await Supabase.initialize(
    url: 'https://qhfgwpnsjzqtxygbdgbb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFoZmd3cG5zanpxdHh5Z2JkZ2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIxODE0ODQsImV4cCI6MjA0Nzc1NzQ4NH0.e-UNyfg5k6bMTdQ4ZyDlWzjB_LSyZzvR8nZj3L1tH2c',
  );
  runApp(InspectionApp());


}

class InspectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl,
      child: MaterialApp(
        initialRoute: '/home',
        routes: {
          '/login': (context) => LoginScreen(),
          '/adduser': (context) => UserManagementScreen(),
          '/permissions': (context) => PermissionsScreen(),
          '/home': (context) =>MainScreen()
        },
      ),
    );
  }
}
