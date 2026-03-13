import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../color.dart';
import '../../controller/home_controller.dart';
import '../../model/home_model.dart';

class CreatePurchaseRequestPage extends StatefulWidget {
  final Car car;
  const CreatePurchaseRequestPage({Key? key, required this.car}) : super(key: key);

  @override
  State<CreatePurchaseRequestPage> createState() => _CreatePurchaseRequestPageState();
}

class _CreatePurchaseRequestPageState extends State<CreatePurchaseRequestPage> {
  final _detailsCtrl = TextEditingController();
  final List<String> _images = [];
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  final HomeController _controller = Get.find<HomeController>();

  @override
  void dispose() {
    _detailsCtrl.dispose();
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
    if (_detailsCtrl.text.trim().isEmpty) {
      Get.snackbar('مطلوب', 'يرجى كتابة تفاصيل الطلب');
      return;
    }

    final currentUser = _controller.userId;
    if (currentUser.isEmpty){  Get.snackbar('خطأ', 'يجب تسجيل الدخول');
    return;
    }
    if (currentUser == widget.car.userId) {
       Get.snackbar('غير مسموح', 'لا يمكنك طلب شراء سيارتك');
       return;
    }
    setState(() => _isSubmitting = true);
    final success = await _controller.createPurchaseRequest(widget.car.id, _detailsCtrl.text.trim(), _images, widget.car.userId);
    setState(() => _isSubmitting = false);

    if (success) {
      Get.snackbar('تم', 'تم إرسال طلب الشراء');
      await Future.delayed(const Duration(milliseconds: 300));
      Get.back();
    } else {
      Get.snackbar('خطأ', 'فشل الإرسال');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب شراء'), backgroundColor: primaryblue),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)]),
            padding: EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('تفاصيل الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              TextField(
                controller: _detailsCtrl,
                maxLines: 6,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'اكتب تفاصيل الطلب'),
              ),

              SizedBox(height: 12),
              Text('أوراق تريد تقديمها', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(children: [
                ElevatedButton.icon(
                  onPressed: _isUploadingImage ? null : _addImage,
                  icon: Icon(Icons.photo_library, color: Colors.white, size: 18),
                  label: Text('أضف صورة', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryblue, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                SizedBox(width: 12),
                if (_isUploadingImage) CircularProgressIndicator(),
              ]),

              SizedBox(height: 12),
              if (_images.isNotEmpty)
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) => Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_images[i], width: 120, height: 90, fit: BoxFit.cover)),
                      Positioned(right: 4, top: 4, child: GestureDetector(onTap: () => setState(() => _images.removeAt(i)), child: CircleAvatar(radius: 12, backgroundColor: Colors.black45, child: Icon(Icons.close, size: 14, color: Colors.white)))),
                    ]),
                    separatorBuilder: (_, __) => SizedBox(width: 8),
                    itemCount: _images.length,
                  ),
                ),
            ]),
          ),

          Spacer(),
          Row(children: [
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: _isSubmitting ? null : _submit, child: _isSubmitting ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('إرسال طلب الشراء', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ])
        ]),
      ),
    );
  }
}
