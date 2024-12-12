import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/Basic/AddArea.dart';
import 'package:inspection_app/Screen/Basic/AddSize.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddFarms extends StatefulWidget {
  final int ScreenID;
  final int ScreenType;
  final String ScreenName;
  AddFarms({
    super.key,
    required this.ScreenID,
    required this.ScreenName,
    required this.ScreenType,
  });
  @override
  State<AddFarms> createState() => _AddFarmsState();
}

class _AddFarmsState extends State<AddFarms> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> farms_list = [];

  int farm_id = 0;
  final TextEditingController _addController = TextEditingController();
  bool add = false;
  bool edit = false;
  bool delete = false;
  int farm_level=0;
  Future<void> AddData() async {
    if (edit) {
      await supabase.from('MenuData').update({
        'Name': _addController.text,
      }).eq('id', farm_id);
    } else if (delete) {
      await supabase.from('MenuData').delete().eq('id', farm_id);
    } else {
      await supabase
          .from('MenuData')
          .insert({'Name': _addController.text, 'Type': widget.ScreenID});
    }
  }

  Future<void> FarmsList() async {
    try {
      final response =
          await supabase.from('MenuData').select().eq('Type', widget.ScreenID);

      if (response.isNotEmpty) {
        setState(() {
          farms_list =
              response.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        print('No data received or data format is unexpected.');
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
  void didUpdateWidget(covariant AddFarms oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ScreenID != widget.ScreenID) {
      // عندما يتغير farmid يتم إعادة تحميل المناطق
      farms_list.clear();
      FarmsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  SizedBox(
                    width: 200,
                    height: double.infinity,
                    // height: MediaQuery.of(context).size.height * .7,
                    child: SingleChildScrollView(
                      child: Column(
                        
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                // اسم الصفحة
                                widget.ScreenName,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                // اضافة عنصر
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

                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _addController,
                                      ),
                                    ),
                                  ],
                                ),
                                //الحفظ والحذف
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
                                              subtitle:list['FarmLevel']!=null?Text('Level:${list['FarmLevel']}'):null ,
                                    selected: farm_id ==
                                        list['id'], // تحديد العنصر عند النقر
                                    selectedTileColor: Colors.grey.shade300,
                                    onTap: () {
                                      setState(() {
                                        farm_id = list['id'];
                                        farm_level=list['FarmLevel']!=null?list['FarmLevel']:0;
                                      });
                                    },
                                  ),
                                  if (farm_id == list['id'])
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
                                              )
                                              )
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
                  if (widget.ScreenID == 1 )
                    Expanded(child: AddArea(farmid: farm_id,ScreenType: 2,ScreenName: 'اسم المنطقه',farm_level:farm_level))
                   else if (widget.ScreenID == 8 &&widget.ScreenType==0)
                    Expanded(child: AddArea(farmid: farm_id,ScreenType: 4,ScreenName: 'الصنف الفرعي',farm_level: farm_level,))
                      else if (widget.ScreenID == 8 &&widget.ScreenType==6)
                    Expanded(child: AddSize(farmid: farm_id,ScreenType: 6,ScreenName: 'تعريف الحجم',))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
