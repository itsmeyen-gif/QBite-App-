import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // UPDATED: Default value to match your specific restaurants
  String selectedRestaurant = 'Serenity';
  bool _isLoading = false;

  Future<void> _handleAdminSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match!");
      return;
    }
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      _showSnackBar("Please fill in all required fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Saves the specific restaurant name to the 'admins' table
      await FirebaseFirestore.instance.collection('admins').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'restaurantName': selectedRestaurant, // Saves e.g., "Uni Cafe"
        'contactNo': _contactController.text.trim(),
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Signup failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFF37021)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Hero(
                tag: 'logo',
                child: Image(image: AssetImage('assets/mainlogo.png'), height: 80),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Admin Registration",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 25),
            _buildInputField("Full Name :", "Erica Blu", controller: _nameController),
            _buildInputField("Email :", "admin@canteen.com", controller: _emailController),

            const Text("Restaurant Name:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRestaurant,
                  isExpanded: true,
                  // UPDATED: The 4 specific restaurants
                  items: ['Serenity', 'Uni Cafe', 'Remarko', 'Heko Beko'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) => setState(() => selectedRestaurant = newValue!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField("Password :", "******", isPassword: true, controller: _passwordController),
            _buildInputField("Confirm Password :", "******", isPassword: true, controller: _confirmPasswordController),
            _buildInputField("Contact No :", "07283689938", controller: _contactController),
            const SizedBox(height: 30),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFF37021))
                  : SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleAdminSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37021),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("REGISTER ADMIN",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {bool isPassword = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
}