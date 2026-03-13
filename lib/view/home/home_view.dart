import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/view/home/shimmer_loading_widget.dart';
import 'package:kindergarten_user/view/home/widgets/BuildEnhancedCarCard.dart';
import 'package:kindergarten_user/view/home/widgets/BuildEnhancedChildrenSection.dart';
import '../../controller/home_controller.dart';
import '../../constants.dart';
import '../../color.dart';
import 'package:http/http.dart' as http;

import '../../model/home_model.dart';
import '../../widgets/custom_snackbar.dart';
import 'car_details_page.dart';
import 'my_cars_page.dart';
import 'service_owner_requests_page.dart';
import 'my_purchase_requests_page.dart';
import 'my_payments_page.dart';
import 'messages_page.dart';

// use colors from ../../color.dart and ../../constants.dart for consistency

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = Get.put(HomeController());
  File? _image;
  final picker = ImagePicker();
  String? uploadedImageUrl;

  // UI state for search & filtering
  String _searchQuery = '';
  String? _selectedBrand;
  String? _selectedFuel;
  int _activeAnnouncementIndex = 0;
  // ensure we only precache announcement images once per lifecycle
  bool _announcementsPrefetched = false;

  // قيم Cloudinary (من Dashboard)
  final String cloudName = "ddpk9jmfc";
  final String uploadPreset = "firas_image"; // أنشئه من Cloudinary Dashboard

  Future pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    return _image;
  }

  Future uploadImageToCloudinary() async {
    File imageFile = await pickImage(ImageSource.gallery);
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final resData = await http.Response.fromStream(response);
        final data = jsonDecode(resData.body);
        setState(() {
          uploadedImageUrl = data['secure_url'];
          print(uploadedImageUrl);
        });
        return data['secure_url'];
      } else {
        print("❌ فشل الرفع: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print(e);
    }
  }

  // Filter sheet returns selected filters or null if cancelled
  Future<Map<String, dynamic>?> _openFilterSheet(
    HomeController controller,
  ) async {
    final brands = controller.cars.map((c) => c.brand).toSet().toList()..sort();
    final fuels = controller.cars.map((c) => c.fuelType).toSet().toList()
      ..sort();

    String? selectedBrand = _selectedBrand;
    String? selectedFuel = _selectedFuel;

    final res = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'فلتر النتائج',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('إغلاق'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('العلامة'),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('كل العلامات'),
                          selected: selectedBrand == null,
                          onSelected: (_) {
                            setState(() => selectedBrand = null);
                          },
                        ),
                        ...brands
                            .map(
                              (b) => ChoiceChip(
                                label: Text(b),
                                selected: selectedBrand == b,
                                onSelected: (_) {
                                  setState(() => selectedBrand = b);
                                },
                              ),
                            )
                            .toList(),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text('نوع الوقود'),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('الكل'),
                          selected: selectedFuel == null,
                          onSelected: (_) {
                            setState(() => selectedFuel = null);
                          },
                        ),
                        ...fuels
                            .map(
                              (f) => ChoiceChip(
                                label: Text(f),
                                selected: selectedFuel == f,
                                onSelected: (_) {
                                  setState(() => selectedFuel = f);
                                },
                              ),
                            )
                            .toList(),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop({
                              'brand': selectedBrand,
                              'fuel': selectedFuel,
                            });
                          },
                          child: Text('تطبيق'),
                        ),
                        SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedBrand = null;
                              selectedFuel = null;
                            });
                          },
                          child: Text('مسح'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return res;
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorBackground,
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => MyPurchaseRequestsPage()),
        backgroundColor: primaryblue,
        icon: Icon(Icons.shopping_cart),
        label: Text('طلباتي'),
      ),*/
      endDrawer: Drawer(
        child: SafeArea(
          child: GetBuilder<HomeController>(
            builder: (controller) {
              final ownedCars = controller.cars
                  .where((c) => c.userId == controller.userId)
                  .toList();
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0C2A45),primaryblue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: primaryblue.withOpacity(0.18), blurRadius: 10),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Text(
                            (controller.userName.isNotEmpty
                                ? controller.userName
                                      .split(' ')
                                      .map((s) => s.isNotEmpty ? s[0] : '')
                                      .take(2)
                                      .join()
                                : 'م'),
                            style: TextStyle(
                              color: primaryblue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.userName.isNotEmpty
                                    ? controller.userName
                                    : 'مرحباً',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'لوحة التحكم',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      children: [
                        if (ownedCars.isNotEmpty)
                          Card(
                            color: Color(0xFF0C2A45),
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryblue,
                                child: Icon(
                                  Icons.directions_car,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text('سياراتي', style: TextStyle(color: Colors.white)),
                              subtitle: Text('عرض وإدارة سياراتك', style: TextStyle(color: Colors.white70)),
                              trailing: Icon(Icons.chevron_right, color: Colors.white70),
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => MyCarsPage());
                              },
                            ),
                          )
                        else
                          Card(
                            color: Color(0xFF0C2A45),
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryblue,
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                              title: Text('أضف سيارة', style: TextStyle(color: Colors.white)),
                              subtitle: Text(
                                'أضف إعلان سيارتك للبيع أو الصيانة',
                                style: TextStyle(color: Colors.white70),
                              ),
                              trailing: Icon(Icons.chevron_right, color: Colors.white70),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        Card(
                          color: Color(0xFF0C2A45),
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryblue,
                              child: Icon(
                                Icons.directions_car_filled,
                                color: Colors.white,
                              ),
                            ),
                            title: Text('طلباتي', style: TextStyle(color: Colors.white)),
                            subtitle: Text('عرض طلباتك', style: TextStyle(color: Colors.white70)),
                            trailing: Icon(Icons.chevron_right, color: Colors.white70),
                            onTap: () {
                              Navigator.of(context).pop();
                              Get.to(() => MyPurchaseRequestsPage());
                            },
                          ),
                        ),

                        Card(
                          color: Color(0xFF0C2A45),
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryblue,
                              child: Icon(Icons.payment, color: Colors.white),
                            ),
                            title: Text('الدفوعات', style: TextStyle(color: Colors.white)),
                            subtitle: Text('عرض وإدارة الفواتير', style: TextStyle(color: Colors.white70)),
                            trailing: Icon(Icons.chevron_right, color: Colors.white70),
                            onTap: () {
                              Navigator.of(context).pop();
                              Get.to(() => MyPaymentsPage());
                            },
                          ),
                        ),

                        Card(
                          color: Color(0xFF0C2A45),
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryblue,
                              child: Icon(Icons.support_agent, color: Colors.white),
                            ),
                            title: Text('إرسال طلب للإدارة', style: TextStyle(color: Colors.white)),
                            subtitle: Text('أبلغ الإدارة بعنوان ووصف', style: TextStyle(color: Colors.white70)),
                            trailing: Icon(Icons.send, color: Colors.white70),
                            onTap: () async {
                              Navigator.of(context).pop();
                              final titleCtrl = TextEditingController();
                              final descCtrl = TextEditingController();
                              bool sending = false;
                              final ok = await Get.dialog<bool>(
                                Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: StatefulBuilder(
                                    builder: (ctx, setState) {
                                      return Container(
                                        constraints: BoxConstraints(maxWidth: 520),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                                              child: Row(children: [Expanded(child: Text('إرسال طلب للإدارة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Get.back(result: false), icon: Icon(Icons.close, color: Colors.white))]),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(14),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'العنوان')),
                                                  SizedBox(height: 8),
                                                  TextField(controller: descCtrl, maxLines: 6, decoration: InputDecoration(labelText: 'الوصف')),
                                                  SizedBox(height: 12),
                                                  Row(children: [Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () => Get.back(result: false), child: Text('إلغاء'))), SizedBox(width: 8), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryblue), onPressed: sending ? null : () async { setState(() => sending = true); final success = await Get.find<HomeController>().createUserRequest(titleCtrl.text.trim(), descCtrl.text.trim()); setState(() => sending = false); if (success) Get.back(result: true); }, child: sending ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('إرسال')))]),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                barrierDismissible: false,
                              );
                              if (ok == true) showCustomSnackbar('نجح', 'تم إرسال الطلب للإدارة');
                            },
                          ),
                        ),
                        Card(
                          color: Color(0xFF0C2A45),
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryblue,
                              child: Icon(Icons.message, color: Colors.white),
                            ),
                            title: Text('رسائلي', style: TextStyle(color: Colors.white)),
                            subtitle: Text('اطلع على محادثاتك', style: TextStyle(color: Colors.white70)),
                            trailing: Icon(Icons.chevron_right, color: Colors.white70),
                            onTap: () {
                              Navigator.of(context).pop();
                              Get.to(() => UserMessagesPage());
                            },
                          ),
                        ),
                        if (controller.isServiceOwner)
                          Card(
                            color: Color(0xFF0C2A45),
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryblue,
                                child: Icon(Icons.build, color: Colors.white),
                              ),
                              title: Text('طلبات الصيانة', style: TextStyle(color: Colors.white)),
                              subtitle: Text('إدارة طلبات الصيانة', style: TextStyle(color: Colors.white70)),
                              trailing: Icon(Icons.chevron_right, color: Colors.white70),
                              onTap: () {
                                Navigator.of(context).pop();
                                Get.to(() => ServiceOwnerRequestsPage());
                              },
                            ),
                          ),
                        Card(
                          color: Color(0xFF0C2A45),
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.logout, color: Colors.white),
                            ),
                            title: Text(
                              'تسجيل الخروج',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text('تسجيل الخروج من التطبيق', style: TextStyle(color: Colors.white70)),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                            ),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: Color(0xFF0C2A45),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  title: Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
                                  content: Text(
                                    'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: Text('إلغاء'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: Text('تسجيل الخروج'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                Navigator.of(context).pop();
                                await controller.signOut();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: Container(
        // لا تغير الخلفية الأساسية
        child: GetBuilder<HomeController>(
          builder: (controller) {
            // Precache announcement images into Flutter's image cache so they appear instantly
            if (controller.announcements.isNotEmpty &&
                !_announcementsPrefetched) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                for (final a in controller.announcements) {
                  final content = (a as Announcement).content;
                  final isImageUrl =
                      content.startsWith('http') &&
                      (content.endsWith('.png') ||
                          content.endsWith('.jpg') ||
                          content.endsWith('.jpeg') ||
                          content.endsWith('.webp'));
                  if (isImageUrl) {
                    try {
                      precacheImage(
                        CachedNetworkImageProvider(content),
                        context,
                      );
                    } catch (e) {
                      print('Precache failed for $content: $e');
                    }
                  }
                }
                setState(() => _announcementsPrefetched = true);
              });
            }

            return controller.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryblue))
                : Stack(
                    children: [
                      SafeArea(
                        child: RefreshIndicator(
                          onRefresh: () => controller.refreshData(),

                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                // spacer for header area so overlayed buttons don't cover content
                                SizedBox(height: 12),
                                // HERO: Announcements carousel with modern header overlay
                                SizedBox(
                                  height: h * 0.36,
                                  child: Stack(
                                    children: [
                                      // Carousel
                                      Positioned.fill(
                                        child: controller.announcements.isEmpty
                                            ? ShimmerLoadingWidget(h * 0.33)
                                            : PageView.builder(
                                                controller:
                                                    controller.addsController,
                                                onPageChanged: (i) => setState(
                                                  () =>
                                                      _activeAnnouncementIndex =
                                                          i,
                                                ),
                                                itemCount: controller
                                                    .announcements
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  final announcement =
                                                      controller
                                                          .announcements[index];
                                                  final content =
                                                      announcement.content;
                                                  final isImageUrl =
                                                      content.startsWith(
                                                        "http",
                                                      ) &&
                                                      (content.endsWith(
                                                            ".png",
                                                          ) ||
                                                          content.endsWith(
                                                            ".jpg",
                                                          ) ||
                                                          content.endsWith(
                                                            ".jpeg",
                                                          ) ||
                                                          content.endsWith(
                                                            ".webp",
                                                          ));

                                                  return ClipRRect(
                                                    child: isImageUrl
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (_) => Dialog(
                                                                  backgroundColor:
                                                                      Colors.black,
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .all(8),
                                                                  child:
                                                                      InteractiveViewer(
                                                                    boundaryMargin:
                                                                        EdgeInsets.all(20),
                                                                    minScale:
                                                                        1.0,
                                                                    maxScale:
                                                                        4.0,
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          content,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      placeholder:
                                                                          (c, u) => Center(
                                                                              child: CircularProgressIndicator()),
                                                                      errorWidget:
                                                                          (c, u, e) => Container(
                                                                              color: Colors.grey[300]),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child:
                                                                CachedNetworkImage(
                                                              width:
                                                                  double.infinity,
                                                              fit: BoxFit.cover,
                                                              imageUrl: content,
                                                              fadeInDuration:
                                                                  Duration.zero,
                                                              fadeOutDuration:
                                                                  Duration.zero,
                                                              placeholder:
                                                                  (
                                                                    ctx,
                                                                    url,
                                                                  ) => Container(
                                                                    color: Colors
                                                                        .transparent,
                                                                  ),
                                                              errorWidget:
                                                                  (
                                                                    ctx,
                                                                    url,
                                                                    error,
                                                                  ) => Container(
                                                                    color: Colors
                                                                        .grey[300],
                                                                  ),
                                                            ),
                                                          )
                                                        : Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                              w * 0.06,
                                                            ),
                                                            alignment:
                                                                Alignment.center,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .notifications_active_rounded,
                                                                  color: Colors
                                                                      .white,
                                                                  size:
                                                                      w * 0.07,
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      h * 0.01,
                                                                ),
                                                                Text(
                                                                  content,
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        w *
                                                                        0.04,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontFamily:
                                                                        kGtSectraFine,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 4,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                  );
                                                },
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            controller.announcements.length,
                                            (i) {
                                              final active =
                                                  i == _activeAnnouncementIndex;
                                              return AnimatedContainer(
                                                duration: Duration(
                                                  milliseconds: 250,
                                                ),
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                ),
                                                width: active ? 18 : 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: active
                                                      ? Colors.white
                                                      : Colors.white54,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // New modern storefront section with search & filters
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.04,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 16),
                                      Builder(
                                        builder: (context) {
                                          final q = _searchQuery
                                              .trim()
                                              .toLowerCase();
                                          final allCars = controller.cars;
                                          final filtered = allCars.where((c) {
                                            // always hide cars that are not marked as for sale
                                            if (!c.isForSale) return false;
                                            if (_selectedBrand != null &&
                                                _selectedBrand!.isNotEmpty &&
                                                c.brand != _selectedBrand)
                                              return false;
                                            if (_selectedFuel != null &&
                                                _selectedFuel!.isNotEmpty &&
                                                c.fuelType != _selectedFuel)
                                              return false;

                                            final hay =
                                                (c.brand +
                                                        ' ' +
                                                        c.title +
                                                        ' ' +
                                                        c.desc)
                                                    .toLowerCase();
                                            final matchesSearch =
                                                q.isEmpty || hay.contains(q);
                                            return matchesSearch;
                                          }).toList();

                                          final activeFilter =
                                              q.isNotEmpty ||
                                              _selectedBrand != null ||
                                              _selectedFuel != null;

                                          // Show search results only when user performed a search or applied filters
                                          if (!activeFilter) {
                                            return BuildEnhancedChildrenSection(
                                              w: w,
                                              h: h,
                                              controller: controller,
                                            );
                                          }
                                          if (filtered.isEmpty) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: h * 0.04,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'لا توجد نتائج',
                                                  style: textStyleBody,
                                                ),
                                              ),
                                            );
                                          }

                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: w * 0.04,
                                                  mainAxisSpacing: h * 0.02,
                                                  childAspectRatio: 0.56,
                                                ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: w * 0.0,
                                            ),
                                            itemCount: filtered.length,
                                            itemBuilder: (context, index) {
                                              final car = filtered[index];
                                              return BuildEnhancedCarCard(
                                                w: w,
                                                car: car,
                                                onTap: () => Get.to(
                                                  () =>
                                                      CarDetailsPage(car: car),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(height: 12),

                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          top: 43,
                          left: 12,
                          right: 12,
                        ),
                        height: 42, // 🔹 ارتفاع صغير
                        child: Row(
                          children: [
                            /// 🔍 Search capsule
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8,
                                    sigmaY: 8,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          size: 20,
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: TextField(
                                            onChanged: (q) => setState(
                                              () => _searchQuery = q,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),

                                            decoration: const InputDecoration(
                                              hintText: 'ابحث عن سيارة',
                                              hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsetsGeometry.symmetric(
                                                    vertical: 10,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            /// 🎛 Floating filter button and logout button (same style)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final result = await _openFilterSheet(
                                      controller,
                                    );
                                    if (result != null) {
                                      setState(() {
                                        _selectedBrand = result['brand'];
                                        _selectedFuel = result['fuel'];
                                      });
                                    }
                                  },
                                  child: ClipOval(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 8,
                                        sigmaY: 8,
                                      ),
                                      child: Container(
                                        height: 42,
                                        width: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.45),

                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.tune,
                                          size: 20,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Builder(
                                  builder: (ctx) => GestureDetector(
                                    onTap: () =>
                                        Scaffold.of(ctx).openEndDrawer(),
                                    child: ClipOval(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 8,
                                          sigmaY: 8,
                                        ),
                                        child: Container(
                                          height: 42,
                                          width: 42,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.45,
                                            ),

                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.dehaze,
                                            size: 20,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
