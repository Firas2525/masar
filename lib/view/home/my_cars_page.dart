
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../color.dart';
import '../../constants.dart';
import '../../controller/home_controller.dart';
import '../../model/home_model.dart';
import 'maintenance_records_page.dart';
import 'car_requests_page.dart';
import 'service_centers_list_page.dart';
import 'seller_purchase_requests_page.dart';
import 'messages_page.dart';
import 'edit_car_page.dart';
import 'package:kindergarten_user/view_manager/home_manager/manager_violations_page.dart';

class MyCarsPage extends StatelessWidget {
  const MyCarsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder<HomeController>(
      builder: (ctrl) {
        final ownedCars = ctrl.cars
            .where((c) => c.userId == ctrl.userId)
            .toList();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                          children: ownedCars
                              .map((car) => _buildCarDetailCard(car, context))
                              .toList(),
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarDetailCard(Car car, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image with price & badges
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (car.image.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: InteractiveViewer(
                          boundaryMargin: EdgeInsets.all(20),
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: CachedNetworkImage(
                            imageUrl: car.image,
                            fit: BoxFit.contain,
                            placeholder: (c, u) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (c, u, e) =>
                                Container(color: Colors.grey[300]),
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: car.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: car.image,
                            fit: BoxFit.cover,
                            placeholder: (c, u) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (c, u, e) =>
                                Container(color: Colors.grey[300]),
                          )
                        : Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 120,
                              color: primaryblue,
                            ),
                          ),
                  ),
                ),
              ),

