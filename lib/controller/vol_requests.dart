import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kindergarten_user/model/inf_model.dart';
import 'package:kindergarten_user/model/vol_requests_model.dart';
import 'package:kindergarten_user/model/vol_requests_model.dart';
import '../main.dart';
import '../model/course_model.dart';
import '../model/home_model.dart';
import '../model/course_model.dart';
import '../mywidget.dart';

class Vol_requestsController extends GetxController {
  bool isLoading = false;
  PageController pagecontroller = new PageController();
  late List volunteer_reqs;
  CollectionReference volunteer_requests =
  FirebaseFirestore.instance.collection('volunteer_requests');
  delete_req(id) {
    isLoading = true;
    update();
    try{
      return volunteer_requests.doc(id).delete().then((value) {
        getAll();
        isLoading = false;
        update();
        MySnackbar("حذف طلب تطوع", "تم حذف الطلب بنجاح");
      }).catchError((error) {
        getAll();
        isLoading = false;
        update();
        MySnackbar("حذف طلب تطوع", "حدث خطأ ... حاول مجددا");
      });}catch(e){ MySnackbar("خطأ", "حدث خطأ ... حاول مجددا");
    isLoading=false;update();}
  }

  update_req(id) {
    Get.back();
    isLoading = true;
    update();
    try{
      return volunteer_requests.doc(id).update({
        "req_status":true,
      }).then((value) {
        getAll();
        isLoading = false;
        update();
        MySnackbar("طلب تطوع", "تم قبول الطلب بنجاح");
      }).catchError((error) {
        getAll();
        isLoading = false;
      update();
        MySnackbar("طلب تطوع", "حدث خطأ ... حاول مجددا");
      });}catch(e){ MySnackbar("خطأ", "حدث خطأ ... حاول مجددا");
    isLoading=false;update();}
  }

  getAll() async {
    isLoading = true;
    update();
    List thevolunter_reqs = [];
    try {
      await FirebaseFirestore.instance
          .collection('volunteer_requests')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          Vol_requestsModel a = Vol_requestsModel(
              id: doc['id']
              , age: doc['age'], name: doc['name']
              , experience: doc['experience'], work: doc['work'], req_status:doc['req_status'], main_id: '${doc.id}' );
          if(doc['req_status']==false){
          thevolunter_reqs.add(a);}
        });
        volunteer_reqs = thevolunter_reqs;
        print(volunteer_reqs);
      });
      isLoading = false;
      update();
    } catch (e) {
      MySnackbar("خطأ", "حدث خطأ ... حاول مجددا");
      isLoading = false;
      update();
    }
  }

  void onInit() {
    getAll();
    super.onInit();
  }
}
