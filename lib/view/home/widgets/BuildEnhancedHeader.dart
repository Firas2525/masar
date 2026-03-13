import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import '../my_payments_page.dart';

import 'package:http/http.dart' as http;

import '../../../color.dart';
import '../../../controller/home_controller.dart';
import '../service_owner_requests_page.dart';
import '../messages_page.dart';
import 'BuildEnhancedProfileAvatar.dart';
class BuildEnhancedHeader extends StatelessWidget {

  const BuildEnhancedHeader({super.key, required this.w, required this.controller});
  final double w;
  final HomeController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الواجهة الرئيسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF22223B))),
              SizedBox(height: 4),
              Row(children: [
                Text(controller.userName.isNotEmpty ? 'مرحبا، ${controller.userName}' : 'مرحباً', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                SizedBox(width: 8),
                if (controller.isServiceOwner)
                  GestureDetector(
                    onTap: () => Get.to(() => ServiceOwnerRequestsPage()),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: primaryblue.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text('قائمة طلبات الصيانة', style: TextStyle(color: primaryblue, fontSize: 12)),
                    ),
                  ),
              ])
            ],
          ),
          Row(children: [
            IconButton(
              tooltip: 'الدفوعات',
              icon: Icon(Icons.payment, color: primaryblue),
              onPressed: () => Get.to(() => MyPaymentsPage()),
            ),
            BuildEnhancedProfileAvatar(w: w),
          ]),
        ],
      ),
    );
  }
}