import 'package:firebasepractice/auth/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'pages/onboarding_screen.dart';
import 'package:firebasepractice/pages/home_page.dart';
import 'package:firebasepractice/pages/login_page.dart';
import 'package:firebasepractice/pages/registration_page.dart';
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
class PredictionEntry {
  final String illness;
  final double confidence;
  final String notes;
  final DateTime timestamp;
  final List<String> symptoms;
  final List<Map<String, dynamic>> otherDiagnoses;

  PredictionEntry({
    required this.illness,
    required this.confidence,
    required this.notes,
    required this.timestamp,
    required this.symptoms,
    this.otherDiagnoses = const [],
  });
}

class InMemoryDB {
  static final List<PredictionEntry> history = [];
  static String currentUserName = 'User';
  static String currentUserEmail = 'user@healthsense.example';
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/onboarding',
      routes: {
        '/': (context) => const MainPage(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => LoginPage(
          showRegisterPage: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
        '/register': (context) => RegisterPage(
          showLoginPage: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
        '/home': (context) => const HomePage(),
        '/symptoms': (context) => const SymptomInputScreen(),
        '/result': (context) => const PredictionResultScreen(),
        '/history': (context) => const HistoryScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}