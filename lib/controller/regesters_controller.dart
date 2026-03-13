
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegestersController extends GetxController {
  bool isLoading = false;
  PageController pagecontroller = new PageController();
 late List regesters ;
  late String title ;
  late String desc ;
  late int total ;
  late int mines ;

  void onInit() {
    regesters=Get.arguments['regesters'];
    title=Get.arguments['title'];
    desc=Get.arguments['desc'];
    total=Get.arguments['total'];
    mines=Get.arguments['mines'];
    super.onInit();
  }
}
