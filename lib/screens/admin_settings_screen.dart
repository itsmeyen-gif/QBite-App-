import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_nav_bar.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool isAcceptingOrders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: const Text("Admin Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Accepting Orders",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Toggle to pause new student orders"),
                  value: isAcceptingOrders,
                  activeColor: const Color(0xFFF37021),
                  onChanged: (val) {
                    setState(() => isAcceptingOrders = val);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Color(0xFFF37021)),
                  title: const Text("Reset Password"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/forgot_password'),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Color(0xFFF37021)),
                  title: const Text("Help & Support"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(currentIndex: 2), // Index 2 for Settings
    );
  }
}