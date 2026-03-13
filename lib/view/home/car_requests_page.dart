import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
// lightweight datetime formatting without adding new package

import '../../color.dart';
import '../../constants.dart';
import '../../model/home_model.dart';
import '../../controller/home_controller.dart';
import '../../view/shared/request_card.dart';
import '../../widgets/custom_snackbar.dart';
import 'create_request_page.dart';

class CarRequestsPage extends StatelessWidget {
  final Car car;
  const CarRequestsPage({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryblue,
          title: Text('طلباتي', style: TextStyle(color: Colors.white)),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Get.back()),
          bottom: TabBar(
            indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primaryPink, width: 3), insets: EdgeInsets.symmetric(horizontal: 28)),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: 'الطلبات'), Tab(text: 'المنتهية')],
          ),
          actions: [
            if (controller.userId == car.userId)
              IconButton(
                onPressed: () => Get.to(() => CreateRequestPage(car: car)),
                icon: Icon(Icons.add, color: Colors.white),
                tooltip: 'إنشاء طلب جديد',
              )
          ],
        ),
        body: StreamBuilder<List<CarRequest>>(
          stream: controller.streamUserCarRequests(car.id),
          builder: (context, snap) {
          if (snap.hasError) {
            print('CarRequests stream error: ${snap.error}');
            final err = snap.error.toString();
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('حدث خطأ في جلب الطلبات', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    SelectableText(err, textAlign: TextAlign.center),
                    SizedBox(height: 12),
                    ElevatedButton(onPressed: () => Get.back(), child: Text('رجوع')),
                  ],
                ),
              ),
            );
          }

          if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          final requests = snap.data ?? [];


          final active = requests.where((r) {
            final s = (r.status ?? '').toLowerCase();
            return s != 'finished' && s != 'منتهي';
          }).toList();

          final finished = requests.where((r) {
            final s = (r.status ?? '').toLowerCase();
            return s == 'finished' || s == 'منتهي';
          }).toList();

          return TabBarView(
            children: [
              // Active requests
              active.isEmpty
                  ? Center(child: Text('لا توجد طلبات حتى الآن'))
                  : ListView.separated(
                      padding: EdgeInsets.all(12),
                      itemCount: active.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final r = active[index];
                        return RequestCard(
                          request: r,
                          isAdmin: false,
                        );
                      },
                    ),

              // Finished requests
              finished.isEmpty
                  ? Center(child: Text('لا توجد طلبات منتهية'))
                  : ListView.separated(
                      padding: EdgeInsets.all(12),
                      itemCount: finished.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final r = finished[index];
                        return RequestCard(
                          request: r,
                          isAdmin: false,
                          );
                      },
                    ),
            ],
          );
        },
      ),
    ));
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

  Widget _categoryChip(CarRequest r) {
    final isMaintenance = r.serviceCenterId != null && r.serviceCenterId!.isNotEmpty;
    final color = isMaintenance ? Colors.blue : Colors.grey;
    final label = isMaintenance ? 'صيانة' : 'إداري';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
