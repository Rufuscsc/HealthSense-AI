import 'package:flutter/material.dart';
import 'package:firebasepractice/pages/registration_page.dart';
import 'package:firebasepractice/pages/login_page.dart';

// This widget acts as a "Controller" or "Gatekeeper".
// It doesn't display UI itself, but decides whether to show the Login or Register screen.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  // 1. VARIABLE: Tracks which screen is currently visible.
  // We initialize it to true so the user sees the Login page first.
  bool showLoginPage = true;

  // 2. FUNCTION: Toggles the state.
  // When this function is called, it flips the boolean (true -> false, or false -> true)
  // and triggers a rebuild of the UI (setState).
  void toggleScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 3. LOGIC: Decide which widget to return based on the boolean.
    if(showLoginPage){
      // If true, return the Login Page.
      // IMPORTANT: We pass the 'toggleScreens' function to the LoginPage.
      // This allows the LoginPage (child) to tell this AuthPage (parent) to switch screens.
      return LoginPage(showRegisterPage: toggleScreens);
    }
    else{
      // If false, return the Register Page.
      // We also pass the function here so the user can switch back to Login.
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
