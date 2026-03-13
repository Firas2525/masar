import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/course_model.dart';
import '../widgets/custom_snackbar.dart';

class CourseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final isLoading = false.obs;
  final courses = <CourseModel>[].obs;
  final selectedCourse = Rxn<CourseModel>();
  final currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  void _initializeUser() {
    try {
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          currentUserId.value = user.uid;
          _loadCourses();
        } else {
          Get.offAllNamed('/login');
        }
      });
    } catch (e) {
      print('Error in _initializeUser: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تهيئة المستخدم");
    }
  }

  Future<void> _loadCourses() async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await _firestore
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .get();

      final loadedCourses = querySnapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
          .toList();

      courses.value = loadedCourses;
    } catch (e) {
      print('Error loading courses: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل الدورات");
      courses.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCourses() async {
    await _loadCourses();
  }

  Future<void> joinCourse(String courseId) async {
    try {
      if (currentUserId.value.isEmpty) {
        showCustomSnackbar("خطأ", "يجب تسجيل الدخول أولاً");
        return;
      }

      final courseDoc = await _firestore
          .collection('courses')
          .doc(courseId)
          .get();

      if (!courseDoc.exists) {
        showCustomSnackbar("خطأ", "الدورة غير موجودة");
        return;
      }

      final courseData = courseDoc.data()!;
      final currentUsers = List<String>.from(courseData['users'] ?? []);

      if (currentUsers.contains(currentUserId.value)) {
        showCustomSnackbar("تنبيه", "أنت مسجل بالفعل في هذه الدورة");
        return;
      }

      if (currentUsers.length >= courseData['total_num']) {
        showCustomSnackbar("تنبيه", "الدورة ممتلئة");
        return;
      }

      currentUsers.add(currentUserId.value);

      await _firestore
          .collection('courses')
          .doc(courseId)
          .update({'users': currentUsers});

      showCustomSnackbar("نجح", "تم الانضمام للدورة بنجاح");
      await refreshCourses();
    } catch (e) {
      print('Error joining course: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في الانضمام للدورة");
    }
  }

  Future<void> leaveCourse(String courseId) async {
    try {
      if (currentUserId.value.isEmpty) {
        showCustomSnackbar("خطأ", "يجب تسجيل الدخول أولاً");
        return;
      }

      final courseDoc = await _firestore
          .collection('courses')
          .doc(courseId)
          .get();

      if (!courseDoc.exists) {
        showCustomSnackbar("خطأ", "الدورة غير موجودة");
        return;
      }

      final courseData = courseDoc.data()!;
      final currentUsers = List<String>.from(courseData['users'] ?? []);

      if (!currentUsers.contains(currentUserId.value)) {
        showCustomSnackbar("تنبيه", "أنت غير مسجل في هذه الدورة");
        return;
      }

      currentUsers.remove(currentUserId.value);

      await _firestore
        .collection('courses')
          .doc(courseId)
          .update({'users': currentUsers});

      showCustomSnackbar("نجح", "تم الانسحاب من الدورة بنجاح");
      await refreshCourses();
    } catch (e) {
      print('Error leaving course: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في الانسحاب من الدورة");
    }
  }

  bool isUserJoined(String courseId) {
    final course = courses.firstWhereOrNull((c) => c.id == courseId);
    if (course == null) return false;
    return course.users.contains(currentUserId.value);
  }

  int getJoinedUsersCount(String courseId) {
    final course = courses.firstWhereOrNull((c) => c.id == courseId);
    return course?.users.length ?? 0;
  }

  void selectCourse(CourseModel course) {
    selectedCourse.value = course;
  }

  void clearSelectedCourse() {
    selectedCourse.value = null;
  }

  List<CourseModel> getCoursesForCategory(String category) {
    return courses.where((course) => course.forr == category).toList();
  }

  List<String> getAvailableCategories() {
    return courses.map((course) => course.forr).toSet().toList();
  }

  List<CourseModel> getCoursesByPriceRange(double minPrice, double maxPrice) {
    return courses.where((course) {
      final price = _extractPriceFromString(course.cost);
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  double _extractPriceFromString(String priceString) {
    try {
      final numbers = RegExp(r'\d+').allMatches(priceString);
      if (numbers.isNotEmpty) {
        return double.parse(numbers.first.group(0)!);
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
