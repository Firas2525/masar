import 'package:flutter/material.dart';
import 'package:kindergarten_user/color.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/manager_register_requests_controller.dart';

class ManagerRegisterRequestsPage extends StatelessWidget {
  const ManagerRegisterRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات التسجيل'),
        backgroundColor: primaryblue,
      ),
      body: GetBuilder<ManagerRegisterRequestsController>(
        init: ManagerRegisterRequestsController(),
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(primaryblue),
              ),
            );
          }
          if (ctrl.pendingChildren.isEmpty) {
            return Center(child: Text('لا توجد طلبات تسجيل حالياً'));
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

              return Container(
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
                        ],
                      ),
                      SizedBox(height: h * 0.014),
                      GridView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                      SizedBox(height: h * 0.012),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // show parent/user info
                              final parentId = (item['parentId'] ?? '').toString();
                              if (parentId.isEmpty) {
                                Get.snackbar('معلومة', 'معرف المستخدم غير متوفر');
                                return;
                              }
                              await _showUserInfo(context, parentId);
                            },
                            icon: Icon(Icons.person_outline),
                            label: Text('عرض المستخدم'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryblue,
                              elevation: 0,
                              side: BorderSide(
                                color: primaryblue.withOpacity(0.12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(width: w * 0.02),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final ok = await _confirm(context, 'rejected');
                              if (ok == true) {
                                await ctrl.updateApproval(id, 'rejected');
                              }
                            },
                            icon: Icon(Icons.cancel_outlined),
                            label: Text('رفض الطلب'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryPink,
                              elevation: 0,
                              side: BorderSide(
                                color: primaryPink.withOpacity(0.6),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),



                          SizedBox(width: w * 0.02),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final ok = await _confirm(context, 'approved');
                              if (ok == true) {
                                await ctrl.updateApproval(id, 'approved');
                              }
                            },
                            icon: Icon(Icons.check_circle_outline),
                            label: Text('موافقة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryblue,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),

                  ),

              );
            },
          );
        },
      ),
    );
  }

  Future<bool?> _confirm(BuildContext context, String newStatus) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('تأكيد'),
        content: Text('هل أنت متأكد من تغيير الحالة إلى "$newStatus"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: primaryPink),
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserInfo(BuildContext context, String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('المستخدم'),
            content: Text('لم يتم العثور على بيانات المستخدم.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('إغلاق'))],
          ),
        );
        return;
      }

      final data = doc.data() ?? {};
      final name = (data['name'] ?? '').toString();
      final email = (data['email'] ?? '').toString();
      final phone = (data['phone'] ?? '').toString();
      final address = (data['address'] ?? '').toString();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text('معلومات المستخدم'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name.isNotEmpty) Text('الاسم: $name'),
              if (email.isNotEmpty) Text('البريد: $email'),
              if (phone.isNotEmpty) Text('الهاتف: $phone'),
              if (address.isNotEmpty) Text('العنوان: $address'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('إغلاق')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // إمكانية إضافة تنقل لصفحة ملف المستخدم لاحقاً
              },
              child: Text('حسناً'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر جلب بيانات المستخدم');
    }
  }

  // _chip removed (replaced by _chipColored)

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
