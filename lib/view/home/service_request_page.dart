import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../color.dart';
import '../../controller/home_controller.dart';
import '../../widgets/custom_snackbar.dart';

class ServiceRequestPage extends StatefulWidget {
  final String carId;
  final String serviceCenterId;
  final Map profile;

  const ServiceRequestPage({Key? key, required this.carId, required this.serviceCenterId, required this.profile}) : super(key: key);

  @override
  _ServiceRequestPageState createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  final _typeCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final HomeController controller = Get.find<HomeController>();
  final ImagePicker _picker = ImagePicker();
  bool _isSending = false;
  List<String> _images = [];

  @override
  void dispose() {
    _typeCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final p = await _picker.pickImage(source: ImageSource.gallery);
    if (p != null) {
      final url = await controller.uploadImageToCloudinary(File(p.path));
      if (url != null) setState(() => _images.add(url));
    }
  }

  Future<void> _send() async {
    final type = _typeCtrl.text.trim();
    final details = _detailsCtrl.text.trim();
    if (type.isEmpty || details.isEmpty) {
      showCustomSnackbar('خطأ', 'يرجى تعبئة الحقول المطلوبة');
      return;
    }

    setState(() => _isSending = true);
    try {
      await controller.createMaintenanceRequest(
        carId: widget.carId,
        type: type,
        details: details,
        userId: controller.userId,
        serviceCenterId: widget.serviceCenterId,
        images: _images,
      );

      showCustomSnackbar('نجح', 'تم إرسال طلب الصيانة');
      Get.back();
    } catch (e) {
      showCustomSnackbar('خطأ', 'حدث خطأ أثناء إرسال الطلب');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب صيانة'), backgroundColor: primaryblue),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.profile['title'] ?? 'مركز صيانة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 8),
                if ((widget.profile['address'] ?? '').toString().isNotEmpty)
                  Text('العنوان: ${widget.profile['address']}', style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 12),
                TextField(controller: _typeCtrl, decoration: InputDecoration(labelText: 'نوع الخدمة')),
                SizedBox(height: 8),
                TextField(controller: _detailsCtrl, maxLines: 5, decoration: InputDecoration(labelText: 'تفاصيل الطلب')),
                SizedBox(height: 12),
                Row(children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.photo),
                    label: Text('أضف صورة'),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryPink),
                    onPressed: _pickImage,
                  ),
                  SizedBox(width: 12),
                  if (_images.isNotEmpty) Text('${_images.length} صورة مرفوعة')
                ]),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryblue, minimumSize: Size(double.infinity, 48)),
                  onPressed: _isSending ? null : _send,
                  child: _isSending ? CircularProgressIndicator(color: Colors.white) : Text('إرسال الطلب'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
