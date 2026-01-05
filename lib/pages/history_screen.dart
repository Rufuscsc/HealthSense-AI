import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:google_fonts/google_fonts.dart';

import 'database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 2;
  final DatabaseService _dbService = DatabaseService(); // Initialize Service

  // Navigation Logic (Unchanged)
  void _onTapNav(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, '/home'); break;
      case 1: Navigator.pushReplacementNamed(context, '/symptoms'); break;
      case 2: break; // Already on History
      case 3: Navigator.pushReplacementNamed(context, '/feedback'); break;
      case 4: Navigator.pushReplacementNamed(context, '/profile'); break;
    }
  }

  // --- DELETE FUNCTION (UPDATED FOR FIREBASE) ---
  void _deleteItem(String docId) {
    _dbService.deleteHistoryItem(docId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prediction History',
                        style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Swipe left to delete items',
                        style: GoogleFonts.inter(
                          fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Clear All Button
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear All History?'),
                          content: const Text('This will delete all saved predictions permanently.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _dbService.clearAllHistory(); // Call Service
                                Navigator.pop(context);
                              },
                              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- FIREBASE STREAM BUILDER ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _dbService.getHistoryStream(),
                  builder: (context, snapshot) {
                    // 1. Handling Loading State
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 2. Handling Empty State
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 15),
                            Text(
                              'No history yet',
                              style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    // 3. Handling Data
                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (_, idx) {
                        // Get data and document ID
                        final doc = docs[idx];
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;

                        // Safely access fields (handle nulls)
                        final illness = data['illness'] ?? 'Unknown';
                        final confidence = (data['confidence'] ?? 0.0).toDouble();
                        final symptomsList = List<String>.from(data['symptoms'] ?? []);
                        final notes = data['notes'] ?? 'No advice provided.';

                        // Format Timestamp
                        String dateStr = 'Just now';
                        if (data['timestamp'] != null) {
                          DateTime date = (data['timestamp'] as Timestamp).toDate();
                          dateStr = "${date.year}-${date.month}-${date.day}";
                        }

                        return Dismissible(
                          key: Key(docId), // Must use Document ID for keys
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => _deleteItem(docId),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete, color: Colors.white, size: 30),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.sick, color: Colors.deepPurple),
                              ),
                              title: Text(
                                illness,
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  '${confidence.toStringAsFixed(1)}% confidence • $dateStr',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text(illness, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _infoRow('Confidence', '${confidence.toStringAsFixed(1)}%'),
                                      const SizedBox(height: 10),
                                      _infoRow('Symptoms', symptomsList.join(', ')),
                                      const SizedBox(height: 10),
                                      _infoRow('Advice', notes),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteItem(docId);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close', style: TextStyle(color: Colors.deepPurple)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
            BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search, fontWeight: FontWeight.bold), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Feedback'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}