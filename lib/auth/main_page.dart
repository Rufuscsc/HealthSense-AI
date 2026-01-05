import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasepractice/pages/home_page.dart';
import 'package:firebasepractice/pages/login_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // 1. The Stream: Listens for login/logout events
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 2. The Logic: If user data exists, they are logged in
          if (snapshot.hasData) {
            return HomePage();
          }
          // 3. The Logic: If no data, they are logged out
          else {
            return LoginPage(
              showRegisterPage: () {
                Navigator.pushNamed(context, '/register');
              },
            );
          }
        },
      ),
    );
  }
}
