import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../color.dart';
import '../../../constants.dart';
import '../../../model/home_model.dart';
import 'BuildEnhancedApprovalStatusIndicator.dart';

class BuildEnhancedChildCard extends StatelessWidget {
  const BuildEnhancedChildCard({
    super.key,
    required this.w,
    required this.child,
    required this.onTap,
  });

  final double w;
  final Child child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.015),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryPurble.withOpacity(0.10),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: w * 0.16,
                  height: w * 0.16,
                  decoration: BoxDecoration(
                    color: primaryPurble,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurble.withOpacity(0.18),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.family_restroom_rounded,
                    color: Colors.white,
                    size: w * 0.08,
                  ),
                ),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              child.name,
                              style: textStyleSubheading.copyWith(
                                fontSize: w * 0.042,
                                color: Color(0xFF22223B),
                              ),
                            ),
                          ),
                          BuildEnhancedApprovalStatusIndicator(
                            w: w,
                            child: child,
                          ),
                        ],
                      ),
                      SizedBox(height: w * 0.015),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.025,
                          vertical: w * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: primaryblue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${child.classroom} - ${child.age}",
                          style: textStyleBody.copyWith(
                            color: primaryblue,
                            fontSize: w * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(w * 0.025),
                  decoration: BoxDecoration(
                    color: primaryblue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryblue.withOpacity(0.25),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: w * 0.045,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
