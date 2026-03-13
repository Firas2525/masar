import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/home_model.dart';
import '../widgets/custom_snackbar.dart';

class StatusController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final isLoading = false.obs;
  final currentUserId = ''.obs;
  final userChildren = <Child>[].obs;
  final selectedChild = Rxn<Child>();

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
          _loadUserChildren();
        } else {
          Get.offAllNamed('/login');
        }
      });
    } catch (e) {
      print('Error in _initializeUser: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تهيئة المستخدم");
    }
  }

  Future<void> _loadUserChildren() async {
    try {
      isLoading.value = true;
      
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUserId.value)
          .get();

      if (!userDoc.exists) {
        userChildren.value = [];
        return;
      }

      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('children')) {
        userChildren.value = [];
        return;
      }

      final List childrenRefs = userData['children'];
      final childrenDocs = await Future.wait(
        childrenRefs.map((ref) => (ref as DocumentReference).get()),
      );

      userChildren.value = childrenDocs
          .where((doc) => doc.exists)
          .map((doc) => Child.fromFirestore(doc.data() as Map<String, dynamic>, doc.id!))
          .toList();
    } catch (e) {
      print('Error loading user children: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل بيانات الأطفال");
      userChildren.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshChildren() async {
    await _loadUserChildren();
  }

  void selectChild(Child child) {
    selectedChild.value = child;
  }

  void clearSelectedChild() {
    selectedChild.value = null;
  }

  List<Child> getChildrenByClassroom(String classroom) {
    return userChildren.where((child) => child.classroom == classroom).toList();
  }

  List<String> getAvailableClassrooms() {
    return userChildren.map((child) => child.classroom).toSet().toList();
  }

  int getChildrenCount() {
    return userChildren.length;
  }

  int getChildrenCountByClassroom(String classroom) {
    return getChildrenByClassroom(classroom).length;
  }

  double getAverageAge() {
    if (userChildren.isEmpty) return 0.0;
    
    double totalAge = 0.0;
    int validAges = 0;
    
    for (final child in userChildren) {
      try {
        final age = _calculateAge(child.birthDate);
        if (age > 0) {
          totalAge += age;
          validAges++;
        }
      } catch (e) {
        print('Error calculating age for child ${child.name}: $e');
      }
    }
    
    return validAges > 0 ? totalAge / validAges : 0.0;
  }

  double _calculateAge(String birthDate) {
    try {
      final birthDateParts = birthDate.split('-');
      if (birthDateParts.length == 3) {
        final birth = DateTime(
          int.parse(birthDateParts[2]),
          int.parse(birthDateParts[1]),
          int.parse(birthDateParts[0]),
        );
        final now = DateTime.now();
        return now.difference(birth).inDays / 365.25;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Map<String, int> getGenderDistribution() {
    final Map<String, int> distribution = {'male': 0, 'female': 0};
    
    for (final child in userChildren) {
      // افتراض أن النموذج يحتوي على حقل gender
      // إذا لم يكن موجوداً، يمكن إضافته للنموذج
      final gender = _getChildGender(child);
      distribution[gender] = (distribution[gender] ?? 0) + 1;
    }
    
    return distribution;
  }

  String _getChildGender(Child child) {
    // يمكن إضافة حقل gender للنموذج أو استخدام طريقة أخرى لتحديد الجنس
    // حالياً نستخدم طريقة بسيطة
    return 'male'; // افتراضي
  }

  List<Child> getChildrenByAgeRange(int minAge, int maxAge) {
    return userChildren.where((child) {
      final age = _calculateAge(child.birthDate);
      return age >= minAge && age <= maxAge;
    }).toList();
  }

  Child? getYoungestChild() {
    if (userChildren.isEmpty) return null;
    
    Child youngest = userChildren.first;
    double youngestAge = _calculateAge(youngest.birthDate);
    
    for (final child in userChildren) {
      final age = _calculateAge(child.birthDate);
      if (age < youngestAge) {
        youngest = child;
        youngestAge = age;
      }
    }
    
    return youngest;
  }

  Child? getOldestChild() {
    if (userChildren.isEmpty) return null;
    
    Child oldest = userChildren.first;
    double oldestAge = _calculateAge(oldest.birthDate);
    
    for (final child in userChildren) {
      final age = _calculateAge(child.birthDate);
      if (age > oldestAge) {
        oldest = child;
        oldestAge = age;
      }
    }
    
    return oldest;
  }
} 