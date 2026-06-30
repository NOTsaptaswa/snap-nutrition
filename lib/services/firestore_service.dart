import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_entry.dart';

// Service: thin wrapper around Firestore. No business logic — just raw
// CRUD calls scoped to a user's food_entries collection.
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('food_entries');
  }

  Future<void> addEntry(FoodEntry entry) async {
    await _collection(entry.userId).doc(entry.id).set(entry.toFirestore());
  }

  Future<void> deleteEntry(String userId, String entryId) async {
    await _collection(userId).doc(entryId).delete();
  }

  Stream<List<FoodEntry>> watchEntries(String userId) {
    return _collection(userId)
        .orderBy('loggedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FoodEntry.fromFirestore(doc.id, doc.data()))
        .toList());
  }
}
