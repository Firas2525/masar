import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../model/home_model.dart';
import '../widgets/custom_snackbar.dart';
import 'login_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
class ManagerHomeViewController extends GetxController {
  bool isLoading = false;
  List children = <Child>[];
  List announcements = <Announcement>[];
  List<Car> cars = <Car>[];
  String userName = '';
  String userId = '';
  PageController addsController = PageController();
  int addsCurrentPage = 0;
  int first_time = 1;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  File? _image;
  final picker = ImagePicker();
  String? uploadedImageUrl;

  // internal caches and streams for merging user requests + admin mirror
  StreamSubscription<QuerySnapshot>? _userRequestsSub;
  StreamSubscription<QuerySnapshot>? _userRequestsAdminSub;
  final Map<String, UserRequest> _userRequestsCache = {};
  final Map<String, UserRequest> _adminMirrorCache = {};
  StreamController<List<UserRequest>> _userRequestsController = StreamController<List<UserRequest>>.broadcast();
  // Cache of last emitted merged user requests so new subscribers receive the latest state immediately
  List<UserRequest>? _lastMergedUserRequests;


  void _ensureUserRequestsListeners() {
    // If subscriptions already active, nothing to do
    if (_userRequestsSub != null || _userRequestsAdminSub != null) return;

    try {
      _userRequestsSub = _firestore.collection('user_requests').snapshots().listen((snap) {
        try {
          print('Manager: received user_requests snapshot with ${snap.docs.length} docs');
          _userRequestsCache.clear();
          for (var d in snap.docs) {
            print(' - user_request ${d.id}: ${d.data()}');
            final ur = UserRequest.fromFirestore(d.data(), d.id);
            _userRequestsCache[d.id] = ur;
          }
          _emitMergedUserRequests();
        } catch (e) {
          print('Manager: error while processing user_requests snapshot: $e');
          try { _userRequestsController.addError(e); } catch (_) {}
        }
      }, onError: (e) async {
        print('Manager: user_requests snapshot error: $e');
        try { _userRequestsController.addError(e); } catch (_) {}
        await _userRequestsSub?.cancel();
        _userRequestsSub = null;
        // retry after delay
        Future.delayed(Duration(seconds: 5), () {
          if (!_userRequestsController.isClosed) _ensureUserRequestsListeners();
        });
      });

      _userRequestsAdminSub = _firestore.collection('user_requests_admin').snapshots().listen((snap) {
        try {
          print('Manager: received user_requests_admin snapshot with ${snap.docs.length} docs');
          _adminMirrorCache.clear();
          for (var d in snap.docs) {
            print(' - admin_mirror ${d.id}: ${d.data()}');
            final ur = UserRequest.fromFirestore(d.data(), d.id);
            _adminMirrorCache[d.id] = ur;
          }
          _emitMergedUserRequests();
        } catch (e) {
          print('Manager: error while processing user_requests_admin snapshot: $e');
          try { _userRequestsController.addError(e); } catch (_) {}
        }
      }, onError: (e) async {
        print('Manager: user_requests_admin snapshot error: $e');
        try { _userRequestsController.addError(e); } catch (_) {}
        await _userRequestsAdminSub?.cancel();
        _userRequestsAdminSub = null;
        Future.delayed(Duration(seconds: 5), () {
          if (!_userRequestsController.isClosed) _ensureUserRequestsListeners();
        });
      });

      // Ensure new subscribers immediately get the latest merged list
      _userRequestsController.onListen = () {
        try {
          if (_lastMergedUserRequests != null) _userRequestsController.add(_lastMergedUserRequests!);
        } catch (_) {}
      };

      // Emit initial merged list immediately so UI doesn't stay stuck in waiting state
      _emitMergedUserRequests();
    } catch (e) {
      print('Error initializing user requests listeners: $e');
      try { _userRequestsController.addError(e); } catch (_) {}
      Future.delayed(Duration(seconds: 5), () {
        if (!_userRequestsController.isClosed) _ensureUserRequestsListeners();
      });
    }
  }

