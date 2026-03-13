import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_snackbar.dart';

class LoginController extends GetxController {
  FirebaseAuth get auth => _auth;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // للحفاظ على التوافق مع الواجهة الحالية
  TextEditingController get myemail => emailController;
  TextEditingController get mypassword => passwordController;

  @override
  void onInit() {
    super.onInit();
    // التحقق من وجود مستخدم مسجل دخول
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      Get.offAllNamed('/home');
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> signIn() async {
    // التحقق من صحة البيانات يدوياً
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      showCustomSnackbar("خطأ", "يرجى إدخال البريد الإلكتروني");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      showCustomSnackbar("خطأ", "يرجى إدخال بريد إلكتروني صحيح");
      return;
    }

    if (password.isEmpty) {
      showCustomSnackbar("خطأ", "يرجى إدخال كلمة المرور");
      return;
    }

    if (password.length < 6) {
      showCustomSnackbar("خطأ", "كلمة المرور يجب أن تكون 6 أحرف على الأقل");
      return;
    }

    try {
      isLoading.value = true;

      // تسجيل الدخول باستخدام Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // التحقق من وجود بيانات المستخدم في Firestore
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userQuery.docs.isNotEmpty) {
          showCustomSnackbar("نجح", "تم تسجيل الدخول بنجاح");
          Get.offAllNamed('/home');
        } else {
          // إذا لم تكن بيانات المستخدم موجودة في Firestore، إنشاؤها
          final userData = {
            'email': email,
            'name': userCredential.user!.displayName ?? '',
            'phone': '',
            'address': '',
            'children': [],
            'createdAt': FieldValue.serverTimestamp(),
          };

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userData);

          showCustomSnackbar("نجح", "تم إنشاء حساب جديد وتسجيل الدخول بنجاح");
          Get.offAllNamed('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "حدث خطأ في تسجيل الدخول";

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "البريد الإلكتروني غير مسجل";
          break;
        case 'wrong-password':
          errorMessage = "كلمة المرور غير صحيحة";
          break;
        case 'invalid-email':
          errorMessage = "البريد الإلكتروني غير صحيح";
          break;
        case 'user-disabled':
          errorMessage = "تم تعطيل هذا الحساب";
          break;
        case 'too-many-requests':
          errorMessage = "تم تجاوز عدد المحاولات المسموح، حاول لاحقاً";
          break;
        case 'network-request-failed':
          errorMessage = "خطأ في الاتصال بالشبكة";
          break;
      }

      showCustomSnackbar("خطأ", errorMessage);
    } catch (e) {
      print('Error in signIn: $e');
      showCustomSnackbar("خطأ", "حدث خطأ غير متوقع");
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    formKey.currentState?.reset();
  }

  @override
  void onClose() {
    emailController.text = "";
    passwordController.text = "";
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    if (!GetUtils.isEmail(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  // للحفاظ على التوافق مع الواجهة الحالية
  Future<void> login() async {
    await signIn();
  }
}