              Positioned(
                top: 20,
                right: 12,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.arrow_back, color: primaryBlack),
                  ),
                ),
              ),
              // Top-left price tag (if present)
              if ((car.price ?? '').isNotEmpty)
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryPink,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPink.withOpacity(0.32),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '${car.price}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              // Edit + Delete floating
              Positioned(
                right: 16,
                bottom: 16,
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      elevation: 6,
                      shape: CircleBorder(),
                      child: InkWell(
                        customBorder: CircleBorder(),
                        onTap: () => Get.to(() => EditCarPage(car: car)),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.edit, color: primaryblue, size: 20),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Material(
                      color: Colors.white,
                      elevation: 6,
                      shape: CircleBorder(),
                      child: InkWell(
                        customBorder: CircleBorder(),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('تأكيد الحذف'),
                              content: Text(
                                'هل أنت متأكد أنك تريد حذف هذا الإعلان؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('إلغاء'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text('حذف'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await Get.find<HomeController>().deleteCar(car);
                            try {
                              if (Get.isRegistered<HomeController>()) {
                                await Get.find<HomeController>().refreshData();
                              }
                            } catch (e) {
                              print('Error refreshing HomeController after delete: $e');
                            }
                            Get.offAllNamed('/home');
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        car.title.isNotEmpty ? car.title : car.brand,
                        style: textStyleSubheading.copyWith(fontSize: 20),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '${car.mileageKill} كلم',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // رقم اللوحة
                if ((car.plateNumber ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('رقم اللوحة: ${car.plateNumber}', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                  ),

                // Sale toggle (owner only)
                if (Get.find<HomeController>().userId == car.userId)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: car.isForSale
                                    ? primaryblue.withOpacity(0.06)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: car.isForSale
                                      ? primaryblue.withOpacity(0.18)
                                      : Colors.grey[200]!,
                                ),
                                boxShadow: car.isForSale
                                    ? [
                                        BoxShadow(
                                          color: primaryblue.withOpacity(0.04),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: car.isForSale
                                          ? primaryblue
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      car.isForSale
                                          ? Icons.sell
                                          : Icons.remove_circle_outline,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          car.isForSale
                                              ? 'معروض للبيع'
                                              : 'غير معروض للبيع',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: primaryBlack,
                                          ),
                                        ),
                                        if (car.isForSale &&
                                            (car.price ?? '').isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              '${car.price}',
                                              style: TextStyle(
                                                color: primaryPink,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Builder(
                                    builder: (_) {
                                      final hc = Get.find<HomeController>();
                                      if (hc.isCarUpdating(car.id)) {
                                        return SizedBox(
                                          width: 36,
                                          height: 24,
                                          child: Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return Switch.adaptive(
                                        value: car.isForSale,
                                        activeColor: primaryPink,
                                        onChanged: (v) async {
                                          await hc.toggleCarSale(car, v);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // المخالفات (موجز)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('المخالفات', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (car.violations.isNotEmpty ? Colors.orange : Colors.grey[200])!.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${car.violations.length}', style: TextStyle(fontWeight: FontWeight.w600, color: (car.violations.isNotEmpty ? Colors.orange : Colors.grey[600]))),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => CarViolationsPage(car: car)),
                        child: Text('عرض المخالفات'),
                      ),
                    ],
                  ),
                ),

                // Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(Icons.local_gas_station, car.fuelType),
                    _infoChip(Icons.settings, car.trans),
                    if (car.bodyType.isNotEmpty)
                      _infoChip(Icons.directions_car_filled, car.bodyType),
                    if (car.color.isNotEmpty)
                      _infoChip(Icons.palette, car.color),
                    if (car.registerDate != null)
                      _infoChip(
                        Icons.calendar_today,
                        '${car.registerDate!.year}',
                      ),
                  ],
                ),

                SizedBox(height: 12),
                Text(
                  'الوصف',
                  style: textStyleSubheading.copyWith(fontSize: 16),
                ),
                SizedBox(height: 6),
                Text(
                  car.desc,
                  style: textStyleBody,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 14),
                if (Get.find<HomeController>().userId == car.userId)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryblue,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Get.to(() => CarViolationsPage(car: car)),
                      icon: Icon(Icons.report, color: Colors.white, size: 18),
                      label: Text('مخالفاتي', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: primaryblue, size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        car.address,
                        style: textStyleBody.copyWith(color: primaryBlack),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18),
                Text(
                  'أدوات الإعلان',
                  style: textStyleSubheading.copyWith(fontSize: 16),
                ),
                SizedBox(height: 8),
                // Actions grid — responsive, icon + label tiles
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _actionGridTile(
                      icon: Icons.event_available,
                      color: Colors.orangeAccent,
                      label: 'حجز صيانة',
                      onTap: () =>
                          Get.to(() => ServiceCentersListPage(carId: car.id)),
                    ),
                    _actionGridTile(
                      icon: Icons.build_circle_outlined,
                      color: Colors.teal,
                      label: 'سجل الصيانة',
                      onTap: () =>
                          Get.to(() => MaintenanceRecordsPage(car: car)),
                    ),
                    _actionGridTile(
                      icon: Icons.message,
                      color: Colors.blue,
                      label: 'رسائلي',
                      onTap: () => Get.to(() => UserMessagesPage()),
                    ),
                    _actionGridTile(
                      icon: Icons.list_alt,
                      color: Colors.teal[700]!,
                      label: 'طلباتي',
                      onTap: () => Get.to(() => CarRequestsPage(car: car)),
                    ),
                    _actionGridTile(
                      icon: Icons.shopping_bag,
                      color: Colors.deepPurple,
                      label: 'طلبات الشراء',
                      onTap: () =>
                          Get.to(() => SellerPurchaseRequestsPage(car: car)),
                    ),
                    // You can add more tiles here if needed
                  ],
                ),
                SizedBox(height: 18),
                // صور المستندات (Moved to bottom)
                Text(
                  'صور المستندات',
                  style: textStyleSubheading.copyWith(fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _documentThumb(
                        context,
                        car.mechanicImage,
                        'الميكانيك',
                        () async {
                          await Get.find<HomeController>().uploadCarDocument(
                            car,
                            'mechanic',
                          );
                        },
                        '${car.id}_mechanic',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _documentThumb(
                        context,
                        car.licenseImage,
                        'رخصة القيادة',
                        () async {
                          await Get.find<HomeController>().uploadCarDocument(
                            car,
                            'license',
                          );
                        },
                        '${car.id}_license',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryblue.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: primaryblue),
          ),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: primaryBlack, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _actionGridTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _documentThumb(
    BuildContext ctx,
    String imageUrl,
    String label,
    VoidCallback onEdit,
    String uploadingKey,
  ) {
    final bool hasImage = imageUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: textStyleBody.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 6),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: hasImage ? Colors.grey[100] : primaryblue.withOpacity(0.06),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                hasImage
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, u) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (c, u, e) =>
                            Container(color: Colors.grey[300]),
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryblue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.image_not_supported,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'لا توجد صورة',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (hasImage) {
                          showDialog(
                            context: ctx,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: InteractiveViewer(
                                boundaryMargin: EdgeInsets.all(20),
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (c, u) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (c, u, e) =>
                                      Container(color: Colors.grey[300]),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GetBuilder<HomeController>(
                    builder: (hc) {
                      final uploading = hc.isImageUploading(uploadingKey);
                      if (uploading) {
                        return SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return Material(
                        elevation: 4,
                        color: primaryblue,
                        shape: CircleBorder(),
                        child: InkWell(
                          customBorder: CircleBorder(),
                          onTap: onEdit,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.photo_camera,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
