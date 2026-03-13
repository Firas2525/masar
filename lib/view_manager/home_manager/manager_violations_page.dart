import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/home_controller.dart';
import '../../../controller/manager_home_controller.dart';
import '../../../model/home_model.dart';
import '../../../color.dart';
import '../../../widgets/custom_snackbar.dart';
import 'package:kindergarten_user/main.dart';

class ManagerViolationsPage extends StatefulWidget {
  const ManagerViolationsPage({Key? key}) : super(key: key);

  @override
  State<ManagerViolationsPage> createState() => _ManagerViolationsPageState();
}

class _ManagerViolationsPageState extends State<ManagerViolationsPage> {
  late final HomeController hc;
  String query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    hc = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());
    hc.refreshData().then((_) {
      if (mounted) setState(() => _loading = false);
    }).catchError((e) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cars = hc.cars
        .where((c) =>
            query.isEmpty ||
            (c.plateNumber ?? '').toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المخالفات'),
        backgroundColor: primaryblue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ابحث برقم اللوحة',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          Expanded(
            child: cars.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_car_filled, size: 64,
                            color: Colors.grey[350]),
                        SizedBox(height: 12),
                        Text('لم يتم تحميل سيارات للعرض',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 16)),
                        SizedBox(height: 8),
                        Text('تحقق من الاتصال أو اضغط إعادة تحميل',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                        SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            hc.refreshData();
                          }, 
                          icon: Icon(Icons.refresh),
                          label: Text('إعادة تحميل'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryblue),
                        )
                      ],
                    ),
                  )
                : ListView.separated(
                    padding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: cars.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final car = cars[i];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          leading: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[100]),
                            child: car.image.isNotEmpty
                                ? Image.network(car.image,
                                    fit: BoxFit.cover)
                                : Icon(Icons.directions_car,
                                    color: primaryblue, size: 36),
                          ),
                          title: Text(
                              car.title.isNotEmpty ? car.title : car.brand,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'اللوحة: ${car.plateNumber ?? '-'}\n${car.brand} • ${car.mileageKill} كلم',
                              style: TextStyle(height: 1.3)),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryblue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () =>
                                _openAddViolationDialog(car),
                            child: Text('أضف مخالفة',
                                style: TextStyle(color: Colors.white)),
                          ),
                          onTap: () =>
                              Get.to(() => CarViolationsPage(car: car)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

  }

  void _openAddViolationDialog(Car car) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final fine = TextEditingController();
    final typeCtrl = TextEditingController();
    bool isLoading = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryblue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'إضافة مخالفة لـ ${car.plateNumber ?? ''}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: typeCtrl,
                    decoration: InputDecoration(
                      labelText: 'نوع المخالفة',
                      hintText: 'اكتب نوع المخالفة',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: title,
                    decoration: InputDecoration(labelText: 'العنوان'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: desc,
                    decoration: InputDecoration(labelText: 'الوصف'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: fine,
                    decoration: InputDecoration(labelText: 'الغرامة'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    minimumSize: Size.fromHeight(44)),
                onPressed: isLoading ? null : () => Get.back(),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryblue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size.fromHeight(44),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (title.text.trim().isEmpty) {
                          showCustomSnackbar(
                              'ملاحظة', 'العنوان لا يمكن أن يكون فارغاً');
                          return;
                        }
                        setState(() => isLoading = true);
                        // أغلق الـ dialog فوراً
                        Get.back();
                        
                        final v = {
                          'title': title.text.trim(),
                          'description': desc.text.trim(),
                          'fine': double.tryParse(fine.text.trim()) ?? 0.0,
                          'status': 'pending',
                          'type': typeCtrl.text.trim().isNotEmpty
                              ? typeCtrl.text.trim()
                              : 'أخرى',
                          'createdAt': DateTime.now().toIso8601String(),
                        };
                        final ok = await hc.addViolation(car.id, v);
                        if (ok) {
                          showCustomSnackbar('نجح', 'تمت إضافة المخالفة');
                        } else {
                          showCustomSnackbar('خطأ', 'فشل إضافة المخالفة');
                        }
                      },
                child: Builder(builder: (_) {
                  return isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('حفظ');
                }),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }
}

class CarViolationsPage extends StatefulWidget {
  final Car car;

  const CarViolationsPage({Key? key, required this.car}) : super(key: key);

  @override
  State<CarViolationsPage> createState() => _CarViolationsPageState();
}

class _CarViolationsPageState extends State<CarViolationsPage> {
  late HomeController hc;

  @override
  void initState() {
    super.initState();
    hc = Get.find<HomeController>();
  }

  @override
  Widget build(BuildContext context) {
    final isManager = Get.isRegistered<ManagerHomeViewController>() ||
        (sharePref?.getBool('isManager') ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text('مخالفات ${widget.car.plateNumber ?? ''}'),
        backgroundColor: primaryblue,
      ),
      body: StreamBuilder<List<Violation>>(
        stream: hc.getViolationsStream(widget.car.id),
        builder: (context, snapshot) {
          // التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(primaryblue),
              ),
            );
          }

          // خطأ
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  SizedBox(height: 12),
                  Text('حدث خطأ في تحميل المخالفات',
                      style: TextStyle(color: Colors.red[600])),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: Icon(Icons.refresh),
                    label: Text('إعادة محاولة'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryblue),
                  )
                ],
              ),
            );
          }

          final violations = snapshot.data ?? [];

          // لا توجد مخالفات
          if (violations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.report, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 12),
                  Text('لا توجد مخالفات',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          // عرض المخالفات
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: violations.length,
            separatorBuilder: (_, __) => SizedBox(height: 10),
            itemBuilder: (context, i) {
              final v = violations[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                SizedBox(height: 4),
                                Text('النوع: ${v.type}',
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          if (isManager)
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'حذف المخالفة',
                                  content: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('هل تريد حذف هذه المخالفة؟'),
                                  ),
                                  cancel: TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('إلغاء'),
                                  ),
                                  confirm: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () async {
                                      Get.back();
                                      await hc.deleteViolation(
                                          widget.car.id, v.id);
                                    },
                                    child: Text('حذف',
                                        style: TextStyle(
                                            color: Colors.white)),
                                  ),
                                );
                              },
                              tooltip: 'حذف المخالفة',
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(v.description,
                          style: TextStyle(
                              color: Colors.grey[700], height: 1.5)),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.attach_money,
                                    size: 18, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Text('الغرامة: ${v.fine} ر.س',
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          Text(
                            v.createdAt != null
                                ? '${v.createdAt!.year}-${v.createdAt!.month.toString().padLeft(2, '0')}-${v.createdAt!.day.toString().padLeft(2, '0')}'
                                : '-',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
