import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/color.dart';
import 'package:kindergarten_user/view/home/home_view.dart' hide primaryblue;

import '../constants.dart';

void showCustomSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackStyle: SnackStyle.FLOATING,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    borderRadius: 12,
    duration: Duration(seconds: 3),
    forwardAnimationCurve: Curves.easeInOut,
    backgroundGradient: LinearGradient(colors: [primaryblue, colorPrimary]),
    titleText: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    messageText: Text(message, style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 14)),
    boxShadows: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
  );
}
