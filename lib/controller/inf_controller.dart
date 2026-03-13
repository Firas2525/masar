import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/inf_model.dart';
import '../widgets/custom_snackbar.dart';

class InfController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final isLoading = false.obs;
  final informations = <InfModel>[].obs;
  final selectedInfo = Rxn<InfModel>();
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
          _loadInformations();
        } else {
          Get.offAllNamed('/login');
        }
      });
    } catch (e) {
      print('Error in _initializeUser: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تهيئة المستخدم");
    }
  }

  Future<void> _loadInformations() async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await _firestore
          .collection('informations')
          .orderBy('createdAt', descending: true)
          .get();

      final loadedInformations = querySnapshot.docs
          .map((doc) => InfModel.fromFirestore(doc.data(), doc.id))
          .toList();

      informations.value = loadedInformations;
    } catch (e) {
      print('Error loading informations: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل المعلومات");
      informations.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshInformations() async {
    await _loadInformations();
  }

  Future<void> joinInformation(String infoId) async {
    try {
      if (currentUserId.value.isEmpty) {
        showCustomSnackbar("خطأ", "يجب تسجيل الدخول أولاً");
        return;
      }

      final infoDoc = await _firestore
          .collection('informations')
          .doc(infoId)
          .get();

      if (!infoDoc.exists) {
        showCustomSnackbar("خطأ", "المعلومة غير موجودة");
        return;
      }

      final infoData = infoDoc.data()!;
      final currentUsers = List<String>.from(infoData['users'] ?? []);

      if (currentUsers.contains(currentUserId.value)) {
        showCustomSnackbar("تنبيه", "أنت مسجل بالفعل في هذه المعلومة");
        return;
      }

      if (currentUsers.length >= infoData['total_num']) {
        showCustomSnackbar("تنبيه", "المعلومة ممتلئة");
        return;
      }

      currentUsers.add(currentUserId.value);

      await _firestore
          .collection('informations')
          .doc(infoId)
          .update({'users': currentUsers});

      showCustomSnackbar("نجح", "تم الانضمام للمعلومة بنجاح");
      await refreshInformations();
    } catch (e) {
      print('Error joining information: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في الانضمام للمعلومة");
    }
  }

  Future<void> leaveInformation(String infoId) async {
    try {
      if (currentUserId.value.isEmpty) {
        showCustomSnackbar("خطأ", "يجب تسجيل الدخول أولاً");
        return;
      }

      final infoDoc = await _firestore
          .collection('informations')
          .doc(infoId)
          .get();

      if (!infoDoc.exists) {
        showCustomSnackbar("خطأ", "المعلومة غير موجودة");
        return;
      }

      final infoData = infoDoc.data()!;
      final currentUsers = List<String>.from(infoData['users'] ?? []);

      if (!currentUsers.contains(currentUserId.value)) {
        showCustomSnackbar("تنبيه", "أنت غير مسجل في هذه المعلومة");
        return;
      }

      currentUsers.remove(currentUserId.value);

      await _firestore
          .collection('informations')
          .doc(infoId)
          .update({'users': currentUsers});

      showCustomSnackbar("نجح", "تم الانسحاب من المعلومة بنجاح");
      await refreshInformations();
    } catch (e) {
      print('Error leaving information: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في الانسحاب من المعلومة");
    }
  }

  bool isUserJoined(String infoId) {
    final info = informations.firstWhereOrNull((i) => i.id == infoId);
    if (info == null) return false;
    return info.users.contains(currentUserId.value);
  }

  int getJoinedUsersCount(String infoId) {
    final info = informations.firstWhereOrNull((i) => i.id == infoId);
    return info?.users.length ?? 0;
  }

  void selectInfo(InfModel info) {
    selectedInfo.value = info;
  }

  void clearSelectedInfo() {
    selectedInfo.value = null;
  }

  List<InfModel> getInformationsForCategory(String category) {
    return informations.where((info) => info.forr == category).toList();
  }

  List<String> getAvailableCategories() {
    return informations.map((info) => info.forr).toSet().toList();
  }
}
