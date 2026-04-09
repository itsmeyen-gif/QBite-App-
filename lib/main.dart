import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- ADMIN SCREENS ---
import 'package:qq_bite1/screens/login_screen.dart';
import 'package:qq_bite1/screens/signup_screen.dart' as admin;
import 'package:qq_bite1/screens/admin_dashboard.dart';
import 'package:qq_bite1/screens/menu_management.dart';
import 'package:qq_bite1/screens/queue_management.dart';
import 'package:qq_bite1/screens/revenue_screen.dart';
import 'package:qq_bite1/screens/pending_orders.dart';
import 'package:qq_bite1/screens/admin_profile_screen.dart';
import 'package:qq_bite1/screens/admin_settings_screen.dart';

// --- USER SCREENS ---
import 'package:qq_bite1/screens/get_started.dart';
import 'package:qq_bite1/screens/auth_choice.dart';
import 'package:qq_bite1/screens/login_screen_user.dart';
import 'package:qq_bite1/screens/signup_screen_user.dart' as user;
import 'package:qq_bite1/screens/home_screen.dart';
import 'package:qq_bite1/screens/profile_screen.dart';
import 'package:qq_bite1/screens/settings_screen.dart';

// --- COMMON AUTH EXTRAS ---
import 'package:qq_bite1/screens/email_verification_screen.dart';
import 'package:qq_bite1/screens/forget_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const QbiteApp());
}

class QbiteApp extends StatelessWidget {
  const QbiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Q-Bite',

      // Global Theme Settings
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFDF5E6), // Your cream background
        primaryColor: const Color(0xFFF37021),           // Your brand orange
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF37021),
          primary: const Color(0xFFF37021),
          secondary: Colors.orangeAccent,
        ),
        useMaterial3: true,

        // Consistent AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          iconTheme: IconThemeData(color: Color(0xFFF37021)),
        ),
      ),

      // App starts here
      initialRoute: '/get_started',

      routes: {
        // --- Startup & Selection ---
        '/get_started': (context) => const GetStartedPage(),
        '/user_selection': (context) => const AuthChoicePage(),

        // --- Admin Authentication ---
        '/login': (context) => const LoginScreen(),
        '/signup_admin': (context) => const admin.SignupScreen(),

        // --- User Authentication ---
        '/login_user': (context) => const LoginScreenUser(),
        '/signup_user': (context) => const user.SignupScreen(),

        // --- Common Auth Features ---
        '/forgot_password': (context) => const ForgetPasswordScreen(),
        '/verify_email': (context) => const EmailVerificationScreen(email: ''),

        // --- Admin Dashboard & Features ---
        '/dashboard': (context) => const AdminDashboard(),
        '/menu': (context) => const MenuManagement(),
        '/queue': (context) => const QueueManagement(),
        '/revenue': (context) => const RevenueScreen(),
        '/pending_orders': (context) => const PendingOrdersScreen(),
        '/admin_profile': (context) => const AdminProfileScreen(),
        '/admin_settings': (context) => const AdminSettingsScreen(),

        // --- User Core Screens ---
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}