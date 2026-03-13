import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../model/home_model.dart';
import '../../color.dart';
import '../../constants.dart';
import '../../widgets/custom_snackbar.dart';

class MaintenanceRecordsPage extends StatefulWidget {
  final Car car;
  const MaintenanceRecordsPage({Key? key, required this.car}) : super(key: key);

  @override
  _MaintenanceRecordsPageState createState() => _MaintenanceRecordsPageState();
}

class _MaintenanceRecordsPageState extends State<MaintenanceRecordsPage> {
  late final HomeController controller;
  Future<List<CarRequest>>? _requestsFuture;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    // fetch only once when the page is created
    _requestsFuture = controller.getUserCarRequestsOnce(widget.car.id);
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = controller.getUserCarRequestsOnce(widget.car.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final updatedCar = controller.cars.firstWhere((c) => c.id == widget.car.id, orElse: () => widget.car);
    final isOwner = controller.userId.isNotEmpty && updatedCar.userId == controller.userId;

    return GetBuilder<HomeController>(builder: (_) {
      final showRequestsTab = true; // show requests tab for all users (owners see both)
      return DefaultTabController(
        length: showRequestsTab ? 2 : 1,
        child: Scaffold(
          appBar: AppBar(
            title: Text('سجل الصيانة'),
            backgroundColor: primaryblue,
            bottom: TabBar(
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: primaryPink, width: 3),
                insets: EdgeInsets.symmetric(horizontal: 28),
              ),
              labelStyle: TextStyle(fontWeight: FontWeight.w700),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: showRequestsTab
                  ? [Tab(text: 'السجلات'), Tab(text: 'طلبات الصيانة')]
                  : [Tab(text: 'السجلات')],
            ),
            actions: [
              if (isOwner)
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _showAddRecordDialog(context, controller, updatedCar.id),
                ),
            ],
          ),
          body: FutureBuilder<List<CarRequest>>(
            future: _requestsFuture,
            builder: (ctx, snap) {
              final reqs = snap.data ?? [];
              final finishedReqs = reqs.where((r) {
                final s = (r.status ?? '').toString().toLowerCase();
                return s == 'finished' || s == 'منتهي' || s == 'منتهى';
              }).toList();

              // Requests tab should show only active requests targeted to service centers
              final activeReqs = reqs.where((r) {
                final isServiceCenter = r.serviceCenterId != null && r.serviceCenterId!.isNotEmpty;
                final s = (r.status ?? '').toString().toLowerCase();
                final isFinished = s == 'finished' || s == 'منتهي' || s == 'منتهى';
                return isServiceCenter && !isFinished;
              }).toList();

              return TabBarView(
                children: [
                  // Records tab: show maintenance records + finished requests
                  RefreshIndicator(
                    onRefresh: () async {
                      await controller.refreshData();
                      setState(() {
                        _requestsFuture = controller.getUserCarRequestsOnce(widget.car.id);
                      });
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: (updatedCar.maintenance.length + finishedReqs.length) == 0 ? 1 : (updatedCar.maintenance.length + finishedReqs.length),
                      itemBuilder: (ctx, idx) {
                        if (updatedCar.maintenance.isEmpty && finishedReqs.isEmpty) {
                          return Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('لا توجد سجلات صيانة', style: TextStyle(fontSize: 16))));
                        }
                        // determine source
                        if (idx < updatedCar.maintenance.length) {
                          final rec = updatedCar.maintenance[idx];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                              tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              childrenPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              leading: CircleAvatar(radius: 20, backgroundColor: primaryblue.withOpacity(0.08), child: Icon(Icons.build, color: primaryblue)),
                              title: Row(
                                children: [
                                  Expanded(child: Text(rec.title, style: textStyleSubheading)),
                                  if (rec.cost > 0)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: primaryPink.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                                      child: Text('${rec.cost} ر.س', style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              subtitle: Text(rec.date, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              children: [
                                if (rec.description.isNotEmpty) Padding(padding: EdgeInsets.only(bottom: 8), child: Text(rec.description, style: textStyleBody)),
                                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  if (isOwner)
                                    Material(
                                      color: Colors.white,
                                      elevation: 2,
                                      shape: CircleBorder(),
                                      child: InkWell(
                                        customBorder: CircleBorder(),
                                        onTap: () => _showEditRecordDialog(context, controller, updatedCar.id, rec),
                                        child: Padding(padding: EdgeInsets.all(8), child: Icon(Icons.edit, size: 18, color: primaryblue)),
                                      ),
                                    ),
                                  if (isOwner) SizedBox(width: 8),
                                  if (isOwner)
                                    Material(
                                      color: Colors.white,
                                      elevation: 2,
                                      shape: CircleBorder(),
                                      child: InkWell(
                                        customBorder: CircleBorder(),
                                        onTap: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('حذف سجل الصيانة'),
                                              content: Text('هل تريد حذف هذا السجل؟'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('إلغاء')),
                                                ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('حذف')),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            await controller.deleteMaintenanceRecord(updatedCar.id, rec.toMap());
                                            await controller.refreshData();
                                            setState(() => _requestsFuture = controller.getUserCarRequestsOnce(widget.car.id));
                                          }
                                        },
                                        child: Padding(padding: EdgeInsets.all(8), child: Icon(Icons.delete, size: 18, color: Colors.redAccent)),
                                      ),
                                    ),
                                ])
                              ],
                              ),
                            ),
                          );
                        }
                        // finished requests converted to record-like view
                        final reqIndex = idx - updatedCar.maintenance.length;
                        final r = finishedReqs[reqIndex];
                        return Column(
                          children: [
                            Card(
                              margin: EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(radius: 20, backgroundColor: primaryblue.withOpacity(0.12), child: Icon(Icons.check_circle, color: primaryblue)),
                                title: Text(r.type ?? 'طلب صيانة مكتمل', style: textStyleSubheading),
                                subtitle: Text(r.details ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                                trailing: Text('منتهي', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Requests tab (only shown when not owner)
                  if (showRequestsTab)
                    RefreshIndicator(
                      onRefresh: () async {
                        await controller.refreshData();
                        setState(() {
                          _requestsFuture = controller.getUserCarRequestsOnce(widget.car.id);
                        });
                      },
                      child: activeReqs.isEmpty
                          ? ListView(padding: EdgeInsets.all(16), children: [Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('لا توجد طلبات صيانة للمراكز')))])
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: activeReqs.length,
                              itemBuilder: (ctx, i) {
                                final r = activeReqs[i];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                    tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    childrenPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    leading: CircleAvatar(radius: 20, backgroundColor: primaryblue.withOpacity(0.08), child: Icon(Icons.build, color: primaryblue, size: 20)),
                                    title: Row(children: [Expanded(child: Text(r.type ?? 'طلب صيانة', style: textStyleSubheading)), _statusChip(r.status)]),
                                    subtitle: r.scheduledAt != null && r.scheduledAt!.isNotEmpty ? Text('موعد الحجز: ${_formatSchedule(r.scheduledAt)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)) : null,
                                    children: [
                                      if (r.details.isNotEmpty) Text(r.details),
                                      SizedBox(height: 8),
                                      if (r.images.isNotEmpty)
                                        SizedBox(
                                          height: 90,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: r.images.length,
                                            separatorBuilder: (_, __) => SizedBox(width: 8),
                                            itemBuilder: (_, j) => GestureDetector(
                                              onTap: () => Get.dialog(Dialog(
                                                backgroundColor: Colors.transparent,
                                                child: InteractiveViewer(
                                                  boundaryMargin: EdgeInsets.all(20),
                                                  minScale: 1.0,
                                                  maxScale: 4.0,
                                                  child: Image.network(r.images[j], fit: BoxFit.contain),
                                                ),
                                              ),
                                              )),


                                          ),
                                        ),
                                      SizedBox(height: 8),
                                      if (r.response != null && r.response!.isNotEmpty) ...[
                                        Text('رد المحل:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(height: 4),
                                        Text(r.response!),
                                      ],
                                      if (r.finalDescription != null && r.finalDescription!.isNotEmpty) ...[
                                        SizedBox(height: 6),
                                        Text('وصف الانتهاء:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(height: 4),
                                        Text(r.finalDescription!),
                                      ],
                                      if (r.finalPrice != null) ...[
                                        SizedBox(height: 6),
                                        Text('السعر النهائي: ${r.finalPrice} ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: primaryPink)),
                                      ],
                                      SizedBox(height: 8),
                                      _centerLabelForRequest(r),
                                    ],
                                  ),
                                ));
                              },
                            ),
                    ),
                ].where((e) => e != null).toList() as List<Widget>,
              );
            },
          ),
        ),
      );
    });
  }

  void _showAddRecordDialog(BuildContext context, HomeController controller, String carId) async {
    await _showRecordFormDialog(
      context,
      controller,
      dialogTitle: 'إضافة سجل صيانة',
      onSave: (rec) async {
        await controller.addMaintenanceRecord(carId, rec);
      },
    );
  }

  void _showEditRecordDialog(BuildContext context, HomeController controller, String carId, MaintenanceRecord rec) async {
    await _showRecordFormDialog(
      context,
      controller,
      dialogTitle: 'تعديل سجل الصيانة',
      initial: rec,
      onSave: (updated) async {
        await controller.deleteMaintenanceRecord(carId, rec.toMap());
        await controller.addMaintenanceRecord(carId, updated);
        _refreshRequests();
      },
    );
  }

  Widget _centerLabelForRequest(CarRequest r) {
    final id = (r.serviceCenterId != null && r.serviceCenterId!.isNotEmpty) ? r.serviceCenterId! : (r.userId ?? '');
    if (id.isEmpty) return SizedBox.shrink();
    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getUserData(id),
      builder: (ctx, snap) {
        if (!snap.hasData) return SizedBox.shrink();
        final sc = snap.data;
        if (sc == null) return SizedBox.shrink();
        final sp = sc['serviceProfile'] ?? {};
        final label = (sp['title'] ?? sc['title'] ?? sc['name'] ?? '').toString();
        if (label.isEmpty) return SizedBox.shrink();
        return Text('المركز: $label', style: TextStyle(fontWeight: FontWeight.w600));
      },
    );
  }

  Future<void> _showRecordFormDialog(
    BuildContext context,
    HomeController controller, {
    String dialogTitle = 'سجل الصيانة',
    MaintenanceRecord? initial,
    required Future<void> Function(Map<String, dynamic>) onSave,
  }) async {
    final titleCtrl = TextEditingController(text: initial?.title ?? '');
    final descCtrl = TextEditingController(text: initial?.description ?? '');
    final costCtrl = TextEditingController(text: initial != null && initial.cost > 0 ? initial.cost.toString() : '');
    DateTime selected = DateTime.tryParse(initial?.date ?? '') ?? DateTime.now();

    await Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            constraints: BoxConstraints(maxWidth: 620),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black26.withOpacity(0.08), blurRadius: 12)]),
            child: Stack(
              children: [
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Expanded(child: Text(dialogTitle, style: textStyleSubheading)), IconButton(icon: Icon(Icons.close), onPressed: () => Get.back())]),
                  SizedBox(height: 10),
                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'العنوان', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                  SizedBox(height: 10),
                  TextField(controller: descCtrl, maxLines: 4, decoration: InputDecoration(labelText: 'الوصف', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                  SizedBox(height: 10),
                  Row(children: [
                    Flexible(child: TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'التكلفة (ر.س)', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
                    SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(context: context, initialDate: selected, firstDate: DateTime(2000), lastDate: DateTime.now());
                        if (picked != null) setState(() => selected = picked);
                      },
                      child: Text('${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}'),
                    )
                  ]),
                  SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryPink),
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        final desc = descCtrl.text.trim();
                        final cost = double.tryParse(costCtrl.text.trim()) ?? 0.0;
                        if (title.isEmpty) {
                          showCustomSnackbar('خطأ', 'يرجى إدخال عنوان السجل');
                          return;
                        }

                        final rec = {
                          'id': initial?.id ?? UniqueKey().toString(),
                          'date': '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}',
                          'title': title,
                          'description': desc,
                          'cost': cost,
                        };

                        // close dialog immediately
                        Get.back();

                        // run save in background and report result via snackbar
                        onSave(rec).then((_) async {
                          try {
                            await controller.refreshData();
                          } catch (_) {}
                          _refreshRequests();
                          showCustomSnackbar('نجح', 'تم حفظ سجل الصيانة');
                        }).catchError((e) {
                          print('Error saving record: $e');
                          showCustomSnackbar('خطأ', 'حدث خطأ أثناء حفظ السجل');
                        });
                      },
                      child: Text('حفظ', style: TextStyle(color: Colors.white)),
                    ),
                  ])
                ]),
                
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

String _formatSchedule(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

Widget _statusChip(String? status) {
  final s = (status ?? '').toLowerCase();
  Color color;
  String label;
  switch (s) {
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
    case 'finished':
    case 'منتهي':
      color = Colors.blueGrey;
      label = 'منتهي';
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
