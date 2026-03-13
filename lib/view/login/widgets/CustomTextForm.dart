import 'package:flutter/material.dart';

import '../../../../../constants.dart';
class CustomTextForm extends StatelessWidget {
  const CustomTextForm({Key? key, required this.label, required this.myController, required this.icon, required this.borderColor, required this.iconColor, required this.labelColor}) : super(key: key);
  final String label;
  final TextEditingController myController;
  final IconData icon;
  final Color borderColor;
  final Color iconColor;
  final Color labelColor;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: TextFormField(
        controller: myController,
        cursorColor: Colors.black,
        style: TextStyle(fontWeight: FontWeight.w500,fontSize: width*0.04),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide:
                 BorderSide(color: borderColor, width: 3)),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                 BorderSide(color: borderColor, width: 2)),
            icon: Padding(
              padding:  EdgeInsets.only(top: 7),
              child: Icon(icon,color: iconColor,size: width*0.06),
            ),
            label: Text(
              " $label ",
              style:  TextStyle(
                  color: labelColor, fontWeight: FontWeight.bold),
            )),
      ),
    );
  }
}
