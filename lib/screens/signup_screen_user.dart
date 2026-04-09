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
  bool _isAgreed = false;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  Future<void> _handleSignUp() async {
    final String selectedRole = ModalRoute.of(context)!.settings.arguments as String? ?? 'user';

    if (!_isAgreed) {
      _showSnackBar("Please agree to the Terms & Conditions");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match!");
      return;
    }
    if (nameController.text.isEmpty || emailController.text.isEmpty || idController.text.isEmpty) {
      _showSnackBar("Please fill in all required fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String collectionName = selectedRole == 'admin' ? 'admins' : 'users';

      await FirebaseFirestore.instance.collection(collectionName).doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        selectedRole == 'admin' ? 'adminId' : 'studentId': idController.text.trim(),
        'contactNo': contactController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: emailController.text.trim()),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "An error occurred");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: const Color(0xFFF37021))
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    idController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String? ?? 'user';
    String idLabel = role == 'admin' ? "Admin ID :" : "Student ID :";

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
            Hero(
              tag: 'logo',
              child: Image.asset('assets/mainlogo.png', height: 100),
            ),
            const SizedBox(height: 10),
            Text(
              "${role[0].toUpperCase()}${role.substring(1)} Sign Up",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            _buildInputField("Full Name :", "Erica Blu", nameController),
            _buildInputField("Email :", "example@gmail.com", emailController),
            _buildInputField(idLabel, "123456789", idController),
            _buildInputField("Password :", "****************", passwordController, isPassword: true),
            _buildInputField("Confirm Password :", "****************", confirmPasswordController, isPassword: true),
            _buildInputField("Contact No :", "07283689938", contactController),
            Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  activeColor: const Color(0xFFF37021),
                  onChanged: (value) => setState(() => _isAgreed = value!),
                ),
                const Expanded(
                  child: Text("I agree to the Terms & Conditions", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator(color: Color(0xFFF37021))
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF37021),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text("SIGN UP",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26),
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}