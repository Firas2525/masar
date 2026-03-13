import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class AuthMiddlewar extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route){
    if(sharePref?.getString("token")!=null){

      return RouteSettings(name: "/home");};
  }
}