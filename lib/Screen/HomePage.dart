import 'package:flutter/material.dart';
import 'package:inspection_app/Screen/Basic/AddFarms.dart';
import 'package:inspection_app/Screen/InputData/ExportDataList.dart';
import 'package:inspection_app/Screen/InputData/FarmsInputData.dart';
import 'package:inspection_app/Screen/reports/ReportManager.dart';
import 'package:inspection_app/tools/global.dart';
import 'package:inspection_app/users/PoliciesApp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // التحكم في الشاشة المعروضة
  Widget _currentScreen = HomeScreen();
  bool expand = false;
  final supabase = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    if (userid=='0') {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الشاشة الرئيسية'),
          backgroundColor: Colorapp,
          foregroundColor: Colorforeapp,
        ),
        body: Row(
          children: [
            // القائمة الجانبية الثابتة
            Container(
              width: 250, // عرض القائمة الجانبية
              color: colorlist,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpansionTile(
                            initiallyExpanded: expand,
                            leading: Icon(Icons.data_usage),
                            title: Text('البيانات الأساسية'),
                            children: [
                              ListTile(
                                leading: Icon(Icons.data_usage),
                                title: Text('تعريف المزراع'),
                                onTap: () {
                                  setState(() {
                                    _currentScreen = AddFarms(
                                       key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      ScreenID: 1,
                                      ScreenName: 'اسم المزرعة',
                                      ScreenType: 0,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.data_usage),
                                title: Text('تعريف الاصناف'),
                                onTap: () {
                                  setState(() {
                                    _currentScreen = AddFarms(
                                       key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                        ScreenID: 8,
                                        ScreenName: 'الصنف الرئيسي',
                                        ScreenType: 0);
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.data_usage),
                                title: Text('تعريف عيوب الثمار'),
                                onTap: () {
                                  setState(() {
                                    _currentScreen = AddFarms(

                                       key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                        ScreenID: 5,
                                        ScreenName: 'اسم عيوب الثمار',
                                        ScreenType: 0);
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.data_usage),
                                title: Text('تعريف الاحجام'),
                                onTap: () {
                                  setState(() {
                                    _currentScreen = AddFarms(
                                       key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                        ScreenID: 8,
                                        ScreenName: 'الصنف الرئيسي',
                                        ScreenType: 6);
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.data_usage),
                                title: Text('تعريف المواسم'),
                                onTap: () {
                                  setState(() {
                                    _currentScreen = AddFarms(
                                       key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                        ScreenID: 7,
                                        ScreenName: 'اسم الموسم',
                                        ScreenType: 0);
                                  });
                                },
                              ),
                            ],
                          ),
                          ExpansionTile(
                            initiallyExpanded: expand,
                            leading: Icon(Icons.input),
                            title: Text('شاشات الإدخال'),
                            children: [
                              ListTile(
                                leading: Icon(Icons.input),
                                title: Text('إدخال معاينات المزارع'),
                                onTap: () {
                                  setState(() {
                                    List<String> columns = [
                                      'id',
                                      'season',
                                      'farm',
                                      'area',
                                      'subarea',
                                      'crop',
                                      'acre',
                                      'trees',
                                      'qty',
                                      'decision',
                                      'note'
                                    ];
                                    _currentScreen = FarmsInputData(
                                       key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      columns: columns,
                                      ScreenName: 'جدول معاينات المزارع',
                                      Screenid: 1,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.input),
                                title: Text('تسجيل الحصاد الفعلي'),
                                onTap: () {
                                  setState(() {
                                    List<String> columns = [
                                      'id',
                                      'season',
                                      'date',
                                      'farm',
                                      'area',
                                      'subarea',
                                      'crop',
                                      'acre',
                                      'trees',
                                      'qty',
                                      'note'
                                    ];
                                    _currentScreen = FarmsInputData(
                                       key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      columns: columns,
                                      ScreenName: 'جدول تسجيل الحصاد الفعلي',
                                      Screenid: 2,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.input),
                                title: Text('اوامر البيع الاسبوعية'),
                                onTap: () {
                                  setState(() {
                                    _currentScreen = ExportDataList(
                                      
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                          ExpansionTile(
                            initiallyExpanded: expand,
                            leading: Icon(Icons.report),
                            title: Text('التقارير'),
                            children: [
                              ListTile(
                                leading: Icon(Icons.report),
                                title: Text('بيانات المزارع'),
                                onTap: () {
                                  setState(() {
                                    String ReportName = 'بيانات المزارع';

                                    List<String> GroupColumn = [
                                      'farm',
                                      'area',
                                      'reservoir',
                                      'subarea',
                                      'crop'
                                    ];
                                    List<String> formatColumns = [
                                      'acre',
                                      'trees'
                                    ];
                                    List<String> Num_Columns = [
                                      'sum(acre) as acre',
                                      'sum(trees)as trees'
                                    ];
                                    _currentScreen = ReportManager(
                                      key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      ScreenName: 'get_farms_listsub()',
                                      ScreenId: 5,
                                      exportid: 0,
                                      ReportName: ReportName,
                                      Num_Columns: Num_Columns,
                                      GroupColumn: GroupColumn,
                                      formatColumns: formatColumns,
                                      comitt: false,
                                      farm: true,
                                      season: false,
                                      isSales: false,
                                      ispick: false,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.report),
                                title: Text('تقرير المعاينات بالاحجام '),
                                onTap: () {
                                  setState(() {
                                    String ReportName =
                                        'تقرير المعاينات بالاحجام ';

                                    List<String> GroupColumn = [
                                      'season',
                                      'farm',
                                      'area',
                                      'reservoir',
                                      'subarea',
                                      'crop',
                                      'acre',
                                      'trees',
                                      'qty',
                                      'decision',
                                      'note',
                                      'percentage',
                                      'sizecode',
                                    ];
                                    List<String> Num_Columns = [
                                      'sum(raw_qty) as raw_qty',
                                      'sum(farza_qty) as farza_qty',
                                      'sum(class1) as class1'
                                    ];
                                    List<String> formatColumns = [
                                      'raw_qty',
                                      'farza_qty',
                                      'class1'
                                    ];
                                    _currentScreen = ReportManager(
                                      key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      ScreenName: 'get_input_data_bysize()',
                                      ScreenId: 1,
                                      exportid: 0,
                                      ReportName: ReportName,
                                      Num_Columns: Num_Columns,
                                      GroupColumn: GroupColumn,
                                      formatColumns: formatColumns,
                                      comitt: true,
                                      farm: true,
                                      season: true,
                                      isSales: false,
                                      ispick: false,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.report),
                                title: Text('تقرير المعاينات بالعيوب '),
                                onTap: () {
                                  setState(() {
                                    String ReportName =
                                        'تقرير المعاينات بالعيوب ';

                                    List<String> GroupColumn = [
                                      'season',
                                      'farm',
                                      'area',
                                      'reservoir',
                                      'subarea',
                                      'crop',
                                      'acre',
                                      'trees',
                                      'qty',
                                      'decision',
                                      'note',
                                      'percentage',
                                      'defectname',
                                    ];
                                    List<String> Num_Columns = [
                                      'sum(farza_qty) as farza_qty',
                                    ];
                                    List<String> formatColumns = ['farza_qty'];

                                    _currentScreen = ReportManager(
                                      key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      ScreenName: 'get_input_data_bydefect()',
                                      ScreenId: 2,
                                      exportid: 0,
                                      ReportName: ReportName,
                                      Num_Columns: Num_Columns,
                                      GroupColumn: GroupColumn,
                                      formatColumns: formatColumns,
                                      comitt: true,
                                      farm: true,
                                      season: true,
                                      isSales: false,
                                      ispick: false,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.report),
                                title: Text('تقرير خطة المبيعات السنوية '),
                                onTap: () {
                                  setState(() {
                                    String ReportName =
                                        'تقرير خطة المبيعات السنوية ';

                                    List<String> GroupColumn = [
                                      'month',
                                      'week',
                                      'client',
                                      'crop',
                                      'size',
                                    ];
                                    List<String> Num_Columns = [
                                      'sum(qty) as qty',
                                    ];
                                    List<String> formatColumns = [
                                      'qty',
                                    ];
                                    _currentScreen = ReportManager(
                                      key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      ScreenName: 'get_export_plan()',
                                      ScreenId: 3,
                                      exportid: 0,
                                      ReportName: ReportName,
                                      Num_Columns: Num_Columns,
                                      GroupColumn: GroupColumn,
                                      formatColumns: formatColumns,
                                      comitt: false,
                                      farm: false,
                                      season: true,
                                      isSales: true,
                                      ispick: false,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.report),
                                title: Text('تقرير الخطة الاسبوعية '),
                                onTap: () {
                                  setState(() {
                                    String ReportName =
                                        'تقرير الخطة الاسبوعية ';

                                    List<String> GroupColumn = [
                                      'month',
                                      'week',
                                      // 'client',
                                      'crop',
                                      'size',
                                    ];
                                    List<String> Num_Columns = [
                                      'sum(qty) as qty',
                                    ];
                                    List<String> formatColumns = [
                                      'qty',
                                    ];
                                    _currentScreen = ReportManager(
                                      key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      ScreenName: 'get_export_data()',
                                      ScreenId: 6,
                                      exportid: 0,
                                      ReportName: ReportName,
                                      Num_Columns: Num_Columns,
                                      GroupColumn: GroupColumn,
                                      formatColumns: formatColumns,
                                      comitt: false,
                                      farm: false,
                                      season: true,
                                      isSales: true,
                                      ispick: false,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.report),
                                title: Text('مقارنة خطة التصدير بالمزارع'),
                                onTap: () {
                                  setState(() {
                                    String ReportName =
                                        'مقارنة خطة التصدير بالمزارع';
                                    List<String> GroupColumn = [
                                      'group_crop',
                                      'crop',
                                      'size'
                                    ];
                                    List<String> Num_Columns = [
                                      'sum(export_qty) as export_qty',
                                      'sum(farms_qty) as farms_qty',
                                      'sum(variance) as variance'
                                    ];
                                    List<String> formatColumns = [
                                      'export_qty',
                                      'farms_qty',
                                      'variance'
                                    ];
                                    _currentScreen = ReportManager(
                                      key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      ScreenName: 'get_farms_vs_export()',
                                      ScreenId: 4,
                                      exportid: 0,
                                      ReportName: ReportName,
                                      Num_Columns: Num_Columns,
                                      GroupColumn: GroupColumn,
                                      formatColumns: formatColumns,
                                      comitt: false,
                                      farm: false,
                                      season: true,
                                      isSales: false,
                                      ispick: false,
                                    );
                                  });
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.report),
                                title: Text('ارصدة المزارع'),
                                onTap: () {
                                  setState(() {
                                    String ReportName = 'ارصدة المزارع';
                                    List<String> GroupColumn = [
                                      'season',
                                      'farm',
                                      'area',
                                      'subarea',
                                      'crop',
                                    ];
                                    List<String> Num_Columns = [
                                      'sum(acre) as acre',
                                      'sum(trees) as trees',
                                      'sum(previewqty) as previewqty',
                                      'sum(harvest_qty) as harvest_qty',
                                      'sum(balance) as balance'
                                    ];
                                    List<String> formatColumns = [
                                      'acre',
                                      'trees',
                                      'previewqty',
                                      'harvest_qty',
                                      'balance'
                                    ];
                                    _currentScreen = ReportManager(
                                      key: ValueKey(DateTime
                                          .now()), // مفتاح جديد لإعادة التهيئة
                                      ScreenName: 'get_farms_balance()',
                                      exportid: 0,
                                      ScreenId: 8,
                                      ReportName: ReportName,
                                      Num_Columns: Num_Columns,
                                      GroupColumn: GroupColumn,
                                      formatColumns: formatColumns,
                                      comitt: false,
                                      farm: true,
                                      season: true,
                                      isSales: false,
                                      ispick: true,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                       
                          ExpansionTile(
                            initiallyExpanded: expand,
                            leading: Icon(Icons.input),
                            title: Text('ادارة النظام'),
                            children: [
                               ListTile(
                                leading: Icon(Icons.data_usage),
                                title: Text('تعريف الادوار'),
                                onTap: () {
                                  setState(() {
                                    _currentScreen = PoliciesApp(
                                       
                                    );
                                  });
                                },
                              ),
                            ])
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // الشاشة المعروضة
            Expanded(
              child: _currentScreen,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'مرحبًا بك في شركة هامه للاستثمارات الزراعية!',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
