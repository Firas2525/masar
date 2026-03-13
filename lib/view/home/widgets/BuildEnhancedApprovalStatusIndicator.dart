import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../color.dart';
import '../../../constants.dart';
import '../../../model/home_model.dart';



class BuildEnhancedApprovalStatusIndicator extends StatelessWidget {
  const BuildEnhancedApprovalStatusIndicator({
    Key? key, required this.w, required this.child}) : super(key: key);
  final double w;
  final Child child;
  @override
  Widget build(BuildContext context) {
    switch (child.approved.toLowerCase()) {
      case 'wait':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.025,
            vertical: w * 0.015,
          ),
          decoration: BoxDecoration(
            color: primaryPurble.withOpacity(0.13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryPurble.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pending_rounded,
                color: primaryPurble,
                size: w * 0.035,
              ),
              SizedBox(width: w * 0.015),
              Text(
                "في انتظار المراجعة",
                style: textStyleCaption.copyWith(
                  color: Color(0xFF6C63FF),
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case 'approved':
      // لا يتم عرض أي مؤشر لحالة الموافقة
        return SizedBox.shrink();
      case 'rejected':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.025,
            vertical: w * 0.015,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorError.withOpacity(0.1),
                colorError.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorError.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_rounded, color: colorError, size: w * 0.035),
              SizedBox(width: w * 0.015),
              Text(
                "تم الرفض",
                style: textStyleCaption.copyWith(
                  color: colorError,
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.025,
            vertical: w * 0.015,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorTextLight.withOpacity(0.1),
                colorTextLight.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorTextLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_rounded, color: colorTextLight, size: w * 0.035),
              SizedBox(width: w * 0.015),
              Text(
                "غير محدد",
                style: textStyleCaption.copyWith(
                  color: colorTextLight,
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }}
}