// import 'package:flutter/material.dart';
// import 'package:inspection_app/tools/FarmFillter.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class InputDataPage extends StatefulWidget {
//    final int ScreenID;
//    InputDataPage({
//     super.key,
//     required this.ScreenID,
//   });
//   @override
//   _InputDataPageState createState() => _InputDataPageState();
// }

// class _InputDataPageState extends State<InputDataPage> {
//   final SupabaseClient supabase = Supabase.instance.client;

//   TextEditingController committeeEstimationController = TextEditingController();
//   TextEditingController committeeNotesController = TextEditingController();

//   String committeeDecision = '';
//   bool? Decision;
//   List<Map<String, dynamic>> defects = [];
//   List<Map<String, dynamic>> sizes = [];
//   List<double> defectPercentages = [];
//   List<double> sizePercentages = [];
//   List<Map<String, dynamic>> dataTableRows = [];
//   int selectedSubAreaId = 0;
//   int InputData_ID = 0;
//   @override
//   void initState() {
//     super.initState();
//     loadDefectsAndSizes();
//   }

//   Future<void> saveData() async {
//     final response = await supabase
//         .from('InputData')
//         .insert({
//           'subarea_id': selectedSubAreaId,
//           'qty': committeeEstimationController.text,
//           'Note': committeeNotesController.text,
//           'decision': Decision,
//         })
//         .select()
//         .single();
//     if (response.isNotEmpty) {
//       InputData_ID = response['id'];

//       // حفظ البيانات في جدول DefectPercentage
//       for (int i = 0; i < defects.length; i++) {
//         await supabase.from('DefectPercentage').insert({
//           'inputdata_id': InputData_ID,
//           'defect_id': defects[i]['id'],
//           'percentage': defectPercentages[i],
//         });
//       }

//       // حفظ البيانات في جدول SizePercentage
//       for (int i = 0; i < sizes.length; i++) {
//         await supabase.from('SizePercentage').insert({
//           'inputdata_id': InputData_ID,
//           'size_id': sizes[i]['id'],
//           'percentage': sizePercentages[i],
//         });
//       }

//       // عرض رسالة تأكيد
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('تم حفظ البيانات بنجاح'),
//         backgroundColor: Colors.green,
//       ));
//     }
//   }

//   Future<void> fetchDataTable() async {
//     final response = await supabase
//         .rpc(
//           "get_farms_listsub",
//         )
//         .eq('subareaid', selectedSubAreaId);

//     setState(() {
//       dataTableRows =
//           (response as List).map((e) => Map<String, dynamic>.from(e)).toList();
//     });
//   }

//   Future<void> loadDefectsAndSizes() async {
//     final defectsResponse =
//         await supabase.from('MenuData').select('id, Name').eq('Type', 5);
//     final sizesResponse =
//         await supabase.from('MenuData').select('id, Name').eq('Type', 6);

//     setState(() {
//       defects = List<Map<String, dynamic>>.from(defectsResponse);
//       sizes = List<Map<String, dynamic>>.from(sizesResponse);
//       defectPercentages = List<double>.filled(defects.length, 0.0);
//       sizePercentages = List<double>.filled(sizes.length, 0.0);
//     });
//   }

