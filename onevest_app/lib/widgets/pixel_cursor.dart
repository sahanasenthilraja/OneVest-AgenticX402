import 'package:flutter/material.dart';

class PixelCursor extends StatefulWidget {
  final Widget child;

  const PixelCursor({
    super.key,
    required this.child,
  });

  @override
  State<PixelCursor> createState() => _PixelCursorState();
}

class _PixelCursorState extends State<PixelCursor> {
  Offset cursorPosition = Offset.zero;

  bool isInside = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.none,
      onEnter: (event) {
        setState(() {
          isInside = true;
          cursorPosition = event.position;
        });
      },
      onHover: (event) {
        setState(() {
          cursorPosition = event.position;
        });
      },
      onExit: (_) {
        setState(() {
          isInside = false;
        });
      },
      child: Stack(
        children: [
          widget.child,

          if (isInside)
            Positioned(
              left: cursorPosition.dx,
              top: cursorPosition.dy,
              child: IgnorePointer(
                child: Transform.translate(
                  offset: const Offset(-2, -2),
                  child: const _PixelArrowCursor(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PixelArrowCursor extends StatelessWidget {
  const _PixelArrowCursor();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(26, 30),
      painter: _PixelCursorPainter(),
    );
  }
}

class _PixelCursorPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint darkPaint = Paint()
      ..color = const Color(0xFF071020)
      ..style = PaintingStyle.fill;

    // Dark pixel outline
    final Path outline = Path();

    outline.moveTo(2, 1);
    outline.lineTo(2, 23);
    outline.lineTo(8, 18);
    outline.lineTo(13, 27);
    outline.lineTo(17, 25);
    outline.lineTo(12, 17);
    outline.lineTo(22, 17);
    outline.close();

    canvas.drawPath(
      outline,
      darkPaint,
    );

    // White inner cursor
    final Path cursor = Path();

    cursor.moveTo(4, 4);
    cursor.lineTo(4, 19);
    cursor.lineTo(9, 15);
    cursor.lineTo(14, 24);
    cursor.lineTo(16, 23);
    cursor.lineTo(11, 15);
    cursor.lineTo(19, 15);
    cursor.close();

    canvas.drawPath(
      cursor,
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}