import 'package:flutter/material.dart';

import '../config.dart';
import '../models/workout_plan.dart';
import '../services/api_service.dart';
import '../widgets/error_views.dart';
import 'create_plan_screen.dart';
import 'workout_plan_detail_screen.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});
  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}
class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  List<WorkoutPlan> _plans = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final data = await ApiService.getUserPlans(currentUserId);
      if (!mounted) return;
      setState(() {
        _plans = data;
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
      appBar: AppBar(title: const Text('Saját Edzéstervek')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _hasError
              ? ErrorRetryView(onRetry: _fetchPlans)
              : _plans.isEmpty
              ? const Center(
                  child: Text(
                    'Még nincs edzéstervd.\nA + gombbal készíthetsz egyet!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.amber),
                    title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(plan.description ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutPlanDetailScreen(plan: plan)));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final created = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePlanScreen()));
          if (created == true) {
            _fetchPlans();
          }
        },
      ),
    );
  }
}
