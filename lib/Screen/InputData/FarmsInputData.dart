import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/InputData/ActualRaw.dart';
import 'package:inspection_app/Screen/InputData/InputDataPage.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmsInputData extends StatefulWidget {
  final List<String> columns;
  final String ScreenName;
  final int Screenid;
  FarmsInputData({
    super.key,
    required this.columns,
    required this.ScreenName,
    required this.Screenid,
  });
  @override
  _FarmsInputDataState createState() => _FarmsInputDataState();
}

class _FarmsInputDataState extends State<FarmsInputData> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Variables for dropdowns
  List<Map<String, dynamic>> farms = [];
  List<Map<String, dynamic>> Crops = [];
  List<Map<String, dynamic>> areas = [];
  List<Map<String, dynamic>> subAreas = [];
  List<Map<String, dynamic>> Season = [];
  String? selectedFarmId;
  String? selectedAreaId;
  String? selectedSubAreaId;
  String? selectedSeasonId;
  String? selectedCropId;
  int? selectedRowIndex;
  String committeeDecision = '';
  bool? Decision;
  String _edit = 'تعديل';
  String _delete = 'حذف';

  // Variables for datatable
  List<Map<String, dynamic>> dataTableRows = [];

  // Selected columns for hiding
  List<String> hiddenColumns = [];

  @override
  void initState() {
    super.initState();
    fetchFarms();
    fetchCrops();
    fetchSeason();
  }
