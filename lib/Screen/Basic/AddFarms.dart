import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/Basic/AddArea.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddFarms extends StatefulWidget {
  @override
  State<AddFarms> createState() => _AddFarmsState();
}

class _AddFarmsState extends State<AddFarms> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> farms_list = [];
  int farm_id = 0;

  Future<void> FarmsList() async {
    try {
      final response = await supabase.from('MenuData').select().eq('Type', 1);

      if (response != null && response is List) {
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
                      Text('اسم المزرعة',style: TextStyle(fontSize: 20,),),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: farms_list.length,
                        itemBuilder: (context, index) {
                          final list = farms_list[index];
                  
                          return ListTile(
                            title: Text(list['Name'] ?? ''),
                            onTap: () {
                              setState(() {
                                farm_id = list['id'];
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(child: AddArea(farmid: farm_id))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
