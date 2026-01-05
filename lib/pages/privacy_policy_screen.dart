import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: December 2025',
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('1. Introduction'),
            _buildSectionText(
                'Welcome to HealthSense AI. We are committed to protecting your personal information and your right to privacy. This policy explains how we handle your health data.'
            ),

            _buildSectionTitle('2. Information We Collect'),
            _buildSectionText(
                'We collect personal information that you voluntarily provide to us when you register on the application, specifically:\n\n'
                    '• Personal details (Name, Age, Email)\n'
                    '• Health data (Symptoms, recorded history)\n'
                    '• Usage data (Feedback, interaction logs)'
            ),

            _buildSectionTitle('3. How We Use Your Data'),
            _buildSectionText(
                'We use your information to:\n'
                    '• Provide AI-driven health predictions.\n'
                    '• Manage your account history.\n'
                    '• Improve our AI models (anonymized data only).'
            ),

            _buildSectionTitle('4. Data Security'),
            _buildSectionText(
                'We use administrative, technical, and physical security measures to help protect your personal information. Your health records are stored securely via Google Cloud Firestore.'
            ),

            _buildSectionTitle('5. Contact Us'),
            _buildSectionText(
                'If you have questions or comments about this policy, you may email us at rufusmfmwellens@gmail.com.'
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        height: 1.6,
        color: Colors.grey[800],
      ),
    );
  }
}