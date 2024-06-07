
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
   const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

    final formKey = GlobalKey<FormState>();

  Future register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered!'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: emailController,
                                            keyboardType: TextInputType.emailAddress,

                  validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            } else if (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                  
                  decoration: const InputDecoration(
                    labelText: 'Email',
                     contentPadding: EdgeInsets.all(5),
                            
                  ),
                ),
                
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'Please Enter Password';
                            }
                            return null;
                          },
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: confirmPasswordController,
                   validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Repeat Password';
                            } else if (confirmPasswordController.text !=
                                passwordController.text) {
                              return 'Password does not match';
                            }
                            return null;
                          },
                  decoration: const InputDecoration(
                    labelText: 'Password Confirmation',
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 10.0),
                InkWell(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.purple, // Change to your preferred color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () => register(),
                      child: const Center(
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
