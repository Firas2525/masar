import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';

// 🎨 ألوان مبهجة وجذابة
const Color primaryColor = Color(0xFF4FC3F7);
const Color secondaryColor = Color(0xFFFFF176);
const Color backgroundColor = Color(0xFFF1F8E9);
const Color cardColor = Color(0xFFFFF3E0);
const Color textColor = Color(0xFF263238);
const Color accentColor = Color(0xFFF06292);
const Color shadowColor = Colors.black26;

class Status extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // خلفية ضبابية خفيفة
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
            height: h * 0.4,
          ),

          // محتوى الصفحة
          ListView(
            children: [
              SizedBox(height: h * 0.1),
              Row(
                children: [
                  SizedBox(width: w * 0.02),
                  Padding(
                    padding: EdgeInsets.only(right: w * 0.08),
                    child: Text(
                      "حالة الطفل",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: w * 0.07,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(left: w * 0.06),
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_forward,
                        size: w * 0.07,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.01),
              Padding(
                padding: EdgeInsets.only(right: w * 0.1),
                child: Text(
                  "ستتحدث هذه الصفحة باستمرار",
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: w * 0.035,
                  ),
                ),
              ),
              SizedBox(height: h * 0.07),
              SizedBox(
                height: h * 0.7,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, i) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: MyCard(
                              i==0?  Icons.location_city:i==1? Icons.directions_bus: Icons.home ,
                           i==0? 'في الروضة':i==1?"في الباص":"في المنزل",
                            i==0? 'الطفل في الروضة الأن':i==1?'الطفل في الباص الأن':'الطفل في المنزل الأن',
                              i==0? true:i==1?false:false
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// بطاقة مخصصة
Widget MyCard(IconData icon, String text1, String text2,bool active) {
  return Container(
    height: Get.height * 0.15,
    margin: EdgeInsets.symmetric(horizontal: Get.width * 0.09),
    decoration: BoxDecoration(
      color: cardColor,
      border: Border.all(color: active?accentColor:primaryColor, width:  active?2:1),
      boxShadow: [
        BoxShadow(color: shadowColor, blurRadius: 8, offset: Offset(1, 2)),
      ],
      borderRadius: BorderRadius.circular(20),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.only(
        top: Get.height * 0.03,
        right: Get.width * 0.1,
        left: Get.width * 0.1,
      ),
      title: Text(
        text1,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: Get.width * 0.045,
        ),
      ),
      subtitle: Text(
        text2,
        style: TextStyle(
          color: textColor.withOpacity(0.7),
          fontWeight: FontWeight.normal,
          fontSize: Get.width * 0.035,
        ),
      ),
      trailing: CircleAvatar(
        radius: Get.width * 0.07,
        backgroundColor: accentColor,
        child: Icon(
          icon,
          color: Colors.white,
          size: Get.width * 0.08,
        ),
      ),
    ),
  );
}
