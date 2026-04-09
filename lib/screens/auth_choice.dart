import 'package:flutter/material.dart';
// We give these nicknames (as admin/user) to stop the name conflict
import 'signup_screen.dart' as admin;
import 'signup_screen_user.dart' as user;
import 'login_screen_user.dart';
import 'login_screen.dart';

class AuthChoicePage extends StatefulWidget {
  const AuthChoicePage({super.key});

  @override
  State<AuthChoicePage> createState() => _AuthChoicePageState();
}

class _AuthChoicePageState extends State<AuthChoicePage> {
  String selectedRole = 'user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset('assets/mainlogo.png', height: 180),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _roleButton("User", 'user'),
                    _roleButton("Admin", 'admin'),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _feature("Save Time", "See live queue times before you arrive", Icons.timer),
              _feature("Food Updates", "Know which meals are available!", Icons.fastfood),
              _feature("Queue Together", "Invite friends and join the same queue.", Icons.group),

              const SizedBox(height: 40),

              _actionButton("SIGN IN", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => selectedRole == 'user'
                        ? const LoginScreenUser()
                        : const LoginScreen(),
                    settings: RouteSettings(arguments: selectedRole),
                  ),
                );
              }),

              const SizedBox(height: 15),

              _actionButton("SIGN UP", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // FIXED: Using the nicknames to point to the right class
                    builder: (context) => selectedRole == 'user'
                        ? const user.SignupScreen()
                        : const admin.SignupScreen(),
                    settings: RouteSettings(arguments: selectedRole),
                  ),
                );
              }, outline: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String text, String role) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _feature(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onPress, {bool outline = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: outline ? Colors.white : Colors.orange,
          side: outline ? const BorderSide(color: Colors.orange) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: outline ? Colors.orange : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}