  // قيم Cloudinary (من Dashboard)
  final String cloudName = "ddpk9jmfc";
  final String uploadPreset = "firas_image"; // أنشئه من Cloudinary Dashboard

  Future pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {

        _image = File(pickedFile.path);

    }
    else{
      return null;
    }
    return _image;
  }

  Future uploadImageToCloudinary() async {
    File? imageFile = await pickImage(ImageSource.gallery);
    print(imageFile);
    if(imageFile==null){
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
    _initializeUser();
  }

  @override
  void onReady() {
    super.onReady();
    // تحديث البيانات عند العودة للصفحة
    refreshData();
  }

  @override
  void onClose() {
    _userRequestsSub?.cancel();
    _userRequestsAdminSub?.cancel();
    try {
      _userRequestsController.close();
    } catch (e) {}
    super.onClose();
  }

  // تحديث البيانات عند العودة من صفحة إضافة طفل
  Future<void> refreshData() async {
    await _initializeUserData();
  }

  void _initializeUser() {
    try {
      sharePref?.setBool("isManager",true);
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
      await _loadAnnouncements();

    } catch (e) {
      print('Error loading initial data: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل البيانات");
    }
    // load cars for manager view
    await _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      final query = await _firestore.collection('car').get();
      final loadedCars = query.docs.map((doc) => Car.fromFirestore(doc.data(), doc.id)).toList();
      cars = loadedCars;
      print('Manager: Loaded ${cars.length} cars');
      update();
    } catch (e) {
      print('Error loading cars for manager: $e');
      cars = [];
      update();
    }
  }

  // Stream car requests for a given car (admin view)
  Stream<List<CarRequest>> streamCarRequestsForCar(String carId) {
    try {
      // Include all requests for the car (including maintenance requests targeted to service centers)
      return _firestore
          .collection('car_requests')
          .where('carId', isEqualTo: carId)
          .snapshots()
          .map((snap) {
        final list = snap.docs.map((d) => CarRequest.fromFirestore(d.data(), d.id)).toList();
        list.sort((a, b) {
          int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          return bTs.compareTo(aTs);
        });
        return list;
      });
    } catch (e) {
      print('Error creating admin car requests stream: $e');
      return const Stream.empty();
    }
  }

  // Stream all pending car requests across all cars (admin view)
  Stream<List<CarRequest>> streamPendingRequests() {
    try {
      // Only admin/general pending requests (exclude maintenance requests targeted to service centers)
      return _firestore
          .collection('car_requests')
          .where('status', isEqualTo: 'pending')
          .where('serviceCenterId', isNull: true)
          .snapshots()
          .map((snap) {
        final list = snap.docs.map((d) => CarRequest.fromFirestore(d.data(), d.id)).toList();
        list.sort((a, b) {
          int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          return bTs.compareTo(aTs);
        });
        return list;
      });
    } catch (e) {
      print('Error creating pending requests stream: $e');
      return const Stream.empty();
    }
  }

  // Stream general requests that are NOT tied to a car (admin view)
  Stream<List<CarRequest>> streamGeneralRequests() {
    try {
      return _firestore
          .collection('car_requests')
          .where('carId', isNull: true)
          .snapshots()
          .map((snap) {
            print('Manager: received general car_requests snapshot with ${snap.docs.length} docs');
            final list = snap.docs.map((d) => CarRequest.fromFirestore(d.data(), d.id)).toList();
            list.sort((a, b) {
              int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
              int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
              return bTs.compareTo(aTs);
            });
            return list;
          });
    } catch (e) {
      print('Error creating general requests stream: $e');
      return const Stream.empty();
    }
  }

  // Stream all car requests across statuses (admin view)
  Stream<List<CarRequest>> streamAllCarRequests() {
    try {
      return _firestore
          .collection('car_requests')
          .snapshots()
          .map((snap) {
            print('Manager: received all car_requests snapshot with ${snap.docs.length} docs');
            final list = snap.docs.map((d) => CarRequest.fromFirestore(d.data(), d.id)).toList();
            list.sort((a, b) {
              int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
              int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
              return bTs.compareTo(aTs);
            });
            return list;
          });
    } catch (e) {
      print('Error creating all car requests stream: $e');
      return const Stream.empty();
    }
  }
  Stream<List<CarRequest>> streamFinishedRequests() {
    try {
      // Only admin/general finished requests (exclude maintenance requests targeted to service centers)
      return _firestore
          .collection('car_requests')
          .where('status', isEqualTo: 'finished')
          .where('serviceCenterId', isNull: true)
          .snapshots()
          .map((snap) {
        final list = snap.docs.map((d) => CarRequest.fromFirestore(d.data(), d.id)).toList();
        list.sort((a, b) {
          int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          return bTs.compareTo(aTs);
        });
        return list;
      });
    } catch (e) {
      print('Error creating finished requests stream: $e');
      return const Stream.empty();
    }
  }

  // Stream purchase requests for admin (all statuses)
  Stream<List<PurchaseRequest>> streamPurchaseRequestsForAdmin() {
    try {
      return _firestore.collection('purchase_requests').snapshots().map((snap) {
        // Debug: log images field to help investigate missing buyer images
        try {
          for (var d in snap.docs) {
            final imgs = d.data()?['images'];
            print('PurchaseRequest doc ${d.id} images field: $imgs');
          }
        } catch (e) {
          print('Error logging purchase_requests images fields: $e');
        }

        final list = snap.docs.map((d) => PurchaseRequest.fromFirestore(d.data(), d.id)).toList();
        list.sort((a, b) {
          int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          return bTs.compareTo(aTs);
        });
        return list;
      });
    } catch (e) {
      print('Error creating purchase requests stream for admin: $e');
      return const Stream.empty();
    }
  }

  // Stream all payments (admin view)
  Stream<List<Payment>> streamPayments() {
    try {
      return _firestore.collection('payments').snapshots().map((snap) {
        print('Manager: received payments snapshot with ${snap.docs.length} docs');
        final list = snap.docs.map((d) => Payment.fromFirestore(d.data(), d.id)).toList();
        list.sort((a, b) {
          int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
          return bTs.compareTo(aTs);
        });
        return list;
      });
    } catch (e) {
      print('Error creating payments stream for admin: $e');
      return const Stream.empty();
    }
  }

  Future<void> updatePaymentStatus(String paymentId, String status, {String? adminNotes}) async {
    try {
      final data = {'status': status};
      if (adminNotes != null) data['adminNotes'] = adminNotes;
      await _firestore.collection('payments').doc(paymentId).set(data, SetOptions(merge: true));
      showCustomSnackbar('نجح', 'تم تحديث حالة الفاتورة');
    } catch (e) {
      print('Error updating payment status: $e');
      showCustomSnackbar('خطأ', 'فشل تحديث حالة الفاتورة');
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _firestore.collection('payments').doc(id).delete();
      showCustomSnackbar('نجح', 'تم حذف الفاتورة');
    } catch (e) {
      print('Error deleting payment: $e');
      showCustomSnackbar('خطأ', 'فشل حذف الفاتورة');
    }
  }

  // Stream generic user requests to admin/support - merged from user_requests and user_requests_admin
  Stream<List<UserRequest>> streamUserRequests() {
    // If controller was closed earlier, recreate it so it can emit again
    if (_userRequestsController.isClosed) {
      _userRequestsController = StreamController<List<UserRequest>>.broadcast();
      // ensure new subscribers immediately get the latest merged list
      _userRequestsController.onListen = () {
        try {
          if (_lastMergedUserRequests != null) _userRequestsController.add(_lastMergedUserRequests!);
        } catch (_) {}
      };
    }

    // initialize listeners once and return a broadcast stream
    if (!_userRequestsController.hasListener) {
      _ensureUserRequestsListeners();
    }

    return _userRequestsController.stream;
  }

  void _emitMergedUserRequests() {
    try {
      final Map<String, UserRequest> merged = {};
      merged.addAll(_userRequestsCache);
      merged.addAll(_adminMirrorCache);
      final list = merged.values.toList();
      list.sort((a, b) {
        int aTs = a.createdAt?.millisecondsSinceEpoch ?? (a.createdAtClient != null ? (DateTime.tryParse(a.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
        int bTs = b.createdAt?.millisecondsSinceEpoch ?? (b.createdAtClient != null ? (DateTime.tryParse(b.createdAtClient!)?.millisecondsSinceEpoch ?? 0) : 0);
        return bTs.compareTo(aTs);
      });
      print('Manager: emitting merged user requests count: ${list.length}');
      _lastMergedUserRequests = list;
      _userRequestsController.add(list);
    } catch (e) {
      print('Error emitting merged user requests: $e');
    }
  }

  Future<void> updateRequestAsAdmin(String requestId, String status, {String? response, List<String>? images}) async {
    try {
      isLoading = true;
      update();
      final data = <String, dynamic>{'status': status};
      if (response != null) data['response'] = response;
      if (images != null) data['images'] = images;
      await _firestore.collection('car_requests').doc(requestId).set(data, SetOptions(merge: true));
      showCustomSnackbar('نجح', 'تم تحديث حالة الطلب');
    } catch (e) {
      print('Error updating request as admin: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ في تحديث حالة الطلب');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Admin updates purchase request: accept / reject / finish
  Future<void> updatePurchaseRequestByAdmin(String requestId, String status, {String? adminNotes, List<String>? images}) async {
    try {
      isLoading = true;
      update();
      final data = <String, dynamic>{'status': status};
      if (adminNotes != null) data['adminNotes'] = adminNotes;
      if (images != null) data['adminImages'] = images;
      await _firestore.collection('purchase_requests').doc(requestId).set(data, SetOptions(merge: true));
      showCustomSnackbar('نجح', 'تم تحديث حالة طلب الشراء');
    } catch (e) {
      print('Error updating purchase request by admin: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ في تحديث حالة طلب الشراء');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteCarAsManager(Car car) async {
    try {
      isLoading = true;
      update();
      await _firestore.collection('car').doc(car.id).delete();
      cars.removeWhere((c) => c.id == car.id);
      update();
      showCustomSnackbar('نجح', 'تم حذف الإعلان');
    } catch (e) {
      print('Error deleting car as manager: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ في حذف الإعلان');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Delete car by id (convenience) — used when a purchase request is finished
  Future<void> deleteCarById(String carId) async {
    try {
      isLoading = true;
      update();
      await _firestore.collection('car').doc(carId).delete();
      cars.removeWhere((c) => c.id == carId);
      update();
      showCustomSnackbar('نجح', 'تم حذف السيارة المرتبطة بالطلب');
    } catch (e) {
      print('Error deleting car by id as manager: $e');
      showCustomSnackbar('خطأ', 'فشل حذف السيارة المرتبطة');
    } finally {
      isLoading = false;
      update();
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

  Future<void> deleteUserRequest(String id) async {
    try {
      // delete from both collections if present
      await _firestore.collection('user_requests').doc(id).delete();
      try {
        await _firestore.collection('user_requests_admin').doc(id).delete();
      } catch (e) {
        print('Error deleting mirror admin request: $e');
      }
      showCustomSnackbar('نجح', 'تم حذف طلب المستخدم');
    } catch (e) {
      print('Error deleting user request: $e');
      showCustomSnackbar('خطأ', 'فشل حذف طلب المستخدم');
    }
  }

  // Update user request status and optional admin response (mirror to admin collection too)
  Future<void> updateUserRequest(String id, String status, {String? adminResponse}) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (adminResponse != null) data['adminResponse'] = adminResponse;
      await _firestore.collection('user_requests').doc(id).set(data, SetOptions(merge: true));
      try {
        await _firestore.collection('user_requests_admin').doc(id).set(data, SetOptions(merge: true));
      } catch (e) {
        print('Error updating mirror user request: $e');
      }
      showCustomSnackbar('نجح', 'تم تحديث طلب المستخدم');
    } catch (e) {
      print('Error updating user request: $e');
      showCustomSnackbar('خطأ', 'فشل تحديث طلب المستخدم');
    }
  }

  // One-time helper: mirror any missing user_requests into user_requests_admin
  Future<void> mirrorMissingUserRequests() async {
    try {
      final snap = await _firestore.collection('user_requests').get();
      int copied = 0;
      for (var d in snap.docs) {
        final adm = await _firestore.collection('user_requests_admin').doc(d.id).get();
        if (!adm.exists) {
          final data = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
          data['mirroredFrom'] = d.id;
          await _firestore.collection('user_requests_admin').doc(d.id).set(data);
          copied++;
        }
      }
      print('Manager: mirrored $copied missing user_requests to user_requests_admin');
      showCustomSnackbar('نجح', 'تم مزامنة $copied طلبات مفقودة');
    } catch (e) {
      print('Manager: error mirroring missing user requests: $e');
      showCustomSnackbar('خطأ', 'فشل مزامنة طلبات المستخدم');
    }
  }


  Future<void> addAd() async {
    isLoading = true;
    update();
    var image = await uploadImageToCloudinary();
    if (image==null) {
      showCustomSnackbar("خطأ", "يجب اختيار صورة");
      isLoading = false;
      update();
      return;
    }
    try {


      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        showCustomSnackbar("خطأ", "يجب تسجيل الدخول أولاً");
        isLoading = false;
        update();
        return;
      }

      // التحقق من وجود المستخدم في Firestore
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        showCustomSnackbar("خطأ", "بيانات المستخدم غير موجودة");
        isLoading = false;
        update();
        return;
      }

      // إنشاء بيانات الطفل
      final ad = {
        'content': "$image",
      };
      // إضافة الطفل إلى Firestore
      await _firestore.collection('advertisments').add(ad);

      showCustomSnackbar("نجح", "تم إضافة اعلان بنجاح");

    } catch (e) {
      print('Error adding child: $e');
      if (e.toString().contains('permission-denied')) {
        showCustomSnackbar("خطأ", "ليس لديك صلاحية لإضافة طفل. تحقق من قواعد الأمان");
      } else if (e.toString().contains('unavailable')) {
        showCustomSnackbar("خطأ", "خدمة Firestore غير متاحة. تحقق من الاتصال بالإنترنت");
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
      final userDoc =
      await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        userName = userDoc.data()?['name'] ?? '';
        update();
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error in _loadUserData: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في جلب بيانات المستخدم");
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
          print('Loaded child: ${child.name} (ID: ${child.id}, kId: ${child.kId})');
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

      // Prefetch announcement images to show instantly when navigating back
      try {
        for (final a in announcements) {
          final content = (a as Announcement).content;
          final isImageUrl = content.startsWith('http') && (content.endsWith('.png') || content.endsWith('.jpg') || content.endsWith('.jpeg') || content.endsWith('.webp'));
          if (isImageUrl) {
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
                    curve: Curves.easeInOut);
                update();
              } else {
                addsController.animateToPage(0,
                    duration: const Duration(milliseconds: 1),
                    curve: Curves.easeInOut);
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

  Future<void> deleteAdById(String adId) async {
    try {
      isLoading = true;
      update();
      await _firestore.collection('advertisments').doc(adId).delete();
      announcements.removeWhere((a) => (a as Announcement).id == adId);
      update();
      showCustomSnackbar("نجح", "تم حذف الإعلان بنجاح");
    } catch (e) {
      print('Error deleting ad: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في حذف الإعلان");
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
  sharePref?.setBool("isManager",false);
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
              "يرجى الانتظار حتى يتم الموافقة على تسجيل ${child.name}"
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24,
              ),
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
        'children': FieldValue.arrayRemove([_firestore.collection('children').doc(child.id)]),
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
}
