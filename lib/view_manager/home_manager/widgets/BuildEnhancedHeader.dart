import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kindergarten_user/controller/manager_home_controller.dart';
import 'BuildEnhancedProfileAvatar.dart';
import '../../../model/home_model.dart';
import '../../../color.dart';
class BuildEnhancedHeader extends StatelessWidget {

  const BuildEnhancedHeader({super.key, required this.w, required this.controller});
  final double w;
  final ManagerHomeViewController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BuildEnhancedProfileAvatar(w: w),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: w * 0.012),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Row(
                  children: [
                    // Add Ad
                    GestureDetector(
                      onTap: () async {
                        await controller.addAd();
                        await controller.refreshData();
                      },
                      child: Tooltip(
                        message: 'إضافة إعلان',
                        child: CircleAvatar(
                          radius: w * 0.045,
                          backgroundColor: primaryPink,
                          child: Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: w * 0.045),
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    Container(width: 1, height: w * 0.08, color: Colors.white.withOpacity(0.3)),
                    SizedBox(width: w * 0.02),
                    // Delete Ad
                    GestureDetector(
                      onTap: controller.announcements.isEmpty ? null : () async {
                        final currentIndex = controller.addsController.hasClients
                            ? controller.addsController.page?.round() ?? 0
                            : 0;
                        final ad = controller.announcements[currentIndex] as Announcement;
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text("تأكيد الحذف"),
                            content: Text("هل أنت متأكد أنك تريد حذف الإعلان؟"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("إلغاء"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: primaryPink),
                                child: Text("حذف"),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await controller.deleteAdById(ad.id);
                          await controller.refreshData();
                        }
                      },
                      child: Tooltip(
                        message: 'حذف الإعلان',
                        child: CircleAvatar(
                          radius: w * 0.045,
                          backgroundColor: primaryPink,
                          child: Icon(Icons.delete_outline, color: Colors.white, size: w * 0.045),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}