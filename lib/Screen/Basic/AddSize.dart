import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/Basic/AddSubArea.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddSize extends StatefulWidget {
  final int farmid;
  final int ScreenType;
  final String ScreenName;
  AddSize({
    super.key,
    required this.farmid,
    required this.ScreenType,
    required this.ScreenName,
  });
  @override
  State<AddSize> createState() => _AddSizeState();
}

class _AddSizeState extends State<AddSize> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> farms_list = [];
  int area_id = 0;
  final TextEditingController _CodeController = TextEditingController();
  final TextEditingController _KG008Controller = TextEditingController();
  final TextEditingController _KG015Controller = TextEditingController();
  bool add = false;
  bool edit = false;
  bool delete = false;

  Future<void> AddData() async {
    if (edit) {
      await supabase.from('MenuData').update({
        'Name': _CodeController.text,
        'KG008': _KG008Controller.text,
        'KG015': _KG015Controller.text,
      }).eq('id', area_id);
    } else if (delete) {
      await supabase.from('MenuData').delete().eq('id', area_id);
    } else {
      await supabase.from('MenuData').insert({
        'Name': _CodeController.text,
        'Type': widget.ScreenType,
        'Parant': widget.farmid,
        'KG008': _KG008Controller.text,
        'KG015': _KG015Controller.text,
      });
    }
  }

  Future<void> FarmsList() async {
    try {
      final response = await supabase
          .from('MenuData')
          .select()
          .eq('Type', widget.ScreenType)
          .eq('Parant', widget.farmid).order('id', ascending: true);

      if (response.isNotEmpty || response.length > 0) {
        setState(() {
          farms_list =
              response.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        setState(() {
          farms_list.clear();
          //  print('No data received or data format is unexpected.');
        });
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    FarmsList();
  }

  @override
  void didUpdateWidget(covariant AddSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.farmid != widget.farmid) {
      // عندما يتغير farmid يتم إعادة تحميل المناطق
      farms_list.clear();
      FarmsList();
      area_id = 0;
      add = false;
      _CodeController.text = '';
      _KG015Controller.text = '';
      _KG008Controller.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 500,
                height: MediaQuery.of(context).size.height * .7,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.farmid > 0)
                        Row(
                          children: [
                            Text(
                              widget.ScreenName,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _CodeController.text = '';
                                    _KG015Controller.text = '';
                                    _KG008Controller.text = '';
                                    add = true;
                                    edit = false;
                                    delete = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.green,
                                ))
                          ],
                        ),
                      if (add)
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _CodeController,
                                    decoration: InputDecoration(
                                      labelText: 'Code',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                /////// لو دي شاشة الحجم
                                Expanded(
                                  child: TextField(
                                    controller: _KG015Controller,
                                    decoration: InputDecoration(
                                      labelText: 'KG015',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _KG008Controller,
                                    decoration: InputDecoration(
                                      labelText: 'KG008',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      await AddData();
                                      await FarmsList();
                                      setState(() {
                                        _CodeController.text = '';
                                        _KG015Controller.text = '';
                                        _KG008Controller.text = '';
                                        add = false;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.save,
                                      color: Colors.green,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        add = false;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      if (widget.farmid > 0)
                        DataTableTheme(
                          data: DataTableThemeData(
                            headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.blue
                                  .withOpacity(0.1), // لون رأس الأعمدة
                            ),
                            headingTextStyle: TextStyle(
                              color: Colors.blue, // لون النص في رأس الأعمدة
                              fontWeight: FontWeight.bold,
                            ),
                            headingRowHeight: 40
                          ),
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('الاسم')),
                              DataColumn(label: Text('KG015')),
                              DataColumn(label: Text('KG008')),
                              DataColumn(label: Text('إجراءات')),
                            ],
                            rows: farms_list.map((list) {
                              return DataRow(
                                selected: area_id ==
                                    list['id'], // تحديد العنصر عند النقر
                                cells: [
                                  DataCell(Text(list['Name'] ?? '')),
                                  DataCell(Text(list['KG015'] ?? '')),
                                  DataCell(Text(list['KG008'] ?? '')),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,size: 20,
                                            color: Colors.blue),
                                        onPressed: () {
                                          setState(() {
                                            add = true;
                                            edit = true;
                                            delete = false;
                                            _CodeController.text =
                                                list['Name'] ?? '';
                                            _KG008Controller.text =
                                                list['KG008'] ?? '';
                                            _KG015Controller.text =
                                                list['KG015'] ?? '';
                                            area_id = list['id'];
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,size: 20,
                                            color: Colors.red),
                                        onPressed: () {
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
                                                          .pop();
                                                    },
                                                    child: Text('إلغاء'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() async {
                                                        add = false;
                                                        edit = false;
                                                        delete = true;
                                                        await AddData(); // تنفيذ العملية
                                                        await FarmsList(); // تحديث البيانات
                                                      });
                                                    },
                                                    child: Text('تأكيد'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),

               
                    ],
                  ),
                ),
              ),
              if (widget.ScreenType == 2)
                Expanded(child: AddSubArea(Areaid: area_id))
            ],
          ),
        ],
      ),
    );
  }
}
