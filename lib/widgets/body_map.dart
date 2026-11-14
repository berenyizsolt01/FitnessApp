import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'body_shapes.dart';

/// Egyszerű SVG-szerű útvonal (M, L, C, Z, abszolút koordináták) Flutter Path-tá alakítása.
Path parseBodyPath(String d) {
  final path = Path();
  final tokens = RegExp(r'[MLCZ]|-?\d+(?:\.\d+)?')
      .allMatches(d)
      .map((m) => m.group(0)!)
      .toList();
  var i = 0;
  var cmd = '';
  double next() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    final t = tokens[i];
    if (t == 'M' || t == 'L' || t == 'C' || t == 'Z') {
      cmd = t;
      i++;
      if (cmd == 'Z') path.close();
      continue;
    }
    switch (cmd) {
      case 'M':
        path.moveTo(next(), next());
        cmd = 'L';
      case 'L':
        path.lineTo(next(), next());
      case 'C':
        path.cubicTo(next(), next(), next(), next(), next(), next());
      default:
        i++;
    }
  }
  return path;
}

class _ParsedShape {
  final BodyShape shape;
  final Path left;
  final Path right;
  const _ParsedShape(this.shape, this.left, this.right);
}

// Vízszintes tükrözés a vászon közepe körül (x' = 200 - x).
final Float64List _mirror = Float64List.fromList(<double>[
  -1, 0, 0, 0, //
  0, 1, 0, 0, //
  0, 0, 1, 0, //
  bodyCanvasWidth, 0, 0, 1,
]);

List<_ParsedShape> _parse(List<BodyShape> shapes) {
  return shapes.map((s) {
    final left = parseBodyPath(s.path);
    return _ParsedShape(s, left, left.transform(_mirror));
  }).toList();
}

final List<_ParsedShape> _frontParsed = _parse(frontBodyShapes);
final List<_ParsedShape> _backParsed = _parse(backBodyShapes);

/// Testtérkép: az izomcsoportok a kipihentségüknek megfelelő színt kapják.
/// [recovery]: izomnév (magyarul) -> kipihentség százalékban.
class BodyMap extends StatelessWidget {
  final bool front;
  final Map<String, int> recovery;

  const BodyMap({super.key, required this.front, required this.recovery});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: bodyCanvasWidth / bodyCanvasHeight,
      child: CustomPaint(painter: _BodyMapPainter(front: front, recovery: recovery)),
    );
  }
}

class _BodyMapPainter extends CustomPainter {
  final bool front;
  final Map<String, int> recovery;

  const _BodyMapPainter({required this.front, required this.recovery});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / bodyCanvasWidth, size.height / bodyCanvasHeight);
    final dx = (size.width - bodyCanvasWidth * scale) / 2;
    final dy = (size.height - bodyCanvasHeight * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final shapes = front ? _frontParsed : _backParsed;

    // 1) A kimerült izmok körül halvány vörös fény.
    for (final s in shapes) {
      final muscle = s.shape.muscle;
      if (muscle == null) continue;
      final pct = recovery[muscle] ?? 100;
      if (pct >= 40) continue;
      final glow = Paint()
        ..color = AppColors.recovery(pct).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(s.left, glow);
      canvas.drawPath(s.right, glow);
    }

    // 2) A formák kitöltése és körvonala.
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.background;

    for (final s in shapes) {
      final muscle = s.shape.muscle;
      fill.color = muscle == null
          ? AppColors.surfaceHigh
          : AppColors.recovery(recovery[muscle] ?? 100);
      canvas.drawPath(s.left, fill);
      canvas.drawPath(s.right, fill);
      if (!s.shape.seamless) {
        canvas.drawPath(s.left, stroke);
        canvas.drawPath(s.right, stroke);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BodyMapPainter old) =>
      old.front != front || !mapEquals(old.recovery, recovery);
}
