import 'dart:convert'; // لتحويل البيانات من JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // مكتبة لجلب البيانات عبر الإنترنت

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DataScreen(),
    );
  }
}

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  List<dynamic> data = [];
  bool isLoading = true;

  // دالة لجلب البيانات من الـ API
  Future<void> fetchData() async {
    final url = Uri.parse('https://abc123.ngrok.io/api/data'); // رابط API الخاص بك
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body); // تحويل JSON إلى قائمة
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('خطأ أثناء جلب البيانات: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // جلب البيانات عند بدء الصفحة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data from API'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // مؤشر تحميل
          : data.isEmpty
              ? Center(child: Text('لا توجد بيانات'))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return ListTile(
                      title: Text(item['name'] ?? 'No Name'), // عرض البيانات
                      subtitle: Text('ID: ${item['id'] ?? 'No ID'}'),
                    );
                  },
                ),
    );
  }
}
