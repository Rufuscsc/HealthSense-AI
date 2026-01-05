import 'package:firebasepractice/auth/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// --- IMPORT YOUR SCREENS ---
import 'pages/onboarding_screen.dart';
import 'package:firebasepractice/pages/home_page.dart';
import 'package:firebasepractice/pages/login_page.dart';
import 'package:firebasepractice/pages/registration_page.dart'; // Ensure filename matches
import 'package:firebasepractice/pages/history_screen.dart';
import 'package:firebasepractice/pages/prediction_result_screen.dart';
import 'package:firebasepractice/pages/profile_screen.dart';
import 'package:firebasepractice/pages/feedback_screen.dart';
import 'package:firebasepractice/pages/symptom_input_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const MyApp());
}

/* -------------------------
   Global App Colors & Theme
   ------------------------- */
const Color primaryBlue = Color(0xFF4C9EFF);
const Color accentGreen = Color(0xFF34C759);

final ThemeData appTheme = ThemeData(
  primaryColor: primaryBlue,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentGreen),
  scaffoldBackgroundColor: Colors.white,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Inter',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    foregroundColor: Colors.black,
  ),
);

/* -------------------------
   Simple in-memory storage
   ------------------------- */
// Place this inside lib/main.dart or your model file

class PredictionEntry {
  final String illness;
  final double confidence;
  final String notes;
  final DateTime timestamp;
  final List<String> symptoms;
  // NEW: List to hold the other 2 probable diseases
  final List<Map<String, dynamic>> otherDiagnoses;

  PredictionEntry({
    required this.illness,
    required this.confidence,
    required this.notes,
    required this.timestamp,
    required this.symptoms,
    this.otherDiagnoses = const [], // Defaults to empty if not provided
  });
}

class InMemoryDB {
  static final List<PredictionEntry> history = [];
  static String currentUserName = 'User';
  static String currentUserEmail = 'user@healthsense.example';
}

/* -------------------------
   Main App Widget
   ------------------------- */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,

      initialRoute: '/onboarding',

      routes: {
        // 1. The Main Auth Wrapper (Decides Login vs Home)
        '/': (context) => const MainPage(),

        // 2. Onboarding Route
        '/onboarding': (context) => const OnboardingScreen(),

        // 3. Login Route (Standalone)
        '/login': (context) => LoginPage(
          showRegisterPage: () {
            Navigator.pushNamed(context, '/register');
          },
        ),

        // 4. Register Route (FIXED NAVIGATION HERE)
        '/register': (context) => RegisterPage(
          showLoginPage: () {
            // Check if we can just go back
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If we can't pop, force navigation to the Main Page (Login)
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),

        // 5. Home/Dashboard Route
        '/home': (context) => const HomePage(),

        // Other routes
        '/symptoms': (context) => const SymptomInputScreen(),
        '/result': (context) => const PredictionResultScreen(),
        '/history': (context) => const HistoryScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}