import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../color.dart';
import '../../register/register.dart';
class DontHaveAccount extends StatelessWidget {
  final Color color;
  const DontHaveAccount({Key? key, required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "ليس لديك حساب؟",
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: width * 0.03,
          ),
        ),
        SizedBox(width: width * 0.02),
        GestureDetector(
          onTap: () {
            Get.off(() => Register());
          },
          child: Text(
            "إنشاء حساب",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: width * 0.032,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}