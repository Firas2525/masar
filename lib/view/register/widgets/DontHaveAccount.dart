import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/view/login/login.dart';
import '../../../../../constants.dart';
import '../../../color.dart';

class DontHaveAccount extends StatelessWidget {
  final Color color;
  const DontHaveAccount({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "لديك حساب بالفعل؟",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Get.off(() => Login());
          },
          child: Text(
            "تسجيل الدخول",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
