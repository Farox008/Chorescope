import 'package:appp/global/common/toast.dart';
import 'package:appp/screen/forgot_pw.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nav.dart';
import 'sign_up.dart';
import 'package:appp/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const SAVE_KEY_NAME = '_userLoggedIn';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  bool _isSigning = false;
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final _email = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    _passwordController.dispose();
    _email.dispose();
    super.dispose();
  }

  bool _isPasswordVisible = false; // For toggling password visibility
  final _formKey = GlobalKey<FormState>();
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
                "Welcome Back",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 106, 10, 10)),
              ),
              Text(
                "Enter Your credentials To Login",
                style: TextStyle(
                    fontSize: 15, color: const Color.fromARGB(255, 148, 0, 0)),
              ),
              const SizedBox(height: 30),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
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
                          labelText: 'Password',
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
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (ctx) => const ForgotPass()),
                          );
                        },
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                              color: Color.fromARGB(255, 132, 11, 11)),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          label: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color.fromARGB(255, 245, 245, 245),
                              fontSize: 16, // Adjust font size to match
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signIn();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                const Color.fromARGB(255, 73, 30, 17),
                          ),
                          icon: const Icon(
                            Icons.login,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            signUpWithGoogle();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                const Color.fromARGB(255, 73, 30, 17),
                          ),
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center text and image
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text(
                                'Login With Google',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 245, 245, 245),
                                  fontSize: 16, // Match font size
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                radius: 20,
                                child: Image.asset(
                                  'assets/images/google-removebg-preview.png',
                                ),
                              ),
                            ],
                          ),
                          icon: const SizedBox
                              .shrink(), // Empty icon to balance the structure
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Dont have an account? ",
                            style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(255, 148, 0, 0)),
                          ),
                          TextButton(
                              onPressed: () {
                                goTosignin(context);
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 149, 34, 3)),
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

  Future<String?> getUsername(String email) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists) {
        return userDoc['username'];
      } else {
        print("No user found with this email: $email");
        return null;
      }
    } catch (e) {
      print("Firestore Error: $e");
      return null;
    }
  }

  void goTosignin(BuildContext ctx) async {
    Navigator.of(ctx).pushReplacement(
      MaterialPageRoute(builder: (ctx) => const MySignIn()),
    );
  }

  void signIn() async {
    setState(() {
      _isSigning = true;
    });
    //String username = _usernameController.text;
    String email = _email.text;
    String password = _passwordController.text;
    User? user = await _auth.signInWithEmailAndPassword(email, password);
    setState(() {
      _isSigning = false;
    });
    if (user != null) {
      String? username = await getUsername(user.email!);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username ?? '');
      //showToast(message: ' successfulllyy logged in');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const Nav()),
      );
    } else {
      showToast(message: 'Incorrect Credentials');
    }
  }

  void signUpWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: "YOUR_CLIENT_ID",
      scopes: ['email'],
    );
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
      }
    } catch (e) {
      showToast(message: 'errrrrorrr ${e}');
      print('errrrrorrr ${e}');
    }
  }
}
