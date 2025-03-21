import 'package:anime_player/controller/anime.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryScreen extends StatelessWidget {
  final AnimeController controller = Get.find();

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              controller.clearHistory();
            },
          ),
        ],
      ),
      body: GetBuilder<AnimeController>(
        builder: (controller) {
          return controller.history.isEmpty
              ? const Center(child: Text("No history available"))
              : ListView.builder(
                itemCount: controller.history.length,
                itemBuilder: (context, index) {
                  final url = controller.history[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(url, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.removeFromHistory(url),
                    ),
                    onTap: () {
                      Get.back();
                      controller.loadUrl(url);
                    },
                  );
                },
              );
        },
      ),
    );
  }
}
