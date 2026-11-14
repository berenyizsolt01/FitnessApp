import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/equipment_item.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';
import '../models/workout_plan_day.dart';

/// Minden hálózati vagy szerverhiba ilyen kivételként érkezik a képernyőkhöz.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Az összes API-hívás egy helyen. A képernyők nem használnak közvetlenül http-t.
class ApiService {
  ApiService._();

  static const Duration _timeout = Duration(seconds: 8);
  static const Map<String, String> _jsonHeaders = {'Content-Type': 'application/json'};

  static Uri _uri(String path) => Uri.parse('$apiBaseUrl$path');

  /// Bármilyen hibát (időtúllépés, kapcsolat, hibás JSON) ApiException-ná alakít.
  static Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Nem sikerült elérni a szervert: $e');
    }
  }

  static dynamic _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Szerverhiba (${res.statusCode})', res.statusCode);
    }
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  static Future<dynamic> _get(String path) async {
    final res = await http.get(_uri(path)).timeout(_timeout);
    return _decode(res);
  }

  static Future<dynamic> _post(String path, Object body) async {
    final res = await http
        .post(_uri(path), headers: _jsonHeaders, body: jsonEncode(body))
        .timeout(_timeout);
    return _decode(res);
  }

  // ---------- Gyakorlatok és eszközök ----------

  static Future<List<Exercise>> getAvailableExercises(int userId) => _run(() async {
        final data = await _get('/api/exercises/available/$userId') as List;
        return data.map((j) => Exercise.fromJson(j as Map<String, dynamic>)).toList();
      });

  /// Az összes választható eszköz, a felhasználó saját eszközei bejelölve.
  static Future<List<EquipmentItem>> getEquipmentItems(int userId) => _run(() async {
        final all = await _get('/api/equipment') as List;
        final owned = (await _get('/api/equipment/user/$userId') as List).cast<int>();
        return all.map((j) {
          final map = j as Map<String, dynamic>;
          return EquipmentItem.fromJson(map, isSelected: owned.contains(map['id']));
        }).toList();
      });

  static Future<void> saveUserEquipment(int userId, List<int> equipmentIds) => _run(() async {
        await _post('/api/equipment/user/$userId', equipmentIds);
      });

  // ---------- Edzéstervek ----------

  static Future<List<WorkoutPlan>> getUserPlans(int userId) => _run(() async {
        final data = await _get('/api/workoutplans/user/$userId') as List;
        return data.map((j) => WorkoutPlan.fromJson(j as Map<String, dynamic>)).toList();
      });

  static Future<List<WorkoutPlanDay>> getPlanDays(int planId) => _run(() async {
        final data = await _get('/api/workoutplans/$planId/days') as List;
        return data.map((j) => WorkoutPlanDay.fromJson(j as Map<String, dynamic>)).toList();
      });

  static Future<List<dynamic>> getDayExercises(int dayId) => _run(() async {
        return await _get('/api/workoutplans/days/$dayId/exercises') as List<dynamic>;
      });

  static Future<void> createPlan(Map<String, dynamic> payload) => _run(() async {
        await _post('/api/workoutplans', payload);
      });

  // ---------- Edzésnapló és statisztika ----------

  static Future<void> saveWorkoutLog(Map<String, dynamic> payload) => _run(() async {
        await _post('/api/workoutlogs', payload);
      });

  static Future<List<dynamic>> getUserLogs(int userId) => _run(() async {
        return await _get('/api/workoutlogs/user/$userId') as List<dynamic>;
      });

  static Future<List<dynamic>> getMuscleRecovery(int userId) => _run(() async {
        return await _get('/api/workoutlogs/user/$userId/muscle-recovery') as List<dynamic>;
      });
}
