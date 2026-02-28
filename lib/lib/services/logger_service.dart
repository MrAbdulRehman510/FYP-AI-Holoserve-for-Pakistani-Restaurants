import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InteractionLogger {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Global function to log any interaction
  static Future<void> log({
    required String type, // "view" or "recommendation"
    required String item,
  }) async {
    try {
      await _db.collection('logs').add({
        'type': type,
        'item': item,
        'time': FieldValue.serverTimestamp(),
      });
      debugPrint("Log Saved: $type - $item");
    } catch (e) {
      debugPrint("Error saving log: $e");
    }
  }
}
