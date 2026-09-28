import 'package:get/get.dart';

class lang implements Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        "en": {
          "1": "Welcome",
          "2": "Turn on to enable Language",
          "3": "Biometrics Authentication",
          "4": "Turn on to enable biometrics",
          "5": "Dark Mode",
          "6": "Turn on to enable Dark Mode",
          "7": "Are you sure you want to delete your account?",
          "8": "Yes",
          "9": "No",
          "10": "Remove Account"
        },
        "ar": {
          "1": "مرحبًا",
          "2": "قم بتشغيل لتمكين اللغة",
          "3": "المصادقة البيومترية",
          "4": "قم بتشغيل لتمكين المصادقة البيومترية",
          "5": "الوضع الداكن",
          "6": "قم بتشغيل لتمكين الوضع الداكن",
          "7": "هل أنت متأكد أنك تريد حذف حسابك؟",
          "8": "نعم",
          "9": "لا",
          "10": "حذف الحساب"
        }
      };
}
