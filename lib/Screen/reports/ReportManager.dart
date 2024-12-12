import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspection_app/Screen/reports/BestAreaTablePage.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportDetailsBySizeCopy extends StatefulWidget {
  final String ScreenName;
  final String ReportName;
  final int ScreenId;
  final List<String> formatColumns;

  final List<String> GroupColumn;
  final List<String> Num_Columns;
  final bool season;
  final bool farm;
  final bool comitt;
  final int exportid;
  final bool ispick;
  final bool isSales;

  ReportDetailsBySizeCopy(
      {super.key,
      required this.ScreenName,
      required this.ScreenId,
      required this.ReportName,
      required this.Num_Columns,
      required this.GroupColumn,
      required this.formatColumns,
      required this.comitt,
      required this.farm,
      required this.exportid,
      required this.ispick,
      required this.isSales,
      required this.season});
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
  List<Map<String, dynamic>> reservoir = [];
  List<Map<String, dynamic>> Season = [];
  String? selectedFarmId;
  String? selectedAreaId;
  String? selectedReservoirId;
  String? selectedSubAreaId;
  String? selectedSeasonId;
  String? selectedCropId;
  int? selectedRowIndex;
  String committeeDecision = '';
  String PickingDecision = '';
  bool? Decision;
  bool? IsPicking;
  String sql_where = ' ';
  List<DataGridRow> dataGridRows = [];
  bool isLoading = true;
  List<String> View_Columns = [];
  List<String> DGV_Columns = [];
  // Variables for datatable
  List<Map<String, dynamic>> dataTableRows = [];
  Map<String, Map<String, dynamic>> groupedData = {};

  List<String> hiddenColumns = [];

String farmid_string='farmid';
String areaid_string='areaid';
String subareaid_string='subareaid';
String cropid_string='cropid';
String decision_string='decision';
String seasonid_string='seasonid';

  @override
  void initState() {
    super.initState();
    syncColumnsWithDatabase();
    fetchhiddenColumns();
    fetchFarms();
    fetchCrops();
    fetchSeason();
    renamecolumns();
    if (widget.ScreenId==7) {
      fetchDynamicExportPlan2();
    }
  }
  void renamecolumns()
  {
    if (widget.ScreenName == 'get_farms_vs_export()') {
      cropid_string='cropids';
      seasonid_string='seasonids';

    }


  }

  // دالة حساب المجموع
  double _getColumnTotal(String columnName) {
    double total = 0.0;
    for (var row in dataGridRows) {
      for (var cell in row.getCells()) {
        //widget.formatColumns.contains(cell.columnName) &&
        if (cell.value is num && cell.columnName == columnName) {
          total += cell.value;
        }
      }
    }

    return total;
  }


  void wheretext() {
    sql_where = 'where test=0'; // البداية الأساسية للشرط

    if (selectedFarmId != null) {
      sql_where += ' and $farmid_string = $selectedFarmId';
    }
    if (selectedAreaId != null) {
      sql_where += ' and $areaid_string = $selectedAreaId';
    }
    if (selectedSubAreaId != null) {
      sql_where += ' and $subareaid_string = $selectedSubAreaId';
    }
    if (selectedCropId != null) {
      sql_where += ' and $cropid_string = $selectedCropId';
    }
    if (committeeDecision != '') {
      sql_where += ' and $decision_string = $Decision';
    }
    if (PickingDecision != '') {
      sql_where += ' and is_finished = $IsPicking';
    }
    if (selectedSeasonId != null) {
      sql_where += ' and $seasonid_string = $selectedSeasonId';
    }

    print(sql_where); // لطباعة الجملة النهائية للتأكد
  }

  Future<void> fetchDynamicExportPlan2() async {
    wheretext();
    View_Columns = widget.GroupColumn.where((col) =>
            !hiddenColumns.contains(col) && !widget.Num_Columns.contains(col))
        .toList();
    DGV_Columns = View_Columns + widget.formatColumns;

    dataTableRows.clear();
    List<Map<String, dynamic>> allRows = [];
    int batchSize = 1000; // حجم كل دفعة
    int offset = 0; // إزاحة البداية
    String numColumns = widget.Num_Columns.isNotEmpty
        ? ',${widget.Num_Columns.join(", ")}'
        : '';
    String groupByColumns = View_Columns.join(", ");
    String orderby = '';
    if (widget.ScreenId == 7) {
      orderby = ' Order By match_percentage  DESC';
    }
    // بناء الاستعلام
    String query = '''
    SELECT
      $groupByColumns $numColumns

    FROM
    ${widget.ScreenName}
    $sql_where

    GROUP BY
      $groupByColumns
      $orderby
  ''';
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
    // // حفظ كل البيانات المجمعة
    dataTableRows = allRows;
    final rows = (dataTableRows as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    setState(() {
      dataTableRows = rows;
      dataGridRows = rows
          .map((row) => DataGridRow(
                cells: DGV_Columns.map((col) {
                  return DataGridCell(columnName: col, value: row[col]);
                }).toList(),
              ))
          .toList();
      isLoading = false;
    });
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
          widget.GroupColumn.where((col) => !dbColumns.contains(col)).toList();

      // الأعمدة الزائدة: موجودة في dbColumns ولكن غير موجودة في columns
      List<String> extraColumns =
          dbColumns.where((col) => !widget.GroupColumn.contains(col)).toList();

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

  Future<void> fetchreservoir(String areaId) async {
    final response = await supabase
        .from('MenuData')
        .select('id, Name')
        .eq('Type', 9)
        .eq('Parant', areaId);
    setState(() {
      reservoir = (response as List)
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

  void copyToClipboard(List<Map<String, dynamic>> dataTableRows) {
    // إنشاء StringBuffer لتخزين البيانات كنص
    StringBuffer buffer = StringBuffer();

    // إضافة العناوين (الأعمدة)
    if (dataTableRows.isNotEmpty) {
      // استخدام التبويبات للفصل بين الأعمدة
      dataTableRows[0].keys.forEach((key) {
        buffer.write('$key\t');
      });
      buffer.writeln();
    }

    // إضافة البيانات في كل صف
    for (var row in dataTableRows) {
      row.values.forEach((value) {
        buffer.write('$value\t');
      });
      buffer.writeln();
    }

    // نسخ البيانات إلى الحافظة
    Clipboard.setData(ClipboardData(text: buffer.toString())).then((_) {
      print('تم نسخ البيانات إلى الحافظة');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.ReportName),
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
                return widget.GroupColumn.map((filter) {
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
                  if (widget.season)
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedSeasonId,
                        hint: Text('Select Season'),
                        items: [
                          DropdownMenuItem<String>(
                            value: null, // قيمة لإلغاء الاختيار
                            child: Text(
                                'Select Season'), // النص الذي يظهر للمستخدم
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
                  if (widget.farm) SizedBox(width: 16),
                  if (widget.farm)
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedFarmId,
                        hint: Text('Select Farm'),
                        items: [
                          DropdownMenuItem<String>(
                            value: null, // قيمة لإلغاء الاختيار
                            child:
                                Text('Select Farm'), // النص الذي يظهر للمستخدم
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
                            reservoir = [];
                          });
                          if (value != null) fetchAreas(value);
                        },
                      ),
                    ),
                  if (widget.farm) SizedBox(width: 16),
                  if (widget.farm)
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedAreaId,
                        hint: Text('Select Area'),
                        items: [
                          DropdownMenuItem<String>(
                            value: null, // قيمة لإلغاء الاختيار
                            child:
                                Text('Select Area'), // النص الذي يظهر للمستخدم
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
                            reservoir = [];
                          });
                          if (value != null) {
                            fetchreservoir(value);
                            fetchSubAreas(value);
                          }
                        },
                      ),
                    ),
                  if (widget.farm && reservoir.isNotEmpty) SizedBox(width: 16),
                  if (widget.farm && reservoir.isNotEmpty)
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedReservoirId,
                        hint: Text('Select Reservoir'),
                        items: [
                          DropdownMenuItem<String>(
                            value: null, // قيمة لإلغاء الاختيار
                            child: Text(
                                'Select Reservoir'), // النص الذي يظهر للمستخدم
                          ),
                          ...reservoir
                              .map((reservoir) => DropdownMenuItem<String>(
                                    value: reservoir['id'],
                                    child: Text(reservoir['Name']),
                                  ))
                              .toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedReservoirId = value;
                            selectedSubAreaId = null;
                            subAreas = [];
                          });
                          if (value != null) {
                            fetchSubAreas(value);
                          }
                        },
                      ),
                    ),
                  if (widget.farm) SizedBox(width: 16),
                  if (widget.farm)
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedSubAreaId,
                        hint: Text('Select SubArea'),
                        items: [
                          DropdownMenuItem<String>(
                            value: null, // قيمة لإلغاء الاختيار
                            child: Text(
                                'Select SubArea'), // النص الذي يظهر للمستخدم
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
                          child:
                              Text('Select Crops'), // النص الذي يظهر للمستخدم
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
                  if (widget.comitt) SizedBox(width: 16),
                  if (widget.comitt)
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
                        IconButton(
                            onPressed: () {
                              setState(() {
                                committeeDecision = '';
                              });
                            },
                            icon: Icon(
                              Icons.cancel,
                              size: 15,
                              color: Colors.red,
                            ))
                      ],
                    ),
                  if (widget.ispick) SizedBox(width: 16),
                  if (widget.ispick)
                    Wrap(
                      children: [
                        Text('حالة القطف'),
                        SizedBox(
                          width: 20,
                        ),
                        Radio<String>(
                          value: 'تم القطف',
                          groupValue: PickingDecision,
                          onChanged: (value) {
                            setState(() {
                              PickingDecision = value!;
                              IsPicking = PickingDecision == value;
                            });
                          },
                        ),
                        Text('تم القطف'),
                        Radio<String>(
                          value: 'تحت القطف',
                          groupValue: PickingDecision,
                          onChanged: (value) {
                            setState(() {
                              PickingDecision = value!;
                              IsPicking = PickingDecision != value;
                            });
                          },
                        ),
                        Text('تحت القطف'),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                PickingDecision = '';
                              });
                            },
                            icon: Icon(
                              Icons.cancel,
                              size: 15,
                              color: Colors.red,
                            ))
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
                    onPressed: () async {
                      copyToClipboard(dataTableRows);
                    },
                    icon: Icon(Icons.copy),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: SfDataGrid(
                    source: _DataSource(
                      context,
                      widget.exportid,
                      dataGridRows,
                      DGV_Columns,
                      widget.formatColumns,
                    ),
                    columnWidthMode: ColumnWidthMode.fill, // تمدد الأعمدة

                    columns: DGV_Columns.map((col) => GridColumn(
                          columnName: col,
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            color: ColorTablebackHedar,
                            child: Text(
                              col,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        )).toList(),
                    footer: Container(
                        padding: EdgeInsets.all(8.0),
                        color: Colors.grey[200], // تغيير لون خلفية سطر المجموع
                        child: Row(
                          children: DGV_Columns.map((col) {
                            // حساب المجموع فقط للأعمدة الموجودة في formatColumns
                            var total = widget.formatColumns.contains(col)
                                ? _getColumnTotal(col)
                                : null;
                            return Expanded(
                              child: Center(
                                child: Text(
                                  total != null ? total.toStringAsFixed(2) : '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }).toList(),
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataSource extends DataGridSource {
  final BuildContext context; // إضافة BuildContext هنا
  int exportId;

  List<DataGridRow> dataGridRows;
  List<String> columns;
  List<String> formatColumns;

  _DataSource(this.context, this.exportId, this.dataGridRows, this.columns,
      this.formatColumns);

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        final cellValue = cell.value;
        final isNegative = cellValue is num && cellValue < 0;
        final isColumn1 = cell.columnName == 'match_percentage';

        return Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.0),
                color:
                    isColumn1 ? const Color.fromARGB(255, 216, 209, 147) : null,
                child: Text(
                  _formatCellValue(
                      DataGridCell(
                        columnName: cell.columnName,
                        value: isColumn1 ? "${cell.value}%" : cell.value,
                      ),
                      formatColumns),
                  style:
                      TextStyle(color: isNegative ? Colors.red : Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (isColumn1)
              IconButton(
                  onPressed: () async {
                    final subareaId = row
                        .getCells()
                        .firstWhere((cell) => cell.columnName == 'subareaids')
                        .value;
                    print('cell.columnName :${cell.columnName}');
                    print('cell.value :${cell.value}');
                    await showDialog(
                        context: context,
                        builder: (context) => Dialog(
                            child: SizedBox(
                                width: 1000,
                                height: 900,
                                child: BestAreaTablePage(
                                    exportId: exportId,
                                    farmId: subareaId))));
                  },
                  icon: Icon(Icons.menu))
          ],
        );
      }).toList(),
    );
  }

  String _formatCellValue(DataGridCell cell, List<String> formatColumns) {
    // تحقق إذا كانت القيمة رقمية واسم العمود موجود في formatColumns
    if (formatColumns.contains(cell.columnName) && cell.value is num) {
      final formatter = NumberFormat("#,##0.00", "en_US");
      return formatter.format(cell.value);
    }

    // إذا لم تكن القيمة رقمية أو ليست ضمن الأعمدة المحددة
    return cell.value.toString();
  }
}