//   @override
// void dispose() {
//   _isDisposed = true;
//   super.dispose();
// }

  Future<void> fetchSeason() async {
    final response =
        await supabase.from('MenuData').select('id, Name').eq('Type', 7);
    setState(() {
      Season = (response as List)
          .map((e) => {
                'id': e['id'].toString(),
                'Name': e['Name'],
              })
          .toList();
    });
  }

  Future<void> fetchCrops() async {
    final response =
        await supabase.from('MenuData').select('id, Name').eq('Type', 4);
    setState(() {
      Crops = (response as List)
          .map((e) => {
                'id': e['id'].toString(),
                'Name': e['Name'],
              })
          .toList();
    });
  }

  Future<void> fetchFarms() async {
    final response =
        await supabase.from('MenuData').select('id, Name').eq('Type', 1);
    setState(() {
      farms = (response as List)
          .map((e) => {
                'id': e['id'].toString(),
                'Name': e['Name'],
              })
          .toList();
    });
  }

  Future<void> fetchAreas(String farmId) async {
    final response = await supabase
        .from('MenuData')
        .select('id, Name')
        .eq('Type', 2)
        .eq('Parant', farmId);
    setState(() {
      areas = (response as List)
          .map((e) => {
                'id': e['id'].toString(),
                'Name': e['Name'],
              })
          .toList();
    });
  }

  Future<void> fetchSubAreas(String areaId) async {
    final response = await supabase
        .from('MenuData')
        .select('id, Name')
        .eq('Type', 3)
        .eq('Parant', areaId);
    setState(() {
      subAreas = (response as List)
          .map((e) => {
                'id': e['id'].toString(),
                'Name': e['Name'],
              })
          .toList();
    });
  }

  Future<void> fetchDataTable() async {
    // if (_isDisposed) return;
    final response = await supabase
        .rpc(
          "get_input_data",
        )
        .eq('type', widget.Screenid)
        .eq(selectedFarmId != null ? 'farmid' : 'test',
            selectedFarmId != null ? selectedFarmId! : 0)
        .eq(selectedAreaId != null ? 'areaid' : 'test',
            selectedAreaId != null ? selectedAreaId! : 0)
        .eq(selectedSubAreaId != null ? 'subareaid' : 'test',
            selectedSubAreaId != null ? selectedSubAreaId! : 0)
        .eq(selectedCropId != null ? 'cropid' : 'test',
            selectedCropId != null ? selectedCropId! : 0)
        .eq(Decision != null ? 'decision' : 'test',
            Decision != null ? Decision! : 0)
        .eq(selectedSeasonId != null ? 'seasonid' : 'test',
            selectedSeasonId != null ? selectedSeasonId! : 0);

    // if (mounted) {
    //   setState(() {
    dataTableRows =
        (response as List).map((e) => Map<String, dynamic>.from(e)).toList();
    //   });
    // }
  }

  List<Map<String, dynamic>> processRows() {
    if (hiddenColumns.isEmpty) {
      return dataTableRows;
    }

    List<String> groupByColumns = widget.columns
        .where((col) =>
            !hiddenColumns.contains(col) && col != 'acre' && col != 'trees')
        .toList();

    Map<String, Map<String, dynamic>> groupedData = {};

    for (var row in dataTableRows) {
      String key = groupByColumns.map((col) => row[col] ?? '').join('-');

      if (!groupedData.containsKey(key)) {
        groupedData[key] = Map<String, dynamic>.from(row);
        groupedData[key]!['acre'] = row['acre'] ?? 0;
        groupedData[key]!['trees'] = row['trees'] ?? 0;
      } else {
        groupedData[key]!['acre'] += row['acre'] ?? 0;
        groupedData[key]!['trees'] += row['trees'] ?? 0;
      }
    }

    return groupedData.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.ScreenName),
            SizedBox(
              width: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                if (widget.Screenid == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InputDataPage(ScreenID: 0, SubAreaId: 0),
                    ),
                  ).then((value) async {
                    if (value == true) {
                      await fetchDataTable();
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  });
                } else {
                  final result = await showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: SizedBox(
                        width: 900,
                        height: 500,
                        child: ActualRaw(
                          ScreenID: 0,
                          SubAreaId: 0,
                        ),
                      ),
                    ),
                  );
                  if (result) {
                    await fetchDataTable();
                    setState(() {});
                  }
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         ActualRaw(ScreenID: 0, SubAreaId: 0),
                  //   ),
                  // ).then((value) async {
                  //   if (value == true) {
                  //     await fetchDataTable();
                  //     if (mounted) {
                  //       setState(() {});
                  //     }
                  //   }
                  // });
                }
              },
              child: Row(
                children: [
                  Text('انشاء'),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.add)
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTablebackHedar,
                foregroundColor: ColorTableForeHedar,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (column) {
              setState(() {
                if (column != 'id') {
                  if (hiddenColumns.contains(column)) {
                    hiddenColumns.remove(column);
                  } else {
                    hiddenColumns.add(column);
                  }
                }
              });
            },
            itemBuilder: (context) {
              return widget.columns
                  .map((col) => CheckedPopupMenuItem<String>(
                        value: col,
                        checked: !hiddenColumns.contains(col),
                        child: Text(col),
                      ))
                  .toList();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 16, // المسافة الأفقية بين العناصر
                runSpacing: 16, // المسافة الرأسية بين الأسطر
                children: [
                  SizedBox(
                    // width: double.infinity,
                    child: DropdownButton<String>(
                      value: selectedSeasonId,
                      hint: Text('Select Season'),
                      items: Season.map((Season) => DropdownMenuItem<String>(
                            value: Season['id'],
                            child: Text(Season['Name']),
                          )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSeasonId = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    // width: double.infinity,
                    child: DropdownButton<String>(
                      value: selectedFarmId,
                      hint: Text('Select Farm'),
                      items: farms
                          .map((farm) => DropdownMenuItem<String>(
                                value: farm['id'],
                                child: Text(farm['Name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFarmId = value;
                          selectedAreaId = null;
                          selectedSubAreaId = null;
                          areas = [];
                          subAreas = [];
                        });
                        if (value != null) fetchAreas(value);
                      },
                    ),
                  ),
                  SizedBox(
                    // width: double.infinity,
                    child: DropdownButton<String>(
                      value: selectedAreaId,
                      hint: Text('Select Area'),
                      items: areas
                          .map((area) => DropdownMenuItem<String>(
                                value: area['id'],
                                child: Text(area['Name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAreaId = value;
                          selectedSubAreaId = null;
                          subAreas = [];
                        });
                        if (value != null) fetchSubAreas(value);
                      },
                    ),
                  ),
                  SizedBox(
                    // width: double.infinity,
                    child: DropdownButton<String>(
                      value: selectedSubAreaId,
                      hint: Text('Select SubArea'),
                      items: subAreas
                          .map((subArea) => DropdownMenuItem<String>(
                                value: subArea['id'],
                                child: Text(subArea['Name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubAreaId = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    // width: double.infinity,
                    child: DropdownButton<String>(
                      value: selectedCropId,
                      hint: Text('Select Crops'),
                      items: Crops.map((Crops) => DropdownMenuItem<String>(
                            value: Crops['id'],
                            child: Text(Crops['Name']),
                          )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCropId = value;
                        });
                      },
                    ),
                  ),
                  Wrap(
                    children: [
                      Text('قرار اللجنة'),
                      SizedBox(
                        width: 20,
                      ),
                      Radio<String>(
                        value: 'مقبول',
                        groupValue: committeeDecision,
                        onChanged: (value) {
                          setState(() {
                            committeeDecision = value!;
                            Decision = committeeDecision == value;
                          });
                        },
                      ),
                      Text('مقبول'),
                      Radio<String>(
                        value: 'مرفوض',
                        groupValue: committeeDecision,
                        onChanged: (value) {
                          setState(() {
                            committeeDecision = value!;
                            Decision = committeeDecision != value;
                          });
                        },
                      ),
                      Text('مرفوض'),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTablebackHedar,
                      foregroundColor: ColorTableForeHedar,
                    ),
                    onPressed: () async {
                      await fetchDataTable();
                      setState(() {});
                    },
                    child: Text('تحميل البيانات'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
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
                    ),
                    child: DataTable(
                      columnSpacing: 16.0,
                      columns: [
                        ...widget.columns
                            .where((col) => !hiddenColumns.contains(col))
                            .map((col) => DataColumn(label: Text(col)))
                            .toList(),
                        DataColumn(label: Text('Menu')),
                      ],
                      rows: [
                        ...processRows().map(
                          (row) => DataRow(cells: [
                            ...widget.columns
                                .where((col) => !hiddenColumns.contains(col))
                                .map((col) => DataCell(
                                      Text(row[col]?.toString() ?? ''),
                                    ))
                                .toList(),
                            DataCell(PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert), // أيقونة القائمة
                              onSelected: (value) async {
                                if (value == _edit) {
                                  if (widget.Screenid == 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InputDataPage(
                                          ScreenID: row['id'],
                                          SubAreaId: row['subareaid'],
                                        ),
                                      ),
                                    ).then((value) async {
                                      if (value == true) {
                                        await fetchDataTable();
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }
                                    });
                                  } else {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: SizedBox(
                                          width: 900,
                                          height: 500,
                                          child: ActualRaw(
                                            ScreenID: row['id'],
                                            SubAreaId: row['subareaid'],
                                          ),
                                        ),
                                      ),
                                    );
                                    if (result) {
                                      await fetchDataTable();
                                      setState(() {});
                                    }
                                  }
                                }
                                if (value == _delete) {
                                  final originalContext =
                                      context; // حفظ السياق الأصلي
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('تأكيد العملية'),
                                        content: Text(
                                            'هل أنت متأكد من أنك تريد تنفيذ هذه العملية؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // إغلاق مربع الحوار بدون تنفيذ
                                            },
                                            child: Text('إلغاء'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context)
                                                  .pop(); // إغلاق مربع الحوار
                                              await supabase
                                                  .from('InputData')
                                                  .delete()
                                                  .eq('id', row['id']);

                                              await fetchDataTable();
                                              setState(() {});

                                              // استخدام السياق الأصلي هنا
                                              ScaffoldMessenger.of(
                                                      originalContext)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'تم حذف البيانات بنجاح'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                            child: Text('تأكيد'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }

                                // if (value == _delete) {
                                //   showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         title: Text('تأكيد العملية'),
                                //         content: Text(
                                //             'هل أنت متأكد من أنك تريد تنفيذ هذه العملية؟'),
                                //         actions: [
                                //           TextButton(
                                //             onPressed: () {
                                //               Navigator.of(context)
                                //                   .pop(); // إغلاق مربع الحوار بدون تنفيذ
                                //             },
                                //             child: Text('إلغاء'),
                                //           ),
                                //           TextButton(
                                //             onPressed: () async {
                                //               Navigator.of(context)
                                //                   .pop(); // إغلاق مربع الحوار
                                //                     await supabase
                                //                     .from('InputData')
                                //                     .delete()
                                //                     .eq('id', row['id']);

                                //               await    fetchDataTable();
                                //               setState(() async {

                                //               });
                                //                ScaffoldMessenger.of(context)
                                //                     .showSnackBar(SnackBar(
                                //                   content: Text(
                                //                       'تم حذف البيانات بنجاح'),
                                //                   backgroundColor: Colors.green,
                                //                 ));
                                //             },
                                //             child: Text('تأكيد'),
                                //           ),
                                //         ],
                                //       );
                                //     },
                                //   );
                                // }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: _edit,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(_edit),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: _delete,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(_delete),
                                    ],
                                  ),
                                ),
                              ],
                            )

                                // IconButton(
                                //   icon: Icon(Icons.menu),
                                //   onPressed: () async {

                                //   },
                                // ),
                                ),
                          ]),
                        ),
                        DataRow(
                            color: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey.withOpacity(0.3),
                            ),
                            cells: [
                              ...widget.columns
                                  .where((col) => !hiddenColumns.contains(col))
                                  .map(
                                    (col) => DataCell(
                                      col == 'acre' ||
                                              col == 'trees' ||
                                              col == 'qty'
                                          ? Text(
                                              processRows()
                                                  .fold<num>(
                                                    0,
                                                    (sum, row) =>
                                                        sum + (row[col] ?? 0),
                                                  )
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(''),
                                    ),
                                  )
                                  .toList(),
                              DataCell(Text('')),
                            ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
