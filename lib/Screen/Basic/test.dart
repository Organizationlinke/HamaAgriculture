// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class AddSubArea extends StatefulWidget {
//   final int Areaid;
//   AddSubArea({
//     super.key,
//     required this.Areaid,
//   });

//   @override
//   State<AddSubArea> createState() => _AddSubAreaState();
// }

// class _AddSubAreaState extends State<AddSubArea> {
//   final supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> farms_list = [];

//   // هذه المتغيرات ستُستخدم لإضافة سطر جديد
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController cropController = TextEditingController();
//   final TextEditingController acreController = TextEditingController();
//   final TextEditingController treesController = TextEditingController();

//   Future<void> FarmsList() async {
//     try {
//       final response = await supabase
//           .from('MenuData')
//           .select()
//           .eq('Type', 3)
//           .eq('Parant', widget.Areaid);

//       if (response != null && response is List) {
//         setState(() {
//           farms_list =
//               response.map((item) => item as Map<String, dynamic>).toList();
//         });
//       } else {
//         print('No data received or data format is unexpected.');
//       }
//     } catch (e) {
//       print('An unexpected error occurred: $e');
//     }
//   }

//   Future<void> saveChanges() async {
//     try {
//       for (var transaction in farms_list) {
//         // تنفيذ الحفظ إلى قاعدة البيانات بناءً على التعديلات
//         final response = await supabase.from('MenuData').update({
//           'Name': transaction['Name'],
//           'Crop': transaction['Crop'],
//           'Acre': transaction['Acre'],
//           'Trees': transaction['Trees']
//         }).eq('id', transaction['id']);
        
//         if (response.error != null) {
//           print('Error updating data: ${response.error?.message}');
//         }
//       }
//     } catch (e) {
//       print('An error occurred while saving changes: $e');
//     }
//   }

//   Future<void> addNewRow() async {
//     try {
//       final response = await supabase.from('MenuData').insert({
//         'Name': nameController.text,
//         'Crop': cropController.text,
//         'Acre': acreController.text,
//         'Trees': treesController.text,
//         'Type': 3,
//         'Parant': widget.Areaid,
//       });

//       if (response.error != null) {
//         print('Error inserting new row: ${response.error?.message}');
//       } else {
//         // تحديث الجدول بعد إضافة السطر الجديد
//         setState(() {
//           farms_list.add({
//             'Name': nameController.text,
//             'Crop': cropController.text,
//             'Acre': acreController.text,
//             'Trees': treesController.text,
//           });
//         });
//         // مسح الحقول بعد الإضافة
//         nameController.clear();
//         cropController.clear();
//         acreController.clear();
//         treesController.clear();
//       }
//     } catch (e) {
//       print('Error adding new row: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     FarmsList();
//   }

