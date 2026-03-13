import 'package:flutter/material.dart';
class ClotheImage extends StatelessWidget {
  const ClotheImage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height*0.22,
      child: Stack(children: [
        Container(
          //margin: EdgeInsets.only(left: width*0.11),
          height: height*0.22,
          child: Center(child: Image.asset("assets/images/1.png")) ,),
        /*Container(margin: EdgeInsets.only(left: width*0.3),
          height: height*0.2,
          child: Image.asset("assets/images/b6.png") ,),
        Container(margin: EdgeInsets.only(left: width*0.45),
          height: height*0.2,
          child: Image.asset("assets/images/o3.png") ,),*/
      ]),
    );
  }
}
