import 'package:flutter/material.dart';

import '../models/workout_plan_day.dart';
import '../screens/active_workout_screen.dart';
import '../services/api_service.dart';
import 'error_views.dart';

class DayExercisesTile extends StatefulWidget {
  final WorkoutPlanDay day;
  const DayExercisesTile({super.key, required this.day});
  @override
  State<DayExercisesTile> createState() => _DayExercisesTileState();
}
class _DayExercisesTileState extends State<DayExercisesTile> {
  List<dynamic> _exercises = [];
  bool _isLoading = false;
  bool _isFetched = false;

  Future<void> _fetchDayExercises() async {
    if (_isFetched) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getDayExercises(widget.day.id);
      if (!mounted) return;
      setState(() {
        _exercises = data;
        _isLoading = false;
        _isFetched = true;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showApiError(context, 'A gyakorlatok betöltése nem sikerült.');
    }
  }

  void _startWorkout(BuildContext context) async {
    if (!_isFetched) await _fetchDayExercises();
    if (_exercises.isEmpty) return;
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(day: widget.day, exercises: _exercises)));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(widget.day.dayName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
        onExpansionChanged: (expanded) {
          if (expanded) _fetchDayExercises();
        },
        children: [
          if (_isLoading) const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: Colors.amber))
          else if (_exercises.isEmpty) const Padding(padding: EdgeInsets.all(16.0), child: Text('Nincs rögzített gyakorlat.', style: TextStyle(color: Colors.grey)))
          else
            Column(
              children: [
                ..._exercises.map((ex) {
                  return ListTile(
                    dense: true, leading: const Icon(Icons.fitness_center, size: 20, color: Colors.amber),
                    title: Text(ex['exerciseName'], style: const TextStyle(fontSize: 16)), subtitle: Text('Célizom: ${ex['targetMuscle']}'),
                    trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text('${ex['sets']} x ${ex['reps']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
                  );
                }),
                Padding(padding: const EdgeInsets.all(12.0), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), onPressed: () => _startWorkout(context), icon: const Icon(Icons.play_arrow, color: Colors.black), label: const Text('EDZÉS INDÍTÁSA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))),
              ],
            ),
        ],
      ),
    );
  }
}
