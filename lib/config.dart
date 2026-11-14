import 'package:flutter/foundation.dart';

/// Az API címe felülírható futtatáskor, pl. valódi telefonnál a gép IP-címével:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.23:5080
const String _apiOverride = String.fromEnvironment('API_BASE_URL');

String get apiBaseUrl {
  if (_apiOverride.isNotEmpty) return _apiOverride;
  // Android emulátorban a gép "localhost"-ja a 10.0.2.2 címen érhető el.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5080';
  }
  return 'http://localhost:5080';
}

/// Egyelőre egyetlen, fix felhasználó. Bejelentkezés bevezetésekor ez lecserélődik.
const int currentUserId = 1;
