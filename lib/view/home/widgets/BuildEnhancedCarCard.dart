import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/custom_snackbar.dart';

import '../ai_car_chat_page.dart';
import '../../../color.dart';
import '../../../constants.dart';
import '../../../model/home_model.dart';

class BuildEnhancedCarCard extends StatelessWidget {
  const BuildEnhancedCarCard({
    super.key,
    required this.w,
    required this.car,
    required this.onTap,
  });

  final double w;
  final Car car;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // card with image on top and details at bottom
    return Container(
      margin: EdgeInsets.symmetric(vertical: w * 0.01),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryPurble.withOpacity(0.10),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image (non-interactive here; card tap opens details)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      image: car.image.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(car.image),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: car.image.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.directions_car,
                              color: primaryblue,
                              size: w * 0.14,
                            ),
                          )
                        : null,
                  ),
                ),
                // details
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: w * 0.035,
                      right: w * 0.035,
                      top: w * 0.035,
                      bottom: w * 0.015,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.title.isNotEmpty ? car.title : car.brand,
                          style: textStyleSubheading.copyWith(
                            fontSize: w * 0.038,
                            color: primaryBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: w * 0.01),
                        Row(
                          children: [
                            Icon(Icons.business, size: 18, color: primaryblue),
                            SizedBox(width: 5),
                            Text(
                              '${car.brand}',
                              style: textStyleBody.copyWith(
                                color: Colors.grey[700],
                                fontSize: w * 0.032,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: w * 0.01),
                        // fuel type (matches icons used in details view)
                        Row(
                          children: [
                            Icon(
                              Icons.local_gas_station,
                              size: 18,
                              color: primaryblue,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '${car.fuelType}',
                              style: textStyleBody.copyWith(
                                color: Colors.grey[700],
                                fontSize: w * 0.032,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: w * 0.01),
                        Row(
                          children: [
                            Icon(
                              Icons.stacked_line_chart_rounded,
                              size: 18,
                              color: primaryblue,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '${car.mileageKill}km',
                              style: textStyleBody.copyWith(
                                color: Colors.grey[700],
                                fontSize: w * 0.032,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: w * 0.01),
                        Row(
                          children: [
                            Icon(
                              Icons.car_crash_rounded,
                              size: 18,
                              color: primaryblue,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '${car.trans}',
                              style: textStyleBody.copyWith(
                                color: Colors.grey[700],
                                fontSize: w * 0.032,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: w * 0.03),
                        CarCardWidgetButtons(
                          phone: car.phone,
                          id: 0,
                          onAiTap: () => Get.to(() => AiCarChatPage(car: car)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CarCardWidgetButtons extends StatelessWidget {
  const CarCardWidgetButtons({
    super.key,
    required this.phone,
    this.height,
    required this.id,
    this.padding,
    this.onAiTap,
  });

  final String phone;
  final int id;
  final double? height;
  final EdgeInsets? padding;
  final VoidCallback? onAiTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height,
            child: InkWell(
              onTap: () async {
                await GFunPhone(phoneNumber: phone).makePhoneCall();
              },
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: primaryblue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.phone, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: SizedBox(
            height: height,
            child: InkWell(
              onTap: () async {
                await GFunPhone(phoneNumber: phone).openWhatsApp(message: '  ');
              },
              child: Container(
                padding: EdgeInsets.all(5),
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    height: 10,
                    width: 10,
                    child: Image.asset("assets/images/whatsapp.png", width: 10),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: height,
            child: InkWell(
              onTap: onAiTap ?? () async {},
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: primaryblue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "المساعد الذكي",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GFunPhone {
  final String phoneNumber;

  GFunPhone({required this.phoneNumber});

  Future<void> makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {}
  }

  Future<void> openWhatsApp({String message = ''}) async {
    // Normalize phone for WhatsApp (international format without the +)
    String normalize(String raw) {
      var s = raw.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
      if (s.startsWith('00')) s = s.substring(2);
      if (s.startsWith('0')) s = s.substring(1); // drop national leading 0
      if (!s.startsWith('963')) {
        // assume Syria country code if not present
        s = '963' + s;
      }
      return s;
    }

    final normalized = normalize(phoneNumber);
    final encodedMessage = Uri.encodeComponent(message);

    final whatsappUri = Uri.parse(
      'whatsapp://send?phone=$normalized&text=$encodedMessage',
    );
    final waMeUri = Uri.parse('https://wa.me/$normalized?text=$encodedMessage');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return;
      }

      if (await canLaunchUrl(waMeUri)) {
        await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
        return;
      }

      // As a last attempt, try with explicit '+' prefixed (some devices accept it)
      final withPlus = Uri.parse(
        'whatsapp://send?phone=+$normalized&text=$encodedMessage',
      );
      if (await canLaunchUrl(withPlus)) {
        await launchUrl(withPlus, mode: LaunchMode.externalApplication);
        return;
      }

      // show error to user
      showCustomSnackbar('خطأ', 'تعذر فتح واتساب على هذا الجهاز');
    } catch (e) {
      print('Error launching WhatsApp: $e');
      showCustomSnackbar('خطأ', 'حدث خطأ أثناء محاولة فتح واتساب');
    }
  }
}
