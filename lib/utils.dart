import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BG with ChangeNotifier {
  late ImageFilter filter;
  late bool isBlurred;

  BG() {
    filter = ImageFilter.blur(sigmaY: 0, sigmaX: 0);
    isBlurred = false;
  }

  unblur() {
    filter = ImageFilter.blur(sigmaY: 0, sigmaX: 0);
    isBlurred = false;
    notifyListeners();
  }

  blur() {
    filter = ImageFilter.blur(sigmaY: 2.5, sigmaX: 2.5);
    isBlurred = true;
    notifyListeners();
  }
}
