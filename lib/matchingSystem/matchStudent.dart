import 'package:cloud_firestore/cloud_firestore.dart';

class MatchStudent {
  List<Map<String, dynamic>> studentList = [];
  List<Map<String, dynamic>> opportunities = [];
  double finalPer = 0;
  Future<List<Map<String, dynamic>>> getAllStudents(int staus) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('user')
              .where('type', isEqualTo: '0')
              .where('status', isEqualTo: staus.toString())
              .get();
      List<Map<String, dynamic>> userList = [];
      for (var doc in querySnapshot.docs) {
        userList.add(doc.data());
      }
      return userList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllStudentsData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();
      List<Map<String, dynamic>> userList = [];

      for (var doc in querySnapshot.docs) {
        userList.add(doc.data());
      }

      for (int i = 0; i < userList.length; i++) {
        if (userList[i]['type'] == '0') {
          studentList.add(userList[i]);
          print(studentList);
        }
      }

      return userList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  double pref = 0;
  void getPreferences(String email,
      Map<String, Map<String, List<String>>> preferencesOppo) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot2 = await FirebaseFirestore
        .instance
        .collection('user')
        .doc()
        .collection('CV')
        .where('email', isEqualTo: email)
        .get();

    List<Map<String, dynamic>> preferencesStudent = [];

    if (querySnapshot2.docs.isNotEmpty) {
      for (var data in querySnapshot2.docs) {
        if (data.data().containsKey('pereferences')) {
          preferencesStudent.add(data.data()['pereferences']);
        }
      }
    }

    int matchingPreferences = 0;
    for (var studentPref in preferencesStudent) {
      for (var category in studentPref.keys) {
        if (preferencesOppo.containsKey(category)) {
          for (var type in studentPref[category]!.keys) {
            if (preferencesOppo[category]!.containsKey(type)) {
              for (var item in studentPref[category]![type]!) {
                if (preferencesOppo[category]![type]!.contains(item)) {
                  matchingPreferences++;
                }
              }
            }
          }
        }
      }
    }

    pref = 10 * (matchingPreferences / getTotalPreferences(preferencesOppo));
  }

  int getTotalPreferences(
      Map<String, Map<String, List<String>>> categorizedItems) {
    int total = 0;
    for (var category in categorizedItems.values) {
      for (var type in category.values) {
        total += type.length;
      }
    }
    return total;
  }

  Future<List<Map<String, dynamic>>> getAllopp() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('opportinities').get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> opportunityData = doc.data();
        opportunityData['opportunityId'] = doc.id;

        opportunities.add(opportunityData);
        print(opportunities);
      }

      return opportunities;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> filterByStudentEmail(
      List<Map<String, dynamic>> lm, List<Map<String, dynamic>> studentList) {
    List<Map<String, dynamic>> gg = [];

    for (int i = 0; i < lm.length; i++) {
      for (int j = 0; j < studentList.length; j++) {
        if (lm[i]['email'] == studentList[j]['email']) {
          gg.add({
            'Final': lm[i]['Final'],
            'OpoId': lm[i]['OpoId'],
            'email': lm[i]['email'],
            'oppoName': lm[i]['oppoName'],
          });
          break;
        }
      }
    }

    return gg;
  }

  Future<void> addAllStudentOpp(List<Map<String, dynamic>> bb,
      Map<String, dynamic> st, String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('user')
              .where('email', isEqualTo: email)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs[0].id;

        Map<String, dynamic> dataToUpdate = {'Matching': bb};

        await FirebaseFirestore.instance
            .collection('user')
            .doc(docId)
            .update(dataToUpdate);
      } else {
        print('No user found with email:');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool checkUserPreferences(
      Map<String, Map<String, List<String>>> categorizedItems,
      Map<String, List<String>> userPrefs) {
    for (var categoryEntry in categorizedItems.entries) {
      for (var subCategoryEntry in categoryEntry.value.entries) {
        List<String> conditionItems = subCategoryEntry.value;
        List<String> userItems = userPrefs[subCategoryEntry.key] ?? [];

        if (conditionItems.any((item) => !userItems.contains(item))) {
          return false;
        }
      }
    }
    return true;
  }

  double calculateFinal(
      double fper, List<dynamic> test, Map<String, dynamic> studenttest) {
    for (int i = 0; i < test.length; i++) {
      if (test[i]['name'] == 'GPA') {
        if (int.parse(studenttest['GPA']) >= test[i]['value']) {
          fper += test[i]['percentage'];
        } else {
          fper += (test[i]['percentage'] -
              ((test[i]['value'] - int.parse(studenttest['GPA'])))); //65-65/(5)
        }
      } else if (test[i]['name'] == 'Algorithm') {
        if (int.parse(studenttest['Algorithm']) >= test[i]['value']) {
          fper += test[i]['percentage'];
        } else {
          fper += test[i]['percentage'] -
              ((test[i]['value'] - int.parse(studenttest['Algorithm'])));
        }
      } else if (test[i]['name'] == 'Structure') {
        if (int.parse(studenttest['Structure']) >= test[i]['value']) {
          fper += test[i]['percentage'];
        } else {
          fper += test[i]['percentage'] -
              ((test[i]['value'] - int.parse(studenttest['Structure'])));
        }
      } else if (test[i]['name'] == 'DataBase') {
        if (int.parse(studenttest['DataBase']) >= test[i]['value']) {
          fper += test[i]['percentage'];
        } else {
          fper += test[i]['percentage'] -
              ((test[i]['value'] - int.parse(studenttest['DataBase'])));
        }
      }
    }

    return fper;
  }

  List<Map<String, dynamic>> finalPercentage(
      List<Map<String, dynamic>> gg, Map<String, dynamic> stud) {
    for (int i = 0; i < opportunities.length; i++) {
      String opportunityId = opportunities[i]['opportunityId'];
      List<dynamic> conditions = opportunities[i]['conditions'];
      double finalPer = 0;
      finalPer += calculateFinal(finalPer, conditions, stud);

      if (stud['location'] == opportunities[i]['location'] ||
          opportunities[i]['location'] == 'From Home(Remotly)') {
        finalPer += 10;
      }
      List<dynamic> languagesList = opportunities[i]['Languages'];

      Map<String, Map<String, List<String>>> preferencesMap = {
        'Languages': {
          'PreferredLanguageKey': languagesList.cast<String>().toList(),
        }
      };
      getPreferences(stud['email'], preferencesMap);
      finalPer += pref;
      gg.add({
        'Final': finalPer,
        'OpoId': opportunityId,
        'oppoName': opportunities[i]['name'],
        'email': stud['email']
      });
    }
    return gg;
  }
}
