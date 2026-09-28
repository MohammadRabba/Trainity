import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  _MainPageCompanyState createState() => _MainPageCompanyState();
}

class _MainPageCompanyState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school,
                  size: 100,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                SizedBox(height: 30.0),
                Text(
                  'Welcome to Our App!',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.0),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 22.0,
                    color: Colors.white,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText('Explore New Opportunities'),
                      TyperAnimatedText('Unlock Your Potential'),
                      TyperAnimatedText('Dream Big, Work Hard'),
                      TyperAnimatedText('Build Confidence and Competence'),
                      TyperAnimatedText('Learn, Adapt, Grow'),
                      TyperAnimatedText('Stay Positive, Stay Persistent'),
                      TyperAnimatedText('Dream, Believe, Achieve'),
                      TyperAnimatedText('Discover Your Path to Success'),
                      TyperAnimatedText(
                          'Never Stop Learning, Never Stop Growing'),
                    ],
                    repeatForever: true,
                    pause: Duration(milliseconds: 1000),
                  ),
                ),
                SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
