

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🎨 ألوان مبهجة وجذابة
const Color primaryColor = Color(0xFF4FC3F7);
const Color secondaryColor = Color(0xFFFFF176);
const Color backgroundColor = Color(0xFFF1F8E9);
const Color cardColor = Color(0xFFFFF3E0);
const Color textColor = Color(0xFF263238);
const Color accentColor = Color(0xFFF06292);
const Color shadowColor = Colors.black26;

class Rate extends StatelessWidget {

  final String day;
  final List<Map<String, String>> activities;

  const Rate({required this.day, required this.activities});
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.08),
                  child: Row(
                    children: [
                      Text(
                        "الأنشطة و التقييم",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.07,
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Icon(Icons.arrow_forward, size: w * 0.07, color: accentColor),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: w * 0.1, top: h*0.01),
                  child: Text(
                    "تقييم الطفل في كل نشاط",
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.035,
                    ),
                  ),
                ),
                SizedBox(height: h*0.06),
                Expanded(
                  child:ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return Padding(
                        padding:  EdgeInsets.symmetric(vertical: h*0.01,horizontal: w*0.05),
                        child: Container(

                          padding: EdgeInsets.symmetric(vertical: h*0.02,horizontal: w*0.04),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: shadowColor, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: accentColor),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      activity['name']!,
                                      style: TextStyle(
                                        fontSize: w * 0.045,
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Get.height*0.02),
                              Text(
                                "التاريخ: ${activity['date']}",
                                style: TextStyle(color: textColor, fontSize: w * 0.035),
                              ),
                              SizedBox(height: Get.height*0.02),
                              Text(
                                "التقييم: ${activity['evaluation']}",
                                style: TextStyle(color: accentColor, fontSize: w * 0.035),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              ),
            ),
          ),
        ),
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          height: 250,
        ),
      ],
    );
  }
}

/*


 */