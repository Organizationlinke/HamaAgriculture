import 'package:flutter/material.dart';

class PermissionsScreen extends StatelessWidget {
  final Map<String, List<String>> permissions = {
    "admin": ["إضافة", "تعديل", "حذف"],
    "user1": ["عرض"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الصلاحيات'),
      ),
      body: ListView(
        children: permissions.keys.map((username) {
          return ExpansionTile(
            title: Text(username),
            children: permissions[username]!.map((permission) {
              return ListTile(
                title: Text(permission),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
