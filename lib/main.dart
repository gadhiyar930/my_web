import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MacOSDock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class MacOSDock extends StatefulWidget {
  const MacOSDock({
    super.key,
    required this.items,
  });

  final List<IconData> items;

  @override
  State<MacOSDock> createState() => _MacOSDockState();
}

class _MacOSDockState extends State<MacOSDock> {
  late List<IconData> _items;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  // Calculate size based on hover position
  double _getSize(int index) {
    if (_hoveredIndex == null) return 48;

    final distance = (index - _hoveredIndex!).abs();
    if (distance == 0) return 64;
    if (distance == 1) return 56;
    return 48;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ReorderableRow(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return MouseRegion(
            key: ValueKey(item),
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: _getSize(index),
              height: _getSize(index),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.primaries[item.hashCode % Colors.primaries.length],
                boxShadow: [
                  if (_hoveredIndex == index)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Center(
                child: Icon(
                  item,
                  color: Colors.white,
                  size: _getSize(index) * 0.6,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ReorderableRow extends StatefulWidget {
  const ReorderableRow({
    super.key,
    required this.children,
    required this.onReorder,
  });

  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  State<ReorderableRow> createState() => _ReorderableRowState();
}

class _ReorderableRowState extends State<ReorderableRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return Draggable<int>(
          data: index,
          feedback: child,
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: child,
          ),
          onDragStarted: () {},
          onDragEnd: (_) {},
          child: DragTarget<int>(
            onWillAccept: (data) => data != index,
            onAccept: (draggedIndex) {
              widget.onReorder(draggedIndex, index);
            },
            builder: (context, candidateData, rejectedData) {
              return child;
            },
          ),
        );
      }).toList(),
    );
  }
}
