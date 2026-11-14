import 'package:flutter/material.dart';

import '../config.dart';

/// Rövid, semleges tájékoztató üzenet (pl. hiányzó mező).
void showInfoSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Piros hibaüzenet. Alapértelmezetten az API elérhetetlenségét jelzi.
void showApiError(BuildContext context, [String? message]) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade800,
        content: Text(message ?? 'Nem sikerült elérni a szervert. Fut az API ($apiBaseUrl)?'),
      ),
    );
}

class ErrorRetryView extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorRetryView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Nem sikerült elérni a szervert.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Ellenőrizd, hogy az API fut-e ($apiBaseUrl).', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: Colors.black),
            label: const Text('Újrapróbálás', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
