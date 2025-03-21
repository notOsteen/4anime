import 'package:anime_player/views/bookmarks.dart';
import 'package:anime_player/controller/anime.dart';
import 'package:anime_player/views/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AnimeController controller = Get.find();

  final _style = TextStyle(color: Colors.white);

  @override
  void initState() {
    super.initState();
    setData();
  }

  void setData() async {
    await controller.loadData();
    controller.initializeWebView();
  }

  Future<bool> _onBackPressed() async {
    String? currentUrl = await controller.webController.currentUrl();
    if (currentUrl == controller.homeUrl.value) {
      return await _showExitDialog();
    } else {
      if (await controller.webController.canGoBack()) {
        controller.webController.goBack();
        return false;
      } else {
        return true;
      }
    }
  }

  Future<bool> _showExitDialog() async {
    return await Get.defaultDialog(
          title: "Exit App",
          middleText: "Are you sure you want to exit?",
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text("Exit"),
            ),
          ],
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF161616),
          surfaceTintColor: Colors.transparent,
          // foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          title: Text('4Anime', style: _style),
          actions: [
            GetBuilder<AnimeController>(
              builder: (controller) {
                bool isBookmarked = controller.isBookmarked(
                  controller.lastWatched.value,
                );
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'toggle_bookmark':
                        controller.toggleBookmark(
                          "Bookmark",
                          controller.lastWatched.value,
                        );
                        break;
                      case 'bookmarks':
                        Get.to(() => BookmarkScreen());
                        break;
                      case 'history':
                        Get.to(() => HistoryScreen());
                        break;
                      case 'reload':
                        controller.webController.reload();
                        break;
                      case 'exit':
                        _showExitDialog();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'toggle_bookmark',
                          child: ListTile(
                            leading: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            title: Text(
                              isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
                              style: _style,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'bookmarks',
                          child: ListTile(
                            leading: const Icon(
                              Icons.list,
                              color: Colors.white,
                            ),
                            title: Text('View Bookmarks', style: _style),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'history',
                          child: ListTile(
                            leading: const Icon(
                              Icons.history,
                              color: Colors.white,
                            ),
                            title: Text('History', style: _style),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'reload',
                          child: ListTile(
                            leading: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            title: Text('Reload', style: _style),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'exit',
                          child: ListTile(
                            leading: const Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                            ),
                            title: Text('Exit', style: _style),
                          ),
                        ),
                      ],
                  menuPadding: EdgeInsets.zero,
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  iconColor: Colors.white,
                  color: Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ],
        ),
        body: GetBuilder<AnimeController>(
          builder:
              (controller) =>
                  WebViewWidget(controller: controller.webController),
        ),
      ),
    );
  }
}
