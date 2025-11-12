import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idin_diff_prototype/annotation_list.dart';
import 'package:idin_diff_prototype/filtered_view.dart';
import 'package:idin_diff_prototype/miniview.dart';
import 'package:idin_diff_prototype/scroll_notifier.dart';
import 'package:idin_diff_prototype/sidebar_notifier.dart';
import 'package:path_provider/path_provider.dart';

enum SidebarPosition { top, bottom, left, right }

class ExpandableSidebar extends StatefulWidget {
  final SidebarPosition position;
  final ScrollNotifier scrollNotifier;

  const ExpandableSidebar({
    super.key,
    required this.position,
    required this.scrollNotifier,
  });

  @override
  State<ExpandableSidebar> createState() => _ExpandableSidebarState();
}

class _ExpandableSidebarState extends State<ExpandableSidebar> {
  bool expanded = false;
  SideBarWidget selectedWidget = SideBarWidget.miniView;

  Future<void> _deleteJson() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      for (final file in files) {
        if (file is File &&
            file.path.contains('annotations_') &&
            file.path.endsWith('.json')) {
          print('Deleting file: ${file.path}');
          file.deleteSync();
        }
      }
    } catch (e) {
      debugPrint('Error deleting JSON files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget sidebarContent = Container(
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
      width:
          widget.position == SidebarPosition.left ||
                  widget.position == SidebarPosition.right
              ? (expanded ? (470) : 70)
              : double.infinity,
      height:
          widget.position == SidebarPosition.top ||
                  widget.position == SidebarPosition.bottom
              ? (expanded ? 400 : 40)
              : double.infinity,
      child: Row(
        textDirection:
            widget.position == SidebarPosition.right
                ? TextDirection.rtl
                : TextDirection.ltr,
        children: [
          // Main sidebar column - feste Breite
          Container(
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    IconButton(
                      iconSize: 40,
                      icon: Icon(Icons.first_page_rounded, size: 40),
                      onPressed:
                          () => setState(() {
                            widget.scrollNotifier.scrollToPage(1);
                          }),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.auto_awesome_mosaic, size: 40),
                  onPressed:
                      () => setState(() {
                        if (selectedWidget == SideBarWidget.miniView) {
                          expanded = !expanded;
                        }
                        selectedWidget = SideBarWidget.miniView;
                        SidebarNotifier.instance.openSidebar = selectedWidget;
                      }),
                ),
                // SizedBox(height: 24),
                // IconButton(
                //   iconSize: 40,
                //   icon: Icon(Icons.bookmark, size: 40),
                //   onPressed:
                //       () => setState(() {
                //         if (selectedWidget == SideBarWidget.bookmarks) {
                //           expanded = !expanded;
                //         }
                //         selectedWidget = SideBarWidget.bookmarks;
                //         SidebarNotifier.instance.openSidebar = selectedWidget;
                //       }),
                // ),
                // SizedBox(height: 24),
                // IconButton(
                //   iconSize: 40,
                //   icon: Container(
                //     decoration: BoxDecoration(
                //       color:
                //           SidebarNotifier.instance.openSidebar ==
                //                   SideBarWidget.colorPalette
                //               ? Colors.green.shade400
                //               : null,
                //       borderRadius: BorderRadius.circular(100),
                //     ),
                //     padding: EdgeInsets.all(8),
                //     child: Icon(Icons.color_lens, size: 40),
                //   ),
                //   onPressed:
                //       () => setState(() {
                //         expanded = false;
                //         if (selectedWidget == SideBarWidget.colorPalette) {
                //           selectedWidget = SideBarWidget.none;
                //           // expanded = false;
                //         } else {
                //           // expanded = true;
                //           selectedWidget = SideBarWidget.colorPalette;
                //         }
                //         SidebarNotifier.instance.openSidebar = selectedWidget;
                //       }),
                // ),

                // SizedBox(height: 24),
                // IconButton(
                //   iconSize: 40,
                //   icon: Container(
                //     decoration: BoxDecoration(
                //       color:
                //           SidebarNotifier.instance.openSidebar ==
                //                   SideBarWidget.camera
                //               ? Colors.green.shade400
                //               : null,
                //       borderRadius: BorderRadius.circular(100),
                //     ),
                //     padding: EdgeInsets.all(8),
                //     child: Icon(Icons.camera_outlined, size: 40),
                //   ),
                //   onPressed:
                //       () => setState(() {
                //         //expanded = false;
                //         selectedWidget = SideBarWidget.camera;
                //         if (SidebarNotifier.instance.openSidebar !=
                //             SideBarWidget.camera) {
                //           SidebarNotifier.instance.openSidebar = selectedWidget;
                //         } else {
                //           SidebarNotifier.instance.openSidebar =
                //               SideBarWidget.none;
                //         }
                //       }),
                // ),
                SizedBox(height: 24),
                IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.sticky_note_2_outlined, size: 40),
                  onPressed: () {
                    setState(() {
                      if (selectedWidget == SideBarWidget.annot) {
                        expanded = !expanded;
                      } else if (selectedWidget == SideBarWidget.none) {
                        expanded = true;
                      } else {
                        expanded = true;
                      }
                      selectedWidget = SideBarWidget.annot;
                      SidebarNotifier.instance.openSidebar = selectedWidget;
                    });
                  },
                ),
                // SizedBox(height: 24),
                // IconButton(
                //   iconSize: 40,
                //   icon: Icon(Icons.delete_forever, size: 40),
                //   onPressed: () {},
                //   onLongPress: () {
                //     print("Trash Icon Long Pressed");
                //     _deleteJson();
                //     setState(() {
                //       //expanded = false;
                //       selectedWidget = SideBarWidget.trash;
                //       if (SidebarNotifier.instance.openSidebar !=
                //           SideBarWidget.trash) {
                //         SidebarNotifier.instance.openSidebar = selectedWidget;
                //       } else {
                //         SidebarNotifier.instance.openSidebar =
                //             SideBarWidget.none;
                //       }
                //     });
                //   },
                // ),
              ],
            ),
          ),
          // Expanded content column
          if (expanded)
            Expanded(
              child:
                  selectedWidget == SideBarWidget.miniView
                      ? MiniView(
                        pdfAssetPath: "assets/pdfs/lafiamma.pdf",
                        scrollNotifier: widget.scrollNotifier,
                      )
                      : selectedWidget == SideBarWidget.annot
                      ? AnnotationList(scrollNotifier: widget.scrollNotifier)
                      : selectedWidget == SideBarWidget.bookmarks
                      ? FilteredView(
                        isMiniView: true,
                        scrollNotifier: widget.scrollNotifier,
                      )
                      : selectedWidget == SideBarWidget.colorPalette
                      ? Container() //ColorPaletteView()
                      : Container(),
            ),
        ],
      ),
    );

    switch (widget.position) {
      case SidebarPosition.left:
        return Align(alignment: Alignment.centerLeft, child: sidebarContent);
      case SidebarPosition.right:
        return Align(alignment: Alignment.centerRight, child: sidebarContent);
      case SidebarPosition.top:
        return Align(alignment: Alignment.topCenter, child: sidebarContent);
      case SidebarPosition.bottom:
        return Align(alignment: Alignment.bottomCenter, child: sidebarContent);
    }
  }
}
