import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trainity/model/StudentModel.dart';

class Matching {
  int high = 0;
  int medium = 0;
  int low = 0;
  double percentage = 0;
  double persentagehigh = 0;
  double persentagemeadum = 0;
  double persentagelow = 0;

  List<Map<String, dynamic>> conditionsList = [];
  List<StudentModel> studentList = [];

  Future<List<Map<String, dynamic>>> getAllUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();
      List<Map<String, dynamic>> userList = [];
      List<Map<String, dynamic>> studentList = [];

      for (var doc in querySnapshot.docs) {
        userList.add(doc.data());
      }

      for (int i = 0; i < userList.length; i++) {
        if (userList[i]['type'] == '0') {
          studentList.add(userList[i]);
        }
      }
      return userList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void processStatus() {
    for (Map<String, dynamic> item in conditionsList) {
      if (item['priority'] == 'high') {
        high++;
      } else if (item['priority'] == 'medium') {
        medium++;
      } else {
        low++;
      }
    }
  }

  void checkStatus() {
    int status1 = high;
    int status2 = medium;
    int status3 = low;

    if (status1 != 0 && status2 == 0 && status3 == 0) {
      percentage = (80 / status1);
      persentagehigh = percentage;
      print('percentage is: $percentage');
    } else if (status1 == 0 && status2 != 0 && status3 == 0) {
      percentage = (80 / status2);
      persentagemeadum = percentage;

      print('percentage is: $percentage');
    } else if (status1 == 0 && status2 == 0 && status3 != 0) {
      percentage = (80 / status3);
      persentagelow = percentage;

      print('percentage is: $percentage');
    } else if (status1 != 0 && status2 != 0 && status3 == 0) {
      int matchH = 60;
      int matchM = 20;
      persentagehigh = matchH / high;
      persentagemeadum = matchM / medium;
      persentagelow = 0;
      percentage = 80 - ((matchH / high) + (matchM / medium));
      print("MatchH: $matchH, MatchM: $matchM");
      print('percentage is: $percentage');
    } else if (status1 != 0 && status2 == 0 && status3 != 0) {
      int matchH = 80 - 15;
      int matchL = 15;
      persentagehigh = matchH / high;
      persentagelow = matchL / low;
      persentagemeadum = 0;
      percentage = 80 - ((matchH / high) + (matchL / low));

      print("MatchH: $matchH, MatchL: $matchL");
      print('percentage is: $percentage');
    } else if (status1 == 0 && status2 != 0 && status3 != 0) {
      int matchM = 80 - 25;
      int matchL = 25;
      persentagelow = matchL / low;
      persentagemeadum = matchM / medium;
      persentagehigh = 0;
      percentage = 80 - ((matchM / medium) + (matchL / low));

      print("MatchM: $matchM, MatchL: $matchL");
      print('percentage is: $percentage');
    } else {
      int matchH = 50;
      int matchL = 10;
      int matchM = 20;
      persentagehigh = matchH / high;
      persentagelow = matchL / low;
      persentagemeadum = matchM / medium;
      percentage = 80 - ((matchM / medium) + (matchL / low) + (matchH / high));
    }
  }
}
