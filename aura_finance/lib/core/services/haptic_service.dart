import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter/foundation.dart';

class HapticService {
  static Future<void> light() async {
    if (kIsWeb) return;
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.light);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> medium() async {
    if (kIsWeb) return;
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.medium);
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> success() async {
    if (kIsWeb) return;
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.success);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  static Future<void> error() async {
    if (kIsWeb) return;
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.error);
    } else {
      HapticFeedback.vibrate();
    }
  }
}
