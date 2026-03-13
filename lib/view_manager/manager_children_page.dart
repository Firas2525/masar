import 'package:flutter/material.dart';
import 'package:kindergarten_user/color.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/manager_children_controller.dart';

class ManagerChildrenPage extends StatelessWidget {
  const ManagerChildrenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text('الأطفال'), backgroundColor: primaryblue),
      body: GetBuilder<ManagerChildrenController>(
        init: ManagerChildrenController(),
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(primaryblue),
              ),
            );
          }
          if (ctrl.pendingChildren.isEmpty) {
            return Center(child: Text('لا يوجد أطفال حالياً'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(w * 0.04),
            itemCount: ctrl.pendingChildren.length,
            separatorBuilder: (_, __) => SizedBox(height: h * 0.012),
            itemBuilder: (context, index) {
              final item = ctrl.pendingChildren[index];
              final id = (item['id'] ?? '').toString();
              final birthDate = (item['birthDate'] ?? '').toString();
              final classroom = (item['classroom'] ?? '').toString();
              final gender = (item['gender'] ?? '').toString();
              final name = (item['name'] ?? '').toString();
              final approved = (item['approved'] ?? '').toString();
              final registerDateRaw = item['registerDate'];
              String registerDate = '';
              if (registerDateRaw != null) {
                if (registerDateRaw is Timestamp) {
                  final d = registerDateRaw.toDate();
                  registerDate =
                      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                } else {
                  registerDate = registerDateRaw.toString();
                }
              }

              return  approved == "approved" ?InkWell(
                onTap: () {
                  if (id.isNotEmpty && approved == "approved") {
                    Get.toNamed(
                      '/manager/child-details',
                      arguments: {'childId': id},
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryblue.withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryblue.withOpacity(0.12),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(w * 0.028),
                              decoration: BoxDecoration(
                                color: primaryblue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: primaryblue,
                                size: w * 0.065,
                              ),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Text(
                                name.isEmpty ? 'غير محدد' : name,
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF22223B),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: primaryPink),
                              tooltip: 'حذف الطالب',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('تأكيد الحذف'),
                                    content: Text('هل أنت متأكد أنك تريد حذف هذا الطالب؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryPink,
                                        ),
                                        child: Text('حذف'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ctrl.deleteChild(id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تم حذف الطالب بنجاح'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.014),
                        GridView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.6,
                                crossAxisSpacing: w * 0.03,
                                mainAxisSpacing: h * 0.01,
                              ),
                          children: [
                            _chipColored(
                              w,
                              Icons.calendar_today_rounded,
                              'تاريخ الميلاد',
                              birthDate,
                              primaryblue,
                            ),
                            _chipColored(
                              w,
                              Icons.meeting_room_rounded,
                              'الصف',
                              classroom,
                              primaryblue,
                            ),
                            _chipColored(
                              w,
                              Icons.wc_rounded,
                              'الجنس',
                              gender,
                              primaryblue,
                            ),
                            _chipColored(
                              w,
                              Icons.access_time_rounded,
                              'تاريخ التسجيل',
                              registerDate.isEmpty ? 'غير محدد' : registerDate,
                              primaryblue,
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ):SizedBox();
            },
          );
        },
      ),
    );
  }

  Widget _chipColored(
    double w,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.02),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: w * 0.05),
          SizedBox(width: w * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black54, fontSize: w * 0.028),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: w * 0.032,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
