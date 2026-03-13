import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../color.dart';
import '../../controller/home_controller.dart';
import '../../model/home_model.dart';
import '../../widgets/custom_snackbar.dart';

class EditCarPage extends StatefulWidget {
  final Car car;
  const EditCarPage({Key? key, required this.car}) : super(key: key);

  @override
  _EditCarPageState createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  final picker = ImagePicker();
  XFile? pickedImage;
  bool isSaving = false;

  late TextEditingController descController;
  late TextEditingController addressController;
  late TextEditingController priceController;
  late TextEditingController plateController;

  @override
  void initState() {
    super.initState();
    descController = TextEditingController(text: widget.car.desc);
    addressController = TextEditingController(text: widget.car.address);
    priceController = TextEditingController(text: widget.car.price ?? '');
    plateController = TextEditingController(text: widget.car.plateNumber);
  }

  @override
  void dispose() {
    descController.dispose();
    addressController.dispose();
    priceController.dispose();
    plateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedImage = picked;
      });
    }
  }

  Future<void> _save() async {
    if (isSaving) return;
    setState(() => isSaving = true);

    String? uploadedUrl;
    try {
      if (pickedImage != null) {
        uploadedUrl = await Get.find<HomeController>().uploadImageToCloudinary(
          File(pickedImage!.path),
        );
      }

      await Get.find<HomeController>().updateCar(
        widget.car,
        desc: descController.text.trim(),
        address: addressController.text.trim(),
        imageUrl: uploadedUrl,
        price: priceController.text.trim(),
        plateNumber: plateController.text.trim(),
      );

      showCustomSnackbar('نجاح', 'تم حفظ التعديلات بنجاح');
      try {
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().refreshData();
        }
      } catch (e) {
        print('Error refreshing HomeController after edit: $e');
      }
      Get.offAllNamed('/home');
    } catch (e) {
      print('Error saving car edit: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ أثناء حفظ التعديلات');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل الإعلان'),
        backgroundColor: primaryblue,
        actions: [
          TextButton(
            onPressed: isSaving ? null : _save,
            child: Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pickedImage != null
                          ? Image.file(
                              File(pickedImage!.path),
                              fit: BoxFit.cover,
                            )
                          : (widget.car.image.isNotEmpty
                                ? Image.network(
                                    widget.car.image,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: primaryblue,
                                    ),
                                  )),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: 'الوصف'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'مكان التواجد'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'السعر (نص)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: plateController,
                  decoration: InputDecoration(
                    labelText: 'رقم اللوحة',
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                ),
                SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryblue),
                  onPressed: isSaving ? null : _save,
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('حفظ')),
                  ),
                ),
              ],
            ),
          ),
          if (isSaving)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
