import 'package:flutter/material.dart';
import 'ButtomBlue.dart';
import 'TopBlue.dart';

class LoginBackGround extends StatelessWidget {
  const LoginBackGround({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ListView(
      children: [
        Stack(
          children: [
            TopBlue(topFlex: 2, bottomFlex: 18, leftMargin: width * 0.7),
            TopBlue(topFlex: 1, bottomFlex: 19, leftMargin: width * 0.5),
            ButtomBlue(topFlex: 19, bottomFlex: 1, rightMargin: width * 0.5),
            ButtomBlue(topFlex: 18, bottomFlex: 2, rightMargin: width * 0.7),
          ],
        ),
      ],
    );
  }
}
