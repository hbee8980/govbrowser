import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/// Utility class for clipboard operations
class ClipboardUtils {
  ClipboardUtils._();

  /// Copy text to clipboard and show a toast
  static Future<void> copyWithToast(
    String text, {
    String? label,
    BuildContext? context,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    final message = label != null ? '$label copied!' : 'Copied!';

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF323232),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Copy text to clipboard silently (no toast)
  static Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Get text from clipboard
  static Future<String?> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  /// Check if clipboard has text
  static Future<bool> hasText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text?.isNotEmpty ?? false;
  }
}
