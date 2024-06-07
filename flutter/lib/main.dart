
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:textsign/firebase_options.dart';
import 'package:textsign/home.dart';
import 'package:textsign/home_switcher.dart';
import 'package:textsign/login.dart';
import 'package:textsign/register.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // primary color \
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeSwitcher(),
        '/home': (context) => HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        
        
      },
    );
  }
}
