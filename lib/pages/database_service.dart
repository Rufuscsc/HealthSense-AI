import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  // 1. FIRESTORE INITIALIZATION
  // We reference the 'history' collection.
  final CollectionReference historyCollection =
  FirebaseFirestore.instance.collection('history');

  // Helper to get current user ID
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // This accepts the Map dictionary created in your input screen
  Future<void> addHistoryItem(Map<String, dynamic> predictionData) async {
    if (currentUserId == null) return;

    // Create a copy of the data and add the userId to it
    // This is crucial for the security rules and filtering later
    final dataToSave = Map<String, dynamic>.from(predictionData);
    dataToSave['userId'] = currentUserId;

    // If timestamp isn't already there, add it
    if (!dataToSave.containsKey('timestamp')) {
      dataToSave['timestamp'] = FieldValue.serverTimestamp();
    }

    await historyCollection.add(dataToSave);
  }

  // 3. READ OPERATION (fetchHistory)
  // Returns a Stream so the UI updates automatically.
  // NOTE: This query requires the Composite Index you created earlier.
  Stream<QuerySnapshot> getHistoryStream() {
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return historyCollection
        .where('userId', isEqualTo: currentUserId) // Filter by User
        .orderBy('timestamp', descending: true)    // Order by Time
        .snapshots();
  }

  // 4. DELETE SINGLE ITEM
  Future<void> deleteHistoryItem(String docId) async {
    await historyCollection.doc(docId).delete();
  }

  // 5. DELETE ALL (Clear History)
  Future<void> clearAllHistory() async {
    if (currentUserId == null) return;

    // Get all docs for this user and delete them in a batch
    final snapshot = await historyCollection
        .where('userId', isEqualTo: currentUserId)
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}