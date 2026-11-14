import 'package:flutter/material.dart';

import '../config.dart';
import '../models/equipment_item.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';
import '../widgets/error_views.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableExercises();
  }

  Future<void> _fetchAvailableExercises() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final data = await ApiService.getAvailableExercises(currentUserId);
      if (!mounted) return;
      setState(() {
        _exercises = data;
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

  Future<void> _openEquipmentDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      ),
    );

    try {
      final items = await ApiService.getEquipmentItems(currentUserId);
      if (!mounted) return;
      Navigator.pop(context);
      _showEquipmentModal(items);
    } on ApiException {
      if (!mounted) return;
      Navigator.pop(context);
      showApiError(context);
    }
  }

  void _showEquipmentModal(List<EquipmentItem> items) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Otthoni Eszközök'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return CheckboxListTile(
                      title: Text(item.nameHU),
                      value: item.isSelected,
                      activeColor: Colors.amber,
                      onChanged: (val) => setModalState(() => item.isSelected = val ?? false),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mégse'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    final selectedIds = items.where((i) => i.isSelected).map((i) => i.id).toList();
                    try {
                      await ApiService.saveUserEquipment(currentUserId, selectedIds);
                    } on ApiException {
                      if (mounted) showApiError(this.context, 'Az eszközök mentése nem sikerült.');
                    }
                    _fetchAvailableExercises();
                  },
                  child: const Text('Mentés', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elérhető Gyakorlatok'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center, color: Colors.amber),
            onPressed: _openEquipmentDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _hasError
              ? ErrorRetryView(onRetry: _fetchAvailableExercises)
              : _exercises.isEmpty
              ? const Center(child: Text('Nincs elérhető gyakorlat.\nKattints a súlyzó ikonra és állítsd be az eszközeidet!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final ex = _exercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          ex.nameHU,
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(ex.descriptionHU),
                        trailing: Chip(
                          label: Text(ex.targetMuscle, style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
