import 'dart:ui';

import 'package:flutter/foundation.dart';

class AnnotationFilterNotifier extends ChangeNotifier {
  static final AnnotationFilterNotifier instance =
      AnnotationFilterNotifier._internal();

  factory AnnotationFilterNotifier() {
    return instance;
  }

  AnnotationFilterNotifier._internal();
  Map<String, bool> _filter = {};
  Map<String, Color> _userColors = {};

  Map<String, bool> get filter => _filter;
  Map<String, Color> get userColors => _userColors;

  void setFilter(Map<String, bool> selectedAnnotations) {
    _filter = selectedAnnotations;
    notifyListeners();
  }

  void addUserColor(String user, Color color) {
    _userColors[user] = color;
    print('Added color for $user: ${color.toString()}');
  }
}
