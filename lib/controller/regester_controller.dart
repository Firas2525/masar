import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../view/home/home_view.dart';
import '../widgets/custom_snackbar.dart';

class RegesterController extends GetxController {
  bool isLoading = false;
  bool all_information = false;
  FirebaseAuth get auth => _auth;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController myname = TextEditingController();
  TextEditingController myemail = TextEditingController();
  TextEditingController mypassword = TextEditingController();

  regester() async {
    isLoading = true;
    update();
    if (myname.text.trim().isEmpty) {
      showCustomSnackbar("إنشاء حساب", "الرجاء إدخال الاسم الظاهر");
    } else if (myemail.text.length < 6) {
      showCustomSnackbar("إنشاء حساب", "أدخل بريد الكتروني صالح");
    } else if (mypassword.text.length < 8) {
      showCustomSnackbar(
        "إنشاء حساب",
        "يجب أن تكون كلمة المرور ثمانية محارف على الأقل",
      );
    } else {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: myemail.text.trim(),
              password: mypassword.text,
            );

        // Create user document in Firestore with provided name
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': myemail.text.trim(),
          'name': myname.text.trim(),
          'phone': '',
          'address': '',
          'children': [],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Sign in and proceed
        signIn(myemail.text.trim(), mypassword.text);
      } on FirebaseAuthException catch (e) {
        if (e.code.toString() == "network-request-failed") {
          showCustomSnackbar("إنشاء حساب", "خطأ .. تحقق من اتصالك بالانترنت");
        } else if (e.code == "email-already-in-use") {
          showCustomSnackbar(
            "إنشاء حساب",
            "خطأ .. هذا البريد الالكتروني لديه حساب بالفعل",
          );
        } else if (e.code == "invalid-email") {
          showCustomSnackbar(
            "إنشاء حساب",
            "خطأ .. هذا البريد الالكتروني غير صالح",
          );
        }
      } catch (e) {
        showCustomSnackbar("خطأ", e.toString());
      }
    }
    isLoading = false;
    update();
  }

  Future<void> signIn(email, password) async {
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
    } finally {}
  }
}
