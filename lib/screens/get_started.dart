import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using your brand cream color
      backgroundColor: const Color(0xFFFDF5E6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with a simple Hero tag for smooth transitions
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/mainlogo.png',
                  height: 250, // Adjusted slightly for better scaling
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Q-Bite',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
              ),

              const Text(
                'Canteen Queue Management App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 80),

              // THE UPDATED BUTTON
              SizedBox(
                width: double.infinity, // Makes button nice and wide like Figma
                child: ElevatedButton(
                  onPressed: () {
                    // UPDATED: Using Named Route for the selection screen
                    Navigator.pushNamed(context, '/user_selection');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37021), // Your brand orange
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 5,
                    shadowColor: Colors.orange.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}