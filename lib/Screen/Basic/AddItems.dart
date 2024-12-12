import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddItems extends StatefulWidget {
  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> Items_list = [];
  
  int Item_id = 0;
  final TextEditingController _addController = TextEditingController();
  bool add = false;
  bool edit = false;
  bool delete = false;
  Future<void> AddData() async {
    if (edit) {
      await supabase.from('MenuData').update({
        'Name': _addController.text,
      }).eq('id', Item_id);
    } else if (delete) {
      
          await supabase.from('MenuData').delete().eq('id', Item_id);
    } else {
       await supabase
          .from('MenuData')
          .insert({'Name': _addController.text, 'Type': 4});
    }
  }

  Future<void> ItemsList() async {
    try {
      final response = await supabase.from('MenuData').select().eq('Type', 4);

      if (response.isNotEmpty) {
        setState(() {
          Items_list =
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
    ItemsList();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  height: MediaQuery.of(context).size.height * .7,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'اسم الصنف',
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
                                      await ItemsList();
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
                        itemCount: Items_list.length,
                        itemBuilder: (context, index) {
                          final list = Items_list[index];

                          return Stack(
                            children: [
                              ListTile(
                                title: Text(list['Name'] ?? ''),

                                selected: Item_id ==
                                    list['id'], // تحديد العنصر عند النقر
                                selectedTileColor: Colors.grey.shade300,
                                onTap: () {
                                  setState(() {
                                    Item_id = list['id'];
                                  });
                                },
                              ),
                              if (Item_id == list['id'])
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
                                                          await ItemsList(); // تحديث البيانات
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
              
              ],
            ),
          ],
        ),
      ),
    );
  }
}
