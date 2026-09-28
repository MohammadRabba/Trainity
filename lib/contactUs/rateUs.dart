import 'package:Trainity/authentication/beforBegin.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateUsPage extends StatefulWidget {
  const RateUsPage({super.key});

  @override
  _RateUsPageState createState() => _RateUsPageState();
}

class _RateUsPageState extends State<RateUsPage> {
  double _rating = 5;
  String _feedback = '';
  final TextEditingController _feedbackController = TextEditingController();
  void submitFeedback() async {
    if (_rating < 5) {
      if (_feedback.isEmpty) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'You Have to fill all Fields',
          btnOkOnPress: () {},
        ).show();
      } else {
        await FirebaseFirestore.instance.collection('feedback').add({
          'rating': _rating,
          'feedback': _feedback,
          'timestamp': DateTime.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return WelcomePage();
            },
          ),
        );
      }
    } else {
      await FirebaseFirestore.instance.collection('feedback').add({
        'rating': _rating,
        'timestamp': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return WelcomePage();
          },
        ),
      );
    }
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
          'Rate US',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate us:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              _rating < 2.5 ? 'Tell us why?' : 'Thank you for your feedback!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _rating < 2.5 ? Colors.red : Colors.green,
              ),
            ),
            if (_rating < 2.5)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextField(
                  controller: _feedbackController,
                  onChanged: (value) {
                    setState(() {
                      _feedback = value;
                    });
                  },
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter your feedback',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                submitFeedback();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
