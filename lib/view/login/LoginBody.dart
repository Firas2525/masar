import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/login_controller.dart';
import '../login/ListViewBody.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({Key? key}) : super(key: key);

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: [

        ListViewBody()

      ],
    );
  }
}
