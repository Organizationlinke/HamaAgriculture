import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportDetailsBySizeCopy extends StatefulWidget {
  final String ScreenName;
  final int ScreenId;
  final List<String> columns;
  final List<String> formatColumns;

  final List<String> GroupColumn;
  final List<String> Num_Columns;

  ReportDetailsBySizeCopy({
    super.key,
    required this.ScreenName,
    required this.ScreenId,
    required this.columns,
    required this.Num_Columns,
    required this.GroupColumn,
     required this.formatColumns,
  });
  @override
  _ReportDetailsBySizeState createState() => _ReportDetailsBySizeState();
}


class _ReportDetailsBySizeState extends State<ReportDetailsBySizeCopy> {

  
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
  String sql_where = ' ';
 

  // Variables for datatable
  List<Map<String, dynamic>> dataTableRows = [];
  Map<String, Map<String, dynamic>> groupedData = {};

  List<String> hiddenColumns = [];
  // القائمة الأصلية (كل البيانات)
  List<Map<String, dynamic>> allData = [];
  
  // البيانات المعروضة حاليًا في الجدول
  List<Map<String, dynamic>> visibleData = [];

  // عدد العناصر التي يتم تحميلها في كل دفعة
  final int batchSize = 20;

  // مؤشر المرحلة الحالية
  int currentBatch = 0;
  @override
  void initState() {
    super.initState();
    syncColumnsWithDatabase();
    fetchhiddenColumns();
    fetchFarms();
    fetchCrops();
    fetchSeason();
  }
 void generateMockData() {
    for (int i = 0; i < 1000; i++) {
      allData.add({
        'farm': 'Farm $i',
        'area': 'Area $i',
        'reservoir': 'Reservoir $i',
        'subarea': 'Subarea $i',
        'crop': 'Crop $i',
        'acre': i,
      });
    }
  }
  void loadMoreData() {
    // حساب البداية والنهاية للدفعة الجديدة
    int startIndex = currentBatch * batchSize;
    int endIndex = startIndex + batchSize;

    // التحقق من وجود بيانات جديدة
    if (startIndex < allData.length) {
      setState(() {
        visibleData.addAll(allData.sublist(
          startIndex,
          endIndex > allData.length ? allData.length : endIndex,
        ));
        currentBatch++;
      });
    }
  }

  Future<void> fetchDynamicExportPlan2() async {
     List<String> View_Columns = widget.GroupColumn
        .where((col) =>
            // !hiddenColumns.contains(col) && col != 'acre' && col != 'trees')
            !hiddenColumns.contains(col) && !widget.Num_Columns.contains(col))
        .toList();

    dataTableRows.clear();
    List<Map<String, dynamic>> allRows = [];
    int batchSize = 1000; // حجم كل دفعة
    int offset = 0; // إزاحة البداية
    String numColumns = widget.Num_Columns.join(", ");
    String groupByColumns = View_Columns.join(", ");
    // بناء الاستعلام
    String query = '''
    SELECT 
      $groupByColumns,$numColumns
      
    FROM 
    ${widget.ScreenName}
    $sql_where 

    GROUP BY 
      $groupByColumns
  ''';
    print(query);
    while (true) {
    final response = await supabase.rpc(
      'execute_dynamic_query',
      params: {'query': query},
    ).range(offset, offset + batchSize - 1); // إضافة نطاق الصفوف
    // تحويل النتائج إلى قائمة
    final rows =
        (response as List).map((e) => Map<String, dynamic>.from(e)).toList();

    // إضافة النتائج إلى القائمة الكلية
    allRows.addAll(rows);

      // التحقق إذا تم جلب أقل من حجم الدفعة (أي انتهاء البيانات)
      if (rows.length < batchSize) {
        break;
      }

      // تحديث الإزاحة للدفعة التالية
      offset += batchSize;
    }
    // حفظ كل البيانات المجمعة
    dataTableRows = allRows;

  }

