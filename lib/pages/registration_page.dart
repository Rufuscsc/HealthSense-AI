import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();

  // 1. NEW STATE VARIABLES: Track visibility for both password fields
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Loading state
  bool _isSigningUp = false;

  Future signUp() async {
    // 1. Validation
    if (!passwordConfirmed()) return;

    // Basic Age Validation
    if (_ageController.text.trim().isEmpty || int.tryParse(_ageController.text.trim()) == null) {
      _showError("Please enter a valid number for Age");
      return;
    }

    setState(() => _isSigningUp = true);

    try {
      // 2. Create User in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if user is created successfully
      if (userCredential.user != null) {
        // 3. Update Display Name
        String fullName = "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
        await userCredential.user?.updateDisplayName(fullName);
        await userCredential.user?.reload();

        // 4. Save extra details to Firestore
        await addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          int.parse(_ageController.text.trim()),
          _emailController.text.trim(),
          userCredential.user!.uid,
        );

        // 5. SHOW SUCCESS DIALOG
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.green, size: 60),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Success!',
                        style: GoogleFonts.bebasNeue(fontSize: 32, letterSpacing: 1),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome to HealthSense.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // 6. Wait 2 seconds
        await Future.delayed(const Duration(seconds: 2));

        // 7. Close Dialog and Navigate
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }

    } catch (e) {
      print("ERROR DURING REGISTRATION: $e");
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSigningUp = false);
    }
  }

  Future addUserDetails(String firstName, String lastName, int age, String email, String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'email': email,
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim().isEmpty || _confirmPasswordController.text.trim().isEmpty) {
      _showError('Please fill in both password fields.');
      return false;
    }
    if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {
      return true;
    } else {
      _showError('Passwords do not match. Please try again.');
      return false;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                Text('Hello there!', style: GoogleFonts.bebasNeue(fontSize: 50)),
                const Text('Register below with your details', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 50),

                // Normal Fields (obscureText = false)
                _buildTextField(_firstNameController, 'First name', obscureText: false),
                const SizedBox(height: 15),
                _buildTextField(_lastNameController, 'Last name', obscureText: false),
                const SizedBox(height: 15),
                _buildTextField(_ageController, 'Age', obscureText: false, isNumber: true),
                const SizedBox(height: 15),
                _buildTextField(_emailController, 'Email', obscureText: false),

                const SizedBox(height: 15),

                // --- 2. PASSWORD FIELD (With Toggle) ---
                _buildTextField(
                  _passwordController,
                  'Password',
                  obscureText: _obscurePassword, // Pass the variable
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // --- 3. CONFIRM PASSWORD FIELD (With Toggle) ---
                _buildTextField(
                  _confirmPasswordController,
                  'Confirm Password',
                  obscureText: _obscureConfirmPassword, // Pass the variable
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // --- SIGN UP BUTTON ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: _isSigningUp ? null : signUp,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _isSigningUp
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // --- LOGIN LINK ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already a member? ', style: TextStyle(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: const Text('Sign in', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UPDATED HELPER WIDGET ---
  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      {
        required bool obscureText, // Now required so we are explicit
        bool isNumber = false,
        Widget? suffixIcon, // Optional icon
      }
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500]),
              suffixIcon: suffixIcon, // Add icon here
            ),
          ),
        ),
      ),
    );
  }
}