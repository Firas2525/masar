import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../color.dart';
import '../../controller/add_child_controller.dart';

const Color backgroundColor = Color(0xFFF7F9FC);

// التدرجات اللونية
LinearGradient primaryGradient = LinearGradient(
  colors: [primaryblue, primaryblue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AddChildPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddChildController());

    // تأكد من أن الكونترولر تم تهيئته بشكل صحيح
    print('AddChildController initialized: ${controller.hashCode}');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(context, controller),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: primaryblue),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'إضافة سيارة جديدة',
        style: TextStyle(
          color: primaryblue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, AddChildController controller) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 30),
                    _buildImagePicker(controller),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.titleController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'عنوان الإعلان',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.title,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.brandController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'العلامة التجارية',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // سعر السيارة (نص قابل للتعديل)
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.priceController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'السعر (نص)',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // رقم الهاتف
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'رقم الهاتف',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.phone,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // لون السيارة
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.colorController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'لون السيارة',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.format_paint,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // رقم اللوحة
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.plateController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'رقم اللوحة',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.confirmation_number,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.fuelController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'نوع الوقود',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.bodyTypeController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'نوع الهيكل',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.mileageController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'عدد الكيلومترات',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.addressController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'مكان التواجد',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // وصف الإعلان
                    Container(
                      decoration: BoxDecoration(
                        color: primaryWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller.descriptionController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                        maxLines: 4,
                        style: TextStyle(color: primaryBlack, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: primaryWhite,
                          labelText: 'وصف الإعلان',
                          labelStyle: TextStyle(
                            color: primaryBlack.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.description,
                            color: primaryblue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    _buildTransSelection(controller),
                    SizedBox(height: 30),
                    _buildSubmitButton(controller),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
          // Loading overlay
          GetX<AddChildController>(
            builder: (controller) => controller.isLoading.value || controller.isSubmitting.value
                ? Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: primaryblue),
                            SizedBox(height: 15),
                            Text(
                              'جاري إضافة الإعلان...',
                              style: TextStyle(
                                color: primaryBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryblue.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_car_filled,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة سيارتك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'أدخل بيانات السيارة للتسجيل',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(AddChildController controller) {
    return GetBuilder<AddChildController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: Get.context!,
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('اختيار من المعرض'),
                        onTap: () async {
                          await controller.pickImage(ImageSource.gallery);
                          Get.back();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('التقاط صورة'),
                        onTap: () async {
                          await controller.pickImage(ImageSource.camera);
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: primaryWhite,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: controller.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        controller.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: primaryblue),
                          SizedBox(height: 8),
                          Text('اضغط لاختيار صورة', style: TextStyle(color: primaryBlack.withOpacity(0.7))),
                        ],
                      ),
                    ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryblue,
                  ),
                  onPressed: () async {
                    await controller.pickImage(ImageSource.gallery);
                  },
                  icon: Icon(Icons.photo),
                  label: Text('معرض'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    await controller.pickImage(ImageSource.camera);
                  },
                  icon: Icon(Icons.camera_alt),
                  label: Text('كاميرا'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransSelection(AddChildController controller) {
    return Container(
      decoration: BoxDecoration(
        color: primaryWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car_filled, color: primaryblue),
                SizedBox(width: 10),
                Text(
                  'ناقل الحركة',
                  style: TextStyle(
                    color: primaryBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption(
                    controller,
                    'عادي',
                    'عادي',
                    Icons.directions_car_outlined,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildGenderOption(
                    controller,
                    'أوتوماتيك',
                    'أوتوماتيك',
                    Icons.directions_car_outlined,
                    Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    AddChildController controller,
    String gender,
    String label,
    IconData icon,
    Color color,
  ) {
    return GetX<AddChildController>(
      builder: (controller) => GestureDetector(
        onTap: () => controller.selectGender(gender),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            color: controller.selectedGender.value == gender
                ? color.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.selectedGender.value == gender
                  ? color
                  : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: controller.selectedGender.value == gender
                    ? color
                    : Colors.grey,
                size: 30,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: controller.selectedGender.value == gender
                      ? color
                      : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AddChildController controller) {
    return GetX<AddChildController>(
      builder: (controller) => Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: primaryblue.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (controller.isSubmitting.value || controller.isLoading.value) ? null : () {
              if (controller.formKey.currentState?.validate() ?? false) {
                controller.addAd();
              } else {
                Get.snackbar('خطأ', 'يرجى تعبئة جميع الحقول');
              }
            },
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: (controller.isSubmitting.value || controller.isLoading.value)
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إضافة السيارة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
