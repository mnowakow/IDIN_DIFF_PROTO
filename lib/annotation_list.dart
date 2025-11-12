import 'package:flutter/material.dart';
import 'package:idin_diff_prototype/annotation_filter_notifier.dart';
import 'package:idin_diff_prototype/annotation_list_notifier.dart';
import 'package:idin_diff_prototype/annotation_notifier.dart';
import 'package:idin_diff_prototype/annotation.dart';
import 'package:idin_diff_prototype/helper.dart';
import 'package:idin_diff_prototype/scroll_notifier.dart';

class AnnotationList extends StatefulWidget {
  final ScrollNotifier scrollNotifier;
  AnnotationList({super.key, required this.scrollNotifier});

  @override
  State<AnnotationList> createState() => _AnnotationListState();
}

class _AnnotationListState extends State<AnnotationList> {
  //Map<String, List<Annotation>> annotations = {};
  List<Annotation> annotations = [];
  Map<String, bool> filter = {};

  @override
  void initState() {
    super.initState();
    filter = AnnotationFilterNotifier.instance.filter;
    AnnotationNotifier.instance.addListener(_onAnnotationsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnnotationListNotifier.instance.addListener(() {
        int targetIndex = 0;
        final targetY = AnnotationListNotifier.instance.annotationPosition;
        for (int i = 0; i < annotations.length; i++) {
          if (annotations[i].position.dy <= targetY) {
            targetIndex = i;
          } else {
            break;
          }
        }

        AnnotationListNotifier.instance.scrollController.jumpTo(
          targetIndex * 120.0, // Assuming each item has a height of 120.0
        );
      });
    });
    AnnotationFilterNotifier.instance.addListener(() {
      setState(() {
        filter = AnnotationFilterNotifier.instance.filter;
      });
    });
    //annotations = AnnotationNotifier.instance.annotations;
  }

  @override
  void dispose() {
    AnnotationNotifier.instance.removeListener(_onAnnotationsChanged);
    super.dispose();
  }

  void _onAnnotationsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var allAnnotations = <Annotation>[];

    for (final annotationList
        in AnnotationNotifier.instance.annotations.values) {
      allAnnotations.addAll(annotationList);
    }

    if (allAnnotations.isEmpty) {
      return const Center(child: Text('Keine Annotationen vorhanden'));
    }

    allAnnotations.sort((a, b) => a.position.dy.compareTo(b.position.dy));
    allAnnotations =
        allAnnotations.where((annotation) {
          return filter[annotation.owner] != false;
        }).toList();

    annotations = allAnnotations;

    return ListView.builder(
      key: const PageStorageKey('annotationList'),
      controller: AnnotationListNotifier.instance.scrollController,
      itemCount: allAnnotations.length,
      itemBuilder: (context, index) {
        final originalAnnotation = allAnnotations[index];
        final annotation = AnnotationNotifier.instance.copyAnnotation(
          originalAnnotation,
        );
        final containerHeight = 128.0; // Feste Höhe für alle Container
        final annotationHeight = getAnnotationHeight(
          annotation.annotationContent,
        );
        final scaleFactor = containerHeight / annotationHeight;

        return GestureDetector(
          onTap: () {
            final pos = originalAnnotation.position;
            final y = pos.dy - MediaQuery.of(context).size.height / 2;
            widget.scrollNotifier.scrollToPosition(
              y,
              AnnotationNotifier.instance.scrollController,
            );
          },
          child: Container(
            height: containerHeight, // Fixed height for all containers
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AnnotationFilterNotifier
                                .instance
                                .userColors[annotation.owner] ??
                            Colors.blue,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        annotation.owner,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        'Y: ${annotation.position.dy.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  // child: ClipRect(
                  child: OverflowBox(
                    maxHeight: containerHeight,
                    maxWidth: double.infinity,
                    child: Transform.scale(
                      scale: scaleFactor * 0.5, // Skaliere den Inhalt auf 50%
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: getAnnotationWidth(annotation.annotationContent),
                        height: annotationHeight,
                        child: annotation.annotationContent,
                      ),
                    ),
                  ),
                ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
