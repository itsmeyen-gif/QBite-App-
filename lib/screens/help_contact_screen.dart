import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'queue_status_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HelpContactScreen extends StatelessWidget {
  const HelpContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const Text(
              "Help & Contact Us",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),


            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("01. How to use the app?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("1. Log in to your account.\n2. Report items, find lost items or found items.\n3. Choose an available lost or found item.\n4. Handover or get the item.", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 20),
                      Text("02. I didn't receive a confirmation email", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("1. Check your spam folder.\n2. Make sure your email address is correct.", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 20),
                      Text("03. Why is the app not loading properly?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("• Check your internet connection.\n• Close and reopen the app.\n• Update the app to the latest version", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 20),
                      Text("04. Why can't I log in?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Make sure your email and password are correct and check your internet connection. Reset your password if needed.", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 20),
                      Text("Contact us", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("If you need further help, contact us at:\n\nEmail : lostandfoundsupport@gmail.com\nContact Number : 0774801544", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 30),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.groups_outlined, color: Colors.white, size: 30),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QueueStatusScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white, size: 30),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
        ],
      ),
    );
  }
}