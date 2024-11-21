import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/Basic/AddSubArea.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddArea extends StatefulWidget {
 final int farmid;
   AddArea({
    super.key,
    required this.farmid,
  });
  @override
  State<AddArea> createState() => _AddAreaState();
}

class _AddAreaState extends State<AddArea> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> farms_list = [];
  int area_id=0;

  Future<void> FarmsList() async {
    try {
      final response = await supabase.from('MenuData').select().eq('Type', 2).eq('Parant',widget. farmid);
     
      if (response != null && response is List) {
        setState(() {
          farms_list = response.map((item) => item as Map<String, dynamic>).toList();
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
  void didUpdateWidget(covariant AddArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.farmid != widget.farmid) {
      // عندما يتغير farmid يتم إعادة تحميل المناطق
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
            Row(
               mainAxisAlignment: MainAxisAlignment.start,
           crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text('اسم المنطقه',style: TextStyle(fontSize: 20,),),
                      ListView.builder(
                          shrinkWrap: true,
                        itemCount: farms_list.length,
                        itemBuilder: (context, index) {
                          final list = farms_list[index];
                          return ListTile(
                            title: Text(list['Name'] ?? ''),
                             onTap: () {
                              setState(() {
                                area_id = list['id'];
                              });
                            },
                          );
                        },
                      ),
                      
                    ],
                  ),
                ),
                Expanded(child: AddSubArea(Areaid: area_id))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
