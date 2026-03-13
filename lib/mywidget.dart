import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'color.dart';
import 'constants.dart';
import 'main.dart';

class Send {
  static sendToken(token1) async {
    try {
      var token = sharePref?.getString("token");
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': 'ADFRETYUUBFD!#@%*%4455iup!98SCZ@',
        'app-version': '1.0.0',
      };
      var request = http.Request('PATCH', Uri.parse('$baseUrl/auth/fcm-token'));
      request.body = json.encode({"fcm_token": token1});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      print(await response.stream.bytesToString());
      if (response.statusCode == 200) {
        print("okkkkkkkkkkkkkk");
      } else {}
    } catch (e) {
      print(e);
    }
  }
}

MySnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    borderWidth: 1,
    borderColor: Colors.black,
    backgroundColor: colorWhite,
    titleText: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: colorSpecialPink,
          fontWeight: FontWeight.bold,
          fontSize: Get.width * 0.04,
        ),
      ),
    ),
    messageText: Container(
      height: Get.height * 0.03,
      child: Padding(
        padding: EdgeInsets.only(right: 8),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: Get.width * 0.035,
          ),
        ),
      ),
    ),
    forwardAnimationCurve: FlippedCurve(Curves.easeIn),
    backgroundGradient: LinearGradient(
      colors: [Colors.black87, Colors.black87],
    ),
    duration: Duration(seconds: 2),
    borderRadius: 5,
    margin: EdgeInsets.only(
      top: Get.height * 0.08,
      left: Get.width * 0.05,
      right: Get.width * 0.05,
    ),
  );
}
