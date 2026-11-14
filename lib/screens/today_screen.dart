import 'package:flutter/material.dart';

import '../config.dart';
import '../services/api_service.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/body_map.dart';
import '../widgets/error_views.dart';
import 'active_workout_screen.dart';
import 'create_plan_screen.dart';

/// Kezdőképernyő: mai edzésajánló és az izmok regenerációs térképe.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _front = true;
  Map<String, int> _recovery = {};
  List<DayCandidate> _candidates = [];
  Recommendation? _recommendation;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// [silent]: húzásos frissítésnél nem cseréljük le a képernyőt töltésjelzőre.
  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
    try {
      final raw = await ApiService.getMuscleRecovery(currentUserId);
      final candidates = await RecommendationService.loadCandidates(currentUserId);
      if (!mounted) return;

      final recovery = <String, int>{};
      for (final r in raw) {
        recovery[r['muscle'] as String] = (r['recoveryPercentage'] as num).toInt();
      }

      setState(() {
        _recovery = recovery;
        _candidates = candidates;
        _recommendation = RecommendationService.pick(candidates, recovery);
        _isLoading = false;
        _hasError = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = !silent;
      });
      if (silent) showApiError(context);
    }
  }

  Future<void> _startWorkout(Recommendation rec) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          day: rec.candidate.day,
          exercises: rec.candidate.exercises,
        ),
      ),
    );
    if (mounted) _load(silent: true);
  }

  Future<void> _createPlan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePlanScreen()),
    );
    if (mounted) _load(silent: true);
  }

  String _dateLabel() {
    const days = ['hétfő', 'kedd', 'szerda', 'csütörtök', 'péntek', 'szombat', 'vasárnap'];
    const months = [
      'január', 'február', 'március', 'április', 'május', 'június',
      'július', 'augusztus', 'szeptember', 'október', 'november', 'december',
    ];
    final now = DateTime.now();
    final day = days[now.weekday - 1];
    return '${day[0].toUpperCase()}${day.substring(1)}, ${months[now.month - 1]} ${now.day}.';
  }

  String _readinessMessage(int readiness) {
    if (readiness >= 80) return 'Az érintett izmaid kipihentek, mehet a munka!';
    if (readiness >= 50) {
      return 'Rendben van, de néhány izmod még regenerálódik. Ma mérsékeld a súlyokat.';
    }
    return 'Az érintett izmaid még pihennek. Ma inkább pihenőnap vagy könnyű mozgás javasolt.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? ErrorRetryView(onRetry: _load)
                : RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.surfaceHigh,
                    onRefresh: () => _load(silent: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildRecommendationCard(),
                        const SizedBox(height: 16),
                        _buildBodyCard(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _dateLabel(),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          'Mit edzzek ma?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.1),
        ),
      ],
    );
  }

  // ---------------- Ajánlókártya ----------------

  Widget _buildRecommendationCard() {
    if (_candidates.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.event_note_rounded,
        title: 'Még nincs edzéstervd',
        text: 'Készíts egy tervet, és megmondom, melyik napot érdemes ma edzened a kipihent izmaid alapján.',
        buttonLabel: 'Terv készítése',
      );
    }
    final rec = _recommendation;
    if (rec == null) {
      return _buildEmptyCard(
        icon: Icons.fitness_center_rounded,
        title: 'A terveidben nincsenek gyakorlatok',
        text: 'Adj gyakorlatokat az edzésnapokhoz, hogy ajánlani tudjak.',
        buttonLabel: 'Új terv készítése',
      );
    }

    final color = AppColors.recovery(rec.readiness);
    final muscles = rec.candidate.muscleWeights.keys.toList()
      ..sort((a, b) => (_recovery[a] ?? 100).compareTo(_recovery[b] ?? 100));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.16), AppColors.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AJÁNLOTT EDZÉS',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rec.candidate.day.dayName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rec.candidate.plan.name,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: CircularProgressIndicator(
                        value: rec.readiness / 100,
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                        color: color,
                        backgroundColor: AppColors.border,
                      ),
                    ),
                    Text(
                      '${rec.readiness}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _readinessMessage(rec.readiness),
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final m in muscles) _musclePill(m, _recovery[m] ?? 100)],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startWorkout(rec),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Edzés indítása'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String text,
    required String buttonLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: AppColors.textMuted, height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _createPlan, child: Text(buttonLabel)),
          ),
        ],
      ),
    );
  }

  // ---------------- Testtérkép kártya ----------------

  Widget _buildBodyCard() {
    final pills = _recovery.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Izom-regeneráció', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: true, label: Text('Elöl')),
                ButtonSegment(value: false, label: Text('Hátul')),
              ],
              selected: {_front},
              onSelectionChanged: (s) => setState(() => _front = s.first),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 340,
              child: BodyMap(front: _front, recovery: _recovery),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                colors: [AppColors.recovery(0), AppColors.recovery(50), AppColors.recovery(100)],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kimerült', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text('Kipihent', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final e in pills) _musclePill(e.key, e.value)],
          ),
          const SizedBox(height: 14),
          const Text(
            'A kipihentség az utolsó edzésed óta eltelt időből számolódik: kb. 48 óra kell a teljes regenerációhoz. Tájékoztató jellegű becslés.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _musclePill(String muscle, int percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: AppColors.recovery(percent), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('$muscle  $percent%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
