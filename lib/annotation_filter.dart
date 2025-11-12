import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:idin_diff_prototype/annotation_filter_notifier.dart';
import 'package:idin_diff_prototype/helper.dart';
import 'package:idin_diff_prototype/login_page_notifier.dart';
import 'package:path_provider/path_provider.dart';

class AnnotationFilter extends StatefulWidget {
  const AnnotationFilter({Key? key}) : super(key: key);

  @override
  State<AnnotationFilter> createState() => _AnnotationFilterState();
}

class _AnnotationFilterState extends State<AnnotationFilter> {
  List<String> availableAnnotations = [];
  Map<String, bool> selectedAnnotations = {};
  static const List<Color> highContrastColors = [
    Color(0xFF8BC34A), // Light Green
    Color.fromARGB(255, 197, 79, 168), // Deep Orange
    Color.fromARGB(255, 254, 0, 0), // Deep Purple
    Color.fromARGB(255, 25, 185, 132), // Dark Cyan
    Color(0xFF0277BD), // Light Blue
    Color.fromARGB(255, 49, 13, 6), // Dark Brown
    Color(0xFF263238), // Blue Grey
    Color(0xFF827717), // Olive
    Color(0xFF880E4F), // Dark Pink
    Color(0xFF212121), // Dark Grey
    Color(0xFF795548), // Brown
    Color(0xFF1A237E), // Indigo
    Color(0xFF004D40), // Teal
    Color(0xFF33691E), // Light Green Dark

    Color(0xFF6A1B9A), // Purple

    Color(0xFFFF5722), // Deep Orange Red
  ];

  @override
  void initState() {
    super.initState();
    _loadAnnotationFiles();
    AnnotationFilterNotifier.instance.addListener(() {
      setState(() {});
    });
    LoginPageNotifier.instance.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadAnnotationFiles() async {
    try {
      List<String> users = await getAllUsers();
      setState(() {
        availableAnnotations = ["all", ...users];
        selectedAnnotations = {
          for (String annotation in users) annotation: true,
        };
      });
    } catch (e) {
      print('Error loading annotation files: $e');
    }
  }

  void _onCheckboxChanged(String annotation, bool? value) {
    setState(() {
      selectedAnnotations[annotation] = value ?? false;
      if (annotation == "all") {
        for (String key in selectedAnnotations.keys) {
          selectedAnnotations[key] = value ?? false;
        }
      }

      print('Selected Annotations: $selectedAnnotations');
      AnnotationFilterNotifier.instance.setFilter(selectedAnnotations);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: 1300,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.amber.shade100.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Annotation Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Logged in as: ${LoginPageNotifier.instance.username}',
              style: const TextStyle(fontSize: 14),
            ),
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children:
                      availableAnnotations.asMap().entries.map((entry) {
                        int index = entry.key;
                        String annotation = entry.value;
                        Color backgroundColor =
                            highContrastColors[index %
                                highContrastColors.length];
                        AnnotationFilterNotifier.instance.addUserColor(
                          annotation,
                          backgroundColor,
                        );
                        return Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SizedBox(
                            width: 150,
                            child: CheckboxListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              dense: true,
                              title: Text(
                                annotation,
                                style: const TextStyle(color: Colors.white),
                              ),
                              value: selectedAnnotations[annotation] ?? false,
                              onChanged: (value) {
                                print(
                                  'Checkbox changed: $annotation to $value',
                                );
                                _onCheckboxChanged(annotation, value);
                              },
                              checkColor: Colors.white,
                              activeColor: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
