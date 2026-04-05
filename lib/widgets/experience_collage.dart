import 'package:flutter/material.dart';

/// Matches [AppColors] from explore.dart without importing it (avoids import cycles).
class _C {
  static const surfaceHigh = Color(0xFF242837);
  static const textMuted = Color(0xFF5A6070);
  static const border = Color(0xFF2A2F3E);
}

/// Small filmstrip collage (4 slots) for experience cards.
class ExperienceCollageSmall extends StatelessWidget {
  final List<String> paths;
  final double height;

  const ExperienceCollageSmall({
    super.key,
    required this.paths,
    this.height = 120,
  });

  List<String> get _p {
    final out = List<String>.from(paths);
    while (out.length < 4) {
      out.add('');
    }
    return out.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(flex: 5, child: _tile(p[0])),
          const SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(child: _tile(p[1])),
                const SizedBox(height: 2),
                Expanded(child: _tile(p[2])),
                const SizedBox(height: 2),
                Expanded(child: _tile(p[3], overlayCount: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(String path, {bool overlayCount = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExperienceAssetImage(path: path),
          if (overlayCount)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              alignment: Alignment.center,
              child: const Text(
                '+',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Large hero collage for detail header.
class ExperienceCollageHero extends StatelessWidget {
  final List<String> paths;
  final double height;

  const ExperienceCollageHero({
    super.key,
    required this.paths,
    this.height = 220,
  });

  List<String> get _p {
    final out = List<String>.from(paths);
    while (out.length < 4) {
      out.add('');
    }
    return out.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(flex: 5, child: _rounded(_big(p[0]))),
          const SizedBox(width: 3),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(child: _rounded(_big(p[1]))),
                const SizedBox(height: 3),
                Expanded(child: _rounded(_big(p[2]))),
                const SizedBox(height: 3),
                Expanded(child: _rounded(_big(p[3]))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rounded(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: child,
    );
  }

  Widget _big(String path) => ExperienceAssetImage(path: path);
}

class ExperienceAssetImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const ExperienceAssetImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return ColoredBox(
        color: _C.surfaceHigh,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: _C.textMuted,
            size: 22,
          ),
        ),
      );
    }
    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: _C.surfaceHigh,
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: _C.textMuted,
            size: 22,
          ),
        ),
      ),
    );
  }
}
