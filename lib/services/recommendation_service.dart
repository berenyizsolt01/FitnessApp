import '../models/workout_plan.dart';
import '../models/workout_plan_day.dart';
import '../utils/muscle_names.dart';
import 'api_service.dart';

/// Egy edzésnap a hozzá tartozó gyakorlatokkal.
class DayCandidate {
  final WorkoutPlan plan;
  final WorkoutPlanDay day;
  final List<dynamic> exercises;

  const DayCandidate({required this.plan, required this.day, required this.exercises});

  /// Izomcsoportonként hány gyakorlat terheli (magyar izomnevekkel).
  Map<String, int> get muscleWeights {
    final map = <String, int>{};
    for (final ex in exercises) {
      final muscle = MuscleNames.toHungarian((ex as Map)['targetMuscle'] as String?);
      if (muscle != null) map[muscle] = (map[muscle] ?? 0) + 1;
    }
    return map;
  }
}

class Recommendation {
  final DayCandidate candidate;

  /// Az érintett izmok átlagos kipihentsége, 0-100.
  final int readiness;

  const Recommendation({required this.candidate, required this.readiness});
}

class RecommendationService {
  RecommendationService._();

  /// Betölti a felhasználó összes tervének összes napját a gyakorlataikkal.
  static Future<List<DayCandidate>> loadCandidates(int userId) async {
    final plans = await ApiService.getUserPlans(userId);
    final perPlan = await Future.wait(plans.map((plan) async {
      final days = await ApiService.getPlanDays(plan.id);
      return Future.wait(days.map((day) async {
        final exercises = await ApiService.getDayExercises(day.id);
        return DayCandidate(plan: plan, day: day, exercises: exercises);
      }));
    }));
    return perPlan.expand((list) => list).toList();
  }

  /// Kiválasztja azt a napot, amelynek izmai a legkipihentebbek.
  /// Azonos érték esetén a tervben előrébb lévő nap nyer.
  static Recommendation? pick(List<DayCandidate> candidates, Map<String, int> recovery) {
    Recommendation? best;
    for (final candidate in candidates) {
      final weights = candidate.muscleWeights;
      if (weights.isEmpty) continue;

      var total = 0;
      var weighted = 0.0;
      weights.forEach((muscle, count) {
        total += count;
        weighted += (recovery[muscle] ?? 100) * count;
      });

      final readiness = (weighted / total).round();
      if (best == null || readiness > best.readiness) {
        best = Recommendation(candidate: candidate, readiness: readiness);
      }
    }
    return best;
  }
}