  Future<void> syncColumnsWithDatabase() async {
    try {
      // استعلام للحصول على الأعمدة من قاعدة البيانات
      final response = await supabase
          .from('ViewColumns')
          .select('column_name')
          .eq('screen_name', widget.ScreenName)
          .eq('user_id', userid);

      // استخراج أسماء الأعمدة من الاستجابة
      List<String> dbColumns =
          List<String>.from(response.map((item) => item['column_name']));

      // الأعمدة المفقودة: موجودة في columns ولكن غير موجودة في dbColumns
      List<String> missingColumns =
          widget.columns.where((col) => !dbColumns.contains(col)).toList();

      // الأعمدة الزائدة: موجودة في dbColumns ولكن غير موجودة في columns
      List<String> extraColumns =
          dbColumns.where((col) => !widget.columns.contains(col)).toList();

      // إضافة الأعمدة المفقودة
      for (String column in missingColumns) {
        await supabase.from('ViewColumns').insert({
          'screen_name': widget.ScreenName,
          'user_id': userid,
          'column_name': column,
          'check': true, // أو القيمة الافتراضية التي تريد استخدامها
        });
      }

      // حذف الأعمدة الزائدة
      for (String column in extraColumns) {
        await supabase
            .from('ViewColumns')
            .delete()
            .eq('screen_name', widget.ScreenName)
            .eq('user_id', userid)
            .eq('column_name', column);
      }

      print(
          "Synchronization complete. Missing columns added, extra columns removed.");
    } catch (e) {
      print("Error syncing columns: $e");
    }
  }

// دالة لإضافة الأعمدة وتحديث حالة العمود
  Future<void> updateViewColumns({
    required String columnName,
    required bool isVisible,
  }) async {
    try {
      final checkValue = isVisible;

      // التحقق إذا كان العمود موجودًا مسبقًا
      final response = await supabase
          .from('ViewColumns')
          .select('column_name')
          .eq('screen_name', widget.ScreenName)
          .eq('user_id', userid)
          .eq('column_name', columnName)
          .maybeSingle();

      if (response == null) {
        // إذا لم يكن موجودًا، قم بالإضافة
        await supabase.from('ViewColumns').insert({
          'screen_name': widget.ScreenName,
          'user_id': userid,
          'column_name': columnName,
          'check': checkValue,
        });
      } else {
        // إذا كان موجودًا، قم بالتحديث
        await supabase
            .from('ViewColumns')
            .update({'check': checkValue})
            .eq('screen_name', widget.ScreenName)
            .eq('user_id', userid)
            .eq('column_name', columnName);
      }
    } catch (e) {
      print('Error updating ViewColumns: $e');
    }
  }

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

  Future<void> fetchhiddenColumns() async {
    try {
      final response = await supabase
          .from('ViewColumns')
          .select('column_name')
          .eq('screen_name', widget.ScreenName)
          .eq('user_id', userid)
          .eq('check', false);
      if (response.isNotEmpty) {
        hiddenColumns =
            List<String>.from(response.map((item) => item['column_name']));
      }
    } catch (e) {
      print('Error fetching hidden columns: $e');
    }
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

  void wheretext() {
    sql_where = 'where test=0'; // البداية الأساسية للشرط

    if (selectedFarmId != null) {
      sql_where += ' and farmid = $selectedFarmId';
    }
    if (selectedAreaId != null) {
      sql_where += ' and areaid = $selectedAreaId';
    }
    if (selectedSubAreaId != null) {
      sql_where += ' and subareaid = $selectedSubAreaId';
    }
    if (selectedCropId != null) {
      sql_where += ' and cropid = $selectedCropId';
    }
    if (Decision != null) {
      sql_where += ' and decision = $Decision';
    }
    if (selectedSeasonId != null) {
      sql_where += ' and seasonid = $selectedSeasonId';
    }

    print(sql_where); // لطباعة الجملة النهائية للتأكد
  }

  Future<void> fetchDataTable() async {
    dataTableRows.clear();
    // processRows().clear();
    // groupedData.clear();
    List<Map<String, dynamic>> allRows = [];
    int batchSize = 1000; // حجم كل دفعة
    int offset = 0; // إزاحة البداية

    while (true) {
      // تنفيذ الاستعلام باستخدام الإزاحة والحجم
      final response = await supabase
          .rpc(
            widget.ScreenName,
          )
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
              selectedSeasonId != null ? selectedSeasonId! : 0)
          .range(offset, offset + batchSize - 1); // إضافة نطاق الصفوف

      // تحويل النتائج إلى قائمة
      final rows =
          (response as List).map((e) => Map<String, dynamic>.from(e)).toList();

      // إضافة النتائج إلى القائمة الكلية
      allRows.addAll(rows);

      // التحقق إذا تم جلب أقل من حجم الدفعة (أي انتهاء البيانات)
      if (rows.length < batchSize) {
        break;
      }

      // تحديث الإزاحة للدفعة التالية
      offset += batchSize;
    }

    // حفظ كل البيانات المجمعة
    dataTableRows = allRows;
  }

