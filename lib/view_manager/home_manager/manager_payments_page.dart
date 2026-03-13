import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/manager_home_controller.dart';
import '../../../model/home_model.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../color.dart';

class ManagerPaymentsPage extends StatefulWidget {
  const ManagerPaymentsPage({Key? key}) : super(key: key);

  @override
  State<ManagerPaymentsPage> createState() => _ManagerPaymentsPageState();
}

class _ManagerPaymentsPageState extends State<ManagerPaymentsPage> {
  final controller = Get.find<ManagerHomeViewController>();
  String _userFilter = '';
  final Map<String, Map<String, dynamic>> _userCache = {};
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الدفوعات'),
        backgroundColor: primaryblue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
              Expanded(child: TextField(controller: _searchCtrl, decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'بحث'), onSubmitted: (v) => setState(() => _userFilter = v.trim().toLowerCase())),),
              SizedBox(width: 8),
              ElevatedButton(onPressed: () => setState(() => _userFilter = _searchCtrl.text.trim().toLowerCase()), child: Text('بحث'))
            ]),
          ),
          Expanded(
            child: StreamBuilder<List<Payment>>(
              stream: controller.streamPayments(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('خطأ في جلب الدفوعات'));
                if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                var list = snap.data ?? [];
                if (_userFilter.isNotEmpty) {
                  list = list.where((p) {
                    final user = _userCache[p.userId];
                    final name = (user?['name'] ?? '').toString().toLowerCase();
                    final phone = (user?['phone'] ?? '').toString().toLowerCase();
                    final ref = p.transferRef.toLowerCase();
                    if (name.contains(_userFilter) || phone.contains(_userFilter) || ref.contains(_userFilter)) return true;
                    return false;
                  }).toList();
                }
                if (list.isEmpty) return Center(child: Text('لا توجد دفوعات'));
                // populate user cache
                final uids = list.map((e) => e.userId).toSet();
                for (var uid in uids) {
                  if (!_userCache.containsKey(uid)) {
                    controller.getUserData(uid).then((d) { if (d != null) setState(() => _userCache[uid] = d); });
                  }
                }
                return ListView.separated(
                  padding: EdgeInsets.all(12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = list[index];
                    final user = _userCache[p.userId];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        childrenPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(color: primaryblue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text('P', style: TextStyle(color: primaryblue, fontWeight: FontWeight.bold))),
                        ),
                        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [Expanded(child: Text("${p.amount.toStringAsFixed(2)} ر.س - ${user?['name'] ?? p.userId}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))), SizedBox(width: 8), _statusChip(p.status)]),
                          SizedBox(height: 6),
                          Text('مرجع: ${p.transferRef}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        ]),
                        children: [
                          SizedBox(height: 6),
                          if ((p.description ?? '').isNotEmpty) Text(p.description),
                          SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: ElevatedButton(onPressed: () async { await controller.updatePaymentStatus(p.id, 'accepted'); showCustomSnackbar('نجح', 'تم قبول الفاتورة'); }, child: Text('قبول'))),
                            SizedBox(width: 8),
                            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () async { await controller.updatePaymentStatus(p.id, 'rejected'); showCustomSnackbar('نجح', 'تم رفض الفاتورة'); }, child: Text('رفض'))),
                            SizedBox(width: 8),
                            PopupMenuButton<String>(onSelected: (v) async { if (v == 'delete') { final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text('تأكيد الحذف'), content: Text('هل تريد حذف هذه الفاتورة؟'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('إلغاء')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.of(context).pop(true), child: Text('حذف'))])); if (ok == true) { await controller.deletePayment(p.id); showCustomSnackbar('نجح', 'تم حذف الفاتورة'); } } }, itemBuilder: (_) => [PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: Colors.redAccent)))] )
                          ])
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
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
    case 'rejected':
      color = Colors.red;
      label = 'مرفوض';
      break;
    case 'accepted':
      color = Colors.green;
      label = 'مقبول';
      break;
    default:
      color = Colors.grey;
      label = status;
  }
  return Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)));
}