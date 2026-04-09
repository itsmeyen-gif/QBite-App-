import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'queue_status_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
              "Privacy & Policy",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "Last Updated : 09/04/2026",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 20),

                      // Section 1
                      const Text(
                        "1. Information We Collect",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "We collect minimal personal data to facilitate your dining experience:",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint("Identity Data: Name and Student/Employee ID for order identification."),
                      _buildBulletPoint("Transactional Data: Details of orders placed and payment status."),
                      _buildBulletPoint("Usage Data: Information on how you use the app to optimize canteen peak-hour flow."),

                      const SizedBox(height: 20),

                      // Section 2
                      const Text(
                        "2. Data Sharing",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Your order details are shared only with the canteen staff and the integrated payment processor. We do not sell your personal data to third-party advertisers.",
                        style: TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "By using this app, you agree to our privacy and policy practices.",
                        style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                      ),
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

  // Helper widget for better bullet point formatting
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
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