import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/Basic/AddAreaDetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddSubArea extends StatefulWidget {
 final int Areaid;
   AddSubArea({
    super.key,
    required this.Areaid,
  });
  @override
  State<AddSubArea> createState() => _AddSubAreaState();
}

class _AddSubAreaState extends State<AddSubArea> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> farms_list = [];
  int subarea_id=0;
   final TextEditingController _addController = TextEditingController();
  bool add = false;
  bool edit = false;
  bool delete = false;
 Future<void> AddData() async {
    if (edit) {
      await supabase.from('MenuData').update({
        'Name': _addController.text,
      }).eq('id', subarea_id);
    } else if (delete) {
      
          await supabase.from('MenuData').delete().eq('id', subarea_id);
    } else {
       await supabase
          .from('MenuData')
          .insert({'Name': _addController.text, 'Type': 3,'Parant':widget. Areaid});
    }
  }
  Future<void> FarmsList() async {
    try {
      final response = await supabase.from('MenuData').select().eq('Type', 3).eq('Parant',widget. Areaid);
     
      if (response.isNotEmpty) {
        setState(() {
          farms_list = response.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        setState(() {
           farms_list.clear();
        print('No data received or data format is unexpected.');
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
  void didUpdateWidget(covariant AddSubArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.Areaid != widget.Areaid) {
      // عندما يتغير farmid يتم إعادة تحميل المناطق
        farms_list.clear();
      FarmsList();
      subarea_id=0;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
                  // height:  MediaQuery.of(context).size.height * .7,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                    if(widget.Areaid>0)  Row(
                            children: [
                              Text(
                                'اسم الحوشة',
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
                                  selected: subarea_id == list['id'], // تحديد العنصر عند النقر
                                  selectedTileColor: Colors.grey.shade300, // تغيير اللون عند التحديد
                                   onTap: () {
                                    setState(() {
                                      subarea_id = list['id'];
                                    });
                                  },
                                ),
                                if (subarea_id == list['id'])
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
                Expanded(child: AddAreaDetails(subAreaId: subarea_id))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
