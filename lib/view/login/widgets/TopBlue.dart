import 'package:flutter/material.dart';

import '../../../../../constants.dart';
class TopBlue extends StatelessWidget {
  final double leftMargin;
  final int topFlex;
  final int bottomFlex;
  const TopBlue({Key? key,required this.leftMargin,required this.topFlex,
    required this.bottomFlex}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return    SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            flex: topFlex,
            child: Container(
              margin: EdgeInsets.only(left: leftMargin),
              decoration: const BoxDecoration(
                  color: colorSpecialBlue,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(300, 100))),
            ),
          ),
          Expanded(flex: bottomFlex, child: Container()),
        ],
      ),
    );
  }
}
