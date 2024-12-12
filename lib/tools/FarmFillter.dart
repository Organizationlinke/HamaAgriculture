

import 'package:flutter/material.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmScreen extends StatefulWidget {
  final bool is_finished;
  final int seasonid;
  FarmScreen({
    super.key,
    required this.is_finished,
    required this.seasonid
  });
  @override
  _FarmScreenState createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Variables for dropdowns
  List<Map<String, dynamic>> farms = [];
  List<Map<String, dynamic>> areas = [];
  List<Map<String, dynamic>> subAreas = [];

  String? selectedFarmId;
  String? selectedAreaId;
  String? selectedSubAreaId;
int?SubAreaID;
 int? selectedRowIndex;
  // Variables for datatable
  List<Map<String, dynamic>> dataTableRows = [];

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
                'id': e['id'].toString(), // تحويل id إلى String
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
                'id': e['id'].toString(), // تحويل id إلى String
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
                'id': e['id'].toString(), // تحويل id إلى String
                'Name': e['Name'],
              })
          .toList();
    });
  }

  Future<void> fetchDataTable() async {
    final response = await supabase
        .rpc(widget.is_finished?
          "get_farms_listsub":"get_farms_list_is_finished",
        ).eq(widget.seasonid>0?'seasonid':'test', widget.seasonid>0?widget.seasonid:0)
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('Farm Management')),
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
                                value: farm['id'], // `id` الآن String
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
                      foregroundColor: Colors.white
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
                             ColorTablebackHedar // لون رأس الأعمدة
                        ),
                        headingTextStyle: TextStyle(
                          color:ColorTableForeHedar, // لون النص في رأس الأعمدة
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: 
                      DataTable(
                        columnSpacing: 16.0,
                        columns: [
                          DataColumn(label: Expanded(child: Text('اختيار'))),
                          DataColumn(label: Expanded(child: Text('المزرعة'))),
                          DataColumn(label: Expanded(child: Text('المنطقة'))),
                           DataColumn(label: Expanded(child: Text('الجهيره'))),
                          DataColumn(label: Expanded(child: Text('المأخذ'))),
                          DataColumn(label: Expanded(child: Text('المحصول'))),
                          DataColumn(
                              label: Expanded(child: Text('المساحة / فدان'))),
                          DataColumn(label: Expanded(child: Text('عدد الشجر'))),
                        ],
                        rows: dataTableRows.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> row = entry.value;
                      return DataRow(
                        selected: selectedRowIndex == index,
                        onSelectChanged: (bool? selected) {
                          setState(() {
                            selectedRowIndex = selected == true ? index : null;
                          });
                        },
                        cells: [
                          DataCell(Checkbox(
                            value: selectedRowIndex == index,
                            onChanged: (bool? value) {
                              setState(() {
                                selectedRowIndex = value == true ? index : null;
                              });
                            },
                          )),
                          DataCell(Text(row['farm'] ?? '')),
                          DataCell(Text(row['area'] ?? '')),
                          DataCell(Text(row['reservoir'] ?? '')),
                          DataCell(Text(row['subarea'] ?? '')),
                          DataCell(Text(row['crop'] ?? '')),
                          DataCell(Text(row['acre']?.toString() ?? '')),
                          DataCell(Text(row['trees']?.toString() ?? '')),
                        ],
                      );
                    }).toList(),
                        
      
                      ),
                  
                    ),
                  ),
                ),
              ),
               SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (selectedRowIndex != null) {
                    setState(() {
                      SubAreaID = dataTableRows[selectedRowIndex!]['subareaid'];
                       Navigator.pop(context, SubAreaID); 
                    });
                  }
                },
                child: Text('موافق'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
