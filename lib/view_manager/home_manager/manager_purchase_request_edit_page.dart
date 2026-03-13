import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/manager_home_controller.dart';
import '../../../controller/home_controller.dart';
import '../../../model/home_model.dart';
import '../../../color.dart';
import '../../../widgets/custom_snackbar.dart';

class ManagerPurchaseRequestEditPage extends StatefulWidget {
  final PurchaseRequest request;
  const ManagerPurchaseRequestEditPage({Key? key, required this.request}) : super(key: key);

  @override
  State<ManagerPurchaseRequestEditPage> createState() => _ManagerPurchaseRequestEditPageState();
}

class _ManagerPurchaseRequestEditPageState extends State<ManagerPurchaseRequestEditPage> {
  late final TextEditingController _notesCtrl;
  late final List<String> _images;
  bool _uploading = false;
  bool _saving = false;

  // Use manager controller if available, otherwise fallback to HomeController
  dynamic get controller => Get.isRegistered<ManagerHomeViewController>() ? Get.find<ManagerHomeViewController>() : Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.request.adminNotes ?? '');
    _images = List<String>.from(widget.request.adminImages ?? []);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    setState(() => _uploading = true);
    try {
      final url = await controller.uploadImageToCloudinary();
      if (url != null) {
        setState(() => _images.add(url));
      }
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await controller.updatePurchaseRequestByAdmin(widget.request.id, 'finished', adminNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(), images: _images.isEmpty ? null : _images);
      showCustomSnackbar('نجح', 'تم حفظ الطلب بنجاح');

      // Attempt to delete the associated car (if any)
      final carId = widget.request.carId;
      if (carId.isNotEmpty) {
        try {
          if (Get.isRegistered<ManagerHomeViewController>()) {
            await Get.find<ManagerHomeViewController>().deleteCarById(carId);
          } else if (Get.isRegistered<HomeController>()) {
            final hc = Get.find<HomeController>();
            final car = hc.cars.firstWhereOrNull((c) => c.id == carId);
            if (car != null) {
              await hc.deleteCar(car); 
            } else {
              // Fallback: delete by id directly
              await FirebaseFirestore.instance.collection('car').doc(carId).delete();
            }
          } else {
            await FirebaseFirestore.instance.collection('car').doc(carId).delete();
          }
        } catch (e) {
          print('Error deleting car after finishing purchase request: $e');
          // Non-blocking: inform the admin but still finish
          showCustomSnackbar('خطأ', 'فشل حذف السيارة المرتبطة (يمكن المحاولة لاحقاً)');
        }
      }

      // go back to previous screen
      Get.back();
    } catch (e) {
      print('Error saving admin purchase request: $e');
      showCustomSnackbar('خطأ', 'فشل حفظ الطلب. حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل طلب الشراء'),
        backgroundColor: primaryblue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تفاصيل المشتري:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(r.details),
            SizedBox(height: 8),
            if (r.images.isNotEmpty) ...[
              Text('صور مقدم الطلب:'),
              SizedBox(height: 6),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: r.images.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (ctx, j) => GestureDetector(
                    onTap: () => Get.dialog(Dialog(
                      backgroundColor: Colors.transparent,
                        child: InteractiveViewer(
                        boundaryMargin: EdgeInsets.all(20),
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Image.network(r.images[j], fit: BoxFit.contain, errorBuilder: (c, e, s) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        )),
                      ),
                    )),
                    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(r.images[j], width: 120, height: 90, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(
                      width: 120,
                      height: 90,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ))),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
            SizedBox(height: 12),

            if (r.sellerDescription != null) ...[
              Text('وصف البائع:'),
              SizedBox(height: 4),
              Text(r.sellerDescription!),
              SizedBox(height: 12),
            ],

            if (r.sellerFiles != null && r.sellerFiles!.isNotEmpty) ...[
              Text('ملفات البائع:'),
              SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: r.sellerFiles!.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (_, j) => Image.network(r.sellerFiles![j], width: 120, height: 90, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(
                    width: 120,
                    height: 90,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  )),
                ),
              ),
              SizedBox(height: 12),
            ],

            Text('ملاحظات المدير:'),
            SizedBox(height: 6),
            TextField(controller: _notesCtrl, maxLines: 4, decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'اكتب ملاحظات')),
            SizedBox(height: 12),

            Text('صور/ملفات المدير:'),
            SizedBox(height: 8),
            if (_images.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (ctx, i) => Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Get.dialog(Dialog(
                          backgroundColor: Colors.transparent,
                          child: InteractiveViewer(
                            boundaryMargin: EdgeInsets.all(20),
                            minScale: 1.0,
                            maxScale: 4.0,
                            child: Image.network(_images[i], fit: BoxFit.contain),
                          ),
                        )),
                        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_images[i], width: 120, height: 90, fit: BoxFit.cover)),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(i)),
                          child: CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 8),
            Row(children: [
              ElevatedButton.icon(
                onPressed: _uploading ? null : _addImage,
                icon: Icon(Icons.add_a_photo),
                label: Text(_uploading ? 'جارٍ الرفع...' : 'أضف صورة'),
              ),
              SizedBox(width: 12),
              TextButton(onPressed: () => setState(() => _images.clear()), child: Text('حذف الصور')),
            ]),

            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('حفظ وإنهاء'),
              ), 
            ]),
          ],
        ),
      ),
    );
  }
}
