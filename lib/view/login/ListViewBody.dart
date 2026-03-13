import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/view/login/widgets/DontHaveAccount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_manager/home_manager/home_view_manager.dart';
import '../../../../constants.dart';
import '../../controller/login_controller.dart';
import '../../widgets/custom_snackbar.dart';
import '../../color.dart';

class ListViewBody extends StatefulWidget {
  const ListViewBody({super.key});

  @override
  State<ListViewBody> createState() => _ListViewBodyState();
}

class _ListViewBodyState extends State<ListViewBody>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(LoginController());
  bool isAdmin = false;
  final TextEditingController adminCodeController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    adminCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071B2C), primaryblue.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header matching Register
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.asset('assets/images/1.png', width: 68, height: 68, fit: BoxFit.cover),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('انضم إلى سيارتي', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('تسجيل الدخول بسرعة وبشكل آمن', style: TextStyle(color: Colors.white70, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 26),

                    // Form card (dark professional)
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF0C2A45), // aligned with app primary blue palette
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryblue.withOpacity(0.28),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: primaryblue.withOpacity(0.22)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('مرحباً مجدداً', style: textStyleHeading.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    SizedBox(height: 6),
                                    Text('سجل دخولك لعرض سيارتك أو تصفح الإعلانات', style: TextStyle(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              _buildToggleButton(),
                            ],
                          ),
                          SizedBox(height: 18),

                          // Email & Password form
                          Form(
                            key: controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('البريد الإلكتروني', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                SizedBox(height: 6),
                                _outlinedField(controller.myemail, 'example@mail.com', Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: controller.validateEmail),
                                SizedBox(height: 12),

                                Text('كلمة المرور', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                SizedBox(height: 6),
                                _outlinedField(controller.mypassword, '●●●●●●●●', Icons.lock_outline, isPassword: true, validator: controller.validatePassword),

                                if (isAdmin) ...[
                                  SizedBox(height: 12),
                                  _outlinedField(adminCodeController, 'الرمز السري للمدير', Icons.vpn_key, isPassword: true),
                                ],
                              ],
                            ),
                          ),

                          SizedBox(height: 14),



                          SizedBox(height: 8),
                          Obx(() => ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: isAdmin ? Colors.deepOrange : colorPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () async {
                                        if (isAdmin) {
                                          if (adminCodeController.text.trim() != "02050205") {
                                            showCustomSnackbar("خطأ", "الرمز السري غير صحيح");
                                            return;
                                          }
                                          final email = controller.myemail.text.trim();
                                          final password = controller.mypassword.text;
                                          if (email.isEmpty) {
                                            showCustomSnackbar("خطأ", "يرجى إدخال البريد الإلكتروني");
                                            return;
                                          }
                                          if (!GetUtils.isEmail(email)) {
                                            showCustomSnackbar("خطأ", "يرجى إدخال بريد إلكتروني صحيح");
                                            return;
                                          }
                                          if (password.isEmpty) {
                                            showCustomSnackbar("خطأ", "يرجى إدخال كلمة المرور");
                                            return;
                                          }
                                          if (password.length < 6) {
                                            showCustomSnackbar("خطأ", "كلمة المرور يجب أن تكون 6 أحرف على الأقل");
                                            return;
                                          }

                                          await controller.login();
                                          if (controller.auth.currentUser != null) {
                                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeViewManager()));
                                          }
                                        } else {
                                          await controller.login();
                                        }
                                      },
                                child: controller.isLoading.value
                                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(isAdmin ? 'دخول المدير' : 'تسجيل الدخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              )),

                          SizedBox(height: 12),
                          Center(child: DontHaveAccount(color: colorPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () async {
        setState(() {
          isAdmin = !isAdmin;
          if (isAdmin) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isManager', isAdmin);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.deepOrange.withOpacity(0.15) : colorPrimary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAdmin ? Colors.deepOrange : colorPrimary,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              size: 16,
              color: isAdmin ? Colors.deepOrange : colorPrimary,
            ),
            SizedBox(width: 6),
            Text(
              isAdmin ? 'مدير' : 'مستخدم',
              style: TextStyle(
                color: isAdmin ? Colors.deepOrange : colorPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlinedField(TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, bool showPasswordToggle = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && (showPasswordToggle ? !this.controller.isPasswordVisible.value : true),
      validator: validator,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white38),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorPrimary)),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        suffixIcon: showPasswordToggle
            ? Obx(() => IconButton(
                  icon: Icon(this.controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                  onPressed: () => this.controller.togglePasswordVisibility(),
                ))
            : null,
      ),
    );
  }




}
