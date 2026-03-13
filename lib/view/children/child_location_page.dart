import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/color.dart';
import 'package:kindergarten_user/color.dart';
import '../../controller/child_location_controller.dart';
import '../../model/home_model.dart';

const Color accentColor = Color(0xFFFF6B6B);
const Color backgroundColor = Color(0xFFF7F9FC);
const Color cardColor = Colors.white;

class ChildLocationPage extends StatelessWidget {
  final Child child;

  const ChildLocationPage({required this.child});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    final controller = Get.put(ChildLocationController(child));

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Color(0xFF5B86E5),
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'موقع ${child.name}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 340,
          padding: EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.getLocationIcon(),
                size: 64,
                color: controller.getLocationColor(),
              ),
              SizedBox(height: 24),
              Text(
                controller.locationArabicText,
                style: TextStyle(
                  color: Color(0xFF5B86E5),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'آخر تحديث: الآن',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
