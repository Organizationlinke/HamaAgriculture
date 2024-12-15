import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:supabase_flutter/supabase_flutter.dart';

class ExportdataPage extends StatefulWidget {
  final int ScreenID;
  ExportdataPage({
    super.key,
    required this.ScreenID,
  });
  @override
  _ExportdataPageState createState() => _ExportdataPageState();
}

class _ExportdataPageState extends State<ExportdataPage> {
  final supabase = Supabase.instance.client;

  TextEditingController dateController = TextEditingController();
  TextEditingController weekController = TextEditingController();
  TextEditingController qtyController = TextEditingController();

  List<Map<String, dynamic>> Season = [];
  List<Map<String, dynamic>> Crops = [];
  List<Map<String, dynamic>> Size = [];
  List<double> sizeQTY = [];
  late List<TextEditingController> sizeControllers;
  bool _isButtonDisabled = false;
  String? selectedSeasonId;
  String? selectedCropId;
  String? selectedSizeId;
  String? selectedSizeParant;

  @override
  void initState() {
    super.initState();
    fetchSeason();
    fetchCrops();
    if (widget.ScreenID > 0) {
      loadDataForEdit(widget.ScreenID);
    }
  }

  @override
  void dispose() {
    for (var controller in sizeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double calculateTotal(List<double> percentages, double estimation) {
    return percentages.fold(0.0, (sum, value) => sum + (value * estimation));
  }

  Future<void> loadDataForEdit(int id) async {
    try {
      final response = await supabase
          .rpc('get_export_input')
          .eq('id', id)
          .single(); // لجلب صف واحد فقط

      if (response != null) {
        // تعيين القيم الافتراضية للقوائم
        selectedSizeParant = response['sizeparant']?.toString() ?? '';
        await fetchSizes(); // تأكد من استدعاء القيم الصحيحة هنا
        await fetchSizeData();
        setState(() {
          // تعيين القيم للعناصر
          dateController.text = response['month'] ?? '';
          weekController.text = response['week']?.toString() ?? '';
          selectedCropId = response['cropid']?.toString() ?? '';
          selectedSeasonId = response['seasonid']?.toString() ?? '';

          // qtyController.text = response['qty']?.toString() ?? '';
        });

        // // التحقق من تطابق القيم مع القوائم
        // if (!Size.any((sized) => sized.value == selectedSizeId)) {
        //   selectedSizeId = Size.isNotEmpty ? Size.first.value : null;
        // }
      } else {
        print('Error: No data found for id $id');
      }
    } catch (error) {
      print('Error loading data: $error');
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

  Future<void> fetchCrops() async {
    final response = await supabase
        .from('MenuData')
        .select('id, Name, Parant')
        .eq('Type', 4);
    setState(() {
      Crops = (response as List)
          .map((e) => {
                'id': e['id'].toString(),
                'Name': e['Name'],
                'Parant': e['Parant'].toString(),
              })
          .toList();
    });
  }

  Future<void> fetchSizes() async {
    final response = await supabase
        .from('MenuData')
        .select('id, Name,KG008,KG015')
        .eq('Type', 6)
        .eq('Parant', selectedSizeParant!)
        .order('id', ascending: true);
    setState(() {
      Size = List<Map<String, dynamic>>.from(response);
      sizeQTY = List<double>.filled(Size.length, 0.0);
      sizeControllers =
          List.generate(Size.length, (index) => TextEditingController());
    });

    setState(() {});
  }

  Future<void> saveData() async {
    if (dateController.text.isEmpty ||
        weekController.text.isEmpty ||
        selectedCropId == null ||
        selectedSeasonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء تعبئة جميع الحقول')),
      );
      return;
    }

    final data = {
      'Month': dateController.text,
      'Week': int.parse(weekController.text),
      'Crop': selectedCropId,
      'Season': selectedSeasonId,

      // 'QTY': double.parse(qtyController.text),
      'type': 2,
    };

    try {
      if (widget.ScreenID > 0) {
        // تعديل البيانات
        await supabase
            .from('ExportPlan')
            .update(data)
            .eq('id', widget.ScreenID);

        await supabase
            .from('ExportBySize')
            .delete()
            .eq('ExportPlan_id', widget.ScreenID);
        for (int i = 0; i < Size.length; i++) {
          await supabase.from('ExportBySize').upsert({
            'ExportPlan_id': widget.ScreenID,
            'Size_id': Size[i]['id'],
            'QTY': sizeQTY[i],
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('تم تحديث البيانات بنجاح!'),
              backgroundColor: Colors.green),
        );
      } else {
        // إضافة بيانات جديدة
        final response =
            await supabase.from('ExportPlan').insert(data).select().single();

        final newID = response['id'];
        print('newID:$newID');
        for (int i = 0; i < Size.length; i++) {
          await supabase.from('ExportBySize').insert({
            'ExportPlan_id': newID,
            'Size_id': Size[i]['id'],
            'QTY': sizeQTY[i],
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('تم حفظ البيانات بنجاح!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء حفظ البيانات: $e')),
      );
    }
  }

  Future<void> fetchSizeData() async {
    try {
      final sizesResponse = await supabase
          .from('ExportBySize')
          .select('Size_id, QTY')
          .eq('ExportPlan_id', widget.ScreenID);
      sizeQTY = List<double>.filled(Size.length, 0.0);

      for (var size in sizesResponse) {
        final index = Size.indexWhere((s) => s['id'] == size['Size_id']);
        if (index != -1) {
          sizeQTY[index] = size['QTY'];
          sizeControllers[index].text = size['QTY'].toString();
        }
      }

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('Export Plan')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedSeasonId,
                      hint: Text('Select Season'),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Select Season'),
                        ),
                        ...Season.map((season) => DropdownMenuItem<String>(
                              value: season['id'],
                              child: Text(season['Name']),
                            ))
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
                      value: selectedCropId,
                      hint: Text('Select Crop'),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Select Crop'),
                        ),
                        ...Crops.map((crop) => DropdownMenuItem<String>(
                              value: crop['id'],
                              child: Text(crop['Name']),
                            ))
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCropId = value;
                          // البحث عن الصنف المختار واستخراج قيمة Parant
                          final selectedCrop =
                              Crops.firstWhere((crop) => crop['id'] == value);
                          selectedSizeParant = selectedCrop['Parant'];

                          fetchSizes();
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: 'Select date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: weekController,
                      decoration: InputDecoration(labelText: 'Week'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^([1-9]|[1-4][0-9]|5[0-4])$')),
                      ],
                    ),
                  ),
                ],
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
                        child: SizedBox(
                          width: double.infinity,
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
                                DataColumn(
                                    label: Expanded(child: Text('كود الحجم'))),
                                DataColumn(
                                    label: Expanded(child: Text('KG008'))),
                                DataColumn(
                                    label: Expanded(child: Text('KG015'))),
                                DataColumn(
                                    label: Expanded(child: Text('الكمية'))),
                              ],
                              rows: [
                                ...Size.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> size = entry.value;
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
                                              sizeQTY[index] =
                                                  double.tryParse(value) ?? 0.0;
                                            });
                                          },
                                          decoration:
                                              InputDecoration(hintText: '0.0'),
                                        ),
                                      ),
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
                                      calculateTotal(sizeQTY, 1)
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
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isButtonDisabled
                    ? null // تعطيل الزر
                    : () async {
                        setState(() {
                          _isButtonDisabled = true; // تعطيل الزر بعد الضغط
                        });
                        try {
                          await saveData(); // تنفيذ العملية
                          Navigator.pop(
                              context, true); // التنقل بعد انتهاء العملية
                        } finally {
                          setState(() {
                            _isButtonDisabled = false; // إعادة تمكين الزر
                          });
                        }
                      },
                // onPressed: () async {
                //   await saveData();
                //   Navigator.pop(context, true);
                // },
                child: Text('Save'),
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
