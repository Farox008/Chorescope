import 'package:appp/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:appp/global/common/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';
import 'nav.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:firebase_auth/firebase_auth.dart';
///import 'package:google_sign_in/google_sign_in.dart';

class MySignIn extends StatefulWidget {
  const MySignIn({super.key});

  @override
  State<MySignIn> createState() => _MySignInState();
}

class _MySignInState extends State<MySignIn> {
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _isPasswordVisible = false;

  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final _usernameController = TextEditingController();
  final _email = TextEditingController();
  final _passwordController1 = TextEditingController();
  final _passwordController = TextEditingController();

  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 245, 242),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                "Sign Up",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 106, 10, 10)),
              ),
              Text(
                "Create Your Account",
                style: TextStyle(
                    fontSize: 12, color: const Color.fromARGB(255, 148, 0, 0)),
              ),
              const SizedBox(height: 50),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Username",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                            fillColor: const Color.fromARGB(255, 106, 2, 2)
                                .withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.person)),
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                            fillColor: const Color.fromARGB(255, 106, 2, 2)
                                .withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.email)),
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Email id';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid Email ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: const Color.fromARGB(255, 100, 12, 5)
                              .withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.password),
                          labelText: 'Password',
                        ),
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController1,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: const Color.fromARGB(255, 100, 12, 5)
                              .withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.password),
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signUp(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              const Color.fromARGB(255, 73, 30, 17),
                          fixedSize: Size(200, 60),
                        ),
                        icon: const Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                        label: _isSignUp
                            ? CircularProgressIndicator(
                                color: const Color.fromARGB(255, 255, 255, 255),
                              )
                            : const Text('    Sign Up   ',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 245, 245, 245))),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text('Or'),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "already have an account? ",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 110, 9, 9)),
                          ),
                          TextButton(
                              onPressed: () {
                                goToLogin(context);
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 95, 9, 9)),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> storeUserData(String username, String email) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in!");
      return;
    }

    // Convert email to Firestore-safe ID
    String userId = user.email!.replaceAll('.', '_');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('details')
        .add({
      "username": username,
      "email": email,
    });
  }

  void goToLogin(BuildContext ctx) async {
    Navigator.of(ctx).pushReplacement(
      MaterialPageRoute(builder: (ctx) => const MyLogin()),
    );
  }

  void signUp(BuildContext ctx) async {
    setState(() {
      _isSignUp = true;
    });
    String username = _usernameController.text;
    String password1 = _passwordController1.text;
    String email = _email.text;
    String password = _passwordController.text;
    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    setState(() {
      _isSignUp = false;
    });
    if (user != null) {
      if (password1 == password) {
        await storeUserData(username, email);

        showToast(message: 'successfully signed up');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const Nav()),
        );
      } else {
        showToast(message: 'PassWord Does Not Match');
      }
    } else {
      showToast(message: 'Error !! Check Details ');
      print('error');
    }
  }
}