//   double calculateTotal(List<double> percentages, double estimation) {
//     return percentages.fold(0.0, (sum, value) => sum + (value * estimation));
//   }
//   // double calculateTotal(List<double> percentages) {
//   //   return percentages.fold(0.0, (sum, value) => sum + value);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     double committeeEstimation =
//         double.tryParse(committeeEstimationController.text) ?? 0.0;
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('شاشة إدخال المعاينة'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               ElevatedButton(
//                 onPressed: () async {
//                   final result = await showDialog(
//                     context: context,
//                     builder: (context) => Dialog(
//                       child: FarmScreen(),
//                     ),
//                   );
//                   selectedSubAreaId = result;
//                   await fetchDataTable();
//                 },
//                 child: Text('تحميل المنطقة'),
//               ),
//               // الجزء العلوي
//               SingleChildScrollView(
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: DataTableTheme(
//                     data: DataTableThemeData(
//                       headingRowColor: MaterialStateProperty.resolveWith(
//                         (states) =>
//                             Colors.blue.withOpacity(0.1), // لون رأس الأعمدة
//                       ),
//                       headingTextStyle: TextStyle(
//                         color: Colors.blue, // لون النص في رأس الأعمدة
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     child: DataTable(
//                       columnSpacing: 16.0,
//                       columns: [
//                         DataColumn(label: Expanded(child: Text('المزرعة'))),
//                         DataColumn(label: Expanded(child: Text('المنطقة'))),
//                         DataColumn(label: Expanded(child: Text('المأخذ'))),
//                         DataColumn(label: Expanded(child: Text('المحصول'))),
//                         DataColumn(
//                             label: Expanded(child: Text('المساحة / فدان'))),
//                         DataColumn(label: Expanded(child: Text('عدد الشجر'))),
//                       ],
//                       rows: dataTableRows.asMap().entries.map((entry) {
//                         Map<String, dynamic> row = entry.value;
//                         return DataRow(
//                           cells: [
//                             DataCell(Text(row['farm'] ?? '')),
//                             DataCell(Text(row['area'] ?? '')),
//                             DataCell(Text(row['subarea'] ?? '')),
//                             DataCell(Text(row['crop'] ?? '')),
//                             DataCell(Text(row['acre']?.toString() ?? '')),
//                             DataCell(Text(row['trees']?.toString() ?? '')),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               Column(
//                 children: [
//                   Row(
//                     children: [
//                       SizedBox(
//                         width: 150,
//                         child: TextField(
//                           controller: committeeEstimationController,
//                           decoration: InputDecoration(
//                             labelText: 'تقدير اللجنة',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 20,
//                       ),
//                       Expanded(
//                         child: TextField(
//                           controller: committeeNotesController,
//                           decoration: InputDecoration(
//                             labelText: 'ملاحظات اللجنة',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     children: [
//                       Text('قرار اللجنة'),
//                       SizedBox(
//                         width: 20,
//                       ),
//                       Radio<String>(
//                         value: 'مقبول',
//                         groupValue: committeeDecision,
//                         onChanged: (value) {
//                           setState(() {
//                             committeeDecision = value!;
//                             Decision = committeeDecision == value;
//                             print('Decision1:$Decision');
//                           });
//                         },
//                       ),
//                       Text('مقبول'),
//                       Radio<String>(
//                         value: 'مرفوض',
//                         groupValue: committeeDecision,
//                         onChanged: (value) {
//                           setState(() {
//                             committeeDecision = value!;
//                             Decision = committeeDecision != value;
//                             print('Decision2:$Decision');
//                           });
//                         },
//                       ),
//                       Text('مرفوض'),
//                     ],
//                   ),
//                 ],
//               ),
      
//               SizedBox(height: 16),
//               // الجدولان
//               Expanded(
//                 child: Row(
//                   children: [
//                     // جدول عيوب الثمار
//                     Expanded(
//                       child: Column(
//                         children: [
//                           Text('جدول عيوب الثمار',
//                               style: TextStyle(fontSize: 16)),
//                           Expanded(
//                             child: DataTable(
//                               columns: [
//                                 DataColumn(label: Text('اسم العيوب')),
//                                 DataColumn(label: Text('النسبة')),
//                                 DataColumn(label: Text('الكمية')),
//                               ],
//                               rows: [
//                                 ...defects.asMap().entries.map((entry) {
//                                   int index = entry.key;
//                                   Map<String, dynamic> defect = entry.value;
//                                   double qty = defectPercentages[index] *
//                                       committeeEstimation *
//                                       .01;
//                                   return DataRow(
//                                     cells: [
//                                       DataCell(Text(defect['Name'])),
//                                       DataCell(
//                                         TextField(
//                                           onChanged: (value) {
//                                             setState(() {
//                                               defectPercentages[index] =
//                                                   double.tryParse(value) ?? 0.0;
//                                             });
//                                           },
//                                           decoration:
//                                               InputDecoration(hintText: '0.0'),
//                                         ),
//                                       ),
//                                       DataCell(Text(qty.toStringAsFixed(2))),
//                                     ],
//                                   );
//                                 }),
//                                 DataRow(
//                                   cells: [
//                                     DataCell(Text(
//                                       'إجمالي الكميات',
//                                       style:
//                                           TextStyle(fontWeight: FontWeight.bold),
//                                     )),
//                                     DataCell(Text(
//                                       calculateTotal(defectPercentages, 1)
//                                           .toStringAsFixed(2),
//                                       style:
//                                           TextStyle(fontWeight: FontWeight.bold),
//                                     )),
//                                     DataCell(Text(
//                                       calculateTotal(defectPercentages,
//                                               committeeEstimation * .01)
//                                           .toStringAsFixed(2),
//                                       style:
//                                           TextStyle(fontWeight: FontWeight.bold),
//                                     )),
//                                   ],
//                                   color: MaterialStateProperty.all(
//                                       Colors.grey.shade200),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
      
//                     SizedBox(width: 16),
//                     // جدول نسب الأحجام
//                     Expanded(
//                       child: Column(
//                         children: [
//                           Text('جدول نسب الأحجام',
//                               style: TextStyle(fontSize: 16)),
//                           Expanded(
//                             child: DataTable(
//                               columns: [
//                                 DataColumn(label: Text('اسم الحجم')),
//                                 DataColumn(label: Text('النسبة')),
//                                 DataColumn(label: Text('الكمية')),
//                               ],
//                               rows: [
//                                 ...sizes.asMap().entries.map((entry) {
//                                   int index = entry.key;
//                                   Map<String, dynamic> size = entry.value;
//                                   double qty = sizePercentages[index] *
//                                       committeeEstimation *
//                                       .01;
//                                   return DataRow(
//                                     cells: [
//                                       DataCell(Text(size['Name'])),
//                                       DataCell(
//                                         TextField(
//                                           onChanged: (value) {
//                                             setState(() {
//                                               sizePercentages[index] =
//                                                   double.tryParse(value) ?? 0.0;
//                                             });
//                                           },
//                                           decoration:
//                                               InputDecoration(hintText: '0.0'),
//                                         ),
//                                       ),
//                                       DataCell(Text(qty.toStringAsFixed(2))),
//                                     ],
//                                   );
//                                 }),
//                                 DataRow(
//                                   cells: [
//                                     DataCell(Text(
//                                       'إجمالي الكميات',
//                                       style:
//                                           TextStyle(fontWeight: FontWeight.bold),
//                                     )),
//                                     // DataCell(Text('')),
//                                     DataCell(Text(
//                                       calculateTotal(sizePercentages, 1)
//                                           .toStringAsFixed(2),
//                                       style:
//                                           TextStyle(fontWeight: FontWeight.bold),
//                                     )),
//                                     DataCell(Text(
//                                       calculateTotal(sizePercentages,
//                                               committeeEstimation * .01)
//                                           .toStringAsFixed(2),
//                                       style:
//                                           TextStyle(fontWeight: FontWeight.bold),
//                                     )),
//                                   ],
//                                   color: MaterialStateProperty.all(
//                                       Colors.grey.shade200),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: saveData,
//                 child: Text('حفظ البيانات'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue, // لون الزر
//                   padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                   textStyle: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
