import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AnimeController extends GetxController {
  late WebViewController webController;
  RxString homeUrl = "https://4anime.gg".obs;
  RxString lastWatched = "".obs;
  List<String> history = [];
  List<Map<String, String>> bookmarks = [];

  @override
  void onInit() {
    super.onInit();
    loadData();
    initializeWebView();
  }

  void initializeWebView() {
    webController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) {
                saveLastWatched(url);
                addToHistory(url);
              },
              onUrlChange: (change) {
                saveLastWatched(change.url ?? '');
              },
            ),
          )
          ..loadRequest(Uri.parse(homeUrl.value));
  }

  /// **Save last watched URL**
  Future<void> saveLastWatched(String url) async {
    if (url.isNotEmpty) {
      lastWatched.value = url;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_watched', url);
      update(); // Notify UI updates
    }
  }

  /// **Add to history (Avoid duplicates)**
  Future<void> addToHistory(String url) async {
    if (url.isNotEmpty && !history.contains(url)) {
      history.add(url);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('history', history);
      update(); // Notify UI updates
    }
  }

  /// **Remove item from history**
  Future<void> removeFromHistory(String url) async {
    history.remove(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', history);
    update(); // Notify UI updates
  }

  /// **Clear entire watch history**
  Future<void> clearHistory() async {
    history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    update(); // Notify UI updates
  }

  /// **Add bookmark (Avoid duplicates)**
  Future<void> addBookmark(String title, String url) async {
    if (url.isNotEmpty && !bookmarks.any((b) => b['url'] == url)) {
      bookmarks.add({"title": title, "url": url});
      await _saveBookmarks();
      Get.snackbar("Bookmark Added", "Saved: $title");
      update(); // Notify UI updates
    }
  }

  /// **Remove a bookmark**
  Future<void> removeBookmark(String url) async {
    bookmarks.removeWhere((b) => b['url'] == url);
    await _saveBookmarks();
    Get.snackbar("Bookmark Removed", "Deleted bookmark");
    update(); // Notify UI updates
  }

  /// **Toggle bookmark (Add/Remove)**
  void toggleBookmark(String title, String url) {
    if (isBookmarked(url)) {
      removeBookmark(url);
    } else {
      addBookmark(title, url);
    }
  }

  /// **Check if URL is bookmarked**
  bool isBookmarked(String url) {
    return bookmarks.any((b) => b['url'] == url);
  }

  /// **Clear all bookmarks**
  Future<void> clearBookmarks() async {
    bookmarks.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookmarks');
    update(); // Notify UI updates
  }

  /// **Save bookmarks to SharedPreferences**
  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'bookmarks',
      bookmarks.map((b) => "${b['title']}|${b['url']}").toList(),
    );
  }

  /// **Load data from SharedPreferences**
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    lastWatched.value = prefs.getString('last_watched') ?? "";
    history = prefs.getStringList('history') ?? [];
    await _loadBookmarks();
    update();

    if (lastWatched.value.isNotEmpty) {
      homeUrl.value = lastWatched.value;
    }
  }

  /// **Load bookmarks from SharedPreferences**
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedBookmarks = prefs.getStringList('bookmarks') ?? [];
    bookmarks =
        storedBookmarks.map((b) {
          final parts = b.split('|');
          return {"title": parts[0], "url": parts[1]};
        }).toList();
    update(); // Notify UI updates
  }

  /// **Load a URL in WebView**
  void loadUrl(String url) {
    webController.loadRequest(Uri.parse(url));
    saveLastWatched(url);
  }
}
