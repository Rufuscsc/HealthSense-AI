import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebasepractice/main.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _homeView(),
      ),
      bottomNavigationBar: Container(
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
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                activeIcon: Icon(Icons.search, fontWeight: FontWeight.bold),
                label: 'Search'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'History'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Feedback'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeView() {
    String nameFromAuth = user?.displayName ?? "User";
    final String shortName = nameFromAuth.split(RegExp(r"[@\s]"))[0];

    final String formattedName = shortName.isNotEmpty
        ? shortName[0].toUpperCase() + shortName.substring(1)
        : shortName;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $formattedName 👋',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How are you feeling today?',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                IconButton(
                  onPressed: _signOut,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Column(
              children: [
                _quickCard(Icons.health_and_safety, 'Check Symptoms',
                    primaryBlue, () => Navigator.pushNamed(context, '/symptoms')),

                const SizedBox(height: 15),

                _quickCard(Icons.history, 'View History', Colors.orange,
                        () => Navigator.pushNamed(context, '/history')),

                const SizedBox(height: 15),

                _quickCard(Icons.feedback, 'Give Feedback', accentGreen,
                        () => Navigator.pushNamed(context, '/feedback')),

                const SizedBox(height: 15),

                _quickCard(Icons.person, 'Profile', Colors.purple,
                        () => Navigator.pushNamed(context, '/profile')),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _quickCard(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapNav(int i) {
    setState(() => _selectedIndex = i);
    switch (i) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/symptoms');
        break;
      case 2:
        Navigator.pushNamed(context, '/history');
        break;
      case 3:
        Navigator.pushNamed(context, '/feedback');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}