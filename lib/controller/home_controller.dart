import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../model/home_model.dart';
import '../widgets/custom_snackbar.dart';
import 'login_controller.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  List children = <Child>[];
  List<Car> cars = <Car>[];
  List announcements = <Announcement>[];
  String userName = '';
  String userId = '';
  bool isServiceOwner = false;
  Map<String, dynamic>? serviceProfile;
  PageController addsController = PageController();
  int addsCurrentPage = 0;
  int first_time = 1;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Cloudinary config
  final String cloudName = "ddpk9jmfc";
  final String uploadPreset = "firas_image";

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  @override
  void onReady() {
    super.onReady();
    // تحديث البيانات عند العودة للصفحة
    refreshData();
  }

  // تحديث البيانات عند العودة من صفحة إضافة طفل
  Future<void> refreshData() async {
    await _initializeUserData();
  }

  void _initializeUser() {
    try {
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          userId = user.uid;
          print('User ID: ${user.uid}');
          _initializeUserData();
        } else {
          Get.offAllNamed('/login');
        }
      });
    } catch (e) {
      print('Error in _initializeUser: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تهيئة المستخدم");
    }
  }

  Future<void> _initializeUserData() async {
    try {
      await _loadUserData();
      await _loadChildren();
      await _loadCars();
      await _loadAnnouncements();
    } catch (e) {
      print('Error loading initial data: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل البيانات");
    }
  }

  Future<void> addAd(Function f) async {
    var image = await f();
    try {
      isLoading = true;
      update();
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
      final childData = {'title': "title", 'content': "$image"};
      // إضافة الطفل إلى Firestore
      await _firestore.collection('advertisments').add(childData);

      showCustomSnackbar("نجح", "تم إضافة اعلان بنجاح");
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
      isLoading = false;
      update();
    }
  }

  Future<void> _loadUserData() async {
    if (userId.isEmpty) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>? ?? {};
        userName = data['name'] ?? '';
        isServiceOwner = data['isServiceOwner'] == true;
        serviceProfile =
            data['serviceProfile'] != null && data['serviceProfile'] is Map
            ? Map<String, dynamic>.from(data['serviceProfile'])
            : null;
        update();
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error in _loadUserData: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في جلب بيانات المستخدم");
    }
  }

  /// Set or update the current user's display name (used when a new user has no name)
  Future<void> setUserName(String name) async {
    if (userId.isEmpty) {
      showCustomSnackbar('خطأ', 'لم يتم تسجيل الدخول');
      return;
    }
    try {
      isLoading = true;
      update();
      await _firestore.collection('users').doc(userId).set({'name': name}, SetOptions(merge: true));
      userName = name;
      update();
      showCustomSnackbar('نجح', 'تم تحديث اسم المستخدم');
    } catch (e) {
      print('Error setting user name: $e');
      showCustomSnackbar('خطأ', 'فشل تحديث اسم المستخدم');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _loadChildren() async {
    if (userId.isEmpty) return;

    try {
      isLoading = true;
      update();
      print('Loading children for user: ${userId}');

      // البحث عن الأطفال المرتبطين بالمستخدم
      final childrenQuery = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: userId)
          .get();

      print('Found ${childrenQuery.docs.length} children');

      if (childrenQuery.docs.isEmpty) {
        print('No children found for user');
        children = [];
        return;
      }

      children = childrenQuery.docs
          .map((doc) {
            try {
              final child = Child.fromFirestore(doc.data(), doc.id);
              print(
                'Loaded child: ${child.name} (ID: ${child.id}, kId: ${child.kId})',
              );
              return child;
            } catch (e) {
              print('Error parsing child document ${doc.id}: $e');
              print('Document data: ${doc.data()}');
              return null;
            }
          })
          .where((child) => child != null)
          .cast<Child>()
          .toList();
      update();
      print('Successfully loaded ${children.length} children for user');
    } catch (e) {
      print('Error in _loadChildren: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في جلب بيانات الأطفال");
      children = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      final query = await _firestore.collection('advertisments').get();

      final loadedAnnouncements = query.docs
          .map((doc) => Announcement.fromFirestore(doc.data(), doc.id))
          .toList();

      announcements = loadedAnnouncements;
      print('Loaded ${announcements.length} announcements');

      // Prefetch announcement images so they display instantly on navigation
      try {
        for (final a in announcements) {
          final content = (a as Announcement).content;
          final isImageUrl =
              content.startsWith('http') &&
              (content.endsWith('.png') ||
                  content.endsWith('.jpg') ||
                  content.endsWith('.jpeg') ||
                  content.endsWith('.webp'));
          if (isImageUrl) {
            // trigger cache download; don't block the flow
            try {
              await DefaultCacheManager().getSingleFile(content);
            } catch (e) {
              print('Prefetch failed for $content: $e');
            }
          }
        }
      } catch (e) {
        print('Error prefetching announcement images: $e');
      }

      try {
        if (first_time == 1) {
          Timer.periodic(const Duration(seconds: 5), (timer) {
            if (addsController.hasClients) {
              if (addsController.page! < announcements.length - 1) {
                addsController.nextPage(
                  duration: const Duration(milliseconds: 1),
                  curve: Curves.easeInOut,
                );
                update();
              } else {
                addsController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 1),
                  curve: Curves.easeInOut,
                );
                update();
              }
            }
            update();
          });
        }
        first_time++;
      } catch (e) {
        print(e);
      }
    } catch (e) {
      print('Error in _loadAnnouncements: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل الإعلانات");
      announcements = [];
    }
  }

  // تحميل الإعلانات من مجموعة 'car' (السيارات المعروضة)
  Future<void> _loadCars() async {
    try {
      final query = await _firestore.collection('car').get();
      final loadedCars = query.docs
          .map((doc) => Car.fromFirestore(doc.data(), doc.id))
          .toList();
      cars = loadedCars;
      print('Loaded ${cars.length} cars');
      update();
    } catch (e) {
      print('Error loading cars: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل السيارات");
      cars = [];
      update();
    }
  }

  // رفع صورة إلى Cloudinary. إذا لم يُحدد ملف، سنفتح معرض الصور ليختار المستخدم
  Future<String?> uploadImageToCloudinary([File? imageFile]) async {
    try {
      File? fileToUpload = imageFile;
      if (fileToUpload == null) {
        // lazy import/pick to avoid changing other parts
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked == null) return null;
        fileToUpload = File(picked.path);
      }

      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );
      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', fileToUpload.path),
        );

      final response = await request.send();
      if (response.statusCode == 200) {
        final resData = await http.Response.fromStream(response);
        final data = jsonDecode(resData.body);
        return data['secure_url'];
      } else {
        print('Cloudinary upload failed: ${response.statusCode}');
        showCustomSnackbar("خطأ", "فشل رفع الصورة: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في رفع الصورة");
      return null;
    }
  }

  // تحديث بيانات السيارة
  // Track per-car state for operations like toggling isForSale
  final Map<String, bool> _isUpdatingCar = {};

  bool isCarUpdating(String carId) => _isUpdatingCar[carId] == true;

  Future<void> _setCarUpdating(String carId, bool v) async {
    _isUpdatingCar[carId] = v;
    update();
  }

  // Track per-document upload state (keyed by "$carId_field", e.g. "abc123_mechanic")
  final Map<String, bool> _isUploadingImage = {};

  bool isImageUploading(String key) => _isUploadingImage[key] == true;

  Future<void> _setImageUploading(String key, bool v) async {
    _isUploadingImage[key] = v;
    update();
  }

  /// Upload a document image for the given car and field.
  /// field should be 'mechanic' or 'license' (or other keys supported by updateCar).
  Future<void> uploadCarDocument(Car car, String field) async {
    final key = "${car.id}_$field";
    await _setImageUploading(key, true);
    try {
      final url = await uploadImageToCloudinary();
      if (url != null) {
        if (field == 'mechanic') {
          await updateCar(car, mechanicImage: url);
        } else if (field == 'license') {
          await updateCar(car, licenseImage: url);
        } else {
          // Generic setter for other potential fields
          await updateCar(car, imageUrl: url);
        }
      } else {
        showCustomSnackbar("خطأ", "لم يتم اختيار صورة أو فشل الرفع");
      }
    } catch (e) {
      print('Error uploading document for $key: $e');
      showCustomSnackbar("خطأ", "حدث خطأ أثناء رفع الصورة");
    } finally {
      await _setImageUploading(key, false);
    }
  }

  Future<void> updateCar(
    Car car, {
    String? desc,
    String? address,
    String? imageUrl,
    String? title,
    String? mechanicImage,
    String? licenseImage,
    bool? isForSale,
    String? price,
    String? plateNumber,
  }) async {
    try {
      isLoading = true;
      update();
      final data = <String, dynamic>{};
      if (desc != null) data['desc'] = desc;
      if (address != null) data['address'] = address;
      if (imageUrl != null) data['image'] = imageUrl;
      if (title != null) data['title'] = title;
      if (price != null) data['price'] = price;
      if (mechanicImage != null) data['mechanicImage'] = mechanicImage;
      if (licenseImage != null) data['licenseImage'] = licenseImage;
      if (isForSale != null) data['isForSale'] = isForSale;
      if (plateNumber != null) data['plateNumber'] = plateNumber;

      await _firestore
          .collection('car')
          .doc(car.id)
          .set(data, SetOptions(merge: true));

      // إعادة تحميل السيارات
      await _loadCars();

      showCustomSnackbar("نجح", "تم تحديث بيانات السيارة");
    } catch (e) {
      print('Error updating car: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحديث بيانات السيارة");
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Toggle isForSale with per-car loading indicator
  Future<void> toggleCarSale(Car car, bool val) async {
    await _setCarUpdating(car.id, true);
    try {
      await updateCar(car, isForSale: val);
    } catch (e) {
      rethrow;
    } finally {
      await _setCarUpdating(car.id, false);
    }
  }

  // إضافة سجل صيانة
  Future<void> addMaintenanceRecord(
    String carId,
    Map<String, dynamic> record,
  ) async {
    try {
      isLoading = true;
      update();
      await _firestore.collection('car').doc(carId).update({
        'maintenance': FieldValue.arrayUnion([record]),
      });
      await _loadCars();
      showCustomSnackbar("نجح", "تم إضافة سجل الصيانة");
    } catch (e) {
      print('Error adding maintenance record: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إضافة سجل الصيانة");
    } finally {
      isLoading = false;
      update();
    }
  }

  // Stream of available service centers (users who are marked as service owners)
  Stream<List<Map<String, dynamic>>> streamServiceCenters() {
    try {
      return _firestore
          .collection('users')
          .where('isServiceOwner', isEqualTo: true)
          .snapshots()
          .map((snap) {
            return snap.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              // include the document id so callers can reference the uid
              return <String, dynamic>{...data, 'uid': d.id};
            }).toList();
          });
    } catch (e) {
      print('Error creating service centers stream: $e');
      return const Stream.empty();
    }
  }

  // Create a maintenance request assigned to a service center
  Future<void> createMaintenanceRequest({
    required String carId,
    required String type,
    required String details,
    required String userId,
    required String serviceCenterId,
    List<String>? images,
  }) async {
    try {
      final req = CarRequest(
        id: '',
        carId: carId,
        userId: userId,
        type: type,
        details: details,
        images: images ?? [],
        status: 'pending',
        response: '',
        serviceCenterId: serviceCenterId,
        createdAt: DateTime.now(),
        createdAtClient: DateTime.now().toIso8601String(),
      );

      await _firestore.collection('car_requests').add(req.toMap());
      showCustomSnackbar('نجح', 'تم إرسال طلب الصيانة');
    } catch (e) {
      print('Error creating maintenance request: $e');
      showCustomSnackbar('خطأ', 'فشل إرسال طلب الصيانة');
    }
  }

  // Stream all requests assigned to a service owner
  Stream<List<CarRequest>> streamRequestsForServiceOwner(String ownerUid) {
    try {
      return _firestore
          .collection('car_requests')
          .where('serviceCenterId', isEqualTo: ownerUid)
          .snapshots()
          .map((snap) {
            final list = snap.docs
                .map((d) => CarRequest.fromFirestore(d.data(), d.id))
                .toList();
            list.sort((a, b) {
              int aTs =
                  a.createdAt?.millisecondsSinceEpoch ??
                  (a.createdAtClient != null
                      ? (DateTime.tryParse(
                              a.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              int bTs =
                  b.createdAt?.millisecondsSinceEpoch ??
                  (b.createdAtClient != null
                      ? (DateTime.tryParse(
                              b.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              return bTs.compareTo(aTs);
            });
            return list;
          });
    } catch (e) {
      print('Error creating service owner requests stream: $e');
      return const Stream.empty();
    }
  }

  // Stream all requests for a specific car (all users, all statuses)
  Stream<List<CarRequest>> streamRequestsForCar(String carId) {
    try {
      return _firestore
          .collection('car_requests')
          .where('carId', isEqualTo: carId)
          .snapshots()
          .map((snap) {
            final list = snap.docs
                .map((d) => CarRequest.fromFirestore(d.data(), d.id))
                .toList();
            list.sort((a, b) {
              int aTs =
                  a.createdAt?.millisecondsSinceEpoch ??
                  (a.createdAtClient != null
                      ? (DateTime.tryParse(
                              a.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              int bTs =
                  b.createdAt?.millisecondsSinceEpoch ??
                  (b.createdAtClient != null
                      ? (DateTime.tryParse(
                              b.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              return bTs.compareTo(aTs);
            });
            return list;
          });
    } catch (e) {
      print('Error creating car requests stream: $e');
      return const Stream.empty();
    }
  }

  // Add a violation record to a car (manager action)
  Future<bool> addViolation(String carId, Map<String, dynamic> violation) async {
    try {
      // Generate a unique ID for this violation
      final violationId = _firestore.collection('car').doc().id;
      violation['id'] = violationId;
      
      await _firestore.collection('car').doc(carId).update({
        'violations': FieldValue.arrayUnion([violation]),
      });
      await _loadCars();
      showCustomSnackbar('نجح', 'تمت إضافة المخالفة');
      return true;
    } catch (e) {
      print('Error adding violation: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ أثناء إضافة المخالفة');
      return false;
    }
  }

  // Update a violation (replace old map with new map)
  // Normalize violation status to English format (pending/approved/rejected)
  String _normalizeViolationStatus(String status) {
    final s = (status ?? '').toString().toLowerCase();
    if (s.contains('pending') || s.contains('قيد') || s.contains('waiting')) return 'pending';
    if (s.contains('approved') || s.contains('مقبول')) return 'approved';
    if (s.contains('rejected') || s.contains('مرفوض')) return 'rejected';
    return status; // keep as-is if unrecognized
  }

  Future<bool> updateViolation(String carId, Map<String, dynamic> oldViolation, Map<String, dynamic> newViolation) async {
    try {
      final docRef = _firestore.collection('car').doc(carId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        showCustomSnackbar('خطأ', 'سيارة غير موجودة');
        return false;
      }
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final v = data['violations'];
      List<Map<String, dynamic>> violations = [];
      if (v != null && v is List) {
        violations = (v as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      // Replace the violation with the same id, if found; otherwise append
      final idx = violations.indexWhere((el) => el['id'] == newViolation['id']);
      if (idx >= 0) {
        violations[idx] = newViolation;
      } else {
        violations.add(newViolation);
      }

      // Normalize all violation statuses to English to avoid duplicates
      for (int i = 0; i < violations.length; i++) {
        final vStatus = violations[i]['status'] ?? '';
        final normalized = _normalizeViolationStatus(vStatus);
        if (normalized != vStatus) {
          violations[i]['status'] = normalized;
        }
      }

      await docRef.update({'violations': violations});
      await _loadCars();
      showCustomSnackbar('نجح', 'تم تحديث المخالفة');
      return true;
    } catch (e) {
      print('Error updating violation: $e');
      showCustomSnackbar('خطأ', 'فشل تحديث المخالفة');
      return false;
    }
  }

  Future<bool> deleteViolation(String carId, String violationId) async {
    try {
      final docRef = _firestore.collection('car').doc(carId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        showCustomSnackbar('خطأ', 'سيارة غير موجودة');
        return false;
      }
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final v = data['violations'];
      List<Map<String, dynamic>> violations = [];
      if (v != null && v is List) {
        violations = (v as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      // حذف المخالفة بالـ ID
      final beforeCount = violations.length;
      violations.removeWhere((el) => el['id'] == violationId);
      final afterCount = violations.length;

      if (beforeCount == afterCount) {
        showCustomSnackbar('خطأ', 'المخالفة غير موجودة');
        return false;
      }

      await docRef.update({'violations': violations});
      
      // تحديث البيانات المحلية فوراً
      final carIndex = cars.indexWhere((c) => c.id == carId);
      if (carIndex >= 0) {
        cars[carIndex].violations?.removeWhere((v) => v.id == violationId);
      }
      
      update(); // تحديث UI فوراً
      showCustomSnackbar('نجح', 'تم حذف المخالفة بنجاح');
      return true;
    } catch (e) {
      print('Error deleting violation: $e');
      showCustomSnackbar('خطأ', 'فشل حذف المخالفة: $e');
      return false;
    }
  }

  // جلب المخالفات Real-time لسيارة معينة
  Stream<List<Violation>> getViolationsStream(String carId) {
    try {
      return _firestore.collection('car').doc(carId).snapshots().map<List<Violation>>((doc) {
        if (!doc.exists) return [];
        
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final violations = data['violations'] as List<dynamic>? ?? [];
        
        return violations
            .map((v) => Violation.fromMap(Map<String, dynamic>.from(v as Map)))
            .toList();
      });
    } catch (e) {
      print('Error creating violations stream: $e');
      return Stream.value([]);
    }
  }
  // Stream violations for a car
  Stream<List<Map<String, dynamic>>> streamViolationsForCar(String carId) {
    try {
      return _firestore.collection('car').doc(carId).snapshots().map((doc) {
        if (!doc.exists) return [];
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final v = data['violations'];
        if (v == null || v is! List) return [];
        return (v as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
    } catch (e) {
      print('Error creating violations stream: $e');
      return const Stream.empty();
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return doc.data() as Map<String, dynamic>?;
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Update current user's service profile and mark as service owner
  Future<void> updateServiceProfile(Map<String, dynamic> profile) async {
    try {
      if (userId.isEmpty) {
        showCustomSnackbar('خطأ', 'لم يتم تسجيل الدخول');
        return;
      }
      final data = {'isServiceOwner': true, 'serviceProfile': profile};
      await _firestore
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
      // update local state
      isServiceOwner = true;
      serviceProfile = Map<String, dynamic>.from(profile);
      update();
      showCustomSnackbar('نجح', 'تم تحديث بيانات مركز الصيانة');
    } catch (e) {
      print('Error updating service profile: $e');
      showCustomSnackbar('خطأ', 'فشل تحديث بيانات المركز');
    }
  }

  // Update request by service owner (accept with schedule, finish with description/price, or reject)
  Future<void> updateRequestByServiceOwner(
    String requestId,
    String status, {
    String? scheduledAt,
    String? finalDescription,
    double? finalPrice,
    String? response,
    List<String>? images,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (scheduledAt != null) data['scheduledAt'] = scheduledAt;
      if (finalDescription != null) data['finalDescription'] = finalDescription;
      if (finalPrice != null) data['finalPrice'] = finalPrice;
      if (response != null) data['response'] = response;
      if (images != null) data['images'] = images;

      await _firestore
          .collection('car_requests')
          .doc(requestId)
          .set(data, SetOptions(merge: true));
      showCustomSnackbar('نجح', 'تم تحديث حالة الطلب');
    } catch (e) {
      print('Error updating request by service owner: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ في تحديث حالة الطلب');
    }
  }

  // حذف سجل صيانة
  Future<void> deleteMaintenanceRecord(
    String carId,
    Map<String, dynamic> record,
  ) async {
    try {
      isLoading = true;
      update();
      await _firestore.collection('car').doc(carId).update({
        'maintenance': FieldValue.arrayRemove([record]),
      });
      await _loadCars();
      showCustomSnackbar("نجح", "تم حذف سجل الصيانة");
    } catch (e) {
      print('Error deleting maintenance record: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في حذف سجل الصيانة");
    } finally {
      isLoading = false;
      update();
    }
  }

  /// =======================
  /// Car Requests
  /// =======================
  Future<bool> createCarRequest(
    String carId,
    String type,
    String details,
    List<String> images,
  ) async {
    try {
      isLoading = true;
      update();
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        showCustomSnackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return false;
      }

      final data = {
        'carId': carId,
        'userId': currentUser.uid,
        'type': type,
        'details': details,
        'images': images,
        'status': 'pending',
        'response': '',
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtClient': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('car_requests').add(data);
      // نجاح: أرجع true ليتم التعامل في الواجهة
      return true;
    } catch (e) {
      print('Error creating car request: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ في إنشاء الطلب');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // Create purchase request (buyer requests to buy a car)
  Future<bool> createPurchaseRequest(
    String carId,
    String details,
    List<String> images,
    String sellerId,
  ) async {
    try {
      isLoading = true;
      update();
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        showCustomSnackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return false;
      }

      final data = {
        'carId': carId,
        'userId': currentUser.uid,
        'sellerId': sellerId,
        'details': details,
        'images': images,
        'status': 'pending', // to seller
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtClient': DateTime.now().toIso8601String(),
      };

      // Debug: log images being sent with the purchase request
      try {
        print('Creating purchase request for car $carId by ${currentUser.uid} with images: $images');
      } catch (e) {
        print('Error logging createPurchaseRequest images: $e');
      }

      final ref = await _firestore.collection('purchase_requests').add(data);
      // Debug: fetch and print saved doc to ensure images are persisted
      try {
        final saved = await ref.get();
        print('PurchaseRequest created id: ${ref.id}, saved data: ${saved.data()}');
      } catch (e) {
        print('Error fetching saved purchase request ${ref.id}: $e');
      }
      showCustomSnackbar('نجح', 'تم إرسال طلب الشراء');
      return true;
    } catch (e) {
      print('Error creating purchase request: $e');
      showCustomSnackbar('خطأ', 'فشل إرسال طلب الشراء');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // Create a general user request to admin/support
  Future<bool> createUserRequest(String title, String description) async {
    try {
      isLoading = true;
      update();
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        showCustomSnackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return false;
      }
      final data = {
        'userId': currentUser.uid,
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtClient': DateTime.now().toIso8601String(),
      };
      final ref = await _firestore.collection('user_requests').add(data);
      try {
        final saved = await ref.get();
        print('UserRequest created id: ${ref.id}, saved data: ${saved.data()}');
      } catch (e) {
        print('Error fetching saved user request ${ref.id}: $e');
      }

      // Mirror the user request to an admin-visible collection so managers can see it even if rules differ
      try {
        await _firestore.collection('user_requests_admin').doc(ref.id).set({
          ...data,
          'mirroredFrom': ref.id,
        });
        print('UserRequest mirrored to user_requests_admin id: ${ref.id}');
      } catch (e) {
        print('Error mirroring user request ${ref.id}: $e');
      }

      return true;
    } catch (e) {
      print('Error creating user request: $e');
      showCustomSnackbar('خطأ', 'فشل إرسال الطلب');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // Create a payment/invoice from user
  Future<bool> createPayment(double amount, String description, String transferRef) async {
    try {
      isLoading = true;
      update();
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        showCustomSnackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return false;
      }
      final data = {
        'userId': currentUser.uid,
        'amount': amount,
        'description': description,
        'transferRef': transferRef,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtClient': DateTime.now().toIso8601String(),
      };
      final ref = await _firestore.collection('payments').add(data);
      try {
        final saved = await ref.get();
        print('Payment created id: ${ref.id}, saved data: ${saved.data()}');
      } catch (e) {
        print('Error fetching saved payment ${ref.id}: $e');
      }
      showCustomSnackbar('نجح', 'تم إضافة الفاتورة بنجاح');
      return true;
    } catch (e) {
      print('Error creating payment: $e');
      showCustomSnackbar('خطأ', 'فشل إضافة الفاتورة');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // Stream payments of the current user
  Stream<List<Payment>> streamUserPayments(String buyerUid) {
    try {
      return _firestore
          .collection('payments')
          .where('userId', isEqualTo: buyerUid)
          .snapshots()
          .map((snap) {
            final list = snap.docs.map((d) => Payment.fromFirestore(d.data(), d.id)).toList();
            list.sort((a, b) {
              int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
              int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
              return bTs.compareTo(aTs);
            });
            return list;
          });
    } catch (e) {
      print('Error creating payments stream for user: $e');
      return const Stream.empty();
    }
  }

  Stream<List<CarRequest>> streamUserCarRequests(String carId) {
    try {
      // Listen to auth state and switch the query when the user is available
      return _auth.authStateChanges().asyncExpand((user) {
        if (user == null) return const Stream.empty();
        return _firestore
            .collection('car_requests')
            .where('carId', isEqualTo: carId)
            .where('userId', isEqualTo: user.uid)
            .snapshots()
            .map((snap) {
              final list = snap.docs
                  .map((d) => CarRequest.fromFirestore(d.data(), d.id))
                  .toList();
              list.sort((a, b) {
                int aTs =
                    a.createdAt?.millisecondsSinceEpoch ??
                    (a.createdAtClient != null
                        ? (DateTime.tryParse(
                                a.createdAtClient!,
                              )?.millisecondsSinceEpoch ??
                              0)
                        : 0);
                int bTs =
                    b.createdAt?.millisecondsSinceEpoch ??
                    (b.createdAtClient != null
                        ? (DateTime.tryParse(
                                b.createdAtClient!,
                              )?.millisecondsSinceEpoch ??
                              0)
                        : 0);
                return bTs.compareTo(aTs);
              });
              return list;
            });
      });
    } catch (e) {
      print('Error creating car requests stream: $e');
      return const Stream.empty();
    }
  }

  // Stream purchase requests sent by the given buyer (my requests)
  Stream<List<PurchaseRequest>> streamUserPurchaseRequests(String buyerUid) {
    try {
      return _firestore
          .collection('purchase_requests')
          .where('userId', isEqualTo: buyerUid)
          .snapshots()
          .map((snap) {
            final list = snap.docs
                .map((d) => PurchaseRequest.fromFirestore(d.data(), d.id))
                .toList();
            list.sort((a, b) {
              int aTs =
                  a.createdAt?.millisecondsSinceEpoch ??
                  (a.createdAtClient != null
                      ? (DateTime.tryParse(
                              a.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              int bTs =
                  b.createdAt?.millisecondsSinceEpoch ??
                  (b.createdAtClient != null
                      ? (DateTime.tryParse(
                              b.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              return bTs.compareTo(aTs);
            });
            return list;
          });
    } catch (e) {
      print('Error creating purchase requests stream for buyer: $e');
      return const Stream.empty();
    }
  }

  // Stream user generic requests (my general requests to admin)
  Stream<List<UserRequest>> streamUserRequests(String uid) {
    try {
      return _auth.authStateChanges().asyncExpand((user) {
        if (user == null) return const Stream.empty();
        final myUid = user.uid;

        // Create a broadcast controller per-call that merges both collections filtered by the current uid
        final controller = StreamController<List<UserRequest>>.broadcast();

        // assign onListen AFTER controller creation to avoid referencing it before initialization
        controller.onListen = () {
          final Map<String, UserRequest> cache = {};
          StreamSubscription? subA;
          StreamSubscription? subB;

          void emitMerged() {
            final list = cache.values.toList();
            list.sort((a, b) {
              int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
              int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
              return bTs.compareTo(aTs);
            });
            try {
              controller.add(list);
            } catch (e) {
              print('Error adding merged user requests to controller: $e');
            }
          }

          subA = _firestore.collection('user_requests').where('userId', isEqualTo: myUid).snapshots().listen((snap) {
            try {
              print('HomeController: received user_requests snapshot with ${snap.docs.length} docs');
              for (var d in snap.docs) {
                final ur = UserRequest.fromFirestore(d.data(), d.id);
                cache[d.id] = ur;
              }
              emitMerged();
            } catch (e) {
              print('Error processing user_requests snapshot in HomeController: $e');
            }
          }, onError: (e) {
            print('HomeController: user_requests snapshot error: $e');
          });

          subB = _firestore.collection('user_requests_admin').where('userId', isEqualTo: myUid).snapshots().listen((snap) {
            try {
              print('HomeController: received user_requests_admin snapshot with ${snap.docs.length} docs');
              for (var d in snap.docs) {
                final ur = UserRequest.fromFirestore(d.data(), d.id);
                cache[d.id] = ur;
              }
              emitMerged();
            } catch (e) {
              print('Error processing user_requests_admin snapshot in HomeController: $e');
            }
          }, onError: (e) {
            print('HomeController: user_requests_admin snapshot error: $e');
          });

          controller.onCancel = () async {
            await subA?.cancel();
            await subB?.cancel();
            try {
              await controller.close();
            } catch (e) {}
          };
        };

        return controller.stream;
      });
    } catch (e) {
      print('Error creating user requests stream: $e');
      return const Stream.empty();
    }
  }

  // Stream purchase requests for a particular car (for seller)
  // Note: include all statuses so seller can always follow accepted/forwarded requests
  Stream<List<PurchaseRequest>> streamSellerPurchaseRequestsForCar(
    String carId,
  ) {
    try {
      return _firestore
          .collection('purchase_requests')
          .where('carId', isEqualTo: carId)
          .snapshots()
          .map((snap) {
            final list = snap.docs
                .map((d) => PurchaseRequest.fromFirestore(d.data(), d.id))
                .toList();
            list.sort((a, b) {
              int aTs =
                  a.createdAt?.millisecondsSinceEpoch ??
                  (a.createdAtClient != null
                      ? (DateTime.tryParse(
                              a.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              int bTs =
                  b.createdAt?.millisecondsSinceEpoch ??
                  (b.createdAtClient != null
                      ? (DateTime.tryParse(
                              b.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              return bTs.compareTo(aTs);
            });
            return list;
          });
    } catch (e) {
      print('Error creating purchase requests stream for seller: $e');
      return const Stream.empty();
    }
  }

  // Stream purchase requests that were forwarded to admin
  Stream<List<PurchaseRequest>> streamPurchaseRequestsPendingAdmin() {
    try {
      return _firestore
          .collection('purchase_requests')
          .where('status', isEqualTo: 'pending_admin')
          .snapshots()
          .map((snap) {
            final list = snap.docs
                .map((d) => PurchaseRequest.fromFirestore(d.data(), d.id))
                .toList();
            list.sort((a, b) {
              int aTs =
                  a.createdAt?.millisecondsSinceEpoch ??
                  (a.createdAtClient != null
                      ? (DateTime.tryParse(
                              a.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              int bTs =
                  b.createdAt?.millisecondsSinceEpoch ??
                  (b.createdAtClient != null
                      ? (DateTime.tryParse(
                              b.createdAtClient!,
                            )?.millisecondsSinceEpoch ??
                            0)
                      : 0);
              return bTs.compareTo(aTs);
            });
            return list;
          });
    } catch (e) {
      print('Error creating purchase requests stream for admin: $e');
      return const Stream.empty();
    }
  }

  // Fetch user car requests once (no realtime updates)
  Future<List<CarRequest>> getUserCarRequestsOnce(String carId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];
      final snap = await _firestore
          .collection('car_requests')
          .where('carId', isEqualTo: carId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      final list = snap.docs
          .map((d) => CarRequest.fromFirestore(d.data(), d.id))
          .toList();
      list.sort((a, b) {
        int aTs =
            a.createdAt?.millisecondsSinceEpoch ??
            (a.createdAtClient != null
                ? (DateTime.tryParse(
                        a.createdAtClient!,
                      )?.millisecondsSinceEpoch ??
                      0)
                : 0);
        int bTs =
            b.createdAt?.millisecondsSinceEpoch ??
            (b.createdAtClient != null
                ? (DateTime.tryParse(
                        b.createdAtClient!,
                      )?.millisecondsSinceEpoch ??
                      0)
                : 0);
        return bTs.compareTo(aTs);
      });
      return list;
    } catch (e) {
      print('Error fetching car requests once: $e');
      return [];
    }
  }

  Future<void> updateRequestStatus(
    String requestId,
    String status, {
    String? response,
  }) async {
    try {
      isLoading = true;
      update();
      final data = <String, dynamic>{'status': status};
      if (response != null) data['response'] = response;
      await _firestore
          .collection('car_requests')
          .doc(requestId)
          .set(data, SetOptions(merge: true));
      showCustomSnackbar('نجح', 'تم تحديث حالة الطلب');
    } catch (e) {
      print('Error updating request status: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ في تحديث حالة الطلب');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Seller updates purchase request: accept -> forward to admin with description/files, or reject
  Future<void> updatePurchaseRequestBySeller(
    String requestId,
    String status, {
    String? sellerDescription,
    List<String>? sellerFiles,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (sellerDescription != null)
        data['sellerDescription'] = sellerDescription;
      if (sellerFiles != null) data['sellerFiles'] = sellerFiles;
      await _firestore
          .collection('purchase_requests')
          .doc(requestId)
          .set(data, SetOptions(merge: true));
      showCustomSnackbar('نجح', 'تم تحديث حالة طلب الشراء');
    } catch (e) {
      print('Error updating purchase request by seller: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ في تحديث حالة طلب الشراء');
    }
  }

  // Admin updates purchase request: accept / reject / finish
  Future<void> updatePurchaseRequestByAdmin(
    String requestId,
    String status, {
    String? adminNotes,
    List<String>? images,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (adminNotes != null) data['adminNotes'] = adminNotes;
      if (images != null) data['adminImages'] = images;
      await _firestore
          .collection('purchase_requests')
          .doc(requestId)
          .set(data, SetOptions(merge: true));
      showCustomSnackbar('نجح', 'تم تحديث حالة طلب الشراء');
    } catch (e) {
      print('Error updating purchase request by admin: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ في تحديث حالة طلب الشراء');
    }
  }

  // حذف سيارة
  Future<void> deleteCar(Car car) async {
    try {
      isLoading = true;
      update();
      await _firestore.collection('car').doc(car.id).delete();

      // إزالة محلياً
      cars.removeWhere((c) => c.id == car.id);
      update();

      showCustomSnackbar("نجح", "تم حذف السيارة");
    } catch (e) {
      print('Error deleting car: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في حذف السيارة");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      userId = '';
      userName = '';
      children.clear();
      announcements.clear();
      if (Get.isRegistered<LoginController>()) {
        Get.delete<LoginController>();
      }
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error in signOut: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تسجيل الخروج");
    }
  }

  // التعامل مع الضغط على طفل
  void onChildTap(Child child) {
    try {
      if (child == null) {
        showCustomSnackbar("خطأ", "بيانات الطفل غير صحيحة");
        return;
      }

      switch (child.approved.toLowerCase()) {
        case 'approved':
          // الانتقال لصفحة التفاصيل
          Get.toNamed('/child-details', arguments: child);
          break;
        case 'wait':
          // عرض رسالة الانتظار
          showCustomSnackbar(
            "في الانتظار",
            "يرجى الانتظار حتى يتم الموافقة على تسجيل ${child.name}",
          );
          break;
        case 'rejected':
          // عرض رسالة الرفض مع خيار الحذف
          _showRejectionDialog(child);
          break;
        default:
          showCustomSnackbar("خطأ", "حالة غير معروفة للطفل: ${child.approved}");
          break;
      }
    } catch (e) {
      print('Error in onChildTap: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في معالجة الطلب");
    }
  }

  // عرض حوار الرفض
  void _showRejectionDialog(Child child) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_rounded, color: Colors.red, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "تم رفض التسجيل",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "تم رفض تسجيل ${child.name} من قبل الإدارة.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              "هل تريد حذف بيانات الطفل من التطبيق؟",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "إلغاء",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteRejectedChild(child);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "حذف البيانات",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حذف طفل مرفوض
  Future<void> _deleteRejectedChild(Child child) async {
    try {
      isLoading = true;
      update();
      // حذف الطفل من Firestore
      await _firestore.collection('children').doc(child.id).delete();

      // إزالة الطفل من قائمة الأطفال المحلية
      children.removeWhere((c) => c.id == child.id);

      // تحديث قائمة الأطفال في Firestore للمستخدم
      await _firestore.collection('users').doc(userId).update({
        'children': FieldValue.arrayRemove([
          _firestore.collection('children').doc(child.id),
        ]),
      });

      showCustomSnackbar("نجح", "تم حذف ${child.name} بنجاح");
    } catch (e) {
      print('Error deleting rejected child: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في حذف الطفل");
    } finally {
      isLoading = false;
      update();
    }
  }

  /// =======================
  /// Conversations (user-to-user)
  /// =======================

  /// Returns an existing conversation id between current user and [otherUserId], or creates one.
  Future<String?> getOrCreateConversation(
    String otherUserId, {
    String? carId,
  }) async {
    if (userId.isEmpty) {
      showCustomSnackbar('خطأ', 'يجب تسجيل الدخول أولاً');
      return null;
    }

    try {
      final ids = [userId, otherUserId]..sort();
      final convId = ids.join('_');
      final docRef = _firestore.collection('conversations').doc(convId);
      final doc = await docRef.get();
      if (!doc.exists) {
        final otherUser = await getUserData(otherUserId);
        final convData = {
          'participants': [userId, otherUserId],
          'participantNames': {
            userId: userName,
            otherUserId: otherUser != null ? (otherUser['name'] ?? '') : '',
          },
          'lastMessage': '',
          'lastTimestamp': FieldValue.serverTimestamp(),
          'carId': carId ?? '',
        };
        await docRef.set(convData);

        // also create per-user conversation index for reliable listing
        final participants = convData['participants'] is List
            ? List<String>.from(convData['participants'] as List)
            : <String>[];
        final perUserData = {
          'id': convId,
          'participants': participants,
          'participantNames': convData['participantNames'],
          'lastMessage': convData['lastMessage'],
          'lastTimestamp': convData['lastTimestamp'],
          'carId': convData['carId'],
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'unreadCount': 0,
        };
        for (final uid in participants) {
          try {
            // set unreadCount = 0 for both users initially
            await _firestore
                .collection('users')
                .doc(uid)
                .collection('conversations')
                .doc(convId)
                .set(perUserData, SetOptions(merge: true));
          } catch (e) {
            print('Failed to write per-user conversation record for $uid: $e');
          }
        }
      } else {
        // ensure per-user index exists (in case older conversations were created differently)
        final existing = doc.data();
        final participants = (existing != null && existing['participants'] is List)
            ? List<String>.from(existing['participants'] as List)
            : <String>[];
        final participantNames = Map<String, dynamic>.from(
          existing?['participantNames'] ?? {},
        );
        final carVal = existing?['carId'] ?? '';
        final perUserData = {
          'id': convId,
          'participants': participants,
          'participantNames': participantNames,
          'lastMessage': existing?['lastMessage'] ?? '',
          'lastTimestamp':
              existing?['lastTimestamp'] ?? FieldValue.serverTimestamp(),
          'carId': carVal,
          'createdBy': existing?['createdBy'] ?? userId,
          'createdAt': existing?['createdAt'] ?? FieldValue.serverTimestamp(),
          'unreadCount': existing?['unreadCount'] ?? 0,
        };
        for (final uid in participants) {
          try {
            await _firestore
                .collection('users')
                .doc(uid)
                .collection('conversations')
                .doc(convId)
                .set(perUserData, SetOptions(merge: true));
          } catch (e) {
            print('Failed to ensure per-user conversation record for $uid: $e');
          }
        }
      }
      return convId;
    } catch (e) {
      print('Error in getOrCreateConversation: $e');
      showCustomSnackbar('خطأ', 'فشل بدء المحادثة');
      return null;
    }
  }

  /// Stream conversations for the current user ordered by lastTimestamp desc
  Stream<List<Map<String, dynamic>>> streamUserConversations() {
    try {
      if (userId.isEmpty) return const Stream.empty();
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .orderBy('lastTimestamp', descending: true)
          .snapshots()
          .map(
            (snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              return data;
            }).toList(),
          );
    } catch (e) {
      print('Error creating conversations stream: $e');
      return const Stream.empty();
    }
  }

  /// Backfill per-user conversation records for existing conversations
  Future<void> backfillPerUserConversations({int limit = 500}) async {
    try {
      final snap = await _firestore.collection('conversations').limit(limit).get();
      int written = 0;
      for (final d in snap.docs) {
        final convId = d.id;
        final data = d.data();
        final participants = data['participants'] is List ? List<String>.from(data['participants'] as List) : <String>[];
        final participantNames = data['participantNames'] is Map ? Map<String, dynamic>.from(data['participantNames']) : {};
        final perUserData = {
          'id': convId,
          'participants': participants,
          'participantNames': participantNames,
          'lastMessage': data['lastMessage'] ?? '',
          'lastTimestamp': data['lastTimestamp'] ?? FieldValue.serverTimestamp(),
          'carId': data['carId'] ?? '',
          'createdBy': data['createdBy'] ?? null,
          'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
          'unreadCount': 0,
        };
        for (final uid in participants) {
          try {
            await _firestore.collection('users').doc(uid).collection('conversations').doc(convId).set(perUserData, SetOptions(merge: true));
            written++;
          } catch (e) {
            print('Backfill: failed to write for $uid, conv $convId: $e');
          }
        }
      }
      print('Backfill completed, wrote $written per-user conversation docs');
      showCustomSnackbar('نجح', 'انتهى ملء السجلات للمحادثات (لعينة حتى $limit)');
    } catch (e) {
      print('Error in backfillPerUserConversations: $e');
      showCustomSnackbar('خطأ', 'فشل ملء سجلات المحادثات');
    }
  }

  /// Stream messages for a specific conversation
  Stream<List<Map<String, dynamic>>> streamConversationMessages(
    String conversationId,
  ) {
    try {
      return _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots()
          .map(
            (snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              return data;
            }).toList(),
          );
    } catch (e) {
      print('Error creating messages stream: $e');
      return const Stream.empty();
    }
  }

  /// Send a message in a conversation and update conversation metadata.
  Future<void> sendConversationMessage(
    String conversationId,
    String content,
  ) async {
    if (content.trim().isEmpty) return;
    try {
      final convRef = _firestore
          .collection('conversations')
          .doc(conversationId);
      final msg = {
        'content': content.trim(),
        'senderId': userId,
        'senderName': userName,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };
      await convRef.collection('messages').add(msg);
      await convRef.set({
        'lastMessage': content.trim(),
        'lastTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update per-user conversation records so the user's list updates reliably
      try {
        final convDoc = await convRef.get();
        final convData = convDoc.data() ?? {};
        final participants = convData['participants'] is List
            ? List<String>.from(convData['participants'] as List)
            : <String>[];
        final participantNames = Map<String, dynamic>.from(
          convData['participantNames'] ?? {},
        );
        for (final uid in participants) {
          final map = {
            'id': conversationId,
            'participants': participants,
            'participantNames': participantNames,
            'lastMessage': content.trim(),
            'lastTimestamp': FieldValue.serverTimestamp(),
            'carId': convData['carId'] ?? '',
          };
          if (uid == userId) {
            map['unreadCount'] = 0; // sender has read the conversation
          } else {
            map['unreadCount'] = FieldValue.increment(1); // increment unread for recipient
          }

          await _firestore
              .collection('users')
              .doc(uid)
              .collection('conversations')
              .doc(conversationId)
              .set(map, SetOptions(merge: true));
        }
      } catch (e) {
        print('Error updating per-user conversation records: $e');
      }
    } catch (e) {
      print('Error sending conversation message: $e');
      showCustomSnackbar('خطأ', 'فشل إرسال الرسالة');
    }
  }
}
