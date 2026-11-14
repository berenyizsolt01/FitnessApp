/// A testtérkép formái. Egy 200 x 430-as vásznon, csak a bal félre megadva,
/// a jobb felét a rajzoló tükrözi. A `muscle == null` semleges testrész.
///
/// Az útvonalak egyszerű SVG-szerű parancsokat használnak (M, L, C, Z, abszolút koordináták).
class BodyShape {
  /// Az izomcsoport magyar neve (Mell, Váll, Hát, Bicepsz, Tricepsz, Has, Láb), vagy null.
  final String? muscle;
  final String path;

  /// Ha igaz, nincs körvonal, hogy a középvonalon ne látszódjon varrat (fej, nyak, medence).
  final bool seamless;

  const BodyShape(this.muscle, this.path, {this.seamless = false});
}

const double bodyCanvasWidth = 200;
const double bodyCanvasHeight = 430;

const List<BodyShape> frontBodyShapes = [
  BodyShape(null, 'M 100 8 C 88 8 80 18 80 30 C 80 42 88 52 100 52 Z', seamless: true),
  BodyShape(null, 'M 100 54 L 92 54 C 92 62 91 66 88 70 L 100 74 Z', seamless: true),
  BodyShape('Váll', 'M 68 76 C 58 72 48 76 44 88 C 41 98 43 110 49 116 C 57 114 63 106 67 98 Z'),
  BodyShape('Mell', 'M 98 80 C 88 76 77 76 70 82 C 68 94 70 106 76 114 C 84 122 93 120 98 116 Z'),
  BodyShape('Has', 'M 98 126 L 85 126 C 83 146 83 172 87 194 C 91 202 95 204 98 204 Z'),
  BodyShape(null, 'M 83 124 C 76 132 72 152 74 190 L 85 196 C 81 172 81 146 83 126 Z'),
  BodyShape(null, 'M 98 206 L 86 198 C 76 202 70 212 70 224 C 76 234 90 240 98 242 Z', seamless: true),
  BodyShape('Bicepsz', 'M 46 120 C 39 132 37 148 39 164 C 43 170 51 170 55 164 C 59 148 59 134 57 122 Z'),
  BodyShape(null, 'M 39 168 C 33 188 29 210 29 230 L 39 234 C 43 214 51 192 55 170 Z'),
  BodyShape(null, 'M 29 236 C 25 246 27 256 33 260 C 39 256 41 246 39 236 Z'),
  BodyShape('Láb', 'M 98 246 C 88 244 78 240 72 232 C 66 256 66 284 70 306 C 78 314 90 314 98 308 Z'),
  BodyShape('Láb', 'M 72 320 C 68 344 68 370 73 396 C 79 402 87 402 91 396 C 95 370 97 344 98 322 C 90 326 80 326 72 320 Z'),
  BodyShape(null, 'M 73 400 C 67 408 65 416 71 421 L 92 421 C 94 413 93 405 91 400 Z'),
];

const List<BodyShape> backBodyShapes = [
  BodyShape(null, 'M 100 8 C 88 8 80 18 80 30 C 80 42 88 52 100 52 Z', seamless: true),
  BodyShape(null, 'M 100 54 L 92 54 C 92 62 91 66 88 70 L 100 74 Z', seamless: true),
  BodyShape('Váll', 'M 68 76 C 58 72 48 76 44 88 C 41 98 43 110 49 116 C 57 114 63 106 67 98 Z'),
  BodyShape('Hát', 'M 100 70 L 90 72 C 80 76 72 80 68 86 C 74 98 88 108 100 116 Z'),
  BodyShape('Hát', 'M 100 120 C 90 112 78 104 70 100 C 68 116 71 142 79 162 C 87 168 94 168 100 168 Z'),
  BodyShape('Hát', 'M 100 172 L 82 170 C 80 182 82 194 86 204 C 92 208 97 208 100 208 Z'),
  BodyShape('Tricepsz', 'M 46 120 C 39 132 37 148 39 164 C 43 170 51 170 55 164 C 59 148 59 134 57 122 Z'),
  BodyShape(null, 'M 39 168 C 33 188 29 210 29 230 L 39 234 C 43 214 51 192 55 170 Z'),
  BodyShape(null, 'M 29 236 C 25 246 27 256 33 260 C 39 256 41 246 39 236 Z'),
  BodyShape('Láb', 'M 100 212 C 90 208 80 210 72 218 C 68 230 72 244 84 250 C 92 252 98 250 100 248 Z'),
  BodyShape('Láb', 'M 98 254 C 88 256 78 254 72 248 C 66 266 66 288 70 306 C 78 314 90 314 98 308 Z'),
  BodyShape('Láb', 'M 72 320 C 66 340 68 364 74 388 C 80 396 88 396 92 388 C 96 364 98 340 98 322 C 90 326 80 326 72 320 Z'),
  BodyShape(null, 'M 74 398 C 68 406 66 414 72 420 L 92 420 C 94 412 93 404 91 398 Z'),
];
