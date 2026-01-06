import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int stars = 5;
  final _controller = TextEditingController();
  bool _submitted = false;
  int _selectedIndex = 3;
  String get _ratingLabel {
    if (stars == 5) return "Amazing!";
    if (stars == 4) return "Good job!";
    if (stars == 3) return "It was okay";
    if (stars == 2) return "Could be better";
    return "Not good";
  }

  String get _ratingEmoji {
    if (stars == 5) return "🤩";
    if (stars == 4) return "😃";
    if (stars == 3) return "😐";
    if (stars == 2) return "😕";
    return "😢";
  }

  Color get _ratingColor {
    if (stars >= 4) return const Color(0xFF673AB7);
    if (stars == 3) return Colors.amber;
    return Colors.redAccent;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    setState(() => _submitted = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! We appreciate your feedback.'),
            backgroundColor: Colors.deepPurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _onTapNav(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, '/home'); break;
      case 1: Navigator.pushReplacementNamed(context, '/symptoms'); break;
      case 2: Navigator.pushReplacementNamed(context, '/history'); break;
      case 3: break;
      case 4: Navigator.pushReplacementNamed(context, '/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        'Feedback',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                if (!_submitted)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      "We'd love to hear from you!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: _submitted
                        ? _buildSuccessView()
                        : _buildFormView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 10),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Text(
              _ratingEmoji,
              key: ValueKey<int>(stars),
              style: const TextStyle(fontSize: 60),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _ratingLabel,
              key: ValueKey<String>(_ratingLabel),
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _ratingColor,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => stars = starIndex);
                  },
                  child: AnimatedScale(
                    scale: starIndex <= stars ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      starIndex <= stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: starIndex <= stars ? Colors.amber[400] : Colors.grey[300],
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 30),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "What can we improve?",
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                contentPadding: const EdgeInsets.all(20),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: Colors.deepPurple.withOpacity(0.4),
              ),
              child: Text(
                'Submit Feedback',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 30),
            Text(
              "Feedback Received!",
              style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Thank you for helping us make HealthSense AI better for everyone.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Back to Home", style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTapNav,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search), label: 'Check'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Feedback'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}