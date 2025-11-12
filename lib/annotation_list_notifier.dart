import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AnnotationListNotifier extends ChangeNotifier {
  static final AnnotationListNotifier instance =
      AnnotationListNotifier._internal();

  factory AnnotationListNotifier() {
    return instance;
  }

  AnnotationListNotifier._internal();
  double _scrollPosition = 0.0;
  double get annotationPosition => _scrollPosition;
  ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  void scrollTo(double annotationPosition) {
    _scrollPosition = annotationPosition;
    notifyListeners();
  }
}
