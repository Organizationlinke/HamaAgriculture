import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmsReportDetails extends StatefulWidget {
  @override
  _FarmsReportDetailsState createState() => _FarmsReportDetailsState();
}

class _FarmsReportDetailsState extends State<FarmsReportDetails> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Variables for dropdowns
  List<Map<String, dynamic>> farms = [];
  List<Map<String, dynamic>> areas = [];
  List<Map<String, dynamic>> subAreas = [];

  String? selectedFarmId;
  String? selectedAreaId;
  String? selectedSubAreaId;

  // Variables for datatable
  List<Map<String, dynamic>> dataTableRows = [];
  List<String> columns = ['farm', 'area','reservoir', 'subarea', 'crop', 'acre', 'trees'];

  // Selected columns for hiding
  List<String> hiddenColumns = [];

  @override
  void initState() {
    super.initState();
    fetchFarms();
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
    final response = await supabase
        .rpc(
          "get_farms_listsub",
        )
        .eq(selectedFarmId != null ? 'farmid' : 'test',
            selectedFarmId != null ? selectedFarmId! : 0)
        .eq(selectedAreaId != null ? 'areaid' : 'test',
            selectedAreaId != null ? selectedAreaId! : 0)
        .eq(selectedSubAreaId != null ? 'subareaid' : 'test',
            selectedSubAreaId != null ? selectedSubAreaId! : 0);

    setState(() {
      dataTableRows =
          (response as List).map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  List<Map<String, dynamic>> processRows() {
    if (hiddenColumns.isEmpty) {
      return dataTableRows;
    }

    List<String> groupByColumns = columns
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
        title: Text('Farm Management'),
        actions: [
          PopupMenuButton<String>(
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
                SizedBox(width: 16),
                Expanded(
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
                SizedBox(width: 16),
                Expanded(
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
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: fetchDataTable,
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
                        (states) =>
                            Colors.blue.withOpacity(0.1), // لون رأس الأعمدة
                      ),
                      headingTextStyle: TextStyle(
                        color: Colors.blue, // لون النص في رأس الأعمدة
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: DataTable(
                      columnSpacing: 16.0,
                      columns: columns
                          .where((col) => !hiddenColumns.contains(col))
                          .map((col) => DataColumn(label: Text(col)))
                          .toList(),
                      // rows: processRows()
                      //     .map(
                      //       (row) => DataRow(
                      //         cells: columns
                      //             .where((col) => !hiddenColumns.contains(col))
                      //             .map((col) => DataCell(Text(row[col]?.toString() ?? '')))
                      //             .toList(),
                      //       ),
                      //     )
                      //     .toList(),
                      rows: [
                        ...processRows().map(
                          (row) => DataRow(
                            cells: columns
                                .where((col) => !hiddenColumns.contains(col))
                                .map((col) => DataCell(
                                      Text(row[col]?.toString() ?? ''),
                                    ))
                                .toList(),
                          ),
                        ),
                        DataRow(
                          color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey.withOpacity(0.3),
                          ),
                          cells: columns
                              .where((col) => !hiddenColumns.contains(col))
                              .map(
                                (col) => DataCell(
                                  col == 'acre' || col == 'trees'
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
                        ),
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
