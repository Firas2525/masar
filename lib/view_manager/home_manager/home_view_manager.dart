import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/controller/manager_home_controller.dart';
import 'package:kindergarten_user/view_manager/manager_children_page.dart';
import 'package:kindergarten_user/view_manager/users_page.dart';
import '../../color.dart';
import '../../constants.dart';
import '../../view/home/shimmer_loading_widget.dart';
import '../../widgets/custom_snackbar.dart';
import '../manager_classes_page.dart';
import '../manager_register_requests_page.dart';
import 'widgets/BuildEnhancedHeader.dart';
import 'widgets/BuildModernDecorativeBackground.dart';
import 'manager_car_requests_page.dart';
import 'manager_violations_page.dart';
import 'manager_pending_requests_page.dart';
import 'manager_payments_page.dart';
import '../../view/home/car_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/home_model.dart';

class HomeViewManager extends StatefulWidget {
  const HomeViewManager({Key? key}) : super(key: key);

  @override
  State<HomeViewManager> createState() => _HomeViewManagerState();
}

class _HomeViewManagerState extends State<HomeViewManager> {
  final controller = Get.put(ManagerHomeViewController());

  // UI state for search & filtering
  String _searchQuery = '';
  String? _selectedBrand;
  String? _selectedFuel;

  Future<Map<String, dynamic>?> _openFilterSheet(
      ManagerHomeViewController controller,) async {
    final brands = controller.cars.map((c) => c.brand).toSet().toList()
      ..sort();
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
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom,
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
                              (b) =>
                              ChoiceChip(
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
                    Text('الوقود'),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('كل أنواع الوقود'),
                          selected: selectedFuel == null,
                          onSelected: (_) {
                            setState(() => selectedFuel = null);
                          },
                        ),
                        ...fuels
                            .map(
                              (f) =>
                              ChoiceChip(
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            selectedBrand = null;
                            selectedFuel = null;
                            setState(() {});
                          },
                          child: Text('مسح'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop({
                              'brand': selectedBrand,
                              'fuel': selectedFuel,
                            });
                          },
                          child: Text('تطبيق'),
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

  Widget _buildManagerCarItem(dynamic car, double w, double h) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Get.to(() => CarDetailsPage(car: car)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: h * 0.01),
        padding: EdgeInsets.all(w * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: car.image.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: car.image,
                width: w * 0.30,
                height: h * 0.14,
                fit: BoxFit.cover,
                placeholder: (c, s) =>
                    Container(
                      width: w * 0.30,
                      height: h * 0.14,
                      color: Colors.grey[200],
                    ),
                errorWidget: (c, s, e) =>
                    Container(
                      width: w * 0.30,
                      height: h * 0.14,
                      color: Colors.grey[200],
                      child: Icon(Icons.directions_car, color: primaryblue),
                    ),
              )
                  : Container(
                width: w * 0.30,
                height: h * 0.14,
                color: Colors.grey[200],
                child: Icon(Icons.directions_car, color: primaryblue),
              ),
            ),
            SizedBox(width: w * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.title.isNotEmpty ? car.title : car.brand,
                              style: TextStyle(
                                fontSize: w * 0.042,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Text(
                              '${car.brand} • ${car.mileageKill} كلم',
                              style: textStyleBody,
                            ),
                          ],
                        ),
                      ),

