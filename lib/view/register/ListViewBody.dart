import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/view/register/widgets/DontHaveAccount.dart';
import '../../../../constants.dart';
import '../../controller/regester_controller.dart';
import '../../widgets/custom_snackbar.dart';
import '../../color.dart';

class ListViewBody extends StatefulWidget {
  const ListViewBody({Key? key}) : super(key: key);

  @override
  State<ListViewBody> createState() => _ListViewBodyState();
}

class _ListViewBodyState extends State<ListViewBody> {
  final controller = Get.put(RegesterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
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
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // اللوغو

                SizedBox(height: 40,),
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryblue.withOpacity(0.4),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/1.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'انضم إلينا الآن واستمتع بالمميزات',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 32),

                // الاسم الكامل
                _buildSimpleField(
                  controller.myname,
                  'الاسم الكامل',
                  Icons.person_outline,
                  validator: (v) => (v==null || v.trim().isEmpty) ? 'الرجاء إدخال الاسم' : null,
                ),
                SizedBox(height: 16),

                // البريد الإلكتروني
                _buildSimpleField(
                  controller.myemail,
                  'البريد الإلكتروني',
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v==null || !GetUtils.isEmail(v)) ? 'بريد إلكتروني غير صالح' : null,
                ),
                SizedBox(height: 16),

                // كلمة المرور
                _buildSimpleField(
                  controller.mypassword,
                  'كلمة المرور',
                  Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => (v==null || v.length < 8) ? '8 أحرف على الأقل' : null,
                ),
                SizedBox(height: 24),

                // زر الإنشاء
                GetBuilder<RegesterController>(
                  init: controller,
                  builder: (c) {
                    return Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorPrimary, primaryblue],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorPrimary.withOpacity(0.35),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: c.isLoading ? null : _handleRegister,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: c.isLoading
                                ? SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'إنشاء حساب',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 18),
                DontHaveAccount(color: colorPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (controller.myname.text.trim().isEmpty) {
      showCustomSnackbar('خطأ', 'الرجاء إدخال الاسم');
      return;
    }
    if (!GetUtils.isEmail(controller.myemail.text.trim())) {
      showCustomSnackbar('خطأ', 'بريد إلكتروني غير صالح');
      return;
    }
    if (controller.mypassword.text.length < 8) {
      showCustomSnackbar('خطأ', 'كلمة المرور 8 أحرف على الأقل');
      return;
    }
    controller.regester();
  }

  Widget _buildSimpleField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        validator: validator,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white60, size: 22),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
