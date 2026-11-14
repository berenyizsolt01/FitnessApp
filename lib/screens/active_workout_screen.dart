import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';
import '../models/workout_plan_day.dart';
import '../services/api_service.dart';
import '../widgets/error_views.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutPlanDay day;
  final List<dynamic> exercises;
  const ActiveWorkoutScreen({super.key, required this.day, required this.exercises});
  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}
class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late DateTime _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  final List _loggedExercises = [];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
    for (var ex in widget.exercises) {
      int setsCount = ex['sets'] ?? 4;
      int defaultReps = ex['reps'] ?? 10;
      final setsList = [];
      for (int i = 1; i <= setsCount; i++) {
        setsList.add({'setNumber': i, 'weightController': TextEditingController(text: '0'), 'repsController': TextEditingController(text: defaultReps.toString()), 'isDone': false});
      }
      _loggedExercises.add({'exerciseId': ex['exerciseId'], 'exerciseName': ex['exerciseName'], 'targetMuscle': ex['targetMuscle'], 'sets': setsList});
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _elapsedSeconds++));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final h = (totalSeconds ~/ 3600);
    final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Future<void> _finishWorkout() async {
    final setsPayload = [];
    for (var ex in _loggedExercises) {
      for (var s in ex['sets']) {
        if (s['isDone'] == true) {
          setsPayload.add({'exerciseId': ex['exerciseId'], 'setNumber': s['setNumber'], 'weightKg': double.tryParse(s['weightController'].text) ?? 0.0, 'repsCompleted': int.tryParse(s['repsController'].text) ?? 0});
        }
      }
    }
    if (setsPayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Legalább 1 teljesített sorozatot pipálj ki a mentéshez!')));
      return;
    }
    final payload = {'userId': currentUserId, 'workoutPlanDayId': widget.day.id, 'startTime': _startTime.toIso8601String(), 'endTime': DateTime.now().toIso8601String(), 'notes': 'Edzésrögzítés', 'sets': setsPayload};
    try {
      await ApiService.saveWorkoutLog(payload);
      if (!mounted) return;
      showInfoSnack(context, 'Edzés sikeresen elmentve!');
      Navigator.pop(context);
    } on ApiException {
      if (mounted) showApiError(context, 'Az edzés mentése nem sikerült, próbáld újra. Az adataid nem vesztek el.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.day.dayName), actions: [Padding(padding: const EdgeInsets.only(right: 16.0), child: Row(children: [const Icon(Icons.timer, color: Colors.amber, size: 20), const SizedBox(width: 4), Text(_formatDuration(_elapsedSeconds), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber))]))]),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16), itemCount: _loggedExercises.length,
              itemBuilder: (context, exIdx) {
                var ex = _loggedExercises[exIdx];
                List sets = ex['sets'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex['exerciseName'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                        const SizedBox(height: 12),
                        Row(children: const [SizedBox(width: 40, child: Text('Sor.', style: TextStyle(color: Colors.grey, fontSize: 12))), Expanded(child: Text('Súly (kg)', style: TextStyle(color: Colors.grey, fontSize: 12))), SizedBox(width: 8), Expanded(child: Text('Ismétlés', style: TextStyle(color: Colors.grey, fontSize: 12))), SizedBox(width: 48, child: Text('Kész', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center))]),
                        const Divider(),
                        ...sets.map((s) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(width: 40, child: Text('${s['setNumber']}.', style: const TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: TextField(controller: s['weightController'], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)))),
                                const SizedBox(width: 8),
                                Expanded(child: TextField(controller: s['repsController'], keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)))),
                                SizedBox(width: 48, child: Checkbox(value: s['isDone'], activeColor: Colors.amber, onChanged: (val) => setState(() => s['isDone'] = val ?? false))),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(padding: const EdgeInsets.all(16), color: const Color(0xFF1E1E1E), child: SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), onPressed: _finishWorkout, child: const Text('EDZÉS BEFEJEZÉSE ÉS MENTÉSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))))),
        ],
      ),
    );
  }
}
