import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class PoliciesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PoliciesScreen(),
    );
  }
}

class PoliciesScreen extends StatefulWidget {
  @override
  _PoliciesScreenState createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  List<Map<String, dynamic>> policies = []; // قائمة أسماء الصلاحيات
  List<Map<String, dynamic>> policiesSub = []; // بيانات جدول Policies_sub
  int? selectedPolicyId;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchPolicies(); // استدعاء البيانات الأولية
  }

  Future<void> fetchPolicies() async {
    final response = await supabase.from('Policies').select();

    // جلب بيانات الصلاحيات من قاعدة البيانات
    // هنا استبدل بسطر الاتصال بـ Supabase أو أي API
    setState(() {
      policies = [
        {'id': 1, 'name': 'الصلاحية الأولى'},
        {'id': 2, 'name': 'الصلاحية الثانية'},
      ];
    });
  }

  Future<void> fetchPolicyDetails(int policyId) async {
    // جلب بيانات جدول Policies_sub بناءً على الصلاحية المختارة
    setState(() {
      selectedPolicyId = policyId;
      policiesSub = [
        {
          'screenType': 1,
          'screenId': 1,
          'screenName': 'تعريف المزارع',
          'read': false,
          'add': false,
          'edit': false,
          'delete': false,
        },
        // إضافة بيانات أخرى
      ];
    });
  }

  Future<void> savePolicyDetails() async {
    // حفظ التعديلات على جدول Policies_sub
    // أضف هنا الاتصال بـ Supabase أو API
    print('Saving policiesSub: $policiesSub');
  }

  Future<void> addNewPolicy() async {
    // إضافة صلاحية جديدة مع نسخ البيانات
    // أضف هنا الاتصال بـ Supabase أو API
    print('Adding new policy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الصلاحيات'),
      ),
      body: Row(
        children: [
          // قائمة الصلاحيات
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: policies.length,
              itemBuilder: (context, index) {
                final policy = policies[index];
                return ListTile(
                  title: Text(policy['name']),
                  onTap: () => fetchPolicyDetails(policy['id']),
                );
              },
            ),
          ),
          // جدول تعديل بيانات الصلاحية
          Expanded(
            flex: 2,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: addNewPolicy,
                  child: Text('إضافة صلاحية جديدة'),
                ),
                Expanded(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('الشاشة')),
                      DataColumn(label: Text('قراءة')),
                      DataColumn(label: Text('إضافة')),
                      DataColumn(label: Text('تعديل')),
                      DataColumn(label: Text('حذف')),
                    ],
                    rows: policiesSub.map((sub) {
                      return DataRow(cells: [
                        DataCell(Text(sub['screenName'])),
                        DataCell(Checkbox(
                          value: sub['read'],
                          onChanged: (value) {
                            setState(() {
                              sub['read'] = value;
                            });
                          },
                        )),
                        DataCell(Checkbox(
                          value: sub['add'],
                          onChanged: (value) {
                            setState(() {
                              sub['add'] = value;
                            });
                          },
                        )),
                        DataCell(Checkbox(
                          value: sub['edit'],
                          onChanged: (value) {
                            setState(() {
                              sub['edit'] = value;
                            });
                          },
                        )),
                        DataCell(Checkbox(
                          value: sub['delete'],
                          onChanged: (value) {
                            setState(() {
                              sub['delete'] = value;
                            });
                          },
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                  onPressed: savePolicyDetails,
                  child: Text('حفظ التعديلات'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
