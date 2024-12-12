import 'package:flutter/material.dart';
import 'package:inspection_app/tools/FarmFillter.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InputDataPage extends StatefulWidget {
  final int ScreenID;
  final int SubAreaId;
  InputDataPage({
    super.key,
    required this.ScreenID,
    required this.SubAreaId,
  });
  @override
  _InputDataPageState createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  TextEditingController committeeEstimationController = TextEditingController();
  TextEditingController committeeNotesController = TextEditingController();

  late List<TextEditingController> defectControllers;
  late List<TextEditingController> sizeControllers;

  String committeeDecision = '';
  bool? Decision;
  List<Map<String, dynamic>> defects = [];
  List<Map<String, dynamic>> sizes = [];
  List<double> defectPercentages = [];
  List<double> sizePercentages = [];
  List<Map<String, dynamic>> dataTableRows = [];
  int selectedSubAreaId = 0;
  int cropgroup = 0;
  List<Map<String, dynamic>> Season = [];
  String? selectedSeasonId;
  double totalPercentages = 0.0;
  // int InputData_ID = 0;
  @override
  void initState() {
    super.initState();

    loadDefects();
    fetchSeason();
    if (widget.ScreenID > 0) {
      fetchExistingData();
      selectedSubAreaId = widget.SubAreaId;
      fetchDataTable();
    }

   
  }

  @override
  void dispose() {
    for (var controller in defectControllers) {
      controller.dispose();
    }
    for (var controller in sizeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> fetchExistingData() async {
    try {
      final response = await supabase
          .from('InputData')
          .select()
          .eq('id', widget.ScreenID)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          selectedSubAreaId = response['subarea_id'];
          committeeEstimationController.text = response['qty'].toString();
          committeeNotesController.text = response['Note'] ?? '';
          Decision = response['decision'];
          committeeDecision = Decision == true ? 'مقبول' : 'مرفوض';
          selectedSeasonId = response['season'].toString();
        });
        fetchDefectAndSizeData();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل تحميل البيانات: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> fetchDefectAndSizeData() async {
    try {
      // جلب البيانات من جدول DefectPercentage
      final defectsResponse = await supabase
          .from('DefectPercentage')
          .select('defect_id, percentage')
          .eq('inputdata_id', widget.ScreenID);
      defectPercentages = List<double>.filled(defects.length, 0.0);

      for (var defect in defectsResponse) {
        final index = defects.indexWhere((d) => d['id'] == defect['defect_id']);
        if (index != -1) {
          defectPercentages[index] = defect['percentage'];
          defectControllers[index].text = defect['percentage'].toString();
        } 
      }

      // جلب البيانات من جدول SizePercentage
      final sizesResponse = await supabase
          .from('SizePercentage')
          .select('size_id, percentage')
          .eq('inputdata_id', widget.ScreenID);
      sizePercentages = List<double>.filled(sizes.length, 0.0);

      for (var size in sizesResponse) {
        final index = sizes.indexWhere((s) => s['id'] == size['size_id']);
        if (index != -1) {
          sizePercentages[index] = size['percentage'];
          sizeControllers[index].text =size['percentage'].toString();
        }
      }

      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل تحميل نسب العيوب والأحجام: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> saveData() async {
    try {
      if (widget.ScreenID > 0) {
        // تحديث البيانات إذا كانت موجودة
        await supabase.from('InputData').update({
          'subarea_id': selectedSubAreaId,
          'qty': committeeEstimationController.text,
          'Note': committeeNotesController.text,
          'decision': Decision,
          'season': selectedSeasonId,
          'Farza': totalPercentages,
          'type':1
        }).eq('id', widget.ScreenID);

        // تحديث الجداول الفرعية
        for (int i = 0; i < defects.length; i++) {
          await supabase.from('DefectPercentage').upsert({
            'inputdata_id': widget.ScreenID,
            'defect_id': defects[i]['id'],
            'percentage': defectPercentages[i],
          });
       
        }
        await supabase
            .from('SizePercentage')
            .delete()
            .eq('inputdata_id', widget.ScreenID);
        for (int i = 0; i < sizes.length; i++) {
          await supabase.from('SizePercentage').upsert({
            'inputdata_id': widget.ScreenID,
            'size_id': sizes[i]['id'],
            'percentage': sizePercentages[i],
          });
     
        }
      } else {
        // إدخال بيانات جديدة
        final response = await supabase
            .from('InputData')
            .insert({
              'subarea_id': selectedSubAreaId,
              'qty': committeeEstimationController.text,
              'Note': committeeNotesController.text,
              'decision': Decision,
              'season': selectedSeasonId,
              'Farza': totalPercentages,
               'type':1
            })
            .select()
            .single();
        final newID = response['id'];

        for (int i = 0; i < defects.length; i++) {
          await supabase.from('DefectPercentage').insert({
            'inputdata_id': newID,
            'defect_id': defects[i]['id'],
            'percentage': defectPercentages[i],
          });
        }
        for (int i = 0; i < sizes.length; i++) {
          await supabase.from('SizePercentage').insert({
            'inputdata_id': newID,
            'size_id': sizes[i]['id'],
            'percentage': sizePercentages[i],
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم حفظ البيانات بنجاح'),
        backgroundColor: Colors.green,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل حفظ البيانات: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> fetchDataTable() async {
    final response = await supabase
        .rpc(
          "get_farms_listsub",
        )
        .eq('subareaid', selectedSubAreaId);
    cropgroup = response[0]['cropparent'] ?? 0;
    await loadSizes();
    setState(() {
      dataTableRows =
          (response as List).map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  Future<void> loadDefects() async {
    final defectsResponse =
        await supabase.from('MenuData').select('id, Name').eq('Type', 5).order('id', ascending: true);

    setState(() {
      defects = List<Map<String, dynamic>>.from(defectsResponse);
      defectPercentages = List<double>.filled(defects.length, 0.0);
      defectControllers =
          List.generate(defects.length, (index) => TextEditingController());
    });
  }

  Future<void> loadSizes() async {
    final sizesResponse = await supabase
        .from('MenuData')
        .select('id, Name,KG008,KG015')
        .eq('Type', 6)
        .eq('Parant', cropgroup).order('id', ascending: true);

    setState(() {
      sizes = List<Map<String, dynamic>>.from(sizesResponse);
      sizePercentages = List<double>.filled(sizes.length, 0.0);
       sizeControllers =
        List.generate(sizes.length, (index) => TextEditingController());
    });
  }

  double calculateTotal(List<double> percentages, double estimation) {
    return percentages.fold(0.0, (sum, value) => sum + (value * estimation));
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

  @override
  Widget build(BuildContext context) {
    double committeeEstimation =
        double.tryParse(committeeEstimationController.text) ?? 0.0;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('شاشة إدخال المعاينة'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'حدد الموسم : ',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      DropdownButton<String>(
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
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: FarmScreen(is_finished: true,seasonid:0),
                        ),
                      );
                      selectedSubAreaId = result;
                      await fetchDataTable();
                    },
                    child: Text('تحميل المنطقة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTablebackHedar,
                      foregroundColor: ColorTableForeHedar,
                      // لون الزر
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              // الجزء العلوي
              SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTableTheme(
                    data: DataTableThemeData(
                        headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => ColorTablebackHedar
                            // Colors.blue.withOpacity(0.1), // لون رأس الأعمدة
                            ),
                        headingTextStyle: TextStyle(
                          color: ColorTableForeHedar, // لون النص في رأس الأعمدة
                          fontWeight: FontWeight.bold,
                        ),
                        headingRowHeight: 40),
                    child: DataTable(
                      columnSpacing: 16.0,
                      columns: [
                        DataColumn(label: Expanded(child: Text('المزرعة'))),
                        DataColumn(label: Expanded(child: Text('المنطقة'))),
                        DataColumn(label: Expanded(child: Text('المأخذ'))),
                        DataColumn(label: Expanded(child: Text('المحصول'))),
                        DataColumn(
                            label: Expanded(child: Text('المساحة / فدان'))),
                        DataColumn(label: Expanded(child: Text('عدد الشجر'))),
                      ],
                      rows: dataTableRows.asMap().entries.map((entry) {
                        Map<String, dynamic> row = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Text(row['farm'] ?? '')),
                            DataCell(Text(row['area'] ?? '')),
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
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: committeeEstimationController,
                          decoration: InputDecoration(
                            labelText: 'تقدير اللجنة',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: committeeNotesController,
                          decoration: InputDecoration(
                            labelText: 'ملاحظات اللجنة',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
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
                ],
              ),

              SizedBox(height: 16),
              // الجدولان
              Expanded(
                child: Row(
                  children: [
                    // جدول عيوب الثمار
                    Expanded(
                      child: Column(
                        children: [
                          Text('جدول عيوب الثمار',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: const Color.fromARGB(255, 124, 8, 0),
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: SingleChildScrollView(
                              child: DataTableTheme(
                                data: DataTableThemeData(
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) =>
                                                ColorTablebackHedar // لون رأس الأعمدة
                                            ),
                                    headingTextStyle: TextStyle(
                                      color:
                                          ColorTableForeHedar, // لون النص في رأس الأعمدة
                                      fontWeight: FontWeight.bold,
                                    ),
                                    headingRowHeight: 40),
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('اسم العيوب')),
                                    DataColumn(label: Text('النسبة')),
                                    DataColumn(label: Text('الكمية')),
                                  ],
                                  rows: [
                                    ...defects.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      totalPercentages =
                                          calculateTotal(defectPercentages, 1);

                                      Map<String, dynamic> defect = entry.value;
                                      double qty = defectPercentages[index] *
                                          committeeEstimation *
                                          .01;

                                      //  defectControllers[index].text=
                                      //       defectPercentages[index].toString();
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(defect['Name'])),
                                          DataCell(
                                            TextField(
                                              controller:
                                                  defectControllers[index],
                                              onChanged: (value) {
                                                setState(() {
                                                  defectPercentages[index] =
                                                      double.tryParse(value) ??
                                                          0.0;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                  hintText: '0.0'),
                                            ),
                                          ),
                                          DataCell(
                                              Text(qty.toStringAsFixed(2))),
                                        ],
                                      );
                                    }),
                                    DataRow(
                                      cells: [
                                        DataCell(Text(
                                          'إجمالي الكميات',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataCell(Text(
                                          calculateTotal(defectPercentages, 1)
                                              .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataCell(Text(
                                          calculateTotal(defectPercentages,
                                                  committeeEstimation * .01)
                                              .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ],
                                      color: MaterialStateProperty.all(
                                          Colors.grey.shade200),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 16),
                    // جدول نسب الأحجام
                    Expanded(
                      child: Column(
                        children: [
                          Text('جدول نسب الأحجام',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: const Color.fromARGB(255, 124, 8, 0),
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: SingleChildScrollView(
                              child: DataTableTheme(
                                data: DataTableThemeData(
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                      (states) =>
                                          ColorTablebackHedar, // لون رأس الأعمدة
                                    ),
                                    headingTextStyle: TextStyle(
                                      color:
                                          ColorTableForeHedar, // لون النص في رأس الأعمدة
                                      fontWeight: FontWeight.bold,
                                    ),
                                    headingRowHeight: 40),
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('كود الحجم')),
                                    DataColumn(label: Text('KG008')),
                                    DataColumn(label: Text('KG015')),
                                    DataColumn(label: Text('النسبة')),
                                    DataColumn(label: Text('الكمية')),
                                  ],
                                  rows: [
                                    ...sizes.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      Map<String, dynamic> size = entry.value;
                                      double qty = sizePercentages[index] *
                                          committeeEstimation *
                                          .01;
                                      // TextEditingController size_controller =
                                      //     TextEditingController();
                                      // size_controller.text =
                                      //     sizePercentages[index].toString();
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(size['Name'])),
                                          DataCell(Text(size['KG008'])),
                                          DataCell(Text(size['KG015'])),
                                          DataCell(
                                            TextField(
                                              controller: sizeControllers[index],
                                              onChanged: (value) {
                                                setState(() {
                                                  sizePercentages[index] =
                                                      double.tryParse(value) ??
                                                          0.0;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                  hintText: '0.0'),
                                            ),
                                          ),
                                          DataCell(
                                              Text(qty.toStringAsFixed(2))),
                                        ],
                                      );
                                    }),
                                    DataRow(
                                      cells: [
                                        DataCell(Text(
                                          'إجمالي الكميات',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataCell(Text('')),
                                        DataCell(Text('')),
                                        // DataCell(Text('')),
                                        DataCell(Text(
                                          calculateTotal(sizePercentages, 1)
                                              .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataCell(Text(
                                          calculateTotal(sizePercentages,
                                                  committeeEstimation * .01)
                                              .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ],
                                      color: MaterialStateProperty.all(
                                          Colors.grey.shade200),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  await saveData();
                  Navigator.pop(context, true);
                },
                child: Text('حفظ البيانات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTablebackHedar,
                  foregroundColor: ColorTableForeHedar,
                  // لون الزر
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
