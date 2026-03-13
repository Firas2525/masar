import 'package:flutter/material.dart';
import 'LoginBody.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(),
          child:  LoginBody()),
    );
  }
}
