import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kindergarten_user/color.dart';
import '../main.dart';
import '../model/home_model.dart';
import '../mywidget.dart';

class Edit_inf_Controller extends GetxController {
  bool isLoading = false;
  bool all_information = false;
  List courses = [];
  TextEditingController my_name = new TextEditingController();
  TextEditingController my_desc = new TextEditingController();
  TextEditingController my_ishhar_number = new TextEditingController();
  TextEditingController my_ishhar_city = new TextEditingController();
  TextEditingController my_ishhar_date = new TextEditingController();
  TextEditingController my_goul1 = new TextEditingController();
  TextEditingController my_goul2 = new TextEditingController();
  TextEditingController my_goul3 = new TextEditingController();
  TextEditingController my_goul4 = new TextEditingController();
  CollectionReference activity =
      FirebaseFirestore.instance.collection('activity');

  getinf() async {
    isLoading = true;
    update();
    try {
      await FirebaseFirestore.instance
          .collection('information')
          .doc("8YoUe9iXyXz7oUxX8Hh9")
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          my_name.text = documentSnapshot['name'];
          my_ishhar_date.text = documentSnapshot['ishhar_date'];
          my_ishhar_city.text = documentSnapshot['ishhar_city'];
          my_ishhar_number.text = documentSnapshot['ishhar_number'];
          my_desc.text = documentSnapshot['description'];
          my_goul1.text = documentSnapshot['goals'][0];
          my_goul2.text = documentSnapshot['goals'][1];
          my_goul3.text = documentSnapshot['goals'][2];
          my_goul4.text = documentSnapshot['goals'][3];
        }
      });
    } catch(e){ MySnackbar("خطأ", "حدث خطأ ... حاول مجددا");
    isLoading=false;update();}
    isLoading = false;
    update();
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

   updateInf() {
    isLoading = true;
    update();
    try{
    return inf
        .doc('8YoUe9iXyXz7oUxX8Hh9')
        .update({
          'name': my_name.text,
          'ishhar_number': my_ishhar_number.text,
          'ishhar_date': my_ishhar_date.text,
          'ishhar_city': my_ishhar_city.text,
          'description': my_desc.text,
          'goals': [my_goul1.text, my_goul2.text, my_goul3.text, my_goul4.text],
        })
        .then((value){

              Get.back();
              Get.back();
              isLoading = false;
              update();
              MySnackbar("تعديل المعلومات", "تم تعديل المعلومات بنجاح");
            })
        .catchError((error)
            {

              isLoading = false;
              update();
              MySnackbar("تعديل المعلومات", "حدث خطأ ... حاول مجددا");});}catch(e){ MySnackbar("خطأ", "حدث خطأ ... حاول مجددا");
    isLoading=false;update();}
  }

  CollectionReference inf =
      FirebaseFirestore.instance.collection('information');



/*
  edit_course() async {
    isLoading = true;
    update();
    try {
      var token = sharePref?.getString("token");
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var request = http.Request('PUT', Uri.parse('${domain.base_url}/course'));
      request.body = json.encode({
        "title":"course 2",
        "description" :"This is course3 1"
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        MySnackbar("edit course", "course added successfully");
      } else {
        MySnackbar("edit course", "there is something wrong");
      }
    } catch (e) {
      update();
      MySnackbar("edit course", "there is something wrong");
    }
    getAll();

    mytitle.text = "";
    mydescription.text = "";
    isLoading = false;
    update();
  }

  delete_course() async {
    isLoading = true;
    update();
    try {
      var token = sharePref?.getString("token");
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var request = http.Request('DELETE', Uri.parse('${domain.base_url}/course'));
      request.body = json.encode({
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        MySnackbar("delete course", "course added successfully");
      } else {
        MySnackbar("delete course", "there is something wrong");
      }
    } catch (e) {
      update();
      MySnackbar("delete course", "there is something wrong");
    }
    getAll();

    mytitle.text = "";
    mydescription.text = "";
    isLoading = false;
    update();
  }

*/
  void onInit() {
    getinf();
    super.onInit();
  }
}
