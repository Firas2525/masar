import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';
import '../../controller/home_controller.dart';
import '../../widgets/custom_snackbar.dart';
import '../../color.dart';
import 'service_centers_map_page.dart';
import 'service_request_page.dart';
import 'package:latlong2/latlong.dart';

class ServiceCentersListPage extends StatefulWidget {
  final String carId;
  const ServiceCentersListPage({Key? key, required this.carId})
    : super(key: key);

  @override
  _ServiceCentersListPageState createState() => _ServiceCentersListPageState();
}

class _ServiceCentersListPageState extends State<ServiceCentersListPage> {
  final HomeController controller = Get.find<HomeController>();
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matches(Map<String, dynamic> c) {
    final profile = c['serviceProfile'] ?? {};
    final name = (profile['title'] ?? c['name'] ?? '').toString().toLowerCase();
    return name.contains(_query.toLowerCase());
  }

  void _openMap({double? lat, double? lng}) {
    if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
      Get.to(() => ServiceCentersMapPage(carId: widget.carId));
    } else {
      Get.to(
        () => ServiceCentersMapPage(
          initialCenter: LatLng(lat, lng),
          carId: widget.carId,
        ),
      );
    }
  }

  Future<void> _showRequestDialog(Map c, String uid, Map profile) async {
    final typeCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    List<String> images = []; 

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)]),
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, colorPrimary]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                  child: Row(children: [Expanded(child: Text('طلب صيانة إلى ${profile['title'] ?? 'المركز'}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close, color: Colors.white))]),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(controller: typeCtrl, decoration: InputDecoration(labelText: 'نوع الخدمة')),
                    SizedBox(height: 8),
                    TextField(controller: detailsCtrl, maxLines: 4, decoration: InputDecoration(labelText: 'تفاصيل الطلب')),
                    SizedBox(height: 8),
                    Row(children: [
                      ElevatedButton.icon(icon: Icon(Icons.photo), label: Text('أضف صورة'), style: ElevatedButton.styleFrom(backgroundColor: primaryPink), onPressed: () async {
                        final p = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (p != null) {
                          final url = await controller.uploadImageToCloudinary(File(p.path));
                          if (url != null) setState(() { images.add(url); });
                        }
                      }),
                      SizedBox(width: 8),
                      if (images.isNotEmpty) Text('${images.length} صورة مرفوعة')
                    ]),
                    SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('إلغاء'))),
                      SizedBox(width: 10),
                      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue), onPressed: () async {
                        final type = typeCtrl.text.trim();
                        final details = detailsCtrl.text.trim();
                        if (type.isEmpty || details.isEmpty) { showCustomSnackbar('خطأ', 'يرجى تعبئة الحقول المطلوبة'); return; }
                        await controller.createMaintenanceRequest(carId: widget.carId, type: type, details: details, userId: controller.userId, serviceCenterId: uid, images: images);
                        Get.back();
                        showCustomSnackbar('نجح', 'تم إرسال طلب الصيانة');
                      }, child: Text('إرسال'))),
                    ])
                  ]),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مراكز الصيانة'),
        backgroundColor: primaryblue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: Icon(Icons.search, color: primaryblue),
                      hintText: 'ابحث باسم المركز',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.map, color: Colors.white),
                  label: Text('اضغط هنا لرؤية المراكز على الخريطة'),
                  onPressed: () => _openMap(),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.streamServiceCenters(),
              builder: (context, snap) {
                if (snap.hasError)
                  return Center(child: Text('خطأ في جلب المراكز'));
                if (snap.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final raw = snap.data ?? [];
                final centers = _query.isEmpty
                    ? raw
                    : raw.where((c) => _matches(c)).toList();

                if (centers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'لا توجد مراكز متاحة',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => _openMap(),
                          icon: Icon(Icons.map),
                          label: Text('اظهر كل المراكز على الخريطة'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(12),
                  itemCount: centers.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = centers[index];
                    final uid = c['uid'] ?? c['id'] ?? '';
                    final profile = c['serviceProfile'] ?? {};

                    final lat = (profile['lat'] is num)
                        ? (profile['lat'] as num).toDouble()
                        : (double.tryParse('${profile['lat']}') ?? 0.0);
                    final lng = (profile['lng'] is num)
                        ? (profile['lng'] as num).toDouble()
                        : (double.tryParse('${profile['lng']}') ?? 0.0);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: primaryblue.withOpacity(
                                    0.12,
                                  ),
                                  child: Icon(Icons.build, color: primaryblue),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile['title'] ??
                                            c['name'] ??
                                            'مركز صيانة',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        profile['address'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      tooltip: 'عرض على الخريطة',
                                      onPressed: () =>
                                          _openMap(lat: lat, lng: lng),
                                      icon: Icon(
                                        Icons.location_on,
                                        color: primaryPink,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'تفاصيل',
                                      onPressed: () {
                                        Get.dialog(
                                          AlertDialog(
                                            title: Text(
                                              profile['title'] ??
                                                  c['name'] ??
                                                  'مركز صيانة',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 8),
                                                  if ((profile['address'] ?? '')
                                                      .toString()
                                                      .isNotEmpty)
                                                    Text(
                                                      'العنوان: ${profile['address']}',
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  if ((profile['phone'] ?? '')
                                                      .toString()
                                                      .isNotEmpty)
                                                    SizedBox(height: 8),
                                                  if ((profile['phone'] ?? '')
                                                      .toString()
                                                      .isNotEmpty)
                                                    Text(
                                                      'هاتف: ${profile['phone']}',
                                                    ),
                                                  if ((profile['description'] ??
                                                          '')
                                                      .toString()
                                                      .isNotEmpty)
                                                    SizedBox(height: 8),
                                                  if ((profile['description'] ??
                                                          '')
                                                      .toString()
                                                      .isNotEmpty)
                                                    Text(
                                                      '${profile['description']}',
                                                    ),
                                                  SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    primaryblue,
                                                              ),
                                                          onPressed: () {
                                                            Get.back();
                                                            Get.to(
                                                              () => ServiceRequestPage(
                                                                carId: widget
                                                                    .carId,
                                                                serviceCenterId:
                                                                    uid,
                                                                profile:
                                                                    profile,
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            'حجز صيانة',
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          Get.back();
                                                          _openMap(
                                                            lat: lat,
                                                            lng: lng,
                                                          );
                                                        },
                                                        child: Text(
                                                          'عرض الموقع',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: Text('إغلاق'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Get.back();
                                                  _openMap(lat: lat, lng: lng);
                                                },
                                                child: Text('عرض الموقع'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryblue,
                                                ),
                                                onPressed: () {
                                                  Get.back();
                                                  Get.to(
                                                    () => ServiceRequestPage(
                                                      carId: widget.carId,
                                                      serviceCenterId: uid,
                                                      profile: profile,
                                                    ),
                                                  );
                                                },
                                                child: Text('حجز صيانة'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: primaryblue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryblue,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async =>
                                        await _showRequestDialog(
                                          c,
                                          uid,
                                          profile,
                                        ),
                                    child: Text(
                                      'طلب صيانة',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                OutlinedButton(
                                  onPressed: () => _openMap(lat: lat, lng: lng),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text('الخريطة'),
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
          ),
        ],
      ),
    );
  }
}
