import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../color.dart';
import '../../model/home_model.dart';
import '../../widgets/custom_snackbar.dart';

class MyPaymentsPage extends StatelessWidget {
  const MyPaymentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final refCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('الدفوعات'),
        backgroundColor: primaryblue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              titleCtrl.text = '';
              descCtrl.text = '';
              refCtrl.text = '';
              bool sending = false;
              final ok = await Get.dialog<bool>(
                Dialog(
                  backgroundColor: Colors.transparent,
                  child: StatefulBuilder(builder: (ctx, setState) {
                    return Container(
                      constraints: BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                          child: Row(children: [Expanded(child: Text('إضافة فاتورة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(result: false), icon: Icon(Icons.close, color: Colors.white))]),
                        ),
                        Padding(
                          padding: EdgeInsets.all(14),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            TextField(controller: titleCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'القيمة (مثال: 250.0)')),
                            SizedBox(height: 8),
                            TextField(controller: descCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'الوصف')),
                            SizedBox(height: 8),
                            TextField(controller: refCtrl, decoration: InputDecoration(labelText: 'رقم الحوالة / المرجع')),
                            SizedBox(height: 12),
                            Row(children: [
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(result: false), child: Text('إلغاء'))),
                              SizedBox(width: 8),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue), onPressed: sending ? null : () async {
                                setState(() => sending = true);
                                final amt = double.tryParse(titleCtrl.text.trim()) ?? 0.0;
                                final success = await controller.createPayment(amt, descCtrl.text.trim(), refCtrl.text.trim());
                                setState(() => sending = false);
                                if (success) Get.back(result: true);
                              }, child: sending ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('إرسال')))
                            ])
                          ]),
                        )
                      ]),
                    );
                  }),
                ),
                barrierDismissible: false,
              );
              if (ok == true) showCustomSnackbar('نجح', 'تم إضافة الفاتورة');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('دفعاتي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          StreamBuilder<List<Payment>>(
            stream: controller.streamUserPayments(controller.userId),
            builder: (ctx, snap) {
              if (!snap.hasData) return Center(child: CircularProgressIndicator());
              final list = snap.data!;
              if (list.isEmpty) return Center(child: Text('لا توجد دفعات حتى الآن'));
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => SizedBox(height: 8),
                itemBuilder: (c, i) {
                  final p = list[i];
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
                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text('P', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold))),
                      ),
                      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Expanded(child: Text("${p.amount.toStringAsFixed(2)} ر.س", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), SizedBox(width: 8), _statusChip(p.status)]),
                        SizedBox(height: 6),
                        Text('مرجع: ${p.transferRef}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ]),
                      children: [
                        SizedBox(height: 6),
                        if ((p.description ?? '').isNotEmpty) Text(p.description),
                        SizedBox(height: 12),
                        Row(children: [Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () {}, child: Text('مشاركة'))), SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: () {}, child: Text('تفاصيل')))]),
                      ],
                    ),
                  );
                },
              );
            },
          )
        ]),
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
