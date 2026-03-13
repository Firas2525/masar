import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../color.dart';
import '../../constants.dart';
import '../../controller/home_controller.dart';
import '../../model/home_model.dart';
import '../../widgets/custom_snackbar.dart';
import 'car_details_page.dart';
import '../../widgets/styled_dialog.dart';

// Dialog widget to show finished requests with optional date filtering
class FinishedRequestsDialog extends StatefulWidget {
  final HomeController controller;
  const FinishedRequestsDialog({required this.controller, Key? key}) : super(key: key);

  @override
  _FinishedRequestsDialogState createState() => _FinishedRequestsDialogState();
}

class _FinishedRequestsDialogState extends State<FinishedRequestsDialog> {
  DateTime? from;
  DateTime? to;

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: 'الطلبات المنتهية',
      content: SizedBox(
        width: 400,
        height: 360,
        child: Column(
          children: [
            Row(children: [
              ElevatedButton(
                  onPressed: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (d != null) setState(() => from = d);
                  },
                  child: Text(from == null ? 'من' : _formatDate(from!))),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (d != null) setState(() => to = d);
                  },
                  child: Text(to == null ? 'إلى' : _formatDate(to!))),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<CarRequest>>(
                stream: widget.controller.streamRequestsForServiceOwner(widget.controller.userId),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  var list = snap.data!.where((r) => (r.status?.toLowerCase() == 'finished' || r.status?.toLowerCase() == 'منتهي')).toList();
                  if (from != null) {
                    list = list.where((r) {
                      final dt = r.createdAt ?? (r.createdAtClient != null ? DateTime.tryParse(r.createdAtClient!) : null);
                      if (dt == null) return false;
                      return !dt.isBefore(from!);
                    }).toList();
                  }
                  if (to != null) {
                    list = list.where((r) {
                      final dt = r.createdAt ?? (r.createdAtClient != null ? DateTime.tryParse(r.createdAtClient!) : null);
                      if (dt == null) return false;
                      return !dt.isAfter(to!);
                    }).toList();
                  }
                  if (list.isEmpty) return const Center(child: Text('لا توجد طلبات منتهية'));
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (c, i) {
                      final r = list[i];
                      return ListTile(
                        title: Text(r.type ?? ''),
                        subtitle: Text(r.finalDescription ?? ''),
                        trailing: Text(r.finalPrice != null ? r.finalPrice.toString() : '-'),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        )
      ],
    );
  }
}

class ServiceOwnerRequestsPage extends StatefulWidget {
  const ServiceOwnerRequestsPage({Key? key}) : super(key: key);

  @override
  State<ServiceOwnerRequestsPage> createState() => _ServiceOwnerRequestsPageState();
}

class _ServiceOwnerRequestsPageState extends State<ServiceOwnerRequestsPage> {
  final controller = Get.find<HomeController>();