  List<Map<String, dynamic>> processRows() {
    if (hiddenColumns.isEmpty) {
      return dataTableRows;
    }

    List<String> groupByColumns = widget.columns
        .where((col) =>
            // !hiddenColumns.contains(col) && col != 'acre' && col != 'trees')
            !hiddenColumns.contains(col) && !widget.Num_Columns.contains(col))
        .toList();

    // for (var row in dataTableRows) {
    //   String key = groupByColumns.map((col) => row[col] ?? '').join('-');

    //   if (!groupedData.containsKey(key)) {
    //     groupedData[key] = Map<String, dynamic>.from(row);
    //     // إضافة الأعمدة المستهدفة مع التهيئة
    //     for (var col in widget.Num_Columns) {
    //       groupedData[key]![col] = row[col] ?? 0;
    //     }
    //   } else {
    //     // تجميع القيم للأعمدة المستهدفة
    //     for (var col in widget.Num_Columns) {
    //       groupedData[key]![col] += row[col] ?? 0;
    //     }
    //   }
    // }

    return groupedData.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقرير المعاينات بالاحجام'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (column) {
              setState(() {
                if (hiddenColumns.contains(column)) {
                  hiddenColumns.remove(column);
                } else {
                  hiddenColumns.add(column);
                }
              });
            },
            itemBuilder: (context) {
              return widget.columns.map((filter) {
                return PopupMenuItem<String>(
                  value: filter, // تمرير القيمة لضمان `onSelected` يعمل
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return CheckboxListTile(
                        title: Text(filter),
                        value:
                            !hiddenColumns.contains(filter), // عكس الحالة هنا
                        onChanged: (bool? isChecked) {
                          setState(() {
                            if (!(isChecked ?? false)) {
                              // عكس القيمة
                              hiddenColumns.add(filter);
                            } else {
                              hiddenColumns.remove(filter);
                            }
                          });

                          // تحديث حالة العنصر الرئيسي
                          this.setState(() {});
                          updateViewColumns(
                            columnName: filter,
                            isVisible: isChecked ?? false,
                          );
                        },
                      );
                    },
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSeasonId,
                    hint: Text('Select Season'),
                    items: [
                      DropdownMenuItem<String>(
                        value: null, // قيمة لإلغاء الاختيار
                        child: Text('None'), // النص الذي يظهر للمستخدم
                      ),
                      ...Season.map((Season) => DropdownMenuItem<String>(
                            value: Season['id'],
                            child: Text(Season['Name']),
                          )).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSeasonId = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedFarmId,
                    hint: Text('Select Farm'),
                    items: [
                      DropdownMenuItem<String>(
                        value: null, // قيمة لإلغاء الاختيار
                        child: Text('None'), // النص الذي يظهر للمستخدم
                      ),
                      ...farms
                          .map((farm) => DropdownMenuItem<String>(
                                value: farm['id'],
                                child: Text(farm['Name']),
                              ))
                          .toList(),
                    ],
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
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedAreaId,
                    hint: Text('Select Area'),
                    items: [
                      DropdownMenuItem<String>(
                        value: null, // قيمة لإلغاء الاختيار
                        child: Text('None'), // النص الذي يظهر للمستخدم
                      ),
                      ...areas
                          .map((area) => DropdownMenuItem<String>(
                                value: area['id'],
                                child: Text(area['Name']),
                              ))
                          .toList(),
                    ],
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
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSubAreaId,
                    hint: Text('Select SubArea'),
                    items: [
                      DropdownMenuItem<String>(
                        value: null, // قيمة لإلغاء الاختيار
                        child: Text('None'), // النص الذي يظهر للمستخدم
                      ),
                      ...subAreas
                          .map((subArea) => DropdownMenuItem<String>(
                                value: subArea['id'],
                                child: Text(subArea['Name']),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSubAreaId = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCropId,
                    hint: Text('Select Crops'),
                    items: [
                      DropdownMenuItem<String>(
                        value: null, // قيمة لإلغاء الاختيار
                        child: Text('Select Crops'), // النص الذي يظهر للمستخدم
                      ),
                      ...Crops.map((Crops) => DropdownMenuItem<String>(
                            value: Crops['id'],
                            child: Text(Crops['Name']),
                          )).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCropId = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Row(
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
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTablebackHedar,
                    foregroundColor: ColorTableForeHedar,
                  ),
                  onPressed: () async {
                    // await fetchDynamicall(widget.GroupColumn,widget.Num_Columns);
                    await fetchDynamicExportPlan2();
                    // await fetchDataTable();
                    setState(() {});
                  },
                  child: Text('تحميل البيانات'),
                ),
                IconButton(
                  onPressed: () async {},
                  icon: Icon(Icons.copy),
                ),
              ],
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
                            .map(
                                (col) => DataColumn(label: SelectableText(col)))
                            .toList(),
                      ],
                      rows: [
                        ...dataTableRows.map(
                          (row) =>
                          
                           DataRow(cells: [
                            ...widget.columns
                                .where((col) => !hiddenColumns.contains(col))
                                .map((col) => DataCell(
                                      widget.formatColumns.contains(col)
                                          ? SelectableText(
                                              (row[col] ?? 0).toStringAsFixed(
                                                  2), // تنسيق الرقم بعلامتين عشريتين
                                            )
                                          : SelectableText(
                                              row[col]?.toString() ?? ''),
                                    ))
                                .toList(),
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
                                      widget.formatColumns.contains(col)
                                          ? SelectableText(
                                              NumberFormat('#,##0.00').format(
                                                dataTableRows.fold<num>(
                                                  0,
                                                  (sum, row) =>
                                                      sum + (row[col] ?? 0),
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : SelectableText(''),
                                    ),
                                  )
                                  .toList(),
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
