import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/view/company/showorder.dart';
import 'package:Trainity/view/student/oldorder.dart';
import 'package:Trainity/view/student/showtraining.dart';
import 'package:Trainity/view/supervisor/SupervisorShoworder.dart';

class notification {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> handleMessage(RemoteMessage message) async {}

  void subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  void unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void onMessage(Function onMessageCallback) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        onMessageCallback(message.notification!);
      }
    });
  }

  void onLaunch(Function onLaunchCallback) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onLaunchCallback(message);
    });
  }

  void onResume(Function onResumeCallback) {
    FirebaseMessaging.onBackgroundMessage((message) async {
      onResumeCallback(message);
    });
  }

  initInfo() {
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {});
  }

  Future<String> getToken(String status) async {
    await FirebaseMessaging.instance.getToken().then((token) {
      mytoken = token!;
      saveToken(token, status);
    });
    return mytoken;
  }

  Future<void> saveCompanyToken(String token) async {
    QuerySnapshot<Map<String, dynamic>> tokenSnapshot = await FirebaseFirestore
        .instance
        .collection('tokens')
        .doc('company')
        .collection('tokens')
        .where('token', isEqualTo: token)
        .where('uid', isEqualTo: myid)
        .get();

    if (tokenSnapshot.docs.isEmpty && token != '' && token != '0') {
      await FirebaseFirestore.instance
          .collection('tokens')
          .doc('company')
          .collection('tokens')
          .doc()
          .set({'token': token, 'uid': myid});
    }
  }

  Widget getWidgetFromPayload(String payload) {
    if (payload == 'SuperVisorShowOrder') {
      return const SuperVisorShowOrder();
    } else if (payload == 'OldOrder') {
      return const OldOrder();
    } else if (payload == 'ShowOrder') {
      return const ShowOrder();
    } else if (payload == 'ShowTraining') {
      return const ShowTraining();
    }
    return Container();
  }

  Future<void> getNotificationsCounter(String id) async {
    if (id == '') {
    } else {
      DocumentSnapshot notSnap = await FirebaseFirestore.instance
          .collection('user')
          .doc(id)
          .collection('notifications')
          .doc('counter')
          .get();
      if (notSnap.exists) {
        notificationNum = notSnap['counter'];
      }
    }
  }

  Future<void> resetNote(String id) async {
    int counter = 0;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(id)
        .collection('notifications')
        .doc('counter')
        .get();

    if (doc.exists) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(id)
          .collection('notifications')
          .doc('counter')
          .update({'counter': counter});
    } else {
      FirebaseFirestore.instance
          .collection('user')
          .doc(id)
          .collection('notifications')
          .doc('counter')
          .set({'counter': counter});
    }
  }

  Future<void> addNote(
    String id,
    String title,
    String body,
    String payload,
  ) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(id)
        .collection('notifications')
        .doc()
        .set({
          'title': title,
          'body': body,
          'payload': payload,
          'time': FieldValue.serverTimestamp(),
        });
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(id)
        .collection('notifications')
        .doc('counter')
        .get();
    if (doc.exists) {
      if (doc.get('counter') != null) {
        int counter = (doc.get('counter')) ?? 0;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(id)
            .collection('notifications')
            .doc('counter')
            .update({'counter': counter + 1});
      } else {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(id)
            .collection('notifications')
            .doc('counter')
            .set({'counter': 1});
      }
    } else {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(id)
          .collection('notifications')
          .doc('counter')
          .set({'counter': 1});
    }
  }

  Future<String> fetchUserToken(String userId) async {
    try {
      String token = '';
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data();
        if (userData != null) {
          token = userSnapshot['token'];
        }
      }
      return token;
    } catch (e) {
      return '';
    }
  }

  Future<void> sendNote(
    String token,
    String title,
    String body,
    String payload,
  ) async {
    Dio dio = Dio();
    String logo = 'resource://drawable/logo2';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=AAAAU*****',
    };
    final data = {
      "to": token,
      "notification": {
        "title": title,
        "body": body,
        "payload": payload,
        "icon": logo,
      },
    };
    try {
      var response = await dio.post(
        'https://fcm.googleapis.com/fcm/send',
        data: data,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print("await response.data");
      } else {
        print(response.statusMessage);
      }
    } catch (e) {}
  }

  Future<void> saveSupervisorToken(String token) async {
    QuerySnapshot<Map<String, dynamic>> tokenSnapshot = await FirebaseFirestore
        .instance
        .collection('tokens')
        .doc('supervisor')
        .collection('tokens')
        .where('token', isEqualTo: token)
        .where('uid', isEqualTo: myid)
        .get();

    if (tokenSnapshot.docs.isEmpty && token != '' && token != '0') {
      await FirebaseFirestore.instance
          .collection('tokens')
          .doc('supervisor')
          .collection('tokens')
          .doc()
          .set({'token': token, 'uid': myid});
    }
  }

  Future<String> getUserToken(String id) async {
    QuerySnapshot<Map<String, dynamic>> tokenSnapshot = await FirebaseFirestore
        .instance
        .collection('tokens')
        .where('uid', isEqualTo: id)
        .get();

    String tokens = '';
    if (tokenSnapshot.docs.isNotEmpty) {
      tokens = tokenSnapshot.docs
          .map((doc) => doc.get('token').toString())
          .join(', ');
    }

    return tokens;
  }

  Future<List<Map<String, dynamic>>> getStudentsToken() async {
    QuerySnapshot<Map<String, dynamic>> tokenSnapshot = await FirebaseFirestore
        .instance
        .collection('tokens')
        .doc('student')
        .collection('tokens')
        .get();

    List<Map<String, dynamic>> tokens = [];
    if (tokenSnapshot.docs.isNotEmpty) {
      tokens = tokenSnapshot.docs.map((doc) {
        String token = doc.get('token');
        String uid = doc.get('uid');

        return {'token': token, 'uid': uid};
      }).toList();
    }
    print(tokens);
    return tokens;
  }

  Future<void> saveStudentToken(String token) async {
    QuerySnapshot<Map<String, dynamic>> tokenSnapshot = await FirebaseFirestore
        .instance
        .collection('tokens')
        .doc('student')
        .collection('tokens')
        .where('token', isEqualTo: token)
        .where('uid', isEqualTo: myid)
        .get();

    if (tokenSnapshot.docs.isEmpty && token != '' && token != '0') {
      await FirebaseFirestore.instance
          .collection('tokens')
          .doc('student')
          .collection('tokens')
          .doc()
          .set({'token': token, 'uid': myid});
    }
  }

  Future<void> saveToken(String token, String status) async {
    CollectionReference tokenCollection = FirebaseFirestore.instance.collection(
      'tokens',
    );

    QuerySnapshot tokenQuery = await tokenCollection
        .where('token', isEqualTo: token)
        .where('uid', isEqualTo: myid)
        .get();
    List<DocumentSnapshot> tokenDocs = tokenQuery.docs;

    if (tokenDocs.isEmpty && token != '' && token != '0') {
      await tokenCollection.add({'token': token, 'uid': myid});
    } else if (token != '' && token != '0') {
      DocumentSnapshot tokenDoc = tokenDocs.first;
      await tokenDoc.reference.update({'token': token, 'uid': myid});
    }
    if (status == '1') {
      saveCompanyToken(token);
    } else if (status == '2') {
      saveSupervisorToken(token);
    } else if (status == '0') {
      saveStudentToken(token);
    }
  }
}
