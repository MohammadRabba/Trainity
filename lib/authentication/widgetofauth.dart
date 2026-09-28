import 'package:Trainity/component/Color.dart';
import 'package:flutter/material.dart';

Card customCard(
  TextEditingController controllerText,
  String title,
  TextInputType type,
  void Function()? onTappassword,
  bool isHiddenPassword,
  String? Function(String?)? validator,
) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromARGB(255, 84, 81, 224),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: SizedBox(
          height: 80,
          width: double.infinity,
          child: TextFormField(
            validator: validator,
            obscureText: type == TextInputType.visiblePassword
                ? isHiddenPassword
                : false,
            keyboardType: type,
            cursorColor: Colors.black,
            style: const TextStyle(color: Colors.black),
            controller: controllerText,
            decoration: InputDecoration(
              suffixIcon: type != TextInputType.visiblePassword
                  ? const SizedBox()
                  : InkWell(
                      onTap: onTappassword,
                      child: Icon(
                        isHiddenPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue,
                      ),
                    ),
              filled: true,
              fillColor: Colors.grey[200],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    const BorderSide(color: Color.fromARGB(255, 104, 82, 229)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              hintText: title,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontFamily: 'Cobe',
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

ElevatedButton loginbutton(String title, void Function()? onPressed) {
  return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: globalcolor,
          minimumSize: const Size(250, 50)),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      ));
}
