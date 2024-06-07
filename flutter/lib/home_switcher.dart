// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:textsign/home.dart';
import 'package:textsign/login.dart';

class HomeSwitcher extends StatelessWidget {
  const HomeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (builder, snapshot) {
      if(snapshot.hasData){
        return HomeScreen();
      }else{
        return LoginScreen();
      }
      })
    );
  }
}