import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../controller/manager_home_controller.dart';
import '../../../model/home_model.dart';
import '../../../constants.dart';
import '../../color.dart';
import '../../view/shared/request_card.dart';
import '../../widgets/custom_snackbar.dart';

class ManagerCarRequestsPage extends StatefulWidget {
  final Car car;
  const ManagerCarRequestsPage({Key? key, required this.car}) : super(key: key);

  @override
  State<ManagerCarRequestsPage> createState() => _ManagerCarRequestsPageState();
}

class _ManagerCarRequestsPageState extends State<ManagerCarRequestsPage> {
  final controller = Get.find<ManagerHomeViewController>();

  // Local UI state for filters and search
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات السيارة'),
        backgroundColor: primaryblue,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Get.back()),
      ),
      body: Column(
        children: [
          // Filters row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(label: Text('الكل'), selected: _filter == 'all', onSelected: (v) => setState(() => _filter = 'all')),
                      ChoiceChip(label: Text('قيد الانتظار'), selected: _filter == 'pending', onSelected: (v) => setState(() => _filter = 'pending')),
                      ChoiceChip(label: Text('مقبول'), selected: _filter == 'accepted', onSelected: (v) => setState(() => _filter = 'accepted')),
                      ChoiceChip(label: Text('مرفوض'), selected: _filter == 'rejected', onSelected: (v) => setState(() => _filter = 'rejected')),
                    ],
                  ),
                ),
                IconButton(onPressed: () => controller.refreshData(), icon: Icon(Icons.refresh, color: primaryblue)),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<CarRequest>>(
              stream: controller.streamCarRequestsForCar(widget.car.id),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('خطأ في جلب الطلبات'));
                if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                final requests = snap.data ?? [];
                final filtered = requests.where((r) => _filter == 'all' || r.status.toLowerCase() == _filter).toList();
                if (filtered.isEmpty) return Center(child: Text('لا توجد طلبات حسب الفلتر الحالي'));

                return ListView.separated(
                  padding: EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    return _buildRequestCard(r);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(CarRequest r) {
    final TextEditingController responseCtrl = TextEditingController(text: r.response);
    List<String> localImages = List<String>.from(r.images);

    return StatefulBuilder(builder: (context, setState) {
      bool isSubmitting = false;

      return RequestCard(
        request: r,
        isAdmin: true,

        adminEditor: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رد الإدارة:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(controller: responseCtrl, maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'اكتب رد الإدارة')),
          ],
        ),
        onSavePending: () async {
          final confirmed = await Get.dialog(Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                  child: Row(children: [Expanded(child: Text('تأكيد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(result: false), icon: Icon(Icons.close, color: Colors.white))]),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(children: [
                    Text('حفظ كـ قيد؟'),
                    SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(result: false), child: Text('إلغاء'))),
                      SizedBox(width: 10),
                      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue), onPressed: () => Get.back(result: true), child: Text('حفظ'))),
                    ])
                  ]),
                )
              ]),
            ),
          ), barrierDismissible: false);
          if (confirmed == true) {
            setState(() => isSubmitting = true);
            await controller.updateRequestAsAdmin(r.id, 'pending', response: responseCtrl.text.trim(), images: localImages);
            setState(() => isSubmitting = false);
          }
        },
        onReject: () async {
          final confirmed = await Get.dialog(Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                  child: Row(children: [Expanded(child: Text('تأكيد الرفض', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(result: false), icon: Icon(Icons.close, color: Colors.white))]),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(children: [
                    Text('هل تريد رفض الطلب؟'),
                    SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(result: false), child: Text('إلغاء'))),
                      SizedBox(width: 10),
                      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Get.back(result: true), child: Text('رفض'))),
                    ])
                  ]),
                )
              ]),
            ),
          ), barrierDismissible: false);
          if (confirmed == true) {
            setState(() => isSubmitting = true);
            await controller.updateRequestAsAdmin(r.id, 'rejected', response: responseCtrl.text.trim(), images: localImages);
            setState(() => isSubmitting = false);
          }
        },
        onAccept: () async {
          final confirmed = await Get.dialog(Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                  child: Row(children: [Expanded(child: Text('تأكيد القبول', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(result: false), icon: Icon(Icons.close, color: Colors.white))]),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(children: [
                    Text('هل تريد قبول الطلب؟'),
                    SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(result: false), child: Text('إلغاء'))),
                      SizedBox(width: 10),
                      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => Get.back(result: true), child: Text('قبول'))),
                    ])
                  ]),
                )
              ]),
            ),
          ), barrierDismissible: false);
          if (confirmed == true) {
            setState(() => isSubmitting = true);
            await controller.updateRequestAsAdmin(r.id, 'accepted', response: responseCtrl.text.trim(), images: localImages);
            setState(() => isSubmitting = false);
          }
        },
      );
    });
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'مقبول':
        color = Colors.green;
        label = 'مقبول';
        break;
      case 'rejected':
      case 'مرفوض':
        color = Colors.red;
        label = 'مرفوض';
        break;
      default:
        color = Colors.orange;
        label = 'قيد الانتظار';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
