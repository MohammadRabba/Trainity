import 'package:Trainity/authentication/login.dart';
import 'package:Trainity/contactUs/contactUs.dart';
import 'package:Trainity/contactUs/privacy.dart';
import 'package:Trainity/contactUs/rateUs.dart';
import 'package:animated_button/animated_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 150, 164, 243),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const UniversityIcon(),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Trainity',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 63, 81, 181),
                      ),
                    ),
                    const SizedBox(height: 10.0),
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
                        pause: Duration(milliseconds: 4000),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    AnimatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) => const LoginPage(),
                            transitionsBuilder: (_, animation, __, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              var curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      color: const Color.fromARGB(255, 63, 81, 181),
                      height: 60,
                      width: 120,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const PrivacySecurityPage();
                                },
                              ),
                            );
                          },
                          child: const Text(
                            'Privacy & Security',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 20,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AnimatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ContactUsScreen();
                      }));
                    },
                    color: Colors.indigo,
                    height: 55,
                    width: 120,
                    child: const Text(
                      'Contact Us',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AnimatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return const RateUsPage();
                      }));
                    },
                    color: const Color.fromARGB(255, 63, 81, 181),
                    height: 55,
                    width: 160,
                    child: const Text(
                      'you like the app?',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.indigo,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              '© 2023 Training University. All rights reserved.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UniversityIcon extends StatefulWidget {
  const UniversityIcon({super.key});

  @override
  _UniversityIconState createState() => _UniversityIconState();
}

class _UniversityIconState extends State<UniversityIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 120.0,
        height: 120.0,
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 60.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
