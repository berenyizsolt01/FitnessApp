import 'package:flutter/material.dart';

import '../config.dart';
import '../services/api_service.dart';
import '../widgets/error_views.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});
  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}
class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final data = await ApiService.getUserLogs(currentUserId);
      if (!mounted) return;
      setState(() {
        _logs = data;
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
    double totalVolumeAll = 0;
    int totalSetsAll = 0;
    for (var log in _logs) {
      totalVolumeAll += (log['totalVolume'] ?? 0).toDouble();
      totalSetsAll += (log['totalSets'] ?? 0) as int;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Előzmények és Statisztika'), actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.amber), onPressed: _fetchLogs)]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _hasError
              ? ErrorRetryView(onRetry: _fetchLogs)
              : _logs.isEmpty
              ? const Center(child: Text('Még nincs elmentett edzésed.', style: TextStyle(color: Colors.grey, fontSize: 16)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        color: const Color(0xFF1E1E1E), shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber, width: 0.8), borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Edzések', '${_logs.length} db', Icons.emoji_events),
                              _buildStatItem('Összsúly', '${totalVolumeAll.toStringAsFixed(0)} kg', Icons.fitness_center),
                              _buildStatItem('Sorozatok', '$totalSetsAll db', Icons.repeat),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          final List sets = log['sets'] ?? [];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: const Icon(Icons.check_circle, color: Colors.amber),
                              title: Text(log['dayName'] ?? 'Edzés', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                              subtitle: Text('${(log['totalVolume'] ?? 0).toDouble().toStringAsFixed(0)} kg mozgatva', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              children: sets.map((s) => ListTile(dense: true, title: Text('${s['exerciseName']}'), trailing: Text('${s['weightKg']} kg × ${s['repsCompleted']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)))).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(children: [Icon(icon, color: Colors.amber, size: 24), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))]);
  }
}
