import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import 'create_purchase_request_page.dart';
import '../../color.dart';
import '../../model/home_model.dart';
import '../../widgets/custom_snackbar.dart';

class MyPurchaseRequestsPage extends StatelessWidget {
  const MyPurchaseRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('طلباتي'),
        backgroundColor: primaryblue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final titleCtrl = TextEditingController();
              final descCtrl = TextEditingController();
              bool sending = false;
              final ok = await Get.dialog<bool>(
                Dialog(
                  backgroundColor: Colors.transparent,
                  child: StatefulBuilder(
                    builder: (ctx, setState) {
                      return Container(
                        constraints: BoxConstraints(maxWidth: 520),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                              child: Row(children: [Expanded(child: Text('إرسال طلب للإدارة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(result: false), icon: Icon(Icons.close, color: Colors.white))]),
                            ),
                            Padding(
                              padding: EdgeInsets.all(14),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'العنوان')),
                                  SizedBox(height: 8),
                                  TextField(controller: descCtrl, maxLines: 6, decoration: InputDecoration(labelText: 'الوصف')),
                                  SizedBox(height: 12),
                                  Row(children: [Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(result: false), child: Text('إلغاء'))), SizedBox(width: 8), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue), onPressed: sending ? null : () async { setState(() => sending = true); final success = await Get.find<HomeController>().createUserRequest(titleCtrl.text.trim(), descCtrl.text.trim()); setState(() => sending = false); if (success) Get.back(result: true); }, child: sending ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('إرسال')))]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                barrierDismissible: false,
              );
              if (ok == true) {
                showCustomSnackbar('نجح', 'تم إرسال الطلب للإدارة');
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('طلبات للإدارة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            StreamBuilder<List<UserRequest>>(
              stream: controller.streamUserRequests(controller.userId),
              builder: (ctx, snap) {
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                final list = snap.data!;
                if (list.isEmpty) return Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('لا توجد طلبات موجهة للإدارة'));
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemBuilder: (c, i) {
                    final r = list[i];
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Expanded(child: Text(r.title, style: TextStyle(fontWeight: FontWeight.bold))), SizedBox(width: 8), Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(18)), child: Text(r.status, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600))), Text(r.createdAtClient?.split('T').first ?? '')]),
                        SizedBox(height: 6),
                        Text(r.description),
                        if (r.adminResponse != null && r.adminResponse!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(left: BorderSide(color: primaryblue, width: 4)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                            ),
                            child: Text(r.adminResponse!),
                          ),
                        ],
                      ]),
                    );
                  },
                );
              },
            ),


          ],
        ),
      ),
    );
  }


Widget _statusChip(String status) {
  final s = status.toLowerCase();
  Color color;
  String label;
  switch (s) {
    case 'pending':
      color = Colors.orange;
      label = 'قيد الانتظار';
      break;
    case 'rejected_by_seller':
    case 'rejected_by_admin':
      color = Colors.red;
      label = 'مرفوض';
      break;
    case 'pending_admin':
      color = Colors.blueGrey;
      label = 'قيد معالجة الإدارة';
      break;
    case 'accepted':
      color = Colors.green;
      label = 'مقبول';
      break;
    case 'finished':
      color = Colors.blueGrey;
      label = 'تم الانتهاء';
      break;
    default:
      color = Colors.orange;
      label = status;
  }
  return Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)));
}
}