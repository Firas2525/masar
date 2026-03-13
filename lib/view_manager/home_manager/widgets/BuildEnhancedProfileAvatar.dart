import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../color.dart';
import '../../../controller/home_controller.dart';
import '../../../controller/manager_home_controller.dart';

class BuildEnhancedProfileAvatar extends StatelessWidget {
  const BuildEnhancedProfileAvatar({super.key, required this.w});
  final double w;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showLogoutDialog(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(w * 0.012),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryPurble.withOpacity(0.18),
                  blurRadius: 18,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: w * 0.065,
              backgroundColor: primaryPink,
              child: Icon(Icons.logout, color: Colors.white, size: w * 0.065),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout_rounded, color: primaryPink, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "تسجيل الخروج",
                style: TextStyle(
                  color: primaryPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "هل أنت متأكد من أنك تريد تسجيل الخروج؟",
          style: TextStyle(fontSize: 16, height: 1.4, color: Colors.grey[700]),
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
              // جرب إيجاد HomeController أولاً، إذا لم يوجد استخدم ManagerHomeViewController
              try {
                final homeController = Get.find<HomeController>();
                homeController.signOut();
              } catch (e) {
                final managerController = Get.find<ManagerHomeViewController>();
                managerController.signOut();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "تسجيل الخروج",
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
}
