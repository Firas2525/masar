import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controller/home_controller.dart';
import '../../color.dart';
import '../../model/home_model.dart';

class SellerPurchaseRequestsPage extends StatefulWidget {
  final Car car;

  const SellerPurchaseRequestsPage({Key? key, required this.car})
    : super(key: key);

  @override
  State<SellerPurchaseRequestsPage> createState() =>
      _SellerPurchaseRequestsPageState();
}

class _SellerPurchaseRequestsPageState
    extends State<SellerPurchaseRequestsPage> {
  final HomeController controller = Get.find<HomeController>();

  Future<void> _acceptRequest(PurchaseRequest r) async {
    final descCtrl = TextEditingController();
    final List<String> files = [];
    final picker = ImagePicker();
    bool uploading = false;

    final ok = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
              constraints: BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryblue, primaryblue],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'قبول الطلب',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(result: false),
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // details field: disable suggestions/autocorrect
                        TextField(
                          controller: descCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(labelText: 'وصف للادارة'),
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'الأوراق / الملفات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 8),
                        if (files.isNotEmpty)
                          SizedBox(
                            height: 90,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: files.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8),
                              itemBuilder: (_, j) => Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.dialog(
                                      Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: InteractiveViewer(
                                          boundaryMargin: EdgeInsets.all(20),
                                          minScale: 1.0,
                                          maxScale: 4.0,
                                          child: Image.network(files[j], fit: BoxFit.contain),
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(files[j], width: 120, height: 90, fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () => setState(() => files.removeAt(j)),
                                      child: CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final p = await picker.pickImage(source: ImageSource.gallery);
                                if (p != null) {
                                  setState(() => uploading = true);
                                  final url = await controller.uploadImageToCloudinary(File(p.path));
                                  setState(() => uploading = false);
                                  if (url != null) setState(() => files.add(url));
                                }
                              },
                              icon: Icon(Icons.upload_file),
                              label: Text('أضف ملف'),
                            ),
                            SizedBox(width: 8),
                            if (uploading) CircularProgressIndicator(),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => Get.back(result: false),
                                child: Text('إلغاء'),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryblue,
                                ),
                                onPressed: () => Get.back(result: true),
                                child: Text('إرسال'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ), 
            )) ;
          },
        ),
      ),
      barrierDismissible: false,
    );

    if (ok == true) {
      final finalDesc = descCtrl.text.trim();
      await controller.updatePurchaseRequestBySeller(
        r.id,
        'pending_admin',
        sellerDescription: finalDesc.isEmpty ? null : finalDesc,
        sellerFiles: files.isEmpty ? null : files,
      );
    }
  }

  Future<void> _rejectRequest(PurchaseRequest r) async {
    final confirmed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryblue, primaryblue]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'رفض الطلب',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(result: false),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    Text('هل تريد رفض هذا الطلب؟'),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () => Get.back(result: false),
                            child: Text('إلغاء'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () => Get.back(result: true),
                            child: Text('رفض'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    if (confirmed == true) {
      await controller.updatePurchaseRequestBySeller(
        r.id,
        'rejected_by_seller',
      );
    }
  }

  // Follow-up / add files after initial acceptance
  Future<void> _followupRequest(PurchaseRequest r) async {
    final descCtrl = TextEditingController(text: r.sellerDescription ?? '');
    final List<String> newFiles = [];
    bool uploading = false;
    final picker = ImagePicker();

    final ok = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
              constraints: BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryblue, primaryblue],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'متابعة الطلب',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(result: false),
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: descCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'ملاحظات إضافية للبائع',
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final p = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (p != null) {
                                  setState(() => uploading = true);
                                  final url = await controller
                                      .uploadImageToCloudinary(File(p.path));
                                  setState(() => uploading = false);
                                  if (url != null) newFiles.add(url);
                                }
                              },
                              icon: Icon(Icons.upload_file),
                              label: Text('أضف ملف'),
                            ),
                            SizedBox(width: 8),
                            if (uploading) CircularProgressIndicator(),
                          ],
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => Get.back(result: false),
                                child: Text('إلغاء'),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryblue,
                                ),
                                onPressed: () => Get.back(result: true),
                                child: Text('إرسال'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )));
          },
        ),
      ),
      barrierDismissible: false,
    );

    if (ok == true) {
      // combine existing sellerFiles with newFiles
      final combined = <String>[];
      if (r.sellerFiles != null && r.sellerFiles!.isNotEmpty)
        combined.addAll(r.sellerFiles!);
      combined.addAll(newFiles);
      await controller.updatePurchaseRequestBySeller(
        r.id,
        r.status,
        sellerDescription: descCtrl.text.trim(),
        sellerFiles: combined.isEmpty ? null : combined,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات الشراء - ${widget.car.title ?? ''}'),
        backgroundColor: primaryblue,
      ),
      body: StreamBuilder<List<PurchaseRequest>>(
        stream: controller.streamSellerPurchaseRequestsForCar(widget.car.id),
        builder: (ctx, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty)
            return Center(child: Text('لا توجد طلبات شراء حالياً'));
          return ListView.separated(
            padding: EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (c, i) {
              final r = list[i];
              return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'طلب شراء',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _statusChip(r.status),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(r.details),
                    // textual details only
                    SizedBox(height: 8),

                    // Seller-added description/files (if any)
                    if (r.sellerDescription != null) ...[
                      Text('وصف البائع:'),
                      SizedBox(height: 4),
                      Text(r.sellerDescription!),
                      SizedBox(height: 8),
                    ],

                    if (r.sellerFiles != null && r.sellerFiles!.isNotEmpty) ...[
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: r.sellerFiles!.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8),
                          itemBuilder: (_, j) => Image.network(
                            r.sellerFiles![j],
                            width: 120,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],

                    if (r.adminNotes != null) ...[
                      Text('ملاحظات الإدارة:'),
                      SizedBox(height: 4),
                      Text(r.adminNotes!),
                      SizedBox(height: 8),
                    ],

                    if (r.adminImages != null && r.adminImages!.isNotEmpty) ...[
                      Text('صور الإدارة:'),
                      SizedBox(height: 6),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: r.adminImages!.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8),
                          itemBuilder: (_, j) => GestureDetector(
                            onTap: () => Get.dialog(
                              Dialog(
                                backgroundColor: Colors.transparent,
                                child: InteractiveViewer(
                                  boundaryMargin: EdgeInsets.all(20),
                                  minScale: 1.0,
                                  maxScale: 4.0,
                                  child: Image.network(
                                    r.adminImages![j],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            child: Image.network(
                              r.adminImages![j],
                              width: 120,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],

                    // Action row: if still pending, show accept/reject; otherwise show follow-up actions
                    Row(
                      children: [
                        if (r.status.toLowerCase() == 'pending') ...[
                          ElevatedButton(
                            onPressed: () => _acceptRequest(r),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryblue,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'قبول',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _rejectRequest(r),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.redAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(
                                color: Colors.redAccent.withOpacity(0.12),
                              ),
                            ),
                            child: Text(
                              'رفض',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          SizedBox(width: 8),
                        ] else ...[
                          ElevatedButton(
                            onPressed: () => _followupRequest(r),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryblue,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text('متابعة / إضافة ملفات'),
                          ),
                          SizedBox(width: 8),
                        ],

                        ElevatedButton(
                          onPressed: () async {
                            final data = await controller.getUserData(r.userId);
                            if (data != null)
                              await Get.dialog(
                                Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: 520),
                                    decoration: BoxDecoration(
                                      color: Colors.white, 
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primaryblue,
                                                primaryblue,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'معلومات المشتري',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => Get.back(),
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'الاسم: ${data['name'] ?? ''}',
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                'الهاتف: ${data['phone'] ?? ''}',
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                'البريد: ${data['email'] ?? ''}',
                                              ),
                                              SizedBox(height: 14),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[200],
                                                            foregroundColor:
                                                                Colors.black,
                                                          ),
                                                      onPressed: () =>
                                                          Get.back(),
                                                      child: Text('إغلاق'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryblue,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text('عرض المشتري'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
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
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    ),
  );
}
