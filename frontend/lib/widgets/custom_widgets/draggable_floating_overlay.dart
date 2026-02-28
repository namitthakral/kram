import 'package:flutter/material.dart';

class DraggableFloatingOverlay extends StatefulWidget {
  const DraggableFloatingOverlay({
    required this.child,
    required this.onPressed,
    this.isVisible = true,
    super.key,
  });

  final Widget child;
  final VoidCallback onPressed;
  final bool isVisible;

  @override
  State<DraggableFloatingOverlay> createState() =>
      _DraggableFloatingOverlayState();
}

class _DraggableFloatingOverlayState extends State<DraggableFloatingOverlay> {
  // We track position relative to Top-Left for easier calculations.
  Offset? _position;
  bool _isDragging = false;
  Size? _lastConstraints;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // ensure we have valid constraints
      if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
        return widget.child;
      }

      final currentSize = Size(constraints.maxWidth, constraints.maxHeight);
      
      // Initialize position to bottom-right if not set
      if (_position == null) {
        _position = Offset(
          constraints.maxWidth - 56.0 - 24.0,
          constraints.maxHeight - 56.0 - 100.0, // Higher initial position
        );
      } else if (_lastConstraints != null && _lastConstraints != currentSize) {
        // Adjust position when screen size changes
        final oldMaxW = _lastConstraints!.width - 56.0;
        final oldMaxH = _lastConstraints!.height - 56.0;
        final newMaxW = constraints.maxWidth - 56.0;
        final newMaxH = constraints.maxHeight - 56.0;
        
        // Keep the same relative position if possible
        final relativeX = oldMaxW > 0 ? _position!.dx / oldMaxW : 1.0;
        final relativeY = oldMaxH > 0 ? _position!.dy / oldMaxH : 1.0;
        
        _position = Offset(
          (relativeX * newMaxW).clamp(0.0, newMaxW),
          (relativeY * newMaxH).clamp(0.0, newMaxH),
        );
      }
      
      _lastConstraints = currentSize;

      return Stack(
        children: [
          widget.child,
          if (widget.isVisible)
            Positioned(
              left: _position!.dx,
              top: _position!.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _isDragging = true;
                    // Update position
                    var newX = _position!.dx + details.delta.dx;
                    var newY = _position!.dy + details.delta.dy;

                    // Constraints
                    final maxW = constraints.maxWidth - 56.0; // Button width
                    final maxH = constraints.maxHeight - 56.0; // Button height

                    // Clamp to screen
                    newX = newX.clamp(0.0, maxW);
                    newY = newY.clamp(0.0, maxH);

                    _position = Offset(newX, newY);
                  });
                },
                onPanEnd: (details) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _isDragging = false;
                  });
                },
                child: GestureDetector(
                  onTap: _isDragging ? null : widget.onPressed,
                  child: Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