//   @override
//   void didUpdateWidget(covariant AddSubArea oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.Areaid != widget.Areaid) {
//       FarmsList();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height * .7,
//           child: Column(
//             children: [
//               // الرؤوس الثابتة
//               Container(
//                 color: Colors.grey.shade200, // لون خلفية الرؤوس
//                 child: Row(
//                   children: const [
//                     Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
//                     Expanded(child: Text('Crop', style: TextStyle(fontWeight: FontWeight.bold))),
//                     Expanded(child: Text('Acre', style: TextStyle(fontWeight: FontWeight.bold))),
//                     Expanded(child: Text('Trees', style: TextStyle(fontWeight: FontWeight.bold))),
//                   ],
//                 ),
//               ),
//               // البيانات مع التمرير
//               Expanded(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.vertical,
//                   child: Column(
//                     children: farms_list.map<Widget>((transaction) {
//                       return Column(
//                         children: [
//                           SizedBox(height: 10),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: TextEditingController(text: transaction['Name'].toString()),
//                                   decoration: InputDecoration(border: InputBorder.none),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       transaction['Name'] = value;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: TextField(
//                                   controller: TextEditingController(text: transaction['Crop'].toString()),
//                                   decoration: InputDecoration(border: InputBorder.none),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       transaction['Crop'] = value;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: TextField(
//                                   controller: TextEditingController(text: transaction['Acre'].toString()),
//                                   decoration: InputDecoration(border: InputBorder.none),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       transaction['Acre'] = value;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: TextField(
//                                   controller: TextEditingController(text: transaction['Trees'].toString()),
//                                   decoration: InputDecoration(border: InputBorder.none),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       transaction['Trees'] = value;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//               // زر حفظ التعديلات
//               ElevatedButton(
//                 onPressed: saveChanges,
//                 child: Text('حفظ التعديلات'),
//               ),
//               // قسم إضافة سطر جديد
//               SizedBox(height: 20),
//               Text('إضافة سطر جديد'),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(labelText: 'Name'),
//                     ),
//                   ),
//                   Expanded(
//                     child: TextField(
//                       controller: cropController,
//                       decoration: InputDecoration(labelText: 'Crop'),
//                     ),
//                   ),
//                   Expanded(
//                     child: TextField(
//                       controller: acreController,
//                       decoration: InputDecoration(labelText: 'Acre'),
//                     ),
//                   ),
//                   Expanded(
//                     child: TextField(
//                       controller: treesController,
//                       decoration: InputDecoration(labelText: 'Trees'),
//                     ),
//                   ),
//                 ],
//               ),
//               ElevatedButton(
//                 onPressed: addNewRow,
//                 child: Text('إضافة سطر جديد'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';

class AddSubArea extends StatefulWidget {
  final int Areaid;
  AddSubArea({
    super.key,
    required this.Areaid,
  });

  @override
  State<AddSubArea> createState() => _AddSubAreaState();
}

class _AddSubAreaState extends State<AddSubArea> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> farms_list = [];

  Future<void> FarmsList() async {
    try {
      final response = await supabase
          .from('MenuData')
          .select()
          .eq('Type', 3)
          .eq('Parant', widget.Areaid);

      if (response != null && response is List) {
        setState(() {
          farms_list =
              response.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        print('No data received or data format is unexpected.');
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    FarmsList();
  }

  @override
  void didUpdateWidget(covariant AddSubArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.Areaid != widget.Areaid) {
      FarmsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .7,
          child: Column(
            children: [
              // الرؤوس الثابتة
              Container(
                color: Colors.grey.shade200, // لون خلفية الرؤوس
                child: Row(
                  children: const [
                    Expanded(
                        child: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Crop',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Acre',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Trees',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // البيانات مع التمرير
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: farms_list.map<Widget>((transaction) {
                      return Column(
                        children: [
                          SizedBox(height: 30,),
                          Row(
                            children: [
                              Expanded(
                                  child:
                                      Text(transaction['Name'].toString() ?? '')),
                              Expanded(
                                  child:
                                      Text(transaction['Crop'].toString() ?? '')),
                              Expanded(
                                  child:
                                      Text(transaction['Acre'].toString() ?? '')),
                              Expanded(
                                  child:
                                      Text(transaction['Trees'].toString() ?? '')),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          // SingleChildScrollView(
          //   scrollDirection: Axis.vertical,
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     child: farms_list.isNotEmpty
          //         ? DataTable(
          //             columns: const [
          //               DataColumn(label: Text('Name')),
          //               DataColumn(label: Text('Crop')),
          //               DataColumn(label: Text('Acre')),
          //               DataColumn(label: Text('Trees')),
          //             ],
          //             rows: farms_list.map<DataRow>((transaction) {
          //               return DataRow(cells: [
          //                 DataCell(Text(transaction['Name'].toString() ?? '')),
          //                 DataCell(Text(transaction['Crop'].toString() ?? '')),
          //                 DataCell(Text(transaction['Acre'].toString() ?? '')),
          //                 DataCell(Text(transaction['Trees'].toString() ?? '')),
          //               ]);
          //             }).toList(),
          //           )
          //         : Center(
          //             child: Text(
          //               'لا توجد بيانات متاحة',
          //               style: TextStyle(fontSize: 16, color: Colors.grey),
          //             ),
          //           ),
          //   ),
          // ),
        ),
      ),
    );
  }
}
