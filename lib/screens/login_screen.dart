import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // UPDATED: Match the Signup list
  String selectedRestaurant = 'Serenity';
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Security Check: Verify Admin exists in Firestore
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();

      if (adminDoc.exists) {
        // 3. NEW: Logic check - Does the selected restaurant match the Admin's registered one?
        String registeredRestaurant = adminDoc.get('restaurantName');

        if (registeredRestaurant == selectedRestaurant) {
          if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // Wrong restaurant selected!
          await FirebaseAuth.instance.signOut();
          _showError("Access Denied: You are not the Admin for $selectedRestaurant");
        }
      } else {
        await FirebaseAuth.instance.signOut();
        _showError("Access Denied: You are not registered as an Admin.");
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFF37021)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF37021)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Hero(tag: 'logo', child: Image.asset('assets/mainlogo.png', height: 120)),
            const SizedBox(height: 20),
            const Text("Admin Login", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const Text("Access your restaurant dashboard", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 40),

            _buildFieldLabel("Select Restaurant"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRestaurant,
                  isExpanded: true,
                  // UPDATED: The 4 specific restaurants
                  items: ['Serenity', 'Uni Cafe', 'Remarko', 'Heko Beko']
                      .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (newValue) => setState(() => selectedRestaurant = newValue!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel("Email Address"),
            const SizedBox(height: 10),
            _buildTextField(emailController, "admin@canteen.com", false),
            const SizedBox(height: 20),
            _buildFieldLabel("Password"),
            const SizedBox(height: 10),
            _buildTextField(passwordController, "********", true),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF37021),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)));

  Widget _buildTextField(TextEditingController controller, String hint, bool isObscure) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }
}