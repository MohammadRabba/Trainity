import 'package:flutter/material.dart';
import 'package:get/get.dart';

class langauge_manager extends GetxController{



   void Changlang (String lang){
Locale local =Locale(lang);
Get.updateLocale(local);


   }
}