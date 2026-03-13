import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kindergarten_user/controller/manager_home_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../color.dart';
import '../../../constants.dart';
import '../../../controller/home_controller.dart';
import 'BuildEnhancedChildCard.dart';
class BuildEnhancedChildrenSection extends StatelessWidget {
  const BuildEnhancedChildrenSection({Key? key, required this.w, required this.h, required this.controller}) : super(key: key);
  final double w;
  final double h;
  final ManagerHomeViewController controller;
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top: h * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(w * 0.025),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryPink, primaryPink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryblue.withOpacity(0.18),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.family_restroom_rounded,
                        color: Colors.white,
                        size: w * 0.055,
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Text(
                      "الأطفال المسجلين",
                      style: textStyleSubheading.copyWith(
                        fontSize: w * 0.045,
                        color: Color(0xFF22223B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.02),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.children.length,
            itemBuilder: (context, index) {
              final child = controller.children[index];
              return BuildEnhancedChildCard(
                w: w,
                child: child,
                onTap: () => controller.onChildTap(child),
              );
            },
          ),
        ],
      ),
    );
  }
}