import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/controller/subjects_controller.dart';
import '../../controller/classes_controller.dart';
import '../../model/home_model.dart';

// الألوان الأساسية
const Color primaryColor = Color(0xFF5B86E5);
const Color secondaryColor = Color(0xFF36D1DC);
const Color accentColor = Color(0xFFFF6B6B);
const Color backgroundColor = Color(0xFFF7F9FC);
const Color cardColor = Colors.white;
const Color textColor = Color(0xFF2D3436);

// التدرجات اللونية
const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient accentGradient = LinearGradient(
  colors: [Color(0xFFFF6B6B), Color(0xFFFF9F9F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SubjectsPage extends StatelessWidget {
  final Class classItem;

  SubjectsPage({required this.classItem});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubjectsController(classItem.id));
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // خلفية مع نمط زخرفي
          Positioned(
            top: -h * 0.2,
            right: -w * 0.2,
            child: Container(
              width: w * 0.8,
              height: w * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: primaryGradient.scale(0.5),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          // المحتوى الرئيسي
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchSubjects(),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(w, h),
                    _buildSubjectsList(w, h, controller),
                    SizedBox(height: h * 0.05),
                  ],
                ),
              ),
            ),
          ),
          // Loading Overlay
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                )
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildHeader(double w, double h) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(w * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: primaryColor,
                size: w * 0.05,
              ),
            ),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classItem.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "المواد الدراسية",
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: w * 0.035,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(double w, double h, SubjectsController controller) {
    return Obx(() => controller.subjects.isEmpty
        ? Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: h * 0.1),
              child: Column(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: w * 0.2,
                    color: Colors.grey,
                  ),
                  SizedBox(height: h * 0.02),
                  Text(
                    "لا توجد مواد متوفرة",
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: w * 0.045,
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Text(
                    "سيتم إضافة المواد قريباً",
                    style: TextStyle(
                      color: textColor.withOpacity(0.3),
                      fontSize: w * 0.035,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.subjects.length,
            itemBuilder: (context, index) {
              final subject = controller.subjects[index];
              return _buildSubjectCard(w, h, subject);
            },
          ));
  }

  Widget _buildSubjectCard(double w, double h, Subject subject) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: w * 0.04,
        vertical: w * 0.02,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSubjectDetails(w, h, subject),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: w * 0.12,
                      height: w * 0.12,
                      decoration: BoxDecoration(
                        gradient: accentGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.book_rounded,
                        color: Colors.white,
                        size: w * 0.06,
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: w * 0.005),
                          Text(
                            "الترتيب: ${subject.index}",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: w * 0.03,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(w * 0.02),
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: w * 0.04,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.02),
                Text(
                  subject.description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: w * 0.035,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subject.timeline.isNotEmpty) ...[
                  SizedBox(height: w * 0.02),
                  Row(
                    children: [
                      Icon(
                        Icons.timeline_rounded,
                        color: accentColor,
                        size: w * 0.035,
                      ),
                      SizedBox(width: w * 0.01),
                      Text(
                        "${subject.timeline.length} مرحلة",
                        style: TextStyle(
                          color: accentColor,
                          fontSize: w * 0.03,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSubjectDetails(double w, double h, Subject subject) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: w * 0.9,
          height: h * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  gradient: accentGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.book_rounded,
                      color: Colors.white,
                      size: w * 0.06,
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "الترتيب: ${subject.index}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: w * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: w * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(w * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الوصف",
                        style: TextStyle(
                          color: textColor,
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Text(
                        subject.description,
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: w * 0.035,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: h * 0.03),
                      Text(
                        "المراحل الزمنية",
                        style: TextStyle(
                          color: textColor,
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      Expanded(
                        child: subject.timeline.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timeline_outlined,
                                      size: w * 0.15,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: h * 0.02),
                                    Text(
                                      "لا توجد مراحل زمنية",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: w * 0.04,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _buildTimeline(w, h, subject.timeline),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(double w, double h, List<TimelineItem> timeline) {
    return ListView.builder(
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final item = timeline[index];
        final isLast = index == timeline.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            Column(
              children: [
                Container(
                  width: w * 0.04,
                  height: w * 0.04,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: h * 0.08,
                    color: primaryColor.withOpacity(0.3),
                  ),
              ],
            ),
            SizedBox(width: w * 0.03),
            // Content
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: h * 0.02),
                padding: EdgeInsets.all(w * 0.03),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: w * 0.035,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 