import 'package:flutter/material.dart';
import '../../../color.dart';

class BuildModernDecorativeBackground extends StatelessWidget {
  const BuildModernDecorativeBackground({
    super.key,
    required this.w,
    required this.h,
  });

  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.35),
      child: Stack(
        children: [
          // دائرة بنفسجي فاتح
          Positioned(
            top: h * 0.25,
            right: -w * 0.15,
            child: Container(
              width: w * 0.7,
              height: w * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryPurble,
                boxShadow: [
                  BoxShadow(
                    color: primaryPurble.withOpacity(0.08),
                    blurRadius: 60,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          // دائرة زرقاء سماوية
          Positioned(
            top: h * 0.05,
            left: -w * 0.12,
            child: Container(
              width: w * 0.6,
              height: w * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryblue,

                boxShadow: [
                  BoxShadow(
                    color: primaryblue.withOpacity(0.08),
                    blurRadius: 80,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          // فقاعة وردية طفولية في الأسفل يسار
          Positioned(
            bottom: -h * 0.1,
            left: -w * 0.05,
            child: Container(
              width: w * 0.5,
              height: w * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryPink,
                boxShadow: [
                  BoxShadow(
                    color: primaryPink.withOpacity(0.08),
                    blurRadius: 40,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
