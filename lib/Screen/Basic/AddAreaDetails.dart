import 'package:flutter/material.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddAreaDetails extends StatefulWidget {
  final int subAreaId;
  const AddAreaDetails({Key? key, required this.subAreaId}) : super(key: key);

  @override
  State<AddAreaDetails> createState() => _AddAreaDetailsState();
}

class _AddAreaDetailsState extends State<AddAreaDetails> {
  final supabase = Supabase.instance.client;

  // Controllers
  final TextEditingController _areaCountController = TextEditingController();
  final TextEditingController _treesCountController = TextEditingController();

  // State variables
  List<Map<String, dynamic>> farmsList = [];
  List<Map<String, dynamic>> cropList = [];
  int cropId = 0;
  String cropName = '';
  bool isLoading = false;

  // Flags for operations

  bool isEdit = false;
  bool isDelete = false;

  // Load crop list
  Future<void> _loadCrops() async {
    try {
      // تحميل قائمة المحاصيل من الجدول
      final response =
          await supabase.from('MenuData').select('id, Name').eq('Type', 4);

      setState(() {
        cropList = List<Map<String, dynamic>>.from(response);

        // تحديث اسم المحصول بناءً على `cropId`
        cropName = _getCropNameById(cropId);
      });
    } catch (error) {
      print('Error loading crops: $error');
    }
  }

  String _getCropNameById(int id) {
    // البحث عن اسم المحصول بناءً على `id`، وإذا لم يتم العثور على المحصول يتم عرض النص الافتراضي
    final matchedCrop = cropList.firstWhere(
      (crop) => crop['id'] == id,
      orElse: () => {'Name': 'اختر نوع المحصول'},
    );
    return matchedCrop['Name'] ?? 'اختر نوع المحصول';
  }

  void _onCropSelected(dynamic value) {
    if (value != null && value is String) {
      // تحديث `cropId` بناءً على المحصول المختار
      final selectedCrop = cropList.firstWhere(
        (crop) => crop['Name'] == value,
        orElse: () => {'id': 0},
      );
      setState(() {
        cropId = selectedCrop['id'] ?? 0;
      });
    }
  }

  // Add, Edit, or Delete data
  Future<void> _saveData() async {
    try {
      if (isEdit) {
        await supabase.from('MenuData').update({
          'Crop': cropId,
          'Acre': _areaCountController.text,
          'Trees': _treesCountController.text,
        }).eq('id', widget.subAreaId);
      } else if (isDelete) {
        await supabase.from('MenuData').update({
          'Crop': '0',
          'Acre': '0',
          'Trees': '0',
        }).eq('id', widget.subAreaId);
      }
      await _refreshFarmsList();
      await _loadCrops();
      setState(() {});
    } catch (error) {
      print('Error saving data: $error');
    }
  }

  // Load farms list
  Future<void> _refreshFarmsList() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('MenuData')
          .select()
          .eq('Type', 3)
          .eq('id', widget.subAreaId);

      setState(() {
        // تحديث قائمة المزارع
        farmsList = List<Map<String, dynamic>>.from(response);

        // إذا كانت القائمة تحتوي على بيانات، قم بتحديث الحقول
        if (farmsList.isNotEmpty) {
          _treesCountController.text = farmsList[0]['Trees']?.toString() ?? '';
          _areaCountController.text = farmsList[0]['Acre']?.toString() ?? '';
          cropId = farmsList[0]['Crop'];
          cropName = _getCropNameById(cropId);
        } else {
          // إذا كانت فارغة، أعد تعيين الحقول
          _treesCountController.clear();
          _areaCountController.clear();
          cropId = 0;
          cropName = '';
        }
      });
    } catch (error) {
      print('Error loading farms: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCrops();
    _refreshFarmsList();
  }

  @override
  void didUpdateWidget(covariant AddAreaDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subAreaId != widget.subAreaId) {
      _refreshFarmsList();

      // cropName = '';
      // _loadCrops();
    }
  }

  // Confirmation Dialog
  Future<void> _showConfirmationDialog(
      String message, VoidCallback onConfirm) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: widget.subAreaId > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'اضافة التفاصيل',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.add_box,
                        color: Colors.blue,
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Crop Dropdown
                  Row(
                    children: [
                      const Text('اسم الصنف'),
                      const SizedBox(width: 38),
                      SizedBox(
                        width: 200,
                        child: DropdownSearch<dynamic>(
                          onChanged: _onCropSelected,
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            textAlign: TextAlign.center,
                          ),
                          items: cropList.map((e) => e['Name']).toList(),
                          selectedItem:
                              cropName.isEmpty ? 'حدد نوع الصنف' : cropName,
                          popupProps:
                              const PopupProps.menu(showSearchBox: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Acre Field
                  Row(
                    children: [
                      const Text('المساحة /فدان'),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _areaCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Trees Count Field
                  Row(
                    children: [
                      const Text('عدد الأشجار'),
                      const SizedBox(width: 38),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _treesCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _showConfirmationDialog(
                              'هل تريد تعديل البيانات؟',
                              () {
                                setState(() {
                                  isEdit = true;
                                  isDelete = false;
                                });
                                _saveData();
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text('حفظ'),
                              SizedBox(width: 10),
                              Icon(Icons.save)
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _showConfirmationDialog(
                              'هل تريد حذف البيانات؟',
                              () {
                                setState(() {
                                  isEdit = false;
                                  isDelete = true;
                                });
                                _saveData();
                              },
                            );
                          },
                          child: Row(
                            children: [
                              const Text('حذف'),
                              SizedBox(width: 10),
                              Icon(Icons.delete)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
