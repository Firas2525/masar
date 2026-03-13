import 'package:flutter/material.dart';
import 'RegisterBody.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
          decoration: BoxDecoration(),
          child:  RegisterBody()),
    );
  }
}
