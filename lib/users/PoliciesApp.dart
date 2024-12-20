import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRolesScreen extends StatefulWidget {
  @override
  _UserRolesScreenState createState() => _UserRolesScreenState();
}

class _UserRolesScreenState extends State<UserRolesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<dynamic> policies = [];
  Map<int, Map<String, List<dynamic>>> policySubSections = {};

  @override
  void initState() {
    super.initState();
    fetchPolicies();
  }

  Future<void> fetchPolicies() async {
    try {
      final response = await supabase.from('Policies').select();
      setState(() {
        policies = response ?? [];
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchPolicySub(int policyId, String sectionType) async {
    int typeValue = _getScreenType(sectionType);
    try {
      final response = await supabase
          .from('Policies_sub')
          .select('id,ScreenName,Read,Add,Edit,Delete')
          .eq('ScreenType', typeValue)
          .eq('Policies_id', policyId);

      setState(() {
        policySubSections[policyId] ??= {};
        policySubSections[policyId]![sectionType] = response ?? [];
      });
    } catch (e) {
      print('Error fetching $sectionType: $e');
    }
  }

  int _getScreenType(String sectionType) {
    switch (sectionType) {
      case 'البيانات الأساسية':
        return 1;
      case 'شاشات الإدخال':
        return 2;
      case 'التقارير':
        return 3;
      default:
        return 0;
    }
  }

  void updateCheckbox(int policyId, String sectionType, int index, String field, bool value) {
    setState(() {
      policySubSections[policyId]?[sectionType]?[index][field] = value;
    });
  }

  Future<void> saveChanges() async {
    try {
      for (var policyId in policySubSections.keys) {
        for (var section in policySubSections[policyId]!.values) {
          for (var row in section) {
            await supabase.from('Policies_sub').update({
              'Read': row['Read'],
              'Add': row['Add'],
              'Edit': row['Edit'],
              'Delete': row['Delete'],
            }).eq('id', row['id']);
          }
        }
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تم حفظ التغييرات بنجاح')));
    } catch (e) {
      print('Error saving changes: $e');
    }
  }
  // إضافة دور جديد مع الشاشات الافتراضية
  Future<void> addNewRole() async {
    TextEditingController roleController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة دور جديد'),
        
        content: TextField(
          controller: roleController,
          decoration: InputDecoration(hintText: 'اسم الدور'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final roleName = roleController.text.trim();
              if (roleName.isNotEmpty) {
                try {
                  // 1. إدخال الدور في جدول Policies
                  final response = await supabase
                      .from('Policies')
                      .insert({'Name': roleName}).select();

                  if (response.isNotEmpty) {
                    final newPolicyId = response[0]['id'];

                    // 2. جلب الشاشات الافتراضية
                    final screensResponse = await supabase
                        .from('Policies_sub')
                        .select('ScreenName, ScreenType, ScreenID')
                        .eq('Policies_id', 1); // الشاشات المرجعية

                    // 3. إدخال الشاشات مع الربط بـ Policies_id
                    for (var screen in screensResponse) {
                      await supabase.from('Policies_sub').insert({
                        'Policies_id': newPolicyId,
                        'ScreenName': screen['ScreenName'],
                        'ScreenType': screen['ScreenType'],
                        'ScreenID': screen['ScreenID'],
                        'Read': false,
                        'Add': false,
                        'Edit': false,
                        'Delete': false,
                      });
                    }

                    // تحديث القائمة
                    fetchPolicies();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تمت إضافة الدور بنجاح')),
                    );
                  }
                } catch (e) {
                  print('Error: $e');
                }
              }
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('أدوار المستخدمين'),
       actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addNewRole, // زر لإضافة دور جديد
            tooltip: 'إضافة دور جديد',
          ),
        ],
        ),
      body: policies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Row(
              children: [
                _buildPoliciesList(),
                Expanded(
                  child: Column(
                    children: ['البيانات الأساسية', 'شاشات الإدخال', 'التقارير']
                        .map((section) => _buildSectionExpansionTile(section))
                        .toList(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: saveChanges,
          child: Text('حفظ التغييرات'),
        ),
      ),
    );
  }

  Widget _buildPoliciesList() {
    return SizedBox(
      width: 250,
      child: ListView.builder(
        itemCount: policies.length,
        itemBuilder: (context, index) {
          final policy = policies[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(policy['Name']),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: () {
                
                for (var section in ['البيانات الأساسية', 'شاشات الإدخال', 'التقارير']) {
                  fetchPolicySub(policy['id'], section);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionExpansionTile(String sectionType) {
    int selectedPolicyId = policies.isNotEmpty ? policies.first['id'] : 0;

    return ExpansionTile(
      title: Text(sectionType),
      children: policySubSections[selectedPolicyId]?[sectionType]?.map<Widget>((row) {
            int index = policySubSections[selectedPolicyId]![sectionType]!.indexOf(row);
            return ListTile(
              title: Text(row['ScreenName']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['Read', 'Add', 'Edit', 'Delete']
                    .map((field) => buildCheckbox(selectedPolicyId, sectionType, index, field, row[field]))
                    .toList(),
              ),
            );
          }).toList() ??
          [Center(child: Text('لا توجد بيانات'))],
    );
  }

  Widget buildCheckbox(int policyId, String sectionType, int index, String field, bool value) {
    return Row(
      children: [
        Text(field),
        Checkbox(
          value: value ?? false,
          onChanged: (newValue) => updateCheckbox(policyId, sectionType, index, field, newValue!),
        ),
      ],
    );
  }
}
