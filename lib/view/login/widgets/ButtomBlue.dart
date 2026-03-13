import 'package:flutter/material.dart';

import '../../../../../constants.dart';
class ButtomBlue extends StatelessWidget {
  final double rightMargin;
  final int topFlex;
  final int bottomFlex;
  const ButtomBlue({Key? key,required this.rightMargin,required this.topFlex,
    required this.bottomFlex}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return    SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(flex: topFlex, child: Container()),
          Expanded(
            flex: bottomFlex,
            child: Container(
              // height: height*0.3,
              margin: EdgeInsets.only(right: rightMargin),
              decoration: const BoxDecoration(
                  color: colorSpecialBlue,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.elliptical(300, 100))),
            ),
          )
        ],
      ),
    );
  }
}