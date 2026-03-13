import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../color.dart';
import '../../controller/home_controller.dart';
import '../../model/home_model.dart';

class CreateRequestPage extends StatefulWidget {
  final Car car;
  const CreateRequestPage({Key? key, required this.car}) : super(key: key);

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _typeCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final List<String> _images = [];
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  final HomeController _controller = Get.find<HomeController>();

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploadingImage = true);
    final url = await _controller.uploadImageToCloudinary(File(picked.path));
    setState(() => _isUploadingImage = false);

    if (url != null) {
      setState(() => _images.add(url));
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (_typeCtrl.text.trim().isEmpty) {
      Get.snackbar('مطلوب', 'يرجى كتابة نوع الطلب');
      return;
    }
    if (_detailsCtrl.text.trim().isEmpty) {
      Get.snackbar('مطلوب', 'يرجى كتابة تفاصيل الطلب');
      return;
    }

    // prevent creating request for a car that doesn't belong to the current user
    if (_controller.userId != widget.car.userId) {
      Get.snackbar('غير مسموح', 'لا يمكنك إنشاء طلب لسيارة ليست ملكك');
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await _controller.createCarRequest(widget.car.id, _typeCtrl.text.trim(), _detailsCtrl.text.trim(), _images);
    setState(() => _isSubmitting = false);

    if (success) {
      Get.snackbar('نجح', 'تم إنشاء الطلب بنجاح');
      // عودة إلى صفحة الطلبات حتى يرى المستخدم التحديث
      await Future.delayed(const Duration(milliseconds: 300));
      Get.back();
    } else {
      Get.snackbar('خطأ', 'فشل إنشاء الطلب. حاول مرة أخرى');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إنشاء طلب جديد'), backgroundColor: primaryblue),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نوع الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _typeCtrl,
              decoration: InputDecoration(
                labelText: 'نوع الطلب',
                border: OutlineInputBorder(),
                hintText: 'اكتب نوع الطلب هنا',
              ),
            ),
            SizedBox(height: 12),
            Text('تفاصيل الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(controller: _detailsCtrl, maxLines: 5, decoration: InputDecoration(border: OutlineInputBorder())),
            SizedBox(height: 12),
            Text('الصور (اختياري)', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploadingImage ? null : _addImage,
                  icon: Icon(Icons.photo_library),
                  label: Text('اضف صورة'),
                ),
                SizedBox(width: 12),
                if (_isUploadingImage) CircularProgressIndicator(),
              ],
            ),
            SizedBox(height: 12),
            if (_images.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) => Stack(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_images[i], width: 120, height: 90, fit: BoxFit.cover)),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(i)),
                          child: CircleAvatar(radius: 12, backgroundColor: Colors.black45, child: Icon(Icons.close, size: 14, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemCount: _images.length,
                ),
              ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryblue),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting ? CircularProgressIndicator(color: Colors.white) : Text('إنشاء الطلب'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