                      // Badges column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: car.isForSale
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.grey.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              car.isForSale ? 'معروض' : 'غير معروض',
                              style: TextStyle(
                                color: car.isForSale
                                    ? Colors.green[800]
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                fontSize: w * 0.028,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${car.violations.length} مخالف',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w700,
                                fontSize: w * 0.028,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // compact actions row
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'عرض الطلبات',
                        onPressed: () async {
                          try {
                            showCustomSnackbar(
                              'جاري الفتح',
                              'فتح صفحة طلبات السيارة...',
                            );
                            await Get.to(
                                  () => ManagerCarRequestsPage(car: car),
                            );
                          } catch (e) {
                            showCustomSnackbar('خطأ', e.toString());
                          }
                        },
                        icon: Icon(
                          Icons.description_outlined,
                          color: primaryblue,
                        ),
                      ),
                      IconButton(
                        tooltip: 'معلومات المعلن',
                        onPressed: () async {
                          final data = await controller.getUserData(car.userId);
                          if (data != null) {
                            Get.dialog(
                              AlertDialog(
                                title: Text('معلومات المعلن'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('الاسم: ${data['name'] ?? ''}'),
                                    Text('البريد: ${data['email'] ?? ''}'),
                                    Text('الهاتف: ${data['phone'] ?? ''}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('إغلاق'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            showCustomSnackbar(
                              'خطأ',
                              'معلومات المستخدم غير متوفرة',
                            );
                          }
                        },
                        icon: Icon(
                          Icons.person_outline,
                          color: Colors.grey[700],
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        tooltip: 'حذف الإعلان',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: Text('تأكيد الحذف'),
                                  content: Text('هل تريد حذف هذا الإعلان؟'),
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
                          if (confirmed == true)
                            await controller.deleteCarAsManager(car);
                        },
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
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
    );
  }

  Widget _managerPanelButton(double w,
      double h, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: h * 0.012),
        padding: EdgeInsets.symmetric(
          vertical: h * 0.024,
          horizontal: w * 0.045,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2F3), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 12,
              offset: Offset(4, 6),
            ),
          ],
        ),
        child: Row(
          children: [

            /// أيقونة داخل دائرة مميزة
            Container(
              height: w * 0.13,
              width: w * 0.13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryblue, primaryblue.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryblue.withOpacity(0.35),
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: w * 0.065),
              ),
            ),

            SizedBox(width: w * 0.045),

            /// النصوص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: kGtSectraFine,
                      fontWeight: FontWeight.w700,
                      fontSize: w * 0.048,
                      color: Color(0xFF22223B),
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: w * 0.035,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: w * 0.025),

            /// سهم للتنقل داخل Capsule صغير
            Container(
              padding: EdgeInsets.all(w * 0.02),
              decoration: BoxDecoration(
                color: primaryblue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: primaryblue,
                size: w * 0.042,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery
        .of(context)
        .size
        .height;
    double w = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colorBackgroundGradient),
        // لا تغير الخلفية الأساسية
        child: GetBuilder<ManagerHomeViewController>(
          builder: (controller) {
            return controller.isLoading
                ? Stack(
              children: [
                BuildModernDecorativeBackground(w: w, h: h),
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () => controller.refreshData(),
                    color: colorPrimary,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ShimmerLoadingWidget(h * 0.33),
                              BuildEnhancedHeader(
                                w: w,
                                controller: controller,
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: h * 0.03),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.04,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [],
                                  ),
                                ),
                                SizedBox(height: h * 0.02),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: w * 0.05,
                                        vertical: h * 0.01,
                                      ),
                                      child: ShimmerLoadingWidget(
                                        h * 0.1,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
                : Stack(
              children: [
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () => controller.refreshData(),
                    color: colorPrimary,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // Icons moved to header; no overlay here
                              controller.announcements.isEmpty
                                  ? ShimmerLoadingWidget(h * 0.33)
                                  : Container(
                                height: h * 0.33,
                                child: PageView.builder(
                                  controller:
                                  controller.addsController,
                                  itemCount: controller
                                      .announcements
                                      .length,
                                  itemBuilder: (context, index) {
                                    final announcement = controller
                                        .announcements[index];
                                    final content =
                                        announcement.content;
                                    // تحقق إذا المحتوى رابط (صورة أو لا)
                                    final isImageUrl =
                                        content.startsWith(
                                          "http",
                                        ) &&
                                            (content.endsWith(".png") ||
                                                content.endsWith(
                                                  ".jpg",
                                                ) ||
                                                content.endsWith(
                                                  ".jpeg",
                                                ) ||
                                                content.endsWith(
                                                  ".webp",
                                                ));

                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient:
                                        colorGradientAnnouncement,
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorAnnouncement
                                                .withOpacity(0.2),
                                            blurRadius: 18,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child:
                                      // إذا إعلان صورة → اعرضها، غير كده اعرض النص
                                      isImageUrl
                                          ? ClipRRect(
                                        child: Image.network(
                                          content,
                                          height: h * 0.08,
                                          width:
                                          double.infinity,
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context,
                                              error,
                                              stackTrace,) =>
                                              Text(
                                                "فشل تحميل الصورة",
                                                style: TextStyle(
                                                  color: Colors
                                                      .white,
                                                ),
                                              ),
                                        ),
                                      )
                                          : Padding(
                                        padding:
                                        EdgeInsets.all(
                                          w * 0.05,
                                        ),
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
                                              size: w * 0.06,
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
                                                w * 0.038,
                                                fontWeight:
                                                FontWeight
                                                    .w500,
                                                fontFamily:
                                                kGtSectraFine,
                                              ),
                                              textAlign:
                                              TextAlign
                                                  .center,
                                              maxLines: 3,
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
                              BuildEnhancedHeader(
                                w: w,
                                controller: controller,
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: h * 0.03),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.04,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(
                                          w * 0.025,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryPink,
                                              primaryPink,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryblue
                                                  .withOpacity(0.18),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons
                                              .dashboard_customize_outlined,
                                          color: Colors.white,
                                          size: w * 0.055,
                                        ),
                                      ),
                                      SizedBox(width: w * 0.03),
                                      Text(
                                        "لوحة التحكم",
                                        style: textStyleSubheading
                                            .copyWith(
                                          fontSize: w * 0.045,
                                          color: Color(0xFF22223B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: h * 0.025),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.04,
                                  ),
                                  child: Column(
                                    children: [
                                      _managerPanelButton(
                                        w,
                                        h,
                                        icon: Icons.people,
                                        title: "المستخدمون",
                                        subtitle:
                                        "عرض وتعديل المستخدمين، وتحويلهم لمراكز صيانة.",
                                        onTap: () =>
                                            Get.to(() => UsersPage()),
                                      ),


                                      _managerPanelButton(
                                        w,
                                        h,
                                        icon: Icons.description_outlined,
                                        title: "الطلبات",
                                        subtitle:
                                        "عرض جميع الطلبات بجميع حالاتها للمراجعة والإدارة.",
                                        onTap: () =>
                                            Get.to(
                                                  () =>
                                                  ManagerPendingRequestsPage(),
                                            ),
                                      ),

                                      _managerPanelButton(
                                        w,
                                        h,
                                        icon: Icons.payment,
                                        title: "الدفوعات",
                                        subtitle:
                                        "عرض وإدارة دفعات المستخدمين (قبول/رفض/حذف).",
                                        onTap: () =>
                                            Get.to(
                                                  () =>
                                                  ManagerPaymentsPage(),
                                            ),
                                      ),

                                      // مخالفة السيارات
                                      _managerPanelButton(
                                        w,
                                        h,
                                        icon: Icons.report_off_outlined,
                                        title: "المخالفات",
                                        subtitle:
                                        "عرض وإضافة مخالفات مرورية للسيارات.",
                                        onTap: () =>
                                            Get.to(
                                                  () => ManagerViolationsPage(),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // cars section for manager
                          SizedBox(height: h * 0.02),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.04,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'إعلانات السيارات',
                                      style: textStyleSubheading.copyWith(
                                        fontSize: w * 0.045,
                                      ),
                                    ),
                                    Text(
                                      '${controller.cars.length} إعلان',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: h * 0.015),

                                // Search + Filter row
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(30),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 8,
                                            sigmaY: 8,
                                          ),
                                          child: Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.35),
                                              borderRadius:
                                              BorderRadius.circular(
                                                30,
                                              ),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.4),
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
                                                    onChanged: (q) =>
                                                        setState(
                                                              () =>
                                                          _searchQuery =
                                                              q,
                                                        ),
                                                    style:
                                                    const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    decoration: const InputDecoration(
                                                      hintText:
                                                      'ابحث عن سيارة',
                                                      hintStyle:
                                                      TextStyle(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .black54,
                                                      ),
                                                      border: InputBorder
                                                          .none,
                                                      isDense: true,
                                                      contentPadding:
                                                      EdgeInsetsGeometry
                                                          .symmetric(
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
                                    GestureDetector(
                                      onTap: () async {
                                        final result =
                                        await _openFilterSheet(
                                          controller,
                                        );
                                        if (result != null) {
                                          setState(() {
                                            _selectedBrand =
                                            result['brand'];
                                            _selectedFuel =
                                            result['fuel'];
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
                                              color: Colors.white
                                                  .withOpacity(0.45),
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
                                  ],
                                ),

                                SizedBox(height: h * 0.02),

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

                                    if (!activeFilter) {
                                      final shown = controller.cars.where((
                                          c) => c.isForSale).toList();
                                      return shown.isEmpty
                                          ? Center(
                                        child: Text(
                                          'لا توجد إعلانات',
                                        ),
                                      )
                                          : Column(
                                        children: shown.map((car,) {
                                          return _buildManagerCarItem(
                                            car,
                                            w,
                                            h,
                                          );
                                        }).toList(),
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

                                    return Column(
                                      children: filtered.map((car) {
                                        return _buildManagerCarItem(
                                          car,
                                          w,
                                          h,
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.05),
                        ],
                      ),
                    ),
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
