import 'package:flutter/material.dart';
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

  Future<void> FarmsList() async {
    try {
      final response = await supabase.from('MenuData').select().eq('Type', 3).eq('Parant',widget. Areaid);
     
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
  void didUpdateWidget(covariant AddSubArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.Areaid != widget.Areaid) {
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
        child: Row(
        
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text('اسم الحوشة',style: TextStyle(fontSize: 20,),),
                  ListView.builder(
                      shrinkWrap: true,
                    itemCount: farms_list.length,
                    itemBuilder: (context, index) {
                      final transaction = farms_list[index];
                      return ListTile(
                        title: Text(transaction['Name'] ?? ''),
                      );
                    },
                  ),
                  
                ],
              ),
            ),
         
          ],
        ),
      ),
    );
  }
}
