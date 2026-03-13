import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controller/manager_home_controller.dart';
import '../../../controller/home_controller.dart';
import '../../../view/home/car_details_page.dart';
import '../../../model/home_model.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../color.dart';
import '../../view/shared/request_card.dart';
import 'manager_purchase_request_edit_page.dart';

class ManagerPendingRequestsPage extends StatefulWidget {
  const ManagerPendingRequestsPage({super.key});

  @override
  State<ManagerPendingRequestsPage> createState() =>
      _ManagerPendingRequestsPageState();
}

class _ManagerPendingRequestsPageState
    extends State<ManagerPendingRequestsPage> {
  final controller = Get.find<ManagerHomeViewController>();

  String? _selectedCarId;
  String _userSearch = '';
  final Map<String, Map<String, dynamic>> _userCache = {};
  bool _isFiltersExpanded = false;

  Widget _filtersHeader() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 700;
            final carField = DropdownButtonFormField<String?>(
              value: _selectedCarId,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                prefixIcon: Icon(Icons.directions_car),
              ),
              hint: Text('تصفية حسب السيارة'),
              items: [
                DropdownMenuItem(value: null, child: Text('كل السيارات')),
                ...controller.cars
                    .map(
                      (c) =>
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(c.title ?? c.brand ?? c.id),
                      ),
                )
                ,
              ],
              onChanged: (v) => setState(() => _selectedCarId = v),
            );

            final userField = TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'بحث بالمستخدم (الاسم/الهاتف)',
                suffixIcon: _userSearch.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => setState(() => _userSearch = ''),
                )
                    : null,
              ),
              onChanged: (v) => setState(() => _userSearch = v.trim()),
            );

            final clearBtn = TextButton.icon(
              onPressed: () =>
                  setState(() {
                    _selectedCarId = null;
                    _userSearch = '';
                  }),
              icon: Icon(Icons.clear),
              label: Text('مسح'),
            );
            final refreshBtn = IconButton(
              onPressed: () => controller.refreshData(),
              icon: Icon(Icons.refresh, color: primaryblue),
            );

            final syncBtn = IconButton(
              tooltip: 'تحقق الآن',
              onPressed: () async {
                await controller.mirrorMissingUserRequests();
              },
              icon: Icon(Icons.sync, color: primaryblue),
            );
            final checkBtn = IconButton(
              onPressed: () async => await controller.mirrorMissingUserRequests(),
              icon: Icon(Icons.sync, color: primaryblue),
              tooltip: 'تحقق الآن من طلبات المستخدمين',
            );
            if (isWide) {
              return Row( 
                children: [
                  Expanded(flex: 3, child: carField),
                  SizedBox(width: 12),
                  Expanded(flex: 4, child: userField),
                  SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        clearBtn,
                        SizedBox(width: 6),
                        refreshBtn,
                        SizedBox(width: 6),
                        checkBtn,
                      ]),
                    ],
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  carField,
                  SizedBox(height: 10),
                  userField,
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [clearBtn, SizedBox(width: 8), refreshBtn, SizedBox(width: 8), checkBtn],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الطلبات'),
          backgroundColor: primaryblue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'طلبات السيارات'),
              Tab(text: 'طلبات الشراء'),
              Tab(text: 'الشراء المنتهية'),
              Tab(text: 'طلبات المستخدمين'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.w700),
            indicatorWeight: 3.0,
            // add padding for clearer visibility
            labelPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() =>
                      _isFiltersExpanded = !_isFiltersExpanded),
                      icon: Icon(_isFiltersExpanded ? Icons.expand_less : Icons
                          .filter_list),
                      label: Text(
                          _isFiltersExpanded ? 'إخفاء التصفية' : 'عرض التصفية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryblue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isFiltersExpanded) _filtersHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  // All car requests (all statuses) with filters
                  StreamBuilder<List<CarRequest>>(
                    stream: controller.streamAllCarRequests(),
                    builder: (context, snap) {
                      if (snap.hasError)
                        return Center(child: Text('خطأ في جلب الطلبات'));
                      if (snap.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator());
                      var requests = snap.data ?? [];

                      // إخفاء طلبات الصيانة (التي تحتوي على serviceCenterId)
                      requests = requests.where((r) =>
                      (r.serviceCenterId ?? '').isEmpty).toList();

                      if (requests.isEmpty)
                        return Center(child: Text('لا توجد طلبات حتى الآن'));

                      // Populate user cache for name-based search
                      final uids = requests.map((r) => r.userId).toSet();
                      for (var uid in uids) {
                        if (!_userCache.containsKey(uid)) {
                          controller.getUserData(uid).then((d) {
                            if (d != null) setState(() => _userCache[uid] = d);
                          });
                        }
                      }

                      final filtered = requests.where((r) {
                        if (_selectedCarId != null &&
                            _selectedCarId!.isNotEmpty &&
                            r.carId != _selectedCarId)
                          return false;
                        if (_userSearch.isNotEmpty) {
                          final s = _userSearch.toLowerCase();
                          final user = _userCache[r.userId];
                          if (user != null) {
                            final name = (user['name'] ?? '')
                                .toString()
                                .toLowerCase();
                            final phone = (user['phone'] ?? '')
                                .toString()
                                .toLowerCase();
                            if (name.contains(s) || phone.contains(s))
                              return true;
                          }
                          final car = controller.cars.firstWhereOrNull(
                                (c) => c.id == r.carId,
                          );
                          if (car != null &&
                              ((car.title ?? '').toLowerCase().contains(s) ||
                                  (car.brand ?? '').toLowerCase().contains(s)))
                            return true;
                          if (r.details.toLowerCase().contains(s)) return true;
                          return false;
                        }
                        return true;
                      }).toList();

                      if (filtered.isEmpty)
                        return Center(
                          child: Text('لا توجد طلبات حسب الفلتر الحالي'),
                        );

                      return ListView.separated(
                        padding: EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final r = filtered[index];
                          // Use the same card builder as pending requests to allow admin actions
                          return _buildRequestCard(r);
                        },
                      );
                    },
                  ),


                  // Purchase requests for admin - Pending
                  StreamBuilder<List<PurchaseRequest>>(
                    stream: controller.streamPurchaseRequestsForAdmin(),
                    builder: (context, snap) {
                      if (snap.hasError)
                        return Center(child: Text('خطأ في جلب طلبات الشراء'));
                      if (snap.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator());
                      final allRequests = snap.data ?? [];

                      // Show only pending requests
                      final requests = allRequests.where((r) =>
                      r.status != 'finished' &&
                          r.status != 'rejected_by_admin' &&
                          r.status != 'rejected_by_seller').toList();

                      if (requests.isEmpty)
                        return Center(
                          child: Text('لا توجد طلبات شراء قيد الانتظار'),
                        );

                      return _buildPurchaseRequestsList(requests);
                    },
                  ),

                  // Purchase requests for admin - Finished
                  StreamBuilder<List<PurchaseRequest>>(
                    stream: controller.streamPurchaseRequestsForAdmin(),
                    builder: (context, snap) {
                      if (snap.hasError)
                        return Center(child: Text('خطأ في جلب طلبات الشراء'));
                      if (snap.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator());
                      final allRequests = snap.data ?? [];

                      // Show only finished requests
                      final requests = allRequests.where((r) =>
                      r.status == 'finished' ||
                          r.status == 'rejected_by_admin' ||
                          r.status == 'rejected_by_seller').toList();

                      if (requests.isEmpty)
                        return Center(
                          child: Text('لا توجد طلبات شراء منتهية'),
                        );

                      return _buildPurchaseRequestsList(requests);
                    },
                  ),

                  // User requests from users (merged user_requests + user_requests_admin)
                  StreamBuilder<List<UserRequest>>(
                    stream: controller.streamUserRequests(),
                    builder: (context, snap) {
                      if (snap.hasError)
                        return Center(child: Text('خطأ في جلب طلبات المستخدمين'));
                      if (snap.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator());
                      final list = snap.data ?? [];
                      if (list.isEmpty) return Center(child: Text('لا توجد طلبات من المستخدمين'));

                      return ListView.separated(
                        padding: EdgeInsets.all(12),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ur = list[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(ur.title.isNotEmpty ? ur.title : 'بدون عنوان', style: TextStyle(fontWeight: FontWeight.bold))),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(18)),
                                        child: Text(ur.status, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(ur.description),
                                  if (ur.adminResponse != null && ur.adminResponse!.isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(left: BorderSide(color: primaryblue, width: 4)),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                                      ),
                                      child: Text(ur.adminResponse!),
                                    ),
                                  ],
                                  SizedBox(height: 10),
                                  Row(children: [
                                    // Reply (secondary style)
                                    ElevatedButton(
                                      onPressed: () async {
                                        final respCtrl = TextEditingController(text: ur.adminResponse ?? '');
                                        final ok = await Get.dialog<bool>(Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: StatefulBuilder(builder: (ctx, setState) {
                                            return Container(
                                              constraints: BoxConstraints(maxWidth: 520),
                                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                                Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))), child: Row(children: [Expanded(child: Text('رد الإدارة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(result: false), icon: Icon(Icons.close, color: Colors.white))])),
                                                Padding(padding: EdgeInsets.all(14), child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: respCtrl, maxLines: 6, decoration: InputDecoration(labelText: 'رد الإدارة')), SizedBox(height: 12), Row(children: [Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(result: false), child: Text('إلغاء'))), SizedBox(width: 8), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue),
                                                    onPressed: () => Get.back(result: true), child: Text('إرسال')))])]))]));
                                          }),
                                        ));
                                        if (ok == true) {
                                          final text = respCtrl.text.trim();
                                          await controller.updateUserRequest(ur.id, 'responded', adminResponse: text.isEmpty ? null : text);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: primaryblue,
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        side: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      child: Text('رد الإدارة'),
                                    ),
                                    SizedBox(width: 8),

                                    // Accept (primary)
                                    ElevatedButton(
                                      onPressed: ur.status == 'accepted' ? null : () async {
                                        await controller.updateUserRequest(ur.id, 'accepted');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryblue,
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Text('قبول', style: TextStyle(color: Colors.white)),
                                    ),
                                    SizedBox(width: 8),

                                    // Reject (destructive, white bg with red text)
                                    ElevatedButton(
                                      onPressed: ur.status == 'rejected' ? null : () async { await controller.updateUserRequest(ur.id, 'rejected'); },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.redAccent,
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        side: BorderSide(color: Colors.redAccent.withOpacity(0.12)),
                                      ),
                                      child: Text('رفض', style: TextStyle(color: Colors.redAccent)),
                                    ),

                                    Spacer(),
                                    OutlinedButton(onPressed: () async {
                                      final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text('تأكيد الحذف'), content: Text('هل تريد حذف هذا الطلب؟'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('إلغاء')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.of(context).pop(true), child: Text('حذف'))]));
                                      if (ok == true) await controller.deleteUserRequest(ur.id);
                                    }, child: Text('حذف', style: TextStyle(color: Colors.red)))
                                  ])
                                  ,
                                  SizedBox(height: 8),
                                  // Show user (moved below the action row to avoid layout issues)
                                  ElevatedButton(
                                    onPressed: () async {
                                      final data = await controller.getUserData(ur.userId);
                                      if (data != null) {
                                        await Get.dialog(Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            constraints: BoxConstraints(maxWidth: 520),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                                              Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))), child: Row(children: [Expanded(child: Text('معلومات المستخدم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close, color: Colors.white))])),
                                              Padding(padding: const EdgeInsets.all(14.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الاسم: ${data['name'] ?? ''}'), Text('البريد: ${data['email'] ?? ''}'), Text('الهاتف: ${data['phone'] ?? ''}'), if ((data['address'] ?? '').toString().isNotEmpty) SizedBox(height: 8), if ((data['address'] ?? '').toString().isNotEmpty) Text('العنوان: ${data['address']}'), SizedBox(height: 14), Row(children: [Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(), child: Text('إغلاق')))])])),
                                            ]),
                                          ),
                                        ));
                                      } else {
                                        showCustomSnackbar('خطأ', 'معلومات المستخدم غير متوفرة');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: primaryblue,
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      side: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    child: Row(children: [Icon(Icons.person, size: 16), SizedBox(width: 8), Text('عرض المستخدم')]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(CarRequest r) {
    final TextEditingController responseCtrl = TextEditingController(
      text: r.response,
    );
    List<String> localImages = List<String>.from(r.images);

    return StatefulBuilder(
      builder: (context, setState) {
        bool isSubmitting = false;

        return RequestCard(
          request: r,
          isAdmin: true,
          isSubmitting: isSubmitting,
          fetchUser: (uid) => controller.getUserData(uid),
          onAddImage: () async {
            final url = await controller.uploadImageToCloudinary();
            if (url != null) setState(() => localImages.add(url));
          },
          onViewUser: () async {
            final data = await controller.getUserData(r.userId);
            if (data != null) {
              await Get.dialog(Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 520),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(gradient: LinearGradient(
                          colors: [primaryblue, primaryblue]),
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12))),
                      child: Row(children: [
                        Expanded(child: Text('معلومات المستخدم',
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold))),
                        IconButton(onPressed: () => Get.back(),
                            icon: Icon(Icons.close, color: Colors.white))
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الاسم: ${data['name'] ?? ''}'),
                            Text('البريد: ${data['email'] ?? ''}'),
                            Text('الهاتف: ${data['phone'] ?? ''}'),
                            SizedBox(height: 14),
                            Row(children: [
                              Expanded(child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: Colors.black),
                                  onPressed: () => Get.back(),
                                  child: Text('إغلاق')))
                            ]),
                          ]),
                    )
                  ]),
                ),
              ));
            } else {
              showCustomSnackbar('خطأ', 'معلومات المستخدم غير متوفرة');
            }
          },
          adminEditor: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رد الإدارة:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              TextField(
                controller: responseCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اكتب رد الإدارة',
                ),
              ),
            ],
          ),
          onSavePending: () async {
            final confirmed = await Get.dialog(Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(gradient: LinearGradient(
                        colors: [primaryblue, primaryblue]),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12))),
                    child: Row(children: [
                      Expanded(child: Text('تأكيد', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
                      IconButton(onPressed: () => Get.back(result: false),
                          icon: Icon(Icons.close, color: Colors.white))
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(children: [
                      Text('حفظ كـ قيد؟'),
                      SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black),
                            onPressed: () => Get.back(result: false),
                            child: Text('إلغاء'))),
                        SizedBox(width: 10),
                        Expanded(child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryblue),
                            onPressed: () => Get.back(result: true),
                            child: Text('حفظ'))),
                      ])
                    ]),
                  )
                ]),
              ),
            ), barrierDismissible: false);
            if (confirmed == true) {
              setState(() => isSubmitting = true);
              await controller.updateRequestAsAdmin(
                r.id,
                'pending',
                response: responseCtrl.text.trim(),
                images: localImages,
              );
              setState(() => isSubmitting = false);
            }
          },
          onReject: () async {
            final confirmed = await Get.dialog(Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(gradient: LinearGradient(
                        colors: [primaryblue, primaryblue]),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12))),
                    child: Row(children: [
                      Expanded(child: Text('تأكيد الرفض', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
                      IconButton(onPressed: () => Get.back(result: false),
                          icon: Icon(Icons.close, color: Colors.white))
                    ]),
                  ),
                  Padding(padding: const EdgeInsets.all(14.0), child: Column(
                      children: [
                        Text('هل تريد رفض الطلب؟'),
                        SizedBox(height: 14),
                        Row(children: [
                          Expanded(child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black),
                              onPressed: () => Get.back(result: false),
                              child: Text('إلغاء'))),
                          SizedBox(width: 10),
                          Expanded(child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent),
                              onPressed: () => Get.back(result: true),
                              child: Text('رفض'))),
                        ])
                      ])),
                ]),
              ),
            ), barrierDismissible: false);
            if (confirmed == true) {
              setState(() => isSubmitting = true);
              await controller.updateRequestAsAdmin(
                r.id,
                'rejected',
                response: responseCtrl.text.trim(),
                images: localImages,
              );
              setState(() => isSubmitting = false);
            }
          },
          onAccept: () async {
            final confirmed = await Get.dialog(Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(gradient: LinearGradient(
                        colors: [primaryblue, primaryblue]),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12))),
                    child: Row(children: [
                      Expanded(child: Text('تأكيد القبول', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
                      IconButton(onPressed: () => Get.back(result: false),
                          icon: Icon(Icons.close, color: Colors.white))
                    ]),
                  ),
                  Padding(padding: const EdgeInsets.all(14.0), child: Column(
                      children: [
                        Text('هل تريد قبول الطلب؟'),
                        SizedBox(height: 14),
                        Row(children: [
                          Expanded(child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black),
                              onPressed: () => Get.back(result: false),
                              child: Text('إلغاء'))),
                          SizedBox(width: 10),
                          Expanded(child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () => Get.back(result: true),
                              child: Text('قبول'))),
                        ])
                      ])),
                ]),
              ),
            ), barrierDismissible: false);
            if (confirmed == true) {
              setState(() => isSubmitting = true);
              await controller.updateRequestAsAdmin(
                r.id,
                'accepted',
                response: responseCtrl.text.trim(),
                images: localImages,
              );
              setState(() => isSubmitting = false);
            }
          },
          onDelete: () async {
            try {
              await FirebaseFirestore.instance
                  .collection('car_requests')
                  .doc(r.id)
                  .delete();
              Get.snackbar(
                'نجح',
                'تم حذف الطلب بنجاح',
                snackPosition: SnackPosition.BOTTOM,
              );
            } catch (e) {
              Get.snackbar(
                'خطأ',
                'حدث خطأ أثناء الحذف: $e',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        );
      },
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase();
    Color color;
    String label;
    switch (s) {
      case 'pending':
      case 'pending_admin':
      case 'waiting':
        color = Colors.orange;
        label = 'قيد الانتظار';
        break;
      case 'rejected_by_seller':
      case 'rejected_by_admin':
      case 'rejected':
        color = Colors.red;
        label = 'مرفوض';
        break;
      case 'pending_review':
        color = Colors.blueGrey;
        label = 'قيد معالجة الإدارة';
        break;
      case 'accepted':
      case 'accepted_by_admin':
      case 'accepted_by_seller':
      case 'مقبول':
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

  Widget _buildPurchaseRequestsList(List<PurchaseRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Text('لا توجد طلبات'),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(12),
      itemCount: requests.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = requests[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'طلب شراء',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _statusChip(r.status),
                  ],
                ),

                SizedBox(height: 8),
                Text(
                  'تفاصيل المشتري:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(r.details),

                if (r.images.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text('صور المشتري:', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: r.images.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8),
                      itemBuilder: (_, j) => GestureDetector(
                        onTap: () => Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            child: InteractiveViewer(
                              boundaryMargin: EdgeInsets.all(20),
                              minScale: 1.0,
                              maxScale: 4.0,
                              child: Image.network(r.images[j], fit: BoxFit.contain, errorBuilder: (c, e, s) => Container(width: 200, height: 200, color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey))),
                            ),
                          ),
                        ),
                        child: Container(
                          width: 120,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(r.images[j], width: 120, height: 90, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 120, height: 90, color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey))),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                if (r.sellerDescription != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'وصف البائع:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(r.sellerDescription!),
                ],

                if (r.sellerFiles != null &&
                    r.sellerFiles!.isNotEmpty) ...[
                  SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: r.sellerFiles!.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: 8),
                      itemBuilder: (_, j) =>
                          GestureDetector(
                            onTap: () =>
                                Get.dialog(
                                  Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: InteractiveViewer(
                                      boundaryMargin: EdgeInsets.all(20),
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      child: Image.network(
                                        r.sellerFiles![j],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                            child: Container(
                              width: 120,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.06,
                                    ),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  r.sellerFiles![j],
                                  width: 120,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ],

                if (r.adminNotes != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'ملاحظات الإدارة:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(r.adminNotes!),
                ],

                if (r.adminImages != null &&
                    r.adminImages!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    'صور الإدارة:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: r.adminImages!.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: 8),
                      itemBuilder: (_, j) =>
                          GestureDetector(
                            onTap: () =>
                                Get.dialog(
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
                            child: Container(
                              width: 120,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.06,
                                    ),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  r.adminImages![j],
                                  width: 120,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ],

                SizedBox(height: 12),

                Builder(
                  builder: (ctx) {
                    final actions = <Widget>[];

                    // Show Accept button only for pending requests
                    if (r.status != 'finished' &&
                        r.status != 'rejected_by_admin' &&
                        r.status != 'rejected_by_seller') {
                      actions.add(
                        ElevatedButton(
                          onPressed: () async {
                            await Get.to(
                                  () =>
                                  ManagerPurchaseRequestEditPage(
                                    request: r,
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryblue,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
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
                      );
                    }

                    // View car button (hidden when request is finished)
                    if (r.status != 'finished') {
                      actions.add(
                        ElevatedButton.icon(
                          onPressed: () {
                            final HomeController? hc = Get.isRegistered<
                                HomeController>()
                                ? Get.find<HomeController>()
                                : null;
                            final car = hc?.cars.firstWhereOrNull((c) =>
                            c.id == r.carId);
                            if (car != null) {
                              Get.to(() => CarDetailsPage(car: car));
                              return;
                            }
                            try {
                              final m = controller as ManagerHomeViewController;
                              final car2 = m.cars.firstWhereOrNull((c) =>
                              c.id == r.carId);
                              if (car2 != null)
                                Get.to(() => CarDetailsPage(car: car2));
                              else
                                Get.snackbar('خطأ', 'بيانات السيارة غير متوفرة');
                            } catch (e) {
                              Get.snackbar('خطأ', 'بيانات السيارة غير متوفرة');
                            }
                          },
                          icon: Icon(Icons.directions_car, color: primaryblue),
                          label: Text('عرض السيارة', style: TextStyle(
                              color: primaryblue)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryblue,
                            elevation: 0,
                            side: BorderSide(color: Colors.grey.shade300),
                            minimumSize: Size(110, 44),
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      );
                    }

                    // Show action buttons only for pending requests
                    if (r.status != 'finished' &&
                        r.status != 'rejected_by_admin' &&
                        r.status != 'rejected_by_seller') {

                      // Determine whether the car related to this request exists in the app
                      final HomeController? _hc = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
                      bool isCarAvailable = false;
                      try {
                        if ((_hc?.cars.firstWhereOrNull((c) => c.id == r.carId)) != null) isCarAvailable = true;
                      } catch (_) {}
                      try {
                        final mctrl = controller as ManagerHomeViewController;
                        if (mctrl.cars.firstWhereOrNull((c) => c.id == r.carId) != null) isCarAvailable = true;
                      } catch (_) {}



                      // Still allow rejecting the request even if car is external
                      actions.add(
                        OutlinedButton(
                          onPressed: () =>
                              controller.updatePurchaseRequestByAdmin(
                                r.id,
                                'rejected_by_admin',
                              ),
                          child: Text(
                            'رفض',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            side: BorderSide(
                              color: Colors.redAccent.withOpacity(
                                0.15,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    }

                    // Delete button (always available)
                    actions.add(
                      OutlinedButton(
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'حذف الطلب',
                            content: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('هل تريد حذف هذا الطلب بشكل نهائي؟'),
                            ),
                            cancel: TextButton(
                              onPressed: () => Get.back(),
                              child: Text('إلغاء'),
                            ),
                            confirm: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                Get.back();
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('purchase_requests')
                                      .doc(r.id)
                                      .delete();
                                  // إعادة تحميل البيانات
                                  controller.refreshData();
                                  Get.snackbar(
                                    'نجح',
                                    'تم حذف الطلب بنجاح',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                } catch (e) {
                                  Get.snackbar(
                                    'خطأ',
                                    'حدث خطأ أثناء الحذف: $e',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                              child: Text(
                                  'حذف', style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                        child: Text(
                          'حذف',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          side: BorderSide(
                            color: Colors.red.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );

                    final rows = <Widget>[];
                    for (var i = 0; i < actions.length; i += 3) {
                      final end = (i + 3 < actions.length)
                          ? i + 3
                          : actions.length;
                      final chunk = actions.sublist(i, end);
                      rows.add(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: chunk
                              .map(
                                (w) =>
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: w,
                                ),
                          )
                              .toList(),
                        ),
                      );
                    }

                    return Column(children: rows);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
