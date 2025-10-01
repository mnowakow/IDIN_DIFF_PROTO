import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:idin_diff_prototype/annotation_filter_notifier.dart';
import 'package:idin_diff_prototype/scroll_notifier.dart';
import 'package:vector_graphics/vector_graphics.dart' as vg;
import 'package:idin_diff_prototype/annotation_notifier.dart';
import 'package:idin_diff_prototype/sidebar_notifier.dart';

class Annotation extends StatefulWidget {
  final Widget annotationContent;
  final Offset position;
  final double scale;
  @override
  final GlobalKey key;
  final AnnotationNotifier annotationNotifier;
  final ScrollNotifier scrollNotifier;
  final ScrollController scrollController;
  final String owner;

  const Annotation({
    required this.key,
    required this.annotationContent,
    required this.position,
    required this.annotationNotifier,
    required this.scrollNotifier,
    required this.scrollController,
    required this.owner,
    this.scale = 1.0,
  });

  @override
  _AnnotationState createState() => _AnnotationState();
}

class _AnnotationState extends State<Annotation> {
  late Offset _position;
  late double _width;
  late double _height;
  bool _isTapped = false;
  bool _isDragging = false;

  bool _disposed = false;
  VoidCallback? _sidebarListener;
  bool _iAmOwner = false;

  bool _isVisible = true;

  double _getAnnotationWidth() {
    if (widget.annotationContent is SvgPicture) {
      return (widget.annotationContent as SvgPicture).width! / 10;
    } else if (widget.annotationContent is Image) {
      return (widget.annotationContent as Image).width?.toDouble() ?? 200;
    } else if (widget.annotationContent is SizedBox) {
      final sizedBox = widget.annotationContent as SizedBox;
      return sizedBox.width?.toDouble() ?? 200;
    } else if (widget.annotationContent is ClipRRect) {
      final clipRRect = widget.annotationContent as ClipRRect;
      if (clipRRect.child is SizedBox) {
        final sizedBox = clipRRect.child as SizedBox;
        return sizedBox.width?.toDouble() ?? 200;
      }
    }
    return 200;
  }

  double _getAnnotationHeight() {
    if (widget.annotationContent is SvgPicture) {
      return (widget.annotationContent as SvgPicture).height! / 10;
    } else if (widget.annotationContent is Image) {
      return (widget.annotationContent as Image).height?.toDouble() ?? 200;
    } else if (widget.annotationContent is SizedBox) {
      final sizedBox = widget.annotationContent as SizedBox;
      return sizedBox.height?.toDouble() ?? 200;
    } else if (widget.annotationContent is ClipRRect) {
      final clipRRect = widget.annotationContent as ClipRRect;
      if (clipRRect.child is SizedBox) {
        final sizedBox = clipRRect.child as SizedBox;
        return sizedBox.height?.toDouble() ?? 200;
      }
    }
    return 200;
  }

