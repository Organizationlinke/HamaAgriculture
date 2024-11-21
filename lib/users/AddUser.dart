import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  final List<Map<String, String>> users = [
    {"username": "admin", "role": "مدير"},
    {"username": "user1", "role": "موظف"},
  ];

  void _addUser(BuildContext context) {
    // نافذة منبثقة لإضافة مستخدم جديد
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController usernameController = TextEditingController();
        final TextEditingController roleController = TextEditingController();

        return AlertDialog(
          title: Text('إضافة مستخدم جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'اسم المستخدم'),
              ),
              TextField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'الصلاحية'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق النافذة
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                // إضافة المستخدم إلى القائمة (يمكنك استبدال ذلك بعملية تخزين في قاعدة بيانات)
                print('تم إضافة المستخدم: ${usernameController.text}');
                Navigator.pop(context); // إغلاق النافذة
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المستخدمين'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['username']!),
            subtitle: Text('الصلاحية: ${user['role']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // حذف المستخدم (يمكنك استبدال ذلك بحذف من قاعدة البيانات)
                print('تم حذف المستخدم: ${user['username']}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addUser(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
