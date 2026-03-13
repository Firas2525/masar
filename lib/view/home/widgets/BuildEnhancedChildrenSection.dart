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
import '../../../controller/home_controller.dart';
import '../../children/add_child_page.dart' hide primaryblue;
import '../my_cars_page.dart';
import '../car_details_page.dart';
import 'BuildEnhancedCarCard.dart';

class BuildEnhancedChildrenSection extends StatelessWidget {
  const BuildEnhancedChildrenSection({
    Key? key,
    required this.w,
    required this.h,
    required this.controller,
  }) : super(key: key);
  final double w;
  final double h;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final forSaleCars = controller.cars.where((c) => c.isForSale).toList();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "السيارات المعروضة",
                      style: textStyleSubheading.copyWith(
                        fontSize: w * 0.045,
                        color: Color(0xFF22223B),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (controller.userId.isEmpty) {
                      Get.snackbar('تنبيه', 'يجب تسجيل الدخول أولاً');
                      return;
                    }

                    final ownedCars = controller.cars
                        .where((c) => c.userId == controller.userId)
                        .toList();
                    if (ownedCars.isNotEmpty) {
                      // المستخدم لديه سيارة/سيارات -> افتح صفحة 'سيارتي'
                      Get.to(() => MyCarsPage());
                      return;
                    }

                    // لا توجد سيارة للمستخدم -> السماح بإضافة واحدة
                    Get.to(() => AddChildPage());
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.035,
                      vertical: w * 0.02,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          controller.cars.any(
                            (c) => c.userId == controller.userId,
                          )
                          ? null
                          : LinearGradient(
                              colors: [primaryblue, primaryblue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color:
                          controller.cars.any(
                            (c) => c.userId == controller.userId,
                          )
                          ? Colors.grey[300]
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurble.withOpacity(0.12),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color:
                              controller.cars.any(
                                (c) => c.userId == controller.userId,
                              )
                              ? primaryblue
                              : Colors.white,
                          size: w * 0.045,
                        ),
                        SizedBox(width: w * 0.015),
                        Text(
                          controller.cars.any(
                                (c) => c.userId == controller.userId,
                              )
                              ? "عرض سيارتي"
                              : "أضف سيارة",
                          style: TextStyle(
                            color:
                                controller.cars.any(
                                  (c) => c.userId == controller.userId,
                                )
                                ? primaryBlack
                                : Colors.white,
                            fontSize: w * 0.032,
                            fontWeight: FontWeight.bold,
                            fontFamily: kGtSectraFine,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.02),
          if (forSaleCars.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: h * 0.04),
              child: Center(
                child: Text(
                  'لا توجد سيارات معروضة للبيع',
                  style: textStyleBody,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: w * 0.02,
                mainAxisSpacing: h * 0.02,
                childAspectRatio: (0.56),
              ),
              itemCount: forSaleCars.length,
              itemBuilder: (context, index) {
                final car = forSaleCars[index];
                return BuildEnhancedCarCard(
                  w: w,
                  car: car,
                  onTap: () {
                    Get.to(() => CarDetailsPage(car: car));
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
