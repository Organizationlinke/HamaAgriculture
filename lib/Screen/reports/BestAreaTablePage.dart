import 'package:flutter/material.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BestAreaTablePage extends StatefulWidget {
  final int exportId;
  final int farmId;

  const BestAreaTablePage({
    Key? key,
    required this.exportId,
    required this.farmId,
  }) : super(key: key);

  @override
  _BestAreaTablePageState createState() => _BestAreaTablePageState();
}

class _BestAreaTablePageState extends State<BestAreaTablePage> {
  List<Map<String, dynamic>> tableData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBestAreaData();
  }

  Future<void> fetchBestAreaData() async {
    print('exportid:${widget.exportId}');
    print('farmid:${widget.farmId}');

    try {
      final response = await Supabase.instance.client
          .rpc('get_best_area_sub', params: {
            'export_id': widget.exportId,
            'farm_id': widget.farmId,
          })
          .gte('variance_absolut', 0).order('id_s', ascending: true)
          .select();

      if (response.isNotEmpty) {
        setState(() {
          tableData = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else {
        throw Exception('Error fetching data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // حساب المجموع للنسب المئوية
    double totalExportPercent = 0.0;
    double totalFarmsPercent = 0.0;
    double totalVariancePercent = 0.0;

    for (var data in tableData) {

      totalExportPercent += (data['export_percent'] ?? 0.0);
      totalFarmsPercent += (data['farms_percent'] ?? 0.0);
      totalVariancePercent += (data['variance_percent'] ?? 0.0);
    
    }

    // double rowCount = tableData.length.toDouble();

    // double avgExportPercent =
    //     rowCount > 0 ? totalExportPercent / rowCount : 0.0;
    // double avgFarmsPercent = rowCount > 0 ? totalFarmsPercent / rowCount : 0.0;
    // double avgVariancePercent =
    //     rowCount > 0 ? totalVariancePercent / rowCount : 0.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Best Area Table'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                  // scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTableTheme(
                      data: DataTableThemeData(
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => ColorTablebackHedar, // لون رأس الأعمدة
                          ),
                          headingTextStyle: TextStyle(
                            color: ColorTableForeHedar, // لون النص في رأس الأعمدة
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowHeight: 40),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Expanded(child: Text('ID'))),
                          DataColumn(label: Expanded(child: Text('Size Code'))),
                          DataColumn(label: Expanded(child: Text('KG 008'))),
                          DataColumn(label: Expanded(child: Text('KG 015'))),
                          DataColumn(label: Expanded(child: Text('Export %'))),
                          DataColumn(label: Expanded(child: Text('Farm %'))),
                          DataColumn(label: Expanded(child: Text('Variance %'))),
                        ],
                        rows: [
                          ...tableData.map((data) {
                            return DataRow(cells: [
                              DataCell(Text(data['id_s'].toString())),
                              DataCell(Text(data['sizecode'] ?? '')),
                              DataCell(Text(data['kg008'] ?? '')),
                              DataCell(Text(data['kg015'] ?? '')),
                              DataCell(Text((data['export_percent'] ?? 0.0)
                                      .toStringAsFixed(2) +
                                  '%')),
                              DataCell(Text((data['farms_percent'] ?? 0.0)
                                      .toStringAsFixed(2) +
                                  '%')),
                              DataCell(Text((data['variance_percent'] ?? 0.0)
                                      .toStringAsFixed(2) +
                                  '%',style: TextStyle(color: data['variance_percent']<0?Colors.red:Colors.black),)),
                            ]);
                          }).toList(),
                          // إضافة سطر المجموع
                          DataRow(
                              color: MaterialStateProperty.resolveWith(
                                (states) => Colors.grey.withOpacity(0.3),),
                            cells: [
                            DataCell(Text('Total')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(
                                Text(totalExportPercent.toStringAsFixed(2) + '%')),
                            DataCell(
                                Text(totalFarmsPercent.toStringAsFixed(2) + '%')),
                            DataCell(
                                Text(totalVariancePercent.toStringAsFixed(2) + '%')),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class BestAreaTablePage extends StatefulWidget {
//   final int exportId;
//   final int farmId;

//   const BestAreaTablePage({
//     Key? key,
//     required this.exportId,
//     required this.farmId,
//   }) : super(key: key);

//   @override
//   _BestAreaTablePageState createState() => _BestAreaTablePageState();
// }

// class _BestAreaTablePageState extends State<BestAreaTablePage> {
//   List<Map<String, dynamic>> tableData = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchBestAreaData();
//   }

//   Future<void> fetchBestAreaData() async {
//     print('exportid:${widget.exportId}');
//      print('farmid:${widget.farmId}');
    
//     try {
//       final response = await Supabase.instance.client
//           .rpc('get_best_area_sub', params: {
//         'export_id': widget.exportId,
//         'farm_id': widget.farmId,
//       }).select();

//       if (response.isNotEmpty) {
//         setState(() {
//           tableData = List<Map<String, dynamic>>.from(response);
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Error fetching data');
//       }
//     } catch (e) {
//       print(e);
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Best Area Table'),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               // scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: const [
//                   DataColumn(label: Text('ID')),
//                   DataColumn(label: Text('Size Code')),
//                   DataColumn(label: Text('KG 008')),
//                   DataColumn(label: Text('KG 015')),
//                   DataColumn(label: Text('Export %')),
//                   DataColumn(label: Text('Farm %')),
//                   DataColumn(label: Text('Variance %')),
//                 ],
//                 rows: tableData.map((data) {
//                   return DataRow(cells: [
//                     DataCell(Text(data['id_s'].toString())),
//                     DataCell(Text(data['sizecode'] ?? '')),
//                     DataCell(Text(data['kg008'] ?? '')),
//                     DataCell(Text(data['kg015'] ?? '')),
//                     DataCell(Text(data['export_percent']?.toStringAsFixed(2) ?? '0.0')),
//                     DataCell(Text(data['farms_percent']?.toStringAsFixed(2) ?? '0.0')),
//                     DataCell(Text(data['variance_percent']?.toStringAsFixed(2) ?? '0.0')), 
//                   ]);
//                 }).toList(),
//               ),
//             ),
//     );
//   }
// }
