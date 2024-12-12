import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/InputData/ExportdataPage.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inspection_app/Screen/reports/ReportManager.dart';

class ExportDataList extends StatefulWidget {
  @override
  _ExportDataListState createState() => _ExportDataListState();
}

class _ExportDataListState extends State<ExportDataList> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Variables for dropdowns

  List<Map<String, dynamic>> Crops = [];
  List<Map<String, dynamic>> Season = [];

  String? selectedSeasonId;
  String? selectedCropId;
  int? selectedRowIndex;

  // Variables for datatable
  List<Map<String, dynamic>> dataTableRows = [];
  List<String> columns = [
    'id',
    'season',
    'month',
    'week',
    'crop',
    // 'size',
    'qty',
  ];

  // Selected columns for hiding
  List<String> hiddenColumns = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> fetchDataTable() async {
    // if (_isDisposed) return;
    final response = await supabase
        .rpc(
          "get_export_input",
        )
        .eq(selectedCropId != null ? 'cropid' : 'test',
            selectedCropId != null ? selectedCropId! : 0)
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

    List<String> groupByColumns = columns
        .where((col) => !hiddenColumns.contains(col) && col != 'qty')
        .toList();

    Map<String, Map<String, dynamic>> groupedData = {};

    for (var row in dataTableRows) {
      String key = groupByColumns.map((col) => row[col] ?? '').join('-');

      if (!groupedData.containsKey(key)) {
        groupedData[key] = Map<String, dynamic>.from(row);
        groupedData[key]!['qty'] = row['qty'] ?? 0;
      } else {
        groupedData[key]!['qty'] += row['qty'] ?? 0;
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
            Text('جدول ادخال خطط البيع'),
            SizedBox(
              width: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: SizedBox(
                      width: 600,
                      height: 900,
                      child: ExportdataPage(
                        ScreenID: 0,
                      ),
                    ),
                  ),
                );
                if (result) {
                  await fetchDataTable();
                  setState(() {});
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
              return columns
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
            Row(
              children: [
                Expanded(
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
                SizedBox(width: 16),
                Expanded(
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
                SizedBox(width: 16),
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
                        ...columns
                            .where((col) => !hiddenColumns.contains(col))
                            .map((col) => DataColumn(label: Text(col)))
                            .toList(),
                        DataColumn(label: Text('Menu')),
                      ],
                      rows: [
                        ...processRows().map(
                          (row) => DataRow(cells: [
                            ...columns
                                .where((col) => !hiddenColumns.contains(col))
                                .map((col) => DataCell(
                                      Text(row[col]?.toString() ?? ''),
                                    ))
                                .toList(),
                            DataCell(
                             
                                    PopupMenuButton<String>(
                                    icon:
                                        Icon(Icons.more_vert), // أيقونة القائمة
                                    onSelected: (value) async {
                                      if (value == "عرض") {
                                     
                                           final result = await showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: SizedBox(
                                        width: 650,
                                        height: 900,
                                        child: ExportdataPage(
                                          ScreenID: row['id'],
                                        ),
                                      ),
                                    ),
                                  );
                                  if (result) {
                                    await fetchDataTable();
                                    setState(() {});
                                  }
                                      } else if (value ==
                                          "اختيار أفضل موقع للقطف") {
                                             String ReportName ='اختيار افضل مكان للقطف' ;
                                    List<String> GroupColumn = [
                                      'farm',
                                      'area',
                                      'reservoir',
                                      'subarea',
                                      'subareaids',
                                       'crop',
                                        'export_qty',
                                      'farm_balance',
                                      'match_percentage'
                                     
                                    ];
                                    List<String> Num_Columns = [
                                      // 'sum(export_qty) as export_qty',
                                      // 'sum(farm_balance) as farm_balance',
                                      // 'sum(match_percentage) as match_percentage'
                                    ];
                                    List<String> formatColumns = [
                                      // 'export_qty',
                                      // 'farm_balance',
                                      // 'match_percentage'
                                    ];
                                      await showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: SizedBox(
                                        width: 1000,
                                        height: 900,
                                        child: ReportDetailsBySizeCopy( 
                                          isSales: true,
                                          ispick: false,
                                         exportid:row['id'],
                                            ScreenName: 'get_best_area()',
                                      ScreenId: 7,
                                      ReportName: ReportName,
                                      Num_Columns: Num_Columns,
                                      GroupColumn: GroupColumn,
                                      formatColumns: formatColumns,
                                      comitt: false,
                                      farm: false,
                                      season: false,
                                        ),
                                      ),
                                    ),
                                  );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: "عرض",
                                        child: Text("عرض"),
                                      ),
                                      PopupMenuItem(
                                        value: "اختيار أفضل موقع للقطف",
                                        child: Text("اختيار أفضل موقع للقطف"),
                                      ),
                                    ],
                                  )
                                 
                              
                            ),
                          ]),
                        ),
                        DataRow(
                            color: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey.withOpacity(0.3),
                            ),
                            cells: [
                              ...columns
                                  .where((col) => !hiddenColumns.contains(col))
                                  .map(
                                    (col) => DataCell(
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
