import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

// Ensure these point to your actual file locations
import 'package:firebasepractice/main.dart'; // Should contain PredictionEntry class
import 'database_service.dart';

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  // ---------------------------------------------------------------------------
  // 1. STATE VARIABLES
  // ---------------------------------------------------------------------------
  final List<String> symptomsList = [
    'Fever', 'Chills', 'Headache', 'Cough', 'Sore throat',
    'Runny nose', 'Fatigue', 'Nausea', 'Body pain',
    'Diarrhea', 'Joint pain', 'Vomiting'
  ];

  final Map<String, bool> selected = {};
  final TextEditingController _descriptionController = TextEditingController();


  final String _apiKey = 'AIzaSyDugi29iq8CoO0DhNKD8DPFi3bI0h8uzi0';

  bool _loading = false;
  int _selectedIndex = 1;

  // --- VOICE INPUT VARIABLES ---
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize checkboxes
    for (var s in symptomsList) {
      selected[s] = false;
    }
    // Initialize Speech Engine
    _initSpeech();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _speech.stop(); // Stop listening if screen is closed
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 2. VOICE INPUT LOGIC
  // ---------------------------------------------------------------------------
  void _initSpeech() async {
    _speech = stt.SpeechToText();
    // Request permission explicitly on first load
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      try {
        _speechEnabled = await _speech.initialize(
          onStatus: (status) {
            // Auto-update UI when speech stops naturally (e.g., silence)
            if (status == 'notListening') {
              setState(() => _isListening = false);
            }
          },
          onError: (errorNotification) {
            setState(() => _isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Voice Error: ${errorNotification.errorMsg}')),
            );
          },
        );
        setState(() {}); // Refresh UI
      } catch (e) {
        debugPrint("Speech init error: $e");
      }
    }
  }

  void _listen() async {
    if (!_speechEnabled) {
      // Try initializing again if it failed the first time
      _initSpeech();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Initializing microphone... Try again.')),
      );
      return;
    }

    if (_isListening) {
      // STOP LISTENING
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      // START LISTENING
      setState(() => _isListening = true);

      // Capture current text so we don't delete it
      String previousText = _descriptionController.text;

      await _speech.listen(
        onResult: (val) {
          setState(() {
            // Append recognized words to existing text
            String newWords = val.recognizedWords;

            // Logic to append cleanly
            if (previousText.isEmpty) {
              _descriptionController.text = newWords;
            } else {
              // stt returns the full sentence of the *current* session
              // So we display: "Old Text" + " " + "New Spoken Text"
              _descriptionController.text = "$previousText $newWords";
            }

            // Keep cursor at the end
            _descriptionController.selection = TextSelection.fromPosition(
                TextPosition(offset: _descriptionController.text.length));
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: "en_NG", // Optimized for Nigerian accents
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 3. AI & SUBMISSION LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    FocusScope.of(context).unfocus(); // Hide keyboard

    // Gather Data
    final pickedSymptoms = selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final description = _descriptionController.text.trim();

    // Validation
    if (pickedSymptoms.isEmpty && description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select symptoms or describe how you feel.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      // Prompt Engineering
      final prompt = '''
      Context: You are a medical AI assistant for a university health app. 
      Patient Data:
      - Symptoms: ${pickedSymptoms.join(', ')}
      - Description: "$description"
      
      Task: Analyze symptoms and identify exactly 3 possible diagnoses prioritizing common tropical illnesses in West Africa.
      
      OUTPUT FORMAT: Return ONLY a raw JSON Array. No Markdown.
      [
        { "illness": "Name", "confidence": 0-100, "advice": "Short medical advice." }
      ]
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        // Robust JSON Parsing
        String rawText = response.text!;
        int startIndex = rawText.indexOf('[');
        int endIndex = rawText.lastIndexOf(']');

        if (startIndex == -1 || endIndex == -1) {
          throw Exception("AI response was not valid JSON.");
        }

        String jsonString = rawText.substring(startIndex, endIndex + 1);
        List<dynamic> predictions = jsonDecode(jsonString);

        // Sort by confidence
        predictions.sort((a, b) =>
            (b['confidence'] as num).compareTo(a['confidence'] as num));

        final bestMatch = predictions[0];
        final otherMatches = predictions.sublist(1).map((e) {
          return {
            'illness': e['illness'],
            'confidence': (e['confidence'] ?? 0).toDouble(),
          };
        }).toList();

        // Prepare Data for Firestore
        final historyData = {
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'illness': bestMatch['illness'] ?? 'Unknown',
          'confidence': (bestMatch['confidence'] ?? 0).toDouble(),
          'notes': bestMatch['advice'] ?? 'Consult a doctor.',
          'timestamp': FieldValue.serverTimestamp(),
          'symptoms': [...pickedSymptoms, if (description.isNotEmpty) description],
          'otherDiagnoses': otherMatches,
        };

        // Save to Database
        await DatabaseService().addHistoryItem(historyData);

        if (!mounted) return;

        // Navigate to Result
        final entry = PredictionEntry(
          illness: historyData['illness'] as String,
          confidence: historyData['confidence'] as double,
          notes: historyData['notes'] as String,
          timestamp: DateTime.now(),
          symptoms: List<String>.from(historyData['symptoms']),
          otherDiagnoses: otherMatches,
        );

        Navigator.pushNamed(context, '/result', arguments: entry);

        // Reset UI
        _descriptionController.clear();
        setState(() {
          for (var key in selected.keys) {
            selected[key] = false;
          }
        });

      } else {
        throw Exception('AI returned an empty response.');
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis Failed: ${e.toString().replaceAll("Exception:", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // 4. NAVIGATION LOGIC
  // ---------------------------------------------------------------------------
  void _onTapNav(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, '/home'); break;
      case 1: break;
      case 2: Navigator.pushReplacementNamed(context, '/history'); break;
      case 3: Navigator.pushReplacementNamed(context, '/feedback'); break;
      case 4: Navigator.pushReplacementNamed(context, '/profile'); break;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // TITLE
              Text('Symptoms',
                  style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 5),
              Text('Tell us how you are feeling',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 25),

              // SCROLLABLE BODY
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // --- SYMPTOM CHIPS SECTION ---
                    Row(
                      children: [
                        Icon(Icons.local_hospital_outlined,
                            size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text('Common Symptoms',
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: symptomsList.map((s) {
                        final isSelected = selected[s] == true;
                        return FilterChip(
                          label: Text(s),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          selected: isSelected,
                          onSelected: (val) => setState(() => selected[s] = val),
                          backgroundColor: Colors.white,
                          selectedColor: Colors.deepPurple,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),

                    // --- VOICE INPUT & TEXT FIELD SECTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Additional Details',
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        if (_isListening)
                          const Text(
                              "Listening...",
                              style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 12)
                          )
                      ],
                    ),
                    const SizedBox(height: 10),

                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _isListening ? Colors.deepPurple : Colors.grey.shade300,
                                width: _isListening ? 2 : 1
                            ),
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Tap the mic to speak or type here...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              // Add padding to right so text doesn't go under the mic button
                              contentPadding: const EdgeInsets.fromLTRB(16, 16, 60, 16),
                            ),
                          ),
                        ),

                        // MICROPHONE BUTTON
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FloatingActionButton.small(
                            heroTag: "mic_btn",
                            onPressed: _listen,
                            backgroundColor: _isListening ? Colors.deepPurple : Colors.deepPurple,
                            elevation: 2,
                            child: Icon(
                                _isListening ? Icons.mic_off : Icons.mic,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.deepPurple.shade200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                      : Text('Analyze Symptoms',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10)
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
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                activeIcon: Icon(Icons.search),
                label: 'Check'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Feedback'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}