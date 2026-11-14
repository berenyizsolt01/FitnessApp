import 'package:flutter/material.dart';

import '../config.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';
import '../widgets/error_views.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});
  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}
class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final List _days = [];
  List<Exercise> _availableExercises = [];
  bool _isLoadingExercises = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableExercises();
  }

  Future<void> _loadAvailableExercises() async {
    try {
      final data = await ApiService.getAvailableExercises(currentUserId);
      if (!mounted) return;
      setState(() {
        _availableExercises = data;
        _isLoadingExercises = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _isLoadingExercises = false);
      showApiError(context, 'A gyakorlatok betöltése nem sikerült.');
    }
  }

  void _addDay() {
    setState(() {
      _days.add({
        'dayNumber': _days.length + 1,
        'dayName': '${_days.length + 1}. Nap: Új edzésnap',
        'exercises': [],
      });
    });
  }

  void _showAddExerciseDialog(int dayIndex) {
    if (_availableExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nincsenek elérhető gyakorlatok.')));
      return;
    }

    Exercise selectedEx = _availableExercises.first;
    final setsController = TextEditingController(text: '4');
    final repsController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Gyakorlat Hozzáadása'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Exercise>(
                      value: selectedEx,
                      decoration: const InputDecoration(labelText: 'Gyakorlat'),
                      isExpanded: true,
                      items: _availableExercises.map((ex) {
                        return DropdownMenuItem<Exercise>(
                          value: ex,
                          child: Text('${ex.nameHU} (${ex.targetMuscle})', overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedEx = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: setsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sorozat'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ismétlés'))),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mégse')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: () {
                    final int s = int.tryParse(setsController.text) ?? 4;
                    final int r = int.tryParse(repsController.text) ?? 10;
                    setState(() {
                      (_days[dayIndex]['exercises'] as List).add({'exerciseId': selectedEx.id, 'exerciseName': selectedEx.nameHU, 'sets': s, 'reps': r});
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Hozzáadás', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _savePlan() async {
    if (_nameController.text.trim().isEmpty) {
      showInfoSnack(context, 'Adj nevet az edzéstervnek!');
      return;
    }

    final Map<String, dynamic> payload = {
      'userId': currentUserId,
      'name': _nameController.text,
      'description': _descController.text,
      'days': _days,
    };

    try {
      await ApiService.createPlan(payload);
      if (!mounted) return;
      showInfoSnack(context, 'Edzésterv sikeresen elmentve!');
      Navigator.pop(context, true);
    } on ApiException {
      if (mounted) showApiError(context, 'Az edzésterv mentése nem sikerült.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Új Edzésterv Készítése')),
      body: _isLoadingExercises
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Edzésterv neve', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Leírás (opcionális)', border: OutlineInputBorder())),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Edzésnapok', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                      ElevatedButton.icon(
                        onPressed: _addDay, icon: const Icon(Icons.add, size: 18), label: const Text('Nap hozzáadása'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _days.length,
                    itemBuilder: (context, idx) {
                      var day = _days[idx];
                      List dayExList = day['exercises'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber, width: 0.5), borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(initialValue: day['dayName'], decoration: InputDecoration(labelText: '${idx + 1}. Nap megnevezése'), onChanged: (val) => day['dayName'] = val),
                              const SizedBox(height: 8),
                              ...dayExList.asMap().entries.map((exEntry) {
                                int exIdx = exEntry.key;
                                var ex = exEntry.value;
                                return ListTile(
                                  dense: true, leading: const Icon(Icons.fitness_center, size: 18, color: Colors.amber),
                                  title: Text(ex['exerciseName']), subtitle: Text('${ex['sets']} sorozat × ${ex['reps']} ismétlés'),
                                  trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => setState(() => dayExList.removeAt(exIdx))),
                                );
                              }),
                              Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _showAddExerciseDialog(idx), icon: const Icon(Icons.add, size: 16, color: Colors.amber), label: const Text('Gyakorlat hozzáadása', style: TextStyle(color: Colors.amber)))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), onPressed: _savePlan, child: const Text('EDZÉSTERV MENTÉSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)))),
                ],
              ),
            ),
    );
  }
}
