import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../models/workout_plan_day.dart';
import '../services/api_service.dart';
import '../widgets/day_exercises_tile.dart';
import '../widgets/error_views.dart';

class WorkoutPlanDetailScreen extends StatefulWidget {
  final WorkoutPlan plan;
  const WorkoutPlanDetailScreen({super.key, required this.plan});
  @override
  State<WorkoutPlanDetailScreen> createState() => _WorkoutPlanDetailScreenState();
}
class _WorkoutPlanDetailScreenState extends State<WorkoutPlanDetailScreen> {
  List<WorkoutPlanDay> _days = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchDays();
  }

  Future<void> _fetchDays() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final data = await ApiService.getPlanDays(widget.plan.id);
      if (!mounted) return;
      setState(() {
        _days = data;
        _isLoading = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _hasError
              ? ErrorRetryView(onRetry: _fetchDays)
              : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                return DayExercisesTile(day: day);
              },
            ),
    );
  }
}
