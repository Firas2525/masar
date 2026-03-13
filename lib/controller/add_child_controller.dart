import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_snackbar.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'home_controller.dart';

class AddChildController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // Controllers for form fields
  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final mileageController = TextEditingController();
  final colorController = TextEditingController();
  final fuelController = TextEditingController();
  final transController = TextEditingController();
  final brandController = TextEditingController();
  final addressController = TextEditingController();
  final bodyTypeController = TextEditingController();
  final birthDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final plateController = TextEditingController();
  final phoneController = TextEditingController();

  // Observable variables
  final selectedGender = 'عادي'.obs;
  final selectedClass = Rx<Map<String, dynamic>?>(null);
  final classes = <Map<String, dynamic>>[].obs;
  final nextKid = 0.obs;
  PageController addsController = PageController();
  int addsCurrentPage = 0;
  int first_time = 1;
  File? _image;
  File? get image => _image;
  final picker = ImagePicker();
  String? uploadedImageUrl;

  // Form key for validation
  final formKey = GlobalKey<FormState>();
  // قيم Cloudinary (من Dashboard)
  final String cloudName = "ddpk9jmfc";
  final String uploadPreset = "firas_image"; // أنشئه من Cloudinary Dashboard

  Future pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      update();
    } else {
      return null;
    }
    return _image;
  }

  Future uploadImageToCloudinary() async {
    File? imageFile = _image ?? await pickImage(ImageSource.gallery);
    print(imageFile);
    if (imageFile == null) {
      print("ok");
      return null;
    }
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final resData = await http.Response.fromStream(response);
        final data = jsonDecode(resData.body);

        uploadedImageUrl = data['secure_url'];
        update();

        return data['secure_url'];
      } else {
        print("❌ فشل الرفع: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('AddChildController onInit called');
    try {
      _loadClasses();
      _getNextKidNumber();
      print('AddChildController initialization completed');
    } catch (e) {
      print('Error in AddChildController onInit: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    birthDateController.dispose();
    priceController.dispose();
    plateController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> addAd() async {
    // تحقق من الحقول المطلوبة محلياً
    if (titleController.text.trim().isEmpty ||
        brandController.text.trim().isEmpty ||
        fuelController.text.trim().isEmpty ||
        bodyTypeController.text.trim().isEmpty ||
        mileageController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      showCustomSnackbar("خطأ", "يرجى تعبئة جميع الحقول المطلوبة");
      return;
    }

    if (_image == null) {
      showCustomSnackbar("خطأ", "يجب اختيار صورة");
      return;
    }

    isLoading.value = true;

    var image = await uploadImageToCloudinary();
    if (image == null) {
      showCustomSnackbar("خطأ", "فشل رفع الصورة");

      isLoading.value = false;

      return;
    }
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        showCustomSnackbar("خطأ", "يجب تسجيل الدخول أولاً");

        isLoading.value = false;

        return;
      }

      // التحقق من وجود المستخدم في Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) {
        showCustomSnackbar("خطأ", "بيانات المستخدم غير موجودة");

        isLoading.value = false;

        return;
      }

      final ad = {
        'image': "$image",
        'fuelType': fuelController.text,
        'title': titleController.text,
        'desc': descriptionController.text,
        'price': priceController.text.trim(),
        'phone': phoneController.text.trim(),
        'bodyType': bodyTypeController.text,
        'mileageKill': mileageController.text,
        'trans': selectedGender.value,
        'brand': brandController.text,
        'color': colorController.text,
        'address': addressController.text,
        'plateNumber': plateController.text.trim(),
        'docs': {},
        'userId': currentUser.uid, // إرسال UID كسلسلة نصية بدون user/
        'registerDate': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('car').add(ad);

      showCustomSnackbar("نجح", "تم إضافة اعلان بنجاح");
      try {
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().refreshData();
        }
      } catch (e) {
        print('Error refreshing HomeController after addAd: $e');
      }
      // Return to main home page
      Get.offAllNamed('/home');
    } catch (e) {
      print('Error adding child: $e');
      if (e.toString().contains('permission-denied')) {
        showCustomSnackbar(
          "خطأ",
          "ليس لديك صلاحية لإضافة طفل. تحقق من قواعد الأمان",
        );
      } else if (e.toString().contains('unavailable')) {
        showCustomSnackbar(
          "خطأ",
          "خدمة Firestore غير متاحة. تحقق من الاتصال بالإنترنت",
        );
      } else {
        showCustomSnackbar("خطأ", "حدث خطأ في إضافة الطفل: ${e.toString()}");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // جلب الصفوف من Firestore
  Future<void> _loadClasses() async {
    try {
      isLoading.value = true;

      final querySnapshot = await _firestore.collection('class').get();

      classes.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
        };
      }).toList();

      print('Loaded ${classes.length} classes successfully');
    } catch (e) {
      print('Error loading classes: $e');
      if (e.toString().contains('permission-denied')) {
        showCustomSnackbar("خطأ", "ليس لديك صلاحية لتحميل الصفوف");
      } else {
        showCustomSnackbar("خطأ", "حدث خطأ في تحميل الصفوف");
      }
      classes.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // جلب الرقم التالي للطالب
  Future<void> _getNextKidNumber() async {
    try {
      final doc = await _firestore.collection('Numbers').doc('kId').get();

      if (doc.exists) {
        nextKid.value = (doc.data()?['kId'] ?? 0) + 1;
        print('Next kid number: ${nextKid.value}');
      } else {
        nextKid.value = 1;
        print('No existing kid number, starting with: ${nextKid.value}');
      }
    } catch (e) {
      print('Error getting next kid number: $e');
      nextKid.value = 1;
      print('Using default kid number: ${nextKid.value}');
    }
  }

  // تحديث رقم الطالب في Firestore
  Future<void> _updateKidNumber() async {
    try {
      await _firestore.collection('Numbers').doc('kId').set({
        'kId': nextKid.value,
      }, SetOptions(merge: true));
      print('Kid number updated to: ${nextKid.value}');
    } catch (e) {
      print('Error updating kid number: $e');
      // لا نريد إيقاف العملية إذا فشل تحديث الرقم
      // يمكن إعادة المحاولة لاحقاً
    }
  }

  // اختيار الجنس
  void selectGender(String gender) {
    print('Selecting gender: $gender');
    selectedGender.value = gender;
    print('Selected gender updated: ${selectedGender.value}');
  }

  // اختيار الصف
  void selectClass(Map<String, dynamic> classData) {
    print('Selecting class: ${classData['name']}');
    selectedClass.value = classData;
    print('Selected class updated: ${selectedClass.value?['name']}');
  }

  // اختيار تاريخ الميلاد
  Future<void> selectBirthDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(
          Duration(days: 365 * 3),
        ), // 3 سنوات
        firstDate: DateTime.now().subtract(
          Duration(days: 365 * 10),
        ), // 10 سنوات
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        print('Selected birth date: ${birthDateController.text}');
      }
    } catch (e) {
      print('Error selecting birth date: $e');
      // Fallback: Set a default date
      final defaultDate = DateTime.now().subtract(Duration(days: 365 * 3));
      birthDateController.text =
          "${defaultDate.day.toString().padLeft(2, '0')}-${defaultDate.month.toString().padLeft(2, '0')}-${defaultDate.year}";
      showCustomSnackbar(
        "تنبيه",
        "تم تعيين تاريخ افتراضي. يمكنك تعديله لاحقاً",
      );
    }
  }

  // إضافة الطفل
  Future<void> addChild() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedClass.value == null) {
      showCustomSnackbar("خطأ", "يرجى اختيار الصف");
      return;
    }

    try {
      isSubmitting.value = true;
      showCustomSnackbar("جاري الإضافة", "يرجى الانتظار...");

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        showCustomSnackbar("خطأ", "يجب تسجيل الدخول أولاً");
        return;
      }

      // التحقق من وجود المستخدم في Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) {
        showCustomSnackbar("خطأ", "بيانات المستخدم غير موجودة");
        return;
      }

      // إنشاء بيانات الطفل
      final childData = {
        'name': nameController.text.trim(),
        'gender': selectedGender.value,
        'birthDate': birthDateController.text,
        'classroom':
            selectedClass.value!['name'], // استخدام اسم الصف بدلاً من ID
        'kId': nextKid.value,
        'parentId': currentUser.uid, // إرسال UID كسلسلة نصية بدون user/
        'registerDate': FieldValue.serverTimestamp(),
        'approved': 'wait',
      };

      print('Adding child with data: $childData');

      // إضافة الطفل إلى Firestore
      final childRef = await _firestore.collection('children').add(childData);
      print('Child added successfully with ID: ${childRef.id}');

      // تحديث رقم الطالب
      await _updateKidNumber();
      print('Kid number updated successfully');

      // إضافة الطفل إلى قائمة أطفال المستخدم
      await _firestore.collection('users').doc(currentUser.uid).update({
        'children': FieldValue.arrayUnion([childRef]),
      });
      print('Child added to user children array');

      showCustomSnackbar("نجح", "تم إضافة الطفل بنجاح");

      // إعادة تعيين النموذج
      _resetForm();

      // العودة للصفحة الرئيسية مع تحديثها
      Get.offAllNamed('/home');
    } catch (e) {
      print('Error adding child: $e');
      if (e.toString().contains('permission-denied')) {
        showCustomSnackbar(
          "خطأ",
          "ليس لديك صلاحية لإضافة طفل. تحقق من قواعد الأمان",
        );
      } else if (e.toString().contains('unavailable')) {
        showCustomSnackbar(
          "خطأ",
          "خدمة Firestore غير متاحة. تحقق من الاتصال بالإنترنت",
        );
      } else {
        showCustomSnackbar("خطأ", "حدث خطأ في إضافة الطفل: ${e.toString()}");
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // إعادة تعيين النموذج
  void _resetForm() {
    nameController.clear();
    birthDateController.clear();
    selectedGender.value = 'male';
    selectedClass.value = null;
    formKey.currentState?.reset();
  }

  // التحقق من صحة الاسم
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال اسم الطفل';
    }
    if (value.trim().length < 2) {
      return 'يجب أن يكون الاسم أكثر من حرفين';
    }
    return null;
  }

  // التحقق من صحة تاريخ الميلاد
  String? validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى اختيار تاريخ الميلاد';
    }
    return null;
  }
}
