import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCompany extends StatefulWidget {
  const AddCompany({super.key});

  @override
  AddCompanyState createState() => AddCompanyState();
}

class AddCompanyState extends State<AddCompany> {
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _zipCodeController;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _idController = TextEditingController();
    _addressController = TextEditingController();
    _zipCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
    } catch (e) {
      print('Password reset error: $e');
    }
  }

  Future<void> _signUpWithEmailAndPassword() async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: generateRandomPassword(length: 10));

        if (userCredential.user != null) {
          await userCredential.user?.sendEmailVerification();

          await _createUserProfile(userCredential.user!.uid);
          sendPasswordResetEmail(_emailController.text);

          print('Sign up successful: ${userCredential.user!.uid}');
        }
      }
    } catch (e) {
      print('Sign up error: $e');
    }
  }

  String generateRandomPassword({int length = 8}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  Future<void> _createUserProfile(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .set({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
            'zipCode': _zipCodeController.text,
            'address': _addressController.text,
            'type': "1",
            'photo': '',
            'token': '',
          })
          .then((value) => AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.bottomSlide,
                title: 'SignUp  succssfully',
                btnOkOnPress: () {},
              )..show())
          .catchError((error) => AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.bottomSlide,
                title: 'Failed to SignUp',
                btnOkOnPress: () {},
              )..show());
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !EmailValidator.validate(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name.';
    }
    RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]{2,}$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Please enter more than 2 letters and no number.';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Please enter your address.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    RegExp regex = RegExp(r'^[0-9]+$');
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number.';
    } else if (!regex.hasMatch(value)) {
      return 'Please enter a valid phone number .';
    } else if (value.trim().length != 9 && value.trim().length != 10) {
      return 'phone length must be 9 or 10  .';
    }
    return null;
  }

  String? _validateZipCode(String? value) {
    RegExp regex = RegExp(r'^[0-9]+$');
    if (value == null || value.trim().isEmpty) {
      return null;
    } else if (!regex.hasMatch(value) || value.length < 2) {
      return 'Please enter a valid ZIP Code.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Sign Up Company',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_nameController, 'Full Name', Icons.business,
                      _validateName),
                  _buildTextField(_phoneController, 'Phone Number', Icons.phone,
                      _validatePhone),
                  _buildTextField(
                      _emailController, 'Email', Icons.email, _validateEmail),
                  _buildTextField(_addressController, 'Company Address',
                      Icons.location_city, _validateAddress),
                  _buildTextField(_zipCodeController, 'Company ZIP Code',
                      Icons.map, _validateZipCode),
                  const SizedBox(height: 20.0),
                  _buildElevatedButton(_signUpWithEmailAndPassword, 'Sign Up'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String? Function(String?) validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 114, 67, 245)),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 60, 21, 177), width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildElevatedButton(VoidCallback onPressed, String text,
      [Color? buttonColor]) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: buttonColor ?? Colors.indigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