  String _formatSchedule(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _statusChip(String? status) {
    final s = (status ?? '').toLowerCase();
    Color color;
    String label;
    switch (s) {
      case 'accepted':
      case 'مقبول':
        color = Colors.green;
        label = 'مقبول';
        break;
      case 'rejected':
      case 'مرفوض':
        color = Colors.red;
        label = 'مرفوض';
        break;
      case 'finished':
      case 'منتهي':
        color = Colors.blueGrey;
        label = 'منتهي';
        break;
      default:
        color = Colors.orange;
        label = 'قيد الانتظار';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _pickAndUploadImage(CarRequest r) async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (p != null) {
      final url = await controller.uploadImageToCloudinary(File(p.path));
      if (url != null) {
        final images = List<String>.from(r.images ?? []);
        images.add(url);
        await controller.updateRequestByServiceOwner(r.id, r.status ?? '', images: images);
        showCustomSnackbar('نجح', 'تم إضافة الصورة');
      }
    }
  }

  Widget _buildRequestCard(CarRequest r) {
    final localImages = List<String>.from(r.images ?? []);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(r.type ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), _statusChip(r.status)]),
          const SizedBox(height: 8),
          if (r.details != null) Text(r.details!),
          const SizedBox(height: 8),
          if (localImages.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: localImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final img = localImages[i];
                  return GestureDetector(
                    onTap: () => Get.dialog(Dialog(
                      backgroundColor: Colors.transparent,
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: CachedNetworkImage(imageUrl: img, fit: BoxFit.contain),
                      ),
                    )),
                    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: img, width: 120, height: 90, fit: BoxFit.cover)),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          if (r.scheduledAt != null && r.scheduledAt!.isNotEmpty) Text('موعد الحجز: ${_formatSchedule(r.scheduledAt)}', style: const TextStyle(fontWeight: FontWeight.w600)),
          if (r.response != null && r.response!.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Text('رد المحل:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(r.response!),
          ],
          if (r.finalDescription != null && r.finalDescription!.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Text('وصف الانتهاء:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(r.finalDescription!),
          ],
          if (r.finalPrice != null) ...[
            const SizedBox(height: 6),
            Text('السعر النهائي: ${r.finalPrice} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton(
              onPressed: () async {
                final respCtrl = TextEditingController(text: r.response ?? '');
                final res = await Get.dialog(Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 520),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                        child: Row(children: [Expanded(child: Text('عرض / تعديل الرد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close, color: Colors.white))]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          TextField(controller: respCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب الرد')),
                          SizedBox(height: 14),
                          Row(children: [
                            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(), child: Text('إلغاء'))),
                            SizedBox(width: 10),
                            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue), onPressed: () => Get.back(result: true), child: Text('حفظ'))),
                          ])
                        ]),
                      )
                    ]),
                  ),
                ), barrierDismissible: false);
                if (res == true) {
                  await controller.updateRequestByServiceOwner(r.id, r.status ?? '', response: respCtrl.text.trim());
                }
              },
              child: const Text('عرض / تعديل الرد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryblue,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.grey.shade300),
                minimumSize: Size(64, 44),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickAndUploadImage(r),
              icon: Icon(Icons.photo_camera, size: 18, color: Colors.white),
              label: Text('أضف صورة', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryblue,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(64, 44),
              ),
            ),
            OutlinedButton(
                onPressed: () async {
                  final data = await controller.getUserData(r.userId ?? '');
                  if (data != null) {
                    await Get.dialog(Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 520),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                            child: Row(children: [Expanded(child: Text('معلومات المستخدم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close, color: Colors.white))]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('الاسم: ${data['name'] ?? ''}'),
                              SizedBox(height: 6),
                              Text('البريد: ${data['email'] ?? ''}'),
                              SizedBox(height: 6),
                              Text('الهاتف: ${data['phone'] ?? ''}'),
                              SizedBox(height: 14),
                              Row(children: [Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(), child: Text('إغلاق')))]),
                            ]),
                          )
                        ]),
                      ),
                    ));
                  } else {
                    showCustomSnackbar('خطأ', 'معلومات المستخدم غير متوفرة');
                  }
                },
                child: const Text('عرض المستخدم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryblue,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                  minimumSize: Size(64, 44),
                ),
            ),
            OutlinedButton(
                onPressed: () {
                  final car = controller.cars.firstWhereOrNull((c) => c.id == r.carId);
                  if (car != null) {
                    Get.to(() => CarDetailsPage(car: car));
                  } else { 
                    showCustomSnackbar('خطأ', 'بيانات السيارة غير متوفرة');
                  }
                },
                child: const Text('عرض السيارة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryblue,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                  minimumSize: Size(64, 44),
                ),
            ),
            if ((r.status ?? '').toLowerCase() == 'pending' || (r.status ?? '').toLowerCase() == 'قيد الانتظار') ...[
              ElevatedButton(onPressed: () async => await controller.updateRequestByServiceOwner(r.id, 'rejected'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.redAccent, padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.redAccent.withOpacity(0.12))), child: const Text('رفض', style: TextStyle(color: Colors.red))),
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final pickedDate = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(now.year + 2));
                  if (pickedDate == null) return showCustomSnackbar('ملاحظة', 'لم يتم اختيار تاريخ');
                  final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay(hour: now.hour, minute: now.minute));
                  if (pickedTime == null) return showCustomSnackbar('ملاحظة', 'لم يتم اختيار وقت');
                  final scheduled = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                  await controller.updateRequestByServiceOwner(r.id, 'accepted', scheduledAt: scheduled.toIso8601String());
                },
                child: const Text('قبول مع موعد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryblue,
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size(64, 44),
                ),
              ),
            ] else if ((r.status ?? '').toLowerCase() == 'accepted' || (r.status ?? '').toLowerCase() == 'مقبول') ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  final fdCtrl = TextEditingController();
                  final fpCtrl = TextEditingController();
                  final ok = await Get.dialog(Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                          child: Row(children: [Expanded(child: Text('تأكيد الانتهاء', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(result: false), icon: Icon(Icons.close, color: Colors.white))]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            TextField(controller: fdCtrl, decoration: const InputDecoration(labelText: 'وصف الانتهاء')),
                            TextField(controller: fpCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'السعر النهائي')),
                            SizedBox(height: 14),
                            Row(children: [
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(result: false), child: Text('إلغاء'))),
                              SizedBox(width: 10),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue), onPressed: () => Get.back(result: true), child: Text('تأكيد'))),
                            ])
                          ]),
                        )
                      ]),
                    ),
                  ), barrierDismissible: false);
                  if (ok == true) {
                    final desc = fdCtrl.text.trim();
                    final price = double.tryParse(fpCtrl.text.trim()) ?? 0.0;
                    await controller.updateRequestByServiceOwner(r.id, 'finished', finalDescription: desc, finalPrice: price);
                  }
                },
                child: const Text('إنهاء الطلب'),
              )
            ],
          ])
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('قائمة طلبات الصيانة'),
            backgroundColor: primaryblue,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Get.back()),
            bottom: TabBar(
              indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primaryPink, width: 3), insets: EdgeInsets.symmetric(horizontal: 28)),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [Tab(text: 'الطلبات'), Tab(text: 'المنتهية')],
            ),
            actions: [
              IconButton(
                tooltip: 'تفاصيل المحل',
                icon: Icon(Icons.help_outline, color: Colors.white),
                onPressed: () async {
                  final titleCtrl = TextEditingController(text: controller.serviceProfile?['title'] ?? '');
                  final addressCtrl = TextEditingController(text: controller.serviceProfile?['address'] ?? '');
                  final descCtrl = TextEditingController(text: controller.serviceProfile?['description'] ?? '');
                  await Get.dialog(Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, colorPrimary]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                          child: Row(children: [Expanded(child: Text('تفاصيل المحل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close, color: Colors.white))]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'اسم المحل')),
                            SizedBox(height: 8),
                            TextField(controller: addressCtrl, decoration: InputDecoration(labelText: 'العنوان')),
                            SizedBox(height: 8),
                            TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'الوصف')),
                            SizedBox(height: 14),
                            Row(children: [
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () { Get.back(); }, child: Text('إغلاق'))),
                              SizedBox(width: 10),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue), onPressed: () async {
                                final updated = {
                                  'title': titleCtrl.text.trim(),
                                  'address': addressCtrl.text.trim(),
                                  'description': descCtrl.text.trim(),
                                };
                                await controller.updateServiceProfile(updated);
                                Get.back();
                                showCustomSnackbar('نجح', 'تم تحديث بيانات المحل');
                              }, child: Text('حفظ'))),
                              SizedBox(width: 10),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () async {
                                // delete service profile field from user doc
                                final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text('حذف ملف المحل'), content: Text('هل تريد حذف ملف المحل من الواجهة؟ ستُزال جميع بيانات الملف.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('حذف'))]));
                                if (ok == true) {
                                  await controller.updateServiceProfile({ 'title': null, 'address': null, 'description': null, 'lat': null, 'lng': null });
                                  Get.back();
                                  showCustomSnackbar('نجح', 'تم حذف ملف المحل من الواجهة');
                                }
                              }, child: Text('حذف'))),
                            ])
                          ]),
                        )
                      ]),
                    ),
                  ));
                },
              )
            ],
          ),
          body: Column(children: [
        Expanded(
          child: StreamBuilder<List<CarRequest>>(
            stream: controller.streamRequestsForServiceOwner(controller.userId),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final requests = snap.data!;
              final active = requests.where((r) {
                final s = (r.status ?? '').toLowerCase();
                return s != 'finished' && s != 'منتهي';
              }).toList();
              final finished = requests.where((r) {
                final s = (r.status ?? '').toLowerCase();
                return s == 'finished' || s == 'منتهي';
              }).toList();

              return TabBarView(
                children: [
                  active.isEmpty
                      ? Center(child: Text('لا توجد طلبات حالياً'))
                      : ListView.builder(itemCount: active.length, itemBuilder: (c, i) => _buildRequestCard(active[i])),
                  finished.isEmpty
                      ? Center(child: Text('لا توجد طلبات منتهية'))
                      : ListView.builder(itemCount: finished.length, itemBuilder: (c, i) => _buildRequestCard(finished[i])),
                ],
              );
            },
          ), 
        )
      ]),
    ));
  }
}


  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'مقبول':
        color = Colors.green;
        label = 'مقبول';
        break;
      case 'rejected':
      case 'مرفوض':
        color = Colors.red;
        label = 'مرفوض';
        break;
      case 'finished':
      case 'منتهي':
        color = Colors.blueGrey;
        label = 'منتهي';
        break;
      default:
        color = Colors.orange;
        label = 'قيد الانتظار';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );

}
