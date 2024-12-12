import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/Basic/AddSubArea.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddArea extends StatefulWidget {
  final int farmid;
  final int ScreenType;
  final String ScreenName;
  final int farm_level;
  AddArea({
    super.key,
    required this.farmid,
    required this.ScreenType,
    required this.ScreenName,
    required this.farm_level,
  });
  @override
  State<AddArea> createState() => _AddAreaState();
}

class _AddAreaState extends State<AddArea> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> farms_list = [];
  int area_id = 0;
  final TextEditingController _addController = TextEditingController();
  bool add = false;
  bool edit = false;
  bool delete = false;

  Future<void> AddData() async {
    if (edit) {
      await supabase.from('MenuData').update({
        'Name': _addController.text,
      }).eq('id', area_id);
    } else if (delete) {
      await supabase.from('MenuData').delete().eq('id', area_id);
    } else {
      await supabase.from('MenuData').insert({
        'Name': _addController.text,
        'Type': widget.ScreenType,
        'Parant': widget.farmid
      });
    }
  }

  Future<void> FarmsList() async {
    try {
      final response = await supabase
          .from('MenuData')
          .select()
          .eq('Type', widget.ScreenType)
          .eq('Parant', widget.farmid);

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
  void didUpdateWidget(covariant AddArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.farmid != widget.farmid) {
      // عندما يتغير farmid يتم إعادة تحميل المناطق
      farms_list.clear();
      FarmsList();
      area_id = 0;
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
                width: 200,
                // height: MediaQuery.of(context).size.height * .7,
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
                                    _addController.text = '';
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
                            TextField(
                              controller: _addController,
                             
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      await AddData();
                                      await FarmsList();
                                      setState(() {
                                        _addController.text = '';
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
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: farms_list.length,
                        itemBuilder: (context, index) {
                          final list = farms_list[index];
                          return Stack(
                            children: [
                              ListTile(
                                title: Text(list['Name'] ?? ''),
                                selected: area_id ==
                                    list['id'], // تحديد العنصر عند النقر
                                selectedTileColor: Colors
                                    .grey.shade300, // تغيير اللون عند التحديد
                                onTap: () {
                                  setState(() {
                                    area_id = list['id'];
                                  });
                                },
                              ),
                              if (area_id == list['id'])
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              add = true;
                                              edit = true;
                                              delete = false;
                                              _addController.text =
                                                  list['Name'] ?? '';
                                            });
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.blue,
                                          )),
                                      IconButton(
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
                                                            .pop(); // إغلاق مربع الحوار بدون تنفيذ
                                                      },
                                                      child: Text('إلغاء'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context)
                                                            .pop(); // إغلاق مربع الحوار
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
                                          icon: Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ))
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.ScreenType == 2 && widget.farm_level==3)
                Expanded(child: AddSubArea(Areaid: area_id))
             else   if (widget.ScreenType == 2 && widget.farm_level==4)
                 Expanded(child: AddArea(farmid: area_id, ScreenType: 9, ScreenName: 'الجهيره', farm_level: 3))
                 else if  (widget.ScreenType == 9 && widget.farm_level==3)
                Expanded(child: AddSubArea(Areaid: area_id))
            ],
          ),
        ],
      ),
    );
  }
}
