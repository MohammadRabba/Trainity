import 'package:Trainity/authentication/beforBegin.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  ContactUsScreen({super.key});

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
          'Contact Us',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                String message = _messageController.text.trim();

                if (!EmailValidator.validate(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please enter a valid email address"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // AwesomeDialog(
                  //   context: context,
                  //   dialogType: DialogType.error,
                  //   animType: AnimType.bottomSlide,
                  //   title: 'Invalid Email Address',
                  //   desc: 'Please enter a valid email address.',
                  //   btnOkOnPress: () {},
                  // ).show();
                } else if (message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in the message field'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.bottomSlide,
                    title: 'Empty Message',
                    desc: 'Please fill in the message field.',
                    btnOkOnPress: () {},
                  ).show();
                } else {
                  await FirebaseFirestore.instance
                      .collection('contactUs')
                      .doc()
                      .set({
                    'email': _emailController.text,
                    'message': _messageController.text,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Form submitted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _emailController.clear();
                  _messageController.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return WelcomePage();
                      },
                    ),
                  );
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatarWithNavigation(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FirstPage()),
                    );
                  },
                  imagePath: "assets/images/yazan1.jpg",
                  name: 'Yazan',
                ),
                CircleAvatarWithNavigation(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecondPage()),
                    );
                  },
                  imagePath: "assets/images/rabba1.jpg",
                  name: 'Rabba',
                ),
                CircleAvatarWithNavigation(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ThirdPage()),
                    );
                  },
                  imagePath: "assets/images/ashraf1.jpg",
                  name: 'Ashraf',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircleAvatarWithNavigation extends StatelessWidget {
  final VoidCallback onTap;
  final String imagePath;
  final String name;

  const CircleAvatarWithNavigation({
    super.key,
    required this.onTap,
    required this.imagePath,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            name,
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

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
          'Yazan M Alamleh',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 50),
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildSocialIcons(),
            const SizedBox(height: 20),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/yazan2.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage("assets/images/yazan1.jpg"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "Yazan Al-amleh",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Android Developer",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(FontAwesomeIcons.facebook,
            "https://www.facebook.com/profile.php?id=100009541553000"),
        _buildSocialIcon(FontAwesomeIcons.github, "your_github_url"),
        _buildSocialIcon(FontAwesomeIcons.whatsapp, "your_whatsapp_url"),
        _buildSocialIcon(FontAwesomeIcons.linkedin, "your_linkedin_url"),
      ],
    );
  }

  Widget _buildSocialIcon(IconData iconData, String url) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue,
          child: Icon(
            iconData,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "As a Flutter developer, I thrive at crafting elegant and efficient cross-platform applications. My code is a fusion of creativity and precision, resulting in seamless user experiences. With a solid foundation in Dart programming and a knack for UI/UX design, I specialize in building dynamic, responsive, and visually appealing apps. My commitment to continuous learning and staying updated with the latest Flutter trends enables me to deliver top-notch solutions that meet user needs and exceed expectations. Let's turn ideas into innovative realities together.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    try {
      if (await canLaunch(Uri.encodeFull(url))) {
        await launch(Uri.encodeFull(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

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
          'Mohammad rabba',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 50),
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildSocialIcons(),
            const SizedBox(height: 20),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/rabba2.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage("assets/images/rabba1.jpg"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "Mohammad Rabba",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Android Developer",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(FontAwesomeIcons.facebook,
            "https://www.facebook.com/profile.php?id=100009704054491"),
        _buildSocialIcon(FontAwesomeIcons.github, "your_github_url"),
        _buildSocialIcon(FontAwesomeIcons.whatsapp, "your_whatsapp_url"),
        _buildSocialIcon(FontAwesomeIcons.linkedin, "your_linkedin_url"),
      ],
    );
  }

  Widget _buildSocialIcon(IconData iconData, String url) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue,
          child: Icon(
            iconData,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "As a Flutter developer, I thrive at crafting elegant and efficient cross-platform applications. My code is a fusion of creativity and precision, resulting in seamless user experiences. With a solid foundation in Dart programming and a knack for UI/UX design, I specialize in building dynamic, responsive, and visually appealing apps. My commitment to continuous learning and staying updated with the latest Flutter trends enables me to deliver top-notch solutions that meet user needs and exceed expectations. Let's turn ideas into innovative realities together.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

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
          'Ashraf Mtor',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 50),
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildSocialIcons(),
            const SizedBox(height: 20),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/ashtaf2.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage("assets/images/ashraf1.jpg"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "Ashraf Mtor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Android Developer",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
            FontAwesomeIcons.facebook, "https://www.facebook.com/ashraf.mtour"),
        _buildSocialIcon(FontAwesomeIcons.github, "your_github_url"),
        _buildSocialIcon(FontAwesomeIcons.whatsapp, "your_whatsapp_url"),
        _buildSocialIcon(FontAwesomeIcons.linkedin, "your_linkedin_url"),
      ],
    );
  }

  Widget _buildSocialIcon(IconData iconData, String url) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue,
          child: Icon(
            iconData,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "As a Flutter developer, I thrive at crafting elegant and efficient cross-platform applications. My code is a fusion of creativity and precision, resulting in seamless user experiences. With a solid foundation in Dart programming and a knack for UI/UX design, I specialize in building dynamic, responsive, and visually appealing apps. My commitment to continuous learning and staying updated with the latest Flutter trends enables me to deliver top-notch solutions that meet user needs and exceed expectations. Let's turn ideas into innovative realities together.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
