import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receipt.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';

  CollectionReference get _userReceipts => 
      _firestore.collection('users').doc(_userId).collection('receipts');

  Future<String> insertReceipt(Receipt receipt) async {
    final docRef = await _userReceipts.add(receipt.toMap());
    return docRef.id;
  }

  Future<List<Receipt>> getReceipts() async {
    final snapshot = await _userReceipts.orderBy('savedAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Add the document ID as the integer ID (or just use String if preferred)
      // For compatibility with current Receipt model which uses int? id, 
      // we might need to handle this carefully.
      return Receipt.fromMap({...data, 'id': doc.id.hashCode});
    }).toList();
  }

  Future<void> deleteReceipt(int id) async {
    // Note: Since we are using Firestore IDs, deleting by integer hashCode is tricky.
    // Ideally, the Receipt model should use String? id for Firestore.
    // For now, we'll find the doc with that hashCode.
    final snapshot = await _userReceipts.get();
    for (var doc in snapshot.docs) {
      if (doc.id.hashCode == id) {
        await doc.reference.delete();
        break;
      }
    }
  }

  Future<void> clearHistory() async {
    final snapshot = await _userReceipts.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
