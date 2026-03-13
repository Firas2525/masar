import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/home_model.dart';
import '../widgets/custom_snackbar.dart';

class ChildLocationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final isLoading = false.obs;
  final currentUserId = ''.obs;
  final selectedChild = Rxn<Child>();
  final childLocation = 'في المنزل'.obs;
  final locationHistory = <Map<String, dynamic>>[].obs;
  
  StreamSubscription<DocumentSnapshot>? _locationSubscription;

  ChildLocationController([Child? child]) {
    if (child != null) {
      selectedChild.value = child;
      childLocation.value = child.location;
      _startLocationTracking(child.id);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    super.onClose();
  }

  void _initializeUser() {
    try {
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          currentUserId.value = user.uid;
        } else {
          Get.offAllNamed('/login');
        }
      });
    } catch (e) {
      print('Error in _initializeUser: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تهيئة المستخدم");
    }
  }

  void selectChild(Child child) {
    selectedChild.value = child;
    childLocation.value = child.location;
    _startLocationTracking(child.id);
    _loadLocationHistory(child.id);
  }

  void _startLocationTracking(String childId) {
    _locationSubscription?.cancel();
    
    _locationSubscription = _firestore
        .collection('children')
        .doc(childId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final newLocation = data['location']?.toString() ?? 'في المنزل';

        if (newLocation != childLocation.value) {
          childLocation.value = newLocation;
          _addToLocationHistory(newLocation);
        }
      }
    }, onError: (error) {
      print('Error tracking child location: $error');
      showCustomSnackbar("خطأ", "حدث خطأ في تتبع موقع الطفل");
    });
  }

  Future<void> _loadLocationHistory(String childId) async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await _firestore
          .collection('location_history')
          .where('childId', isEqualTo: childId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      locationHistory.value = querySnapshot.docs
          .map((doc) => {
                'location': doc.data()['location'] ?? '',
                'timestamp': (doc.data()['timestamp'] as Timestamp).toDate(),
                'updatedBy': doc.data()['updatedBy'] ?? '',
              })
          .toList();
    } catch (e) {
      print('Error loading location history: $e');
      locationHistory.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _addToLocationHistory(String location) {
    final historyEntry = {
      'location': location,
      'timestamp': DateTime.now(),
      'updatedBy': 'system',
    };
    
    locationHistory.insert(0, historyEntry);
    
    // الاحتفاظ بآخر 20 سجل فقط
    if (locationHistory.length > 20) {
      locationHistory.removeRange(20, locationHistory.length);
    }
  }

  // تحديث موقع الطفل (للمعلمين أو الإدارة)
  Future<void> updateChildLocation(String newLocation) async {
    if (selectedChild.value == null) {
      showCustomSnackbar("خطأ", "لم يتم اختيار طفل");
      return;
    }

    try {
      isLoading.value = true;
      
      final childId = selectedChild.value!.id;
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        showCustomSnackbar("خطأ", "يجب تسجيل الدخول أولاً");
        return;
      }

      // تحديث موقع الطفل في Firestore
      await _firestore.collection('children').doc(childId).update({
        'location': newLocation,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });

      // إضافة سجل في التاريخ
      await _firestore.collection('location_history').add({
        'childId': childId,
        'location': newLocation,
        'timestamp': FieldValue.serverTimestamp(),
        'updatedBy': currentUser.uid,
      });

      childLocation.value = newLocation;
      showCustomSnackbar("نجح", "تم تحديث موقع الطفل بنجاح");
      
    } catch (e) {
      print('Error updating child location: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحديث موقع الطفل");
    } finally {
      isLoading.value = false;
    }
  }

  // الحصول على أيقونة الموقع
  IconData getLocationIcon() {
    switch (childLocation.value) {
      case 'في الروضة':
        return Icons.school;
      case 'في الباص':
        return Icons.directions_bus;
      case 'في المنزل':
        return Icons.home;
      default:
        return Icons.location_on;
    }
  }

  // الحصول على لون الموقع
  Color getLocationColor() {
    switch (childLocation.value) {
      case 'في الروضة':
        return Colors.green;
      case 'في الباص':
        return Colors.orange;
      case 'في المنزل':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get locationArabicText {
    switch (childLocation.value) {
      case 'bus':
        return 'في الباص';
      case 'home':
        return 'في المنزل';
      case 'kindergarten':
        return 'في الروضة';
      default:
        // دعم القيم القديمة أو النصوص العربية مباشرة
        if (childLocation.value == 'في الباص' || childLocation.value == 'في المنزل' || childLocation.value == 'في الروضة') {
          return childLocation.value;
        }
        return 'في المنزل';
    }
  }

  // تنسيق الوقت
  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // تنسيق التاريخ
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
} 