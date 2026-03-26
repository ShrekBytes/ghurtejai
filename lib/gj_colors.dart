import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────
class GJ {
  static const Color yellow = Color(0xFFFFC832);
  static const Color pink   = Color(0xFFFF4D8D);
  static const Color green  = Color(0xFFC5F135);
  static const Color blue   = Color(0xFFADD8F7);
  static const Color dark   = Color(0xFF1A1A1A);
  static const Color white  = Color(0xFFFFFBF0);
  static const Color grey   = Color(0xFFF0EDE0);
}

// ─────────────────────────────────────────────────────────
//  SHARED: TOP HEADER BAR
// ─────────────────────────────────────────────────────────
class GJHeader extends StatelessWidget {
  final bool showBack;
  const GJHeader({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: GJ.yellow,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: GJ.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GJ.dark, width: 2),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: GJ.dark, size: 18),
              ),
            )
          else
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: GJ.dark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GJ.dark, width: 2),
              ),
              child: const Center(
                child: Text('GJ',
                    style: TextStyle(
                        color: GJ.yellow, fontWeight: FontWeight.w900,
                        fontSize: 12, fontFamily: 'Courier')),
              ),
            ),
          const SizedBox(width: 10),
          const Text('GhurteJai',
              style: TextStyle(
                  fontFamily: 'Courier', fontSize: 18,
                  fontWeight: FontWeight.w900, color: GJ.dark)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: GJ.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: GJ.dark, width: 2),
            ),
            child: Row(
              children: const [
                Icon(Icons.explore_rounded, size: 14, color: GJ.dark),
                SizedBox(width: 5),
                Text('Explore',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        fontFamily: 'Courier', color: GJ.dark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SHARED: NEO INPUT FIELD
// ─────────────────────────────────────────────────────────
class GJTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final Color focusColor;
  final String? errorText;

  const GJTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.focusColor = GJ.pink,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
          fontFamily: 'Courier', fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontFamily: 'Courier', fontWeight: FontWeight.w700,
            color: GJ.dark, fontSize: 13),
        errorText: errorText,
        errorStyle: const TextStyle(
            fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon, color: GJ.dark, size: 20),
        suffixIcon: onToggleObscure != null
            ? GestureDetector(
                onTap: onToggleObscure,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: GJ.dark, size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: GJ.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: GJ.dark, width: 2.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: GJ.dark, width: 2.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: focusColor, width: 3)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 3)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SHARED: NEO BUTTON
// ─────────────────────────────────────────────────────────
class GJButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const GJButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GJ.dark, width: 2.5),
          boxShadow: const [BoxShadow(offset: Offset(4, 4), color: GJ.dark)],
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontFamily: 'Courier', fontSize: 15,
                  fontWeight: FontWeight.w900, color: GJ.dark)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SHARED: DOT PATTERN PAINTER
// ─────────────────────────────────────────────────────────
class DotPatternPainter extends CustomPainter {
  final Color color;
  const DotPatternPainter({this.color = const Color(0x22FFFFFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double x = 0; x < size.width; x += 18) {
      for (double y = 0; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 2, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────
//  SHARED: MOUNTAIN PAINTER  (Login hero)
// ─────────────────────────────────────────────────────────
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sun
    canvas.drawCircle(Offset(w * 0.78, h * 0.28), 26,
        Paint()..color = const Color(0xFFFFC832));
    canvas.drawCircle(
        Offset(w * 0.78, h * 0.28), 26,
        Paint()
          ..color = GJ.dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Back mountain
    final back = Path()
      ..moveTo(w * 0.42, h)
      ..lineTo(w * 0.62, h * 0.42)
      ..lineTo(w * 0.82, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0x44FFFFFF));
    canvas.drawPath(
        back,
        Paint()
          ..color = GJ.dark.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Front mountain
    final front = Path()
      ..moveTo(w * 0.52, h)
      ..lineTo(w * 0.72, h * 0.32)
      ..lineTo(w * 0.92, h)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0x66FFFFFF));
    canvas.drawPath(
        front,
        Paint()
          ..color = GJ.dark.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Snow cap
    final snow = Path()
      ..moveTo(w * 0.72, h * 0.32)
      ..lineTo(w * 0.68, h * 0.46)
      ..lineTo(w * 0.76, h * 0.46)
      ..close();
    canvas.drawPath(snow, Paint()..color = GJ.white.withOpacity(0.9));

    // Clouds
    _cloud(canvas, Offset(w * 0.55, h * 0.15), 18, GJ.white.withOpacity(0.5));
    _cloud(canvas, Offset(w * 0.65, h * 0.24), 13, GJ.white.withOpacity(0.3));
  }

  void _cloud(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c.translate(r * 1.1, r * 0.2), r * 0.75, p);
    canvas.drawCircle(c.translate(-r * 0.9, r * 0.2), r * 0.65, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────
//  SHARED: MAP PAINTER  (Signup hero)
// ─────────────────────────────────────────────────────────
class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final line = Paint()
      ..color = GJ.dark.withOpacity(0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final route1 = Path()
      ..moveTo(w * 0.45, h * 0.9)
      ..cubicTo(w * 0.55, h * 0.6, w * 0.65, h * 0.7, w * 0.75, h * 0.45)
      ..cubicTo(w * 0.82, h * 0.3, w * 0.88, h * 0.35, w * 0.92, h * 0.2);
    canvas.drawPath(route1, line);

    _pin(canvas, Offset(w * 0.75, h * 0.38), GJ.pink, 14);
    _pin(canvas, Offset(w * 0.92, h * 0.14), GJ.pink, 11);
    _pin(canvas, Offset(w * 0.6, h * 0.32), const Color(0xFFFFC832), 10);
  }

  void _pin(Canvas canvas, Offset pos, Color color, double r) {
    canvas.drawCircle(pos, r, Paint()..color = color);
    canvas.drawCircle(pos, r,
        Paint()
          ..color = GJ.dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(pos, r * 0.4, Paint()..color = GJ.dark);
    final tail = Path()
      ..moveTo(pos.dx - r * 0.5, pos.dy + r * 0.7)
      ..lineTo(pos.dx, pos.dy + r * 1.8)
      ..lineTo(pos.dx + r * 0.5, pos.dy + r * 0.7)
      ..close();
    canvas.drawPath(tail, Paint()..color = color);
    canvas.drawPath(
        tail,
        Paint()
          ..color = GJ.dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_) => false;
}
