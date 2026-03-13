import 'package:flutter/material.dart';
import 'package:kindergarten_user/color.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget(this.height, {super.key});
  final double height;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height ;
    return Material(
      color: Colors.transparent,
      child:  Shimmer.fromColors(
        baseColor: primaryblue.withOpacity(0.3),
        highlightColor: primaryblue.withOpacity(0.5),
        child: Container(
          height:height,
          decoration: BoxDecoration(
            color: primaryblue,
          ),
        ),
      ),
    );
  }
}