  void checkFilter() {
    Map<String, bool> filter = AnnotationFilterNotifier.instance.filter;
    if (filter.containsKey(widget.owner)) {
      setState(() {
        _isVisible = filter[widget.owner]!;
      });
    } else {
      setState(() {
        _isVisible = true; // Default to visible if not in filter
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AnnotationFilterNotifier.instance.addListener(checkFilter);
    _position = widget.position;
    _width = _getAnnotationWidth();
    _height = _getAnnotationHeight();
    _iAmOwner = widget.owner == widget.annotationNotifier.currentUser;

    // Listener SICHER hinzufügen
    _sidebarListener = () {
      if (_disposed || !mounted) return;

      if (SidebarNotifier.instance.openSidebar == SideBarWidget.trash) {
        widget.annotationNotifier.clearAll();
      }

      if (_disposed || !mounted) return;
      setState(() {
        // Rebuild to show/hide resize handle
      });
    };
    SidebarNotifier.instance.addListener(_sidebarListener!);

    // SVG Position anpassen
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_disposed || !mounted) return;

      if (widget.annotationContent is SvgPicture) {
        setState(() {
          _position = widget.position - Offset(_width / 2, _height / 2);
        });
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;

    // Listener ENTFERNEN
    if (_sidebarListener != null) {
      SidebarNotifier.instance.removeListener(_sidebarListener!);
    }

    super.dispose();
  }

  // Sichere setState Methode
  void _safeSetState(VoidCallback fn) {
    print("Owner: ${widget.owner}, isVisible: $_isVisible");
    if (_disposed || !mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return SizedBox.shrink();

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (!_iAmOwner) return;
          _safeSetState(() {
            _isDragging = true;

            // Auto-scroll when near screen edges
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final scrollThreshold =
                200.0; // Distance from edge to trigger scroll

            // Calculate distances from edges
            final distanceFromTop = details.globalPosition.dy;
            final distanceFromBottom = screenHeight - details.globalPosition.dy;
            final distanceFromLeft = details.globalPosition.dx;
            final distanceFromRight = screenWidth - details.globalPosition.dx;

            // Calculate scroll speeds for both axes
            final verticalScrollSpeed =
                distanceFromTop < scrollThreshold
                    ? (scrollThreshold - distanceFromTop) /
                            scrollThreshold *
                            20.0 +
                        2.0
                    : distanceFromBottom < scrollThreshold
                    ? (scrollThreshold - distanceFromBottom) /
                            scrollThreshold *
                            20.0 +
                        2.0
                    : 0.0;

            final horizontalScrollSpeed =
                distanceFromLeft < scrollThreshold
                    ? (scrollThreshold - distanceFromLeft) /
                            scrollThreshold *
                            20.0 +
                        2.0
                    : distanceFromRight < scrollThreshold
                    ? (scrollThreshold - distanceFromRight) /
                            scrollThreshold *
                            20.0 +
                        2.0
                    : 0.0;

            double verticalOffset = 0.0;
            double horizontalOffset = 0.0;

            // Handle vertical scrolling
            if (distanceFromTop < scrollThreshold) {
              // Near top edge - scroll up
              widget.scrollNotifier.scrollBy(
                -verticalScrollSpeed,
                widget.scrollController,
              );
              verticalOffset = -verticalScrollSpeed;
            } else if (distanceFromBottom < scrollThreshold) {
              // Near bottom edge - scroll down
              widget.scrollNotifier.scrollBy(
                verticalScrollSpeed,
                widget.scrollController,
              );
              verticalOffset = verticalScrollSpeed;
            }

            // Handle horizontal scrolling (if your scroll notifier supports it)
            if (distanceFromLeft < scrollThreshold) {
              // Near left edge - scroll left
              // widget.notifier.scrollNotifier.scrollHorizontallyBy(-horizontalScrollSpeed);
              horizontalOffset = -horizontalScrollSpeed;
            } else if (distanceFromRight < scrollThreshold) {
              // Near right edge - scroll right
              // widget.notifier.scrollNotifier.scrollHorizontallyBy(horizontalScrollSpeed);
              horizontalOffset = horizontalScrollSpeed;
            }

            _position +=
                details.delta + Offset(horizontalOffset, verticalOffset);

            // Prevent position from going above the top edge or left edge
            if (_position.dy < 0) {
              _position = Offset(_position.dx, 0);
            }
            if (_position.dx < 0) {
              _position = Offset(0, _position.dy);
            }
          });
        },
        onPanEnd: (details) {
          if (!_iAmOwner) return;
          _safeSetState(() => _isDragging = false);
          widget.annotationNotifier.updateAnnotation(
            widget.key,
            newPosition: _position,
          );
        },
        onTap: () {
          if (!_iAmOwner) return;
          _safeSetState(() => _isTapped = !_isTapped);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: _width,
              height: _height,
              decoration:
                  _isTapped || _isDragging
                      ? BoxDecoration(
                        border: Border.all(
                          color: Colors.blueGrey.shade100,
                          width: 5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blueGrey.shade50.withOpacity(0.3),
                      )
                      : BoxDecoration(
                        border: Border.all(
                          color:
                              AnnotationFilterNotifier
                                  .instance
                                  .userColors[widget.owner] ??
                              Colors.transparent,
                          width: 5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
              child: FittedBox(
                fit: BoxFit.fill,
                child: widget.annotationContent,
              ),
            ),
            Positioned(
              // Copy button
              top: 0,
              left: 0,
              child: GestureDetector(
                onTapUp: (details) {
                  if (_iAmOwner) return;
                  widget.annotationNotifier.duplicateAnnotation(widget);
                  setState(() {
                    _isVisible = false;
                  });
                },
                child: Container(
                  width: _iAmOwner ? 20 : 40,
                  height: _iAmOwner ? 20 : 40,
                  decoration:
                      _iAmOwner
                          ? null
                          : BoxDecoration(
                            color: Colors.amber.shade300,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                  child: Center(
                    child:
                        _iAmOwner
                            ? Icon(Icons.check_circle_rounded, size: 20)
                            : Icon(Icons.content_copy_rounded, size: 40),
                  ),
                ),
              ),
            ),
            if (_isTapped) ...[
              Positioned(
                // Resize handle
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _width += details.delta.dx;
                      _height += details.delta.dy;
                      if (_width < 20) _width = 20;
                      if (_height < 20) _height = 20;
                    });
                  },
                  onPanEnd:
                      (details) => {
                        widget.annotationNotifier.updateAnnotation(
                          widget.key,
                          newWidth: _width,
                          newHeight: _height,
                        ),
                      },
                  onTap: () => {print('Resize tapped')},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.zoom_out_map_outlined, size: 40),
                    ),
                  ),
                ),
              ),
              Positioned(
                // Delete button
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTapUp:
                      (details) => {
                        // widget.annotationNotifier.removeAnnotationByKey(
                        //   widget.key,
                        // ),
                        widget.annotationNotifier.removeAnnotation(widget),
                      },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Icon(Icons.delete, size: 40)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
