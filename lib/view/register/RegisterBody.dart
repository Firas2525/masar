import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../register/ListViewBody.dart';

class RegisterBody extends StatefulWidget {
  const RegisterBody({Key? key}) : super(key: key);

  @override
  State<RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: [

        ListViewBody()

      ],
    );
  }
}
