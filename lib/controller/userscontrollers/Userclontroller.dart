import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('user').doc(userId).get();
      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (error) {
      print('Error fetching user data: $error');
      rethrow;
    }
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
      print('User profile updated successfully');
    } catch (error) {
      print('Error updating user profile: $error');
      rethrow;
    }
  }
}
