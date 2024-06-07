// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:textsign/sign/sign_to_text.dart';
import 'package:textsign/sign/speech_to_sign.dart';
import 'package:textsign/sign/textsign.dart';
import 'package:textsign/login.dart';
import 'package:textsign/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Sign Language',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            }, icon: Icon(Icons.logout),
          )
        ]

        //...
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignToTextLanguage(),
                  ),
                );
              },
              child: Text('Translates Arabic Sign language To Text'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpeechToSignLanguage(),
                  ),
                );
              },
              child: Text('Translates Speech To English Sign Language'),
            ),
                       const SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextToSignLanguage(),
                  ),
                );
              },
              child: Text('Translates Text To English Sign Language'),
            ),
          ],
        ),
      ),
         );
  }
}