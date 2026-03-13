import 'package:flutter/material.dart';
import '../../../../../constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key, required this.buttonText, required this.function, required this.color})
      : super(key: key);
  final String buttonText;
  final Function function;
  final Color color;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        function();
      },
      child: Container(
        height: height * 0.055,
        margin: EdgeInsets.symmetric(horizontal: width * 0.3),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Center(
            child: Text(
          buttonText,
          style: TextStyle(
              color: colorWhite,
              fontSize: width * 0.035,
              fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}
