import 'package:flutter/material.dart';
import 'package:inspection_app/tools/FarmFillter.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:supabase_flutter/supabase_flutter.dart';

class ActualRaw extends StatefulWidget {
  final int ScreenID;
  final int SubAreaId;
  ActualRaw({
    super.key,
    required this.ScreenID,
    required this.SubAreaId,
  });
  @override
  _ActualRawState createState() => _ActualRawState();
}

class _ActualRawState extends State<ActualRaw> {
  final SupabaseClient supabase = Supabase.instance.client;

  TextEditingController committeeEstimationController = TextEditingController();
  TextEditingController committeeNotesController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  bool Isfinished = false;

  List<Map<String, dynamic>> dataTableRows = [];
  int selectedSubAreaId = 0;
  int cropgroup = 0;
  List<Map<String, dynamic>> Season = [];
  String? selectedSeasonId;
  double totalPercentages = 0.0;
  bool _isButtonDisabled = false;
  // int InputData_ID = 0;
  @override
  void initState() {
    super.initState();

    fetchSeason();
    if (widget.ScreenID > 0) {
      fetchExistingData();
      selectedSubAreaId = widget.SubAreaId;
      fetchDataTable();
    }
  }

  Future<void> update_finished_area() async {
    if (selectedSeasonId != null) {
      await supabase
          .from('InputData')
          .update({'is_finished': Isfinished})
          .eq('subarea_id', selectedSubAreaId)
          .eq('season', selectedSeasonId!);
    }
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
          dateController.text = response['date'] ?? '';
          Isfinished = response['is_finished'] ?? false;
          selectedSeasonId = response['season'].toString();
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل تحميل البيانات: $error'),
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
          'date': dateController.text,
          'season': selectedSeasonId,
          'Farza': totalPercentages,
          'type': 2
        }).eq('id', widget.ScreenID);
      } else {
        // إدخال بيانات جديدة
        final response = await supabase
            .from('InputData')
            .insert({
              'subarea_id': selectedSubAreaId,
              'qty': committeeEstimationController.text,
              'Note': committeeNotesController.text,
              'date': dateController.text,
              'season': selectedSeasonId,
              'Farza': totalPercentages,
              'type': 2
            })
            .select()
            .single();
      }
      await update_finished_area();
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
    setState(() {
      dataTableRows =
          (response as List).map((e) => Map<String, dynamic>.from(e)).toList();
    });
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('شاشة تسجيل الحصاد الفعلي'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
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
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'تاريخ الحصاد: ',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 250,
                        child: TextField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'Select date',
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
                                dateController.text = DateFormat('yyyy-MM-dd')
                                    .format(selectedDate);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedSeasonId != null) {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: FarmScreen(
                                is_finished: false,
                                seasonid: int.parse(selectedSeasonId!)),
                          ),
                        );
                        selectedSubAreaId = result;
                        await fetchDataTable();
                      } else {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('تنبيه'),
                            content: Text('يجب اختيار الموسم أولاً'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('حسناً'),
                              ),
                            ],
                          ),
                        );
                      }
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
                            labelText: 'كمية الحصاد',
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
                            labelText: 'ملاحظات ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Checkbox(
                      value: Isfinished,
                      onChanged: (value) {
                        setState(() {
                          Isfinished = value!;
                          print(Isfinished);
                          ;
                        });
                      }),
                  SizedBox(
                    width: 20,
                  ),
                  Text('هل تم الانتهاء من قطف هذه القطعه')
                ],
              ),
              SizedBox(
                height: 20,
              ),
              if (Isfinished)
                Text(
                  'لن تستطيع التسجيل علي هذه القطعه مره اخري !!!',
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(
                height: 40,
              ),
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
