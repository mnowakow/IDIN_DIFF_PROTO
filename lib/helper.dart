import 'dart:io';
import 'dart:ui';
import 'package:idin_diff_prototype/annotation_filter_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vec;

import 'package:flutter/material.dart';

Offset getTransformedOffset(
  Offset screenPos,
  TransformationController controller,
  double scrollOffset,
) {
  final matrix = controller.value;
  Offset svgPos = screenPos;
  if (matrix != null) {
    final Matrix4 inverse = Matrix4.inverted(matrix);
    final vec.Vector3 local = inverse.transform3(
      vec.Vector3(svgPos.dx, svgPos.dy, 0),
    );
    // Add scroll offset to svgPos
    svgPos = Offset(local.x, local.y + scrollOffset);
  }
  return svgPos;
}

Future<List<String>> getAllUsers() async {
  final directory = await getApplicationDocumentsDirectory();
  List<FileSystemEntity> files = directory.listSync();
  files.sort((a, b) => a.statSync().changed.compareTo(b.statSync().changed));
  List<String> users = [];
  for (FileSystemEntity file in files) {
    if (file is File && file.path.endsWith('.json')) {
      String fileName = file.path.split('/').last;
      if (!fileName.startsWith("annotations_")) return [];
      String userName = fileName.substring(
        fileName.indexOf('annotations_') + 'annotations_'.length,
        fileName.lastIndexOf('.json'),
      );
      print("User Annotation added: $userName");
      users.add(userName);
    }
  }
  return users;
}
