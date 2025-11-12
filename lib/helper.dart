import 'dart:io';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
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

double getAnnotationWidth(Widget annotationContent) {
  if (annotationContent is SvgPicture) {
    return (annotationContent as SvgPicture).width! / 10;
  } else if (annotationContent is Image) {
    return (annotationContent as Image).width?.toDouble() ?? 200;
  } else if (annotationContent is SizedBox) {
    final sizedBox = annotationContent as SizedBox;
    return sizedBox.width?.toDouble() ?? 200;
  } else if (annotationContent is ClipRRect) {
    final clipRRect = annotationContent as ClipRRect;
    if (clipRRect.child is SizedBox) {
      final sizedBox = clipRRect.child as SizedBox;
      return sizedBox.width?.toDouble() ?? 200;
    }
    if (clipRRect.child is Image) {
      final image = clipRRect.child as Image;
      return image.width?.toDouble() ?? 200;
    }
  }
  return 200;
}

double getAnnotationHeight(Widget annotationContent) {
  if (annotationContent is SvgPicture) {
    return (annotationContent as SvgPicture).height! / 10;
  } else if (annotationContent is Image) {
    return (annotationContent as Image).height?.toDouble() ?? 200;
  } else if (annotationContent is SizedBox) {
    final sizedBox = annotationContent as SizedBox;
    return sizedBox.height?.toDouble() ?? 200;
  } else if (annotationContent is ClipRRect) {
    final clipRRect = annotationContent as ClipRRect;
    if (clipRRect.child is SizedBox) {
      final sizedBox = clipRRect.child as SizedBox;
      return sizedBox.height?.toDouble() ?? 200;
    }
    if (clipRRect.child is Image) {
      final image = clipRRect.child as Image;
      return image.height?.toDouble() ?? 200;
    }
  }
  return 200;
}
