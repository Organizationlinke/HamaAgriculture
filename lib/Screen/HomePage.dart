import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/Basic/AddFarms.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // التحكم في الشاشة المعروضة
  Widget _currentScreen = HomeScreen();
   final supabase = Supabase.instance.client;
 @override
  void initState() {
    super.initState();
   
  }
  

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الشاشة الرئيسية'),
          backgroundColor: Colorapp,
          foregroundColor: Colorforeapp,
        ),
        body: Row(
          children: [
            // القائمة الجانبية الثابتة
            Container(
              width: 250, // عرض القائمة الجانبية
              color: colorlist,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpansionTile(
                    leading: Icon(Icons.data_usage),
                    title: Text('البيانات الأساسية'),
                    children: [
                      ListTile(
                        leading: Icon(Icons.data_usage),
                        title: Text('تعريف المزراع'),
                        onTap: () {
                          setState(() {
                            _currentScreen = AddFarms();
                          });
                        },
                      ),
                       ListTile(
                        leading: Icon(Icons.data_usage),
                        title: Text('تعريف المناطق'),
                        onTap: () {
                          setState(() {});
                        },
                      ),
                       ListTile(
                        leading: Icon(Icons.data_usage),
                        title: Text('تعريف الحوشة'),
                        onTap: () {
                          setState(() {});
                        },
                      ),
                       ListTile(
                        leading: Icon(Icons.data_usage),
                        title: Text('تعريف الاصناف'),
                        onTap: () {
                          setState(() {});
                        },
                      ),
                       ListTile(
                        leading: Icon(Icons.data_usage),
                        title: Text('تعريف عيوب الثمار'),
                        onTap: () {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.input),
                    title: Text('شاشات الإدخال'),
                    children: [
                      ListTile(
                        title: Text('شاشة إدخال المعاينة'),
                        onTap: () {
                          setState(() {
                            // _currentScreen = InspectionEntryScreen();
                          });
                        },
                      ),
                    ],
                  ),
                  ListTile(
                    leading: Icon(Icons.report),
                    title: Text('التقارير'),
                    onTap: () {
                      setState(() {
                        _currentScreen = ReportsScreen();
                      });
                    },
                  ),
                ],
              ),
            ),
            // الشاشة المعروضة
            Expanded(
              child: _currentScreen,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'مرحبًا بك في التطبيق!',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// class BasicDataScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'شاشة البيانات الأساسية',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }

// class InspectionEntryScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'شاشة إدخال المعاينة',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'شاشة التقارير',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
