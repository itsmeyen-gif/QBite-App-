import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      _navigateToDashboard();
    }
  }

  Future<void> _navigateToDashboard() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();

    if (mounted) {
      if (userDoc.exists) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: Center( // Centers the entire column on the screen
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers children vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Centers children horizontally
            children: [
              const Icon(
                  Icons.email_outlined,
                  size: 120, // Slightly larger for a better hero-feel
                  color: Color(0xFFF37021)
              ),
              const SizedBox(height: 40),

              const Text(
                  "Verify your Email",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins' // Using your project font
                  )
              ),
              const SizedBox(height: 20),

              Text(
                "We've sent a verification link to:\n${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5 // Adds a little line spacing
                ),
              ),
              const SizedBox(height: 50),

              const CircularProgressIndicator(
                color: Color(0xFFF37021),
                strokeWidth: 3,
              ),
              const SizedBox(height: 30),

              const Text(
                  "Checking automatically...",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => FirebaseAuth.instance.currentUser?.sendEmailVerification(),
                child: const Text(
                    "Resend Email",
                    style: TextStyle(
                        color: Color(0xFFF37021),
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}