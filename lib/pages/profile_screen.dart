import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebasepractice/pages/forgot_password.dart';
import 'package:firebasepractice/pages/privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  int _selectedIndex = 4;
  bool _isEditing = false;

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  // --- LOGIC ---
  void _loadCurrentData() {
    setState(() {
      _emailCtrl.text = user?.email ?? "";

      if (user?.displayName != null && user!.displayName!.isNotEmpty) {
        // LOGIC: Get only the First Name
        _nameCtrl.text = user!.displayName!.split(' ').first;
      } else {
        _fetchNameFromFirestore();
      }
    });
  }

  Future<void> _fetchNameFromFirestore() async {
    if (user?.email == null) return;
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user!.email)
          .get();
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        setState(() {
          // LOGIC: Only use the 'firstName' field
          _nameCtrl.text = "${data['firstName']}".trim();
        });
      }
    } catch (e) {
      debugPrint("Error loading name: $e");
    }
  }

  Future<void> _save() async {
    if (user == null) return;
    try {
      await user!.updateDisplayName(_nameCtrl.text.trim());
      await user!.reload();
      setState(() {
        user = FirebaseAuth.instance.currentUser;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  void _goToForgotPassword() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())
    );
  }

  void _goToPrivacyPolicy() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _onTapNav(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, '/home'); break;
      case 1: Navigator.pushReplacementNamed(context, '/symptoms'); break;
      case 2: Navigator.pushReplacementNamed(context, '/history'); break;
      case 3: Navigator.pushReplacementNamed(context, '/feedback'); break;
      case 4: break;
    }
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [

            // 1. CUSTOM HEADER
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),

                Positioned(
                  top: 60,
                  child: Text(
                    'My Profile',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                Positioned(
                  bottom: -50,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.deepPurple.shade50,
                      child: Icon(Icons.person, size: 60, color: Colors.deepPurple.shade200),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // 2. USER INFO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  // --- PERFECTLY CENTERED TEXT FIELD ---
                  TextField(
                    controller: _nameCtrl,
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() => _isEditing = true),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "",
                      prefixIcon: Icon(Icons.edit, size: 18, color: Colors.transparent),
                      suffixIcon: Icon(Icons.edit, size: 18, color: Colors.grey),
                    ),
                  ),

                  Text(
                    _emailCtrl.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (_isEditing) ...[
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      ),
                      child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. SETTINGS SECTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Account Settings"),
                  _settingsCard([
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: _goToForgotPassword,
                    ),
                    _divider(),
                    _buildSettingsTile(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      showToggle: true,
                      switchValue: _notificationsEnabled,
                      onToggle: (value) {
                        setState(() => _notificationsEnabled = value);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_notificationsEnabled ? "Notifications On" : "Notifications Off"),
                              duration: const Duration(seconds: 1),
                            )
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 25),

                  _sectionTitle("Support & About"),
                  _settingsCard([
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: _goToPrivacyPolicy,
                    ),
                    _divider(),
                    _buildSettingsTile(
                      icon: Icons.headset_mic_outlined,
                      title: 'Contact Support',
                      onTap: () => _showSupportDialog(context),
                    ),
                  ]),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade100),
                        backgroundColor: Colors.red.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "Log Out",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
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
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search), label: 'Check'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Feedback'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool showToggle = false,
    bool switchValue = false,
    ValueChanged<bool>? onToggle,
  }) {
    return ListTile(
      onTap: showToggle ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.deepPurple, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
      ),
      trailing: showToggle
          ? Switch(
        value: switchValue,
        onChanged: onToggle,
        activeColor: Colors.deepPurple,
      )
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 70, endIndent: 20);
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _supportRow(Icons.phone, '+234 9030334953'),
            const SizedBox(height: 15),
            _supportRow(Icons.email, 'rufusmfmwellens@gmail.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.deepPurple)),
          )
        ],
      ),
    );
  }

  Widget _supportRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}
