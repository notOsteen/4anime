import 'package:anime_player/controller/anime.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookmarkScreen extends StatelessWidget {
  final AnimeController controller = Get.find();

  BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: controller.clearBookmarks,
          ),
        ],
      ),
      body: GetBuilder<AnimeController>(
        builder: (controller) {
          return controller.bookmarks.isEmpty
              ? const Center(child: Text("No bookmarks available"))
              : ListView.builder(
                itemCount: controller.bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = controller.bookmarks[index];
                  return ListTile(
                    leading: const Icon(Icons.bookmark, color: Colors.blue),
                    title: Text(bookmark['title']!),
                    subtitle: Text(bookmark['url']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed:
                          () => controller.removeBookmark(bookmark['url']!),
                    ),
                    onTap: () {
                      Get.back();
                      controller.loadUrl(bookmark['url']!);
                    },
                  );
                },
              );
        },
      ),
    );
  }
}
