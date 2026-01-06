import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final CollectionReference historyCollection =
  FirebaseFirestore.instance.collection('history');
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
  Future<void> addHistoryItem(Map<String, dynamic> predictionData) async {
    if (currentUserId == null) return;
    final dataToSave = Map<String, dynamic>.from(predictionData);
    dataToSave['userId'] = currentUserId;
    if (!dataToSave.containsKey('timestamp')) {
      dataToSave['timestamp'] = FieldValue.serverTimestamp();
    }

    await historyCollection.add(dataToSave);
  }
  Stream<QuerySnapshot> getHistoryStream() {
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return historyCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  Future<void> deleteHistoryItem(String docId) async {
    await historyCollection.doc(docId).delete();
  }
  Future<void> clearAllHistory() async {
    if (currentUserId == null) return;
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