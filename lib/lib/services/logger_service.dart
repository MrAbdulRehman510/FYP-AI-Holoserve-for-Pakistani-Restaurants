import 'package:flutter/material.dart';

class InteractionLogger {
  static Future<void> log({
    required String type,
    required String item,
  }) async {
    debugPrint('Log: $type - $item');
  }
}
