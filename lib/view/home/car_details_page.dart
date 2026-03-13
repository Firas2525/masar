import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../color.dart';
import '../../constants.dart';
import '../../controller/home_controller.dart';
import '../../controller/manager_home_controller.dart';
import '../../model/home_model.dart';
import '../../widgets/custom_snackbar.dart';
import 'conversation_chat_page.dart';
import 'maintenance_records_page.dart';
import 'ai_car_chat_page.dart';
import 'car_requests_page.dart';
import 'create_purchase_request_page.dart';
import 'messages_page.dart';
import '../../view_manager/home_manager/manager_violations_page.dart';

class CarDetailsPage extends StatefulWidget {
  final Car car;
  final bool openMessages;
  const CarDetailsPage({Key? key, required this.car, this.openMessages = false})
    : super(key: key);

  @override
  _CarDetailsPageState createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.openMessages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.to(() => UserMessagesPage());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prefer the latest car object from HomeController if available (keeps page in sync)
    final HomeController? hc = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    final bool isManager = Get.isRegistered<ManagerHomeViewController>();
    final car = (hc != null)
      ? hc.cars.firstWhere((c) => c.id == widget.car.id, orElse: () => widget.car)
      : widget.car;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced hero image with rounded bottom corners and overlayed info
            Stack(
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: car.image.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(car.image),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: car.image.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 100,
                            color: primaryblue,
                          ),
                        )
                      : null,
                ),

                // tappable hero to open zoomable viewer
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
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
                      splashColor: Colors.white24,
                      highlightColor: Colors.white10,
                      child: Container(),
                    ),
                  ),
                ),

                // Back button overlay
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
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
                // subtle gradient to aid readability of overlay text
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.45),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              car.title.isNotEmpty ? car.title : car.brand,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${car.brand} • ${car.mileageKill} كلم • ${car.trans}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: car.price != null
                              ? primaryPink
                              : (car.isForSale ? primaryblue : Colors.grey[500]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          car.price != null
                              ? 'السعر: ${car.price}'
                              : (car.isForSale ? 'معروض للبيع' : 'غير معروض'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Content card for readable details with good spacing
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 18,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.title.isNotEmpty ? car.title : car.brand,
                        style: textStyleSubheading.copyWith(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${car.brand} • ${car.mileageKill} كلم • ${car.trans}',
                        style: textStyleBody,
                      ),
                      SizedBox(height: 12),

                      // Car details chips (clear, labeled facts)
                      Text('تفاصيل السيارة', style: textStyleSubheading.copyWith(fontSize: 16)),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (car.mileageKill.isNotEmpty)
                            _detailChip(Icons.speed, 'الممشى: ${car.mileageKill} كلم'),
                          if (car.fuelType.isNotEmpty)
                            _detailChip(Icons.local_gas_station, 'نوع الوقود: ${car.fuelType}'),
                          if (car.trans.isNotEmpty)
                            _detailChip(Icons.settings, 'ناقل الحركة: ${car.trans}'),
                          if (car.bodyType.isNotEmpty)
                            _detailChip(Icons.directions_car, 'نوع الهيكل: ${car.bodyType}'),
                          if (car.color.isNotEmpty)
                            _detailChip(Icons.palette, 'اللون: ${car.color}'),

                          if (car.price != null && car.price!.isNotEmpty)
                            _detailChip(Icons.price_change, 'السعر: ${car.price}'),
                        ],
                      ),

                      SizedBox(height: 12),

                      Text(
                        'الوصف',
                        style: textStyleSubheading.copyWith(fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Text(car.desc, style: textStyleBody),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: primaryblue, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              car.address,
                              style: textStyleBody.copyWith(
                                color: primaryBlack,
                              ),
                            ),
                          ),
                        ],
                      ),



                      // Documents quick actions (hide inline images; allow viewing in dialog)
                      SizedBox(height: 12),
                      // Document buttons (compact, app-styled)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (car.mechanicImage.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: InteractiveViewer(
                                      boundaryMargin: EdgeInsets.all(20),
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      child: CachedNetworkImage(
                                        imageUrl: car.mechanicImage,
                                        fit: BoxFit.contain,
                                        placeholder: (c, u) => Center(child: CircularProgressIndicator()),
                                        errorWidget: (c, u, e) => Container(color: Colors.grey[300]),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: _detailChip(Icons.construction, 'مستند الميكانيك'),
                            ),

                          if (car.licenseImage.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: InteractiveViewer(
                                      boundaryMargin: EdgeInsets.all(20),
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      child: CachedNetworkImage(
                                        imageUrl: car.licenseImage,
                                        fit: BoxFit.contain,
                                        placeholder: (c, u) => Center(child: CircularProgressIndicator()),
                                        errorWidget: (c, u, e) => Container(color: Colors.grey[300]),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: _detailChip(Icons.badge, 'رخصة القيادة'),
                            ),
                        ],
                      ),

                      SizedBox(height: 18),

                      // Action buttons (clean layout, added "رسائلي" for car owner)
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          (hc != null && hc.userId == car.userId) || isManager?Container():
                            _actionButtonGradient(
                            icon: Icons.smart_toy,
                            label: 'اسأل الذكاء الصنعي',
                            gradient: LinearGradient(colors: [Color(0xFF0C2A45),primaryblue]),
                            onTap: () => Get.to(() => AiCarChatPage(car: car)),
                          ),
                          (hc != null && hc.userId == car.userId) || isManager?Container():
                          _actionButtonGradient(
                            icon: Icons.build,
                            label: 'سجل الصيانة',
                            gradient: LinearGradient(colors: [Color(0xFF0C2A45),primaryblue]),
                            onTap: () => Get.to(() => MaintenanceRecordsPage(car: car)),
                          ),

                          if (car.isForSale && (hc == null || hc.userId != car.userId) && !isManager)
                            _actionButtonGradient(
                              icon: Icons.shopping_cart,
                              label: 'طلب شراء',
                              gradient: LinearGradient(colors: [Color(0xFF0C2A45),primaryblue]),
                              onTap: () => Get.to(() => CreatePurchaseRequestPage(car: car)),
                            ),

                          if ((hc == null || hc.userId != car.userId) && !isManager)
                            _actionButtonGradient(
                              icon: Icons.chat,
                              label: 'تواصل',
                              gradient: LinearGradient(colors: [Color(0xFF0C2A45),primaryblue]),
                              onTap: () async {
                                final HomeController _hc = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());
                                final convId = await _hc.getOrCreateConversation(car.userId, carId: car.id);
                                if (convId != null) {
                                  final other = await _hc.getUserData(car.userId);
                                  final otherName = other != null ? (other['name'] ?? '') : '';
                                  Get.to(() => ConversationChatPage(conversationId: convId, otherUserId: car.userId, otherUserName: otherName ?? ''));
                                }
                              },
                            ),
                        ],
                      ),

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _actionButtonFilled({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(minWidth: 130),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButtonOutlined({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(minWidth: 130),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButtonGradient({required IconData icon, required String label, required Gradient gradient, VoidCallback? onTap}) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minWidth: 140),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient as LinearGradient?,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
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

}
