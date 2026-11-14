/// Az izomnevek egységesítése magyarra (az API ugyanezt csinálja a szerveren).
class MuscleNames {
  MuscleNames._();

  static const Map<String, String> _map = {
    'chest': 'Mell', 'mell': 'Mell',
    'back': 'Hát', 'lats': 'Hát', 'hát': 'Hát',
    'shoulders': 'Váll', 'shoulder': 'Váll', 'váll': 'Váll',
    'biceps': 'Bicepsz', 'bicepsz': 'Bicepsz',
    'triceps': 'Tricepsz', 'tricepsz': 'Tricepsz',
    'legs': 'Láb', 'quads': 'Láb', 'hamstrings': 'Láb', 'glutes': 'Láb', 'calves': 'Láb', 'láb': 'Láb',
    'abs': 'Has', 'core': 'Has', 'has': 'Has',
  };

  static String? toHungarian(String? muscle) {
    if (muscle == null) return null;
    return _map[muscle.trim().toLowerCase()];
  }
}
