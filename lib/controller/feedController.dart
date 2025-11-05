import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:social_feed/api_services.dart';
import 'package:social_feed/model/post_model.dart';

class FeedController extends GetxController {
  final posts = <Post>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;
  int _page = 0;
  final int _limit = 10;
  late Box box;
  RxBool isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box('appBox');
    loadCachedPosts();
    checkNetwork();
    fetchPosts();
  }

  void checkNetwork() async {
    final connectivity = await Connectivity().checkConnectivity();
    isOffline.value = connectivity == ConnectivityResult.none;

    Connectivity().onConnectivityChanged.listen((result) {
      final wasOffline = isOffline.value;
      isOffline.value = result == ConnectivityResult.none;
      if (wasOffline && !isOffline.value) {
        fetchPosts(refresh: true);
      }
    });
  }

  void loadCachedPosts() {
    final cached = box.get('cached_posts', defaultValue: []);
    if (cached.isNotEmpty) {
      posts.assignAll(cached
          .map<Post>((e) => Post.fromMap(Map<String, dynamic>.from(e)))
          .toList());
    }
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (isOffline.value || isLoading.value) return;
    if (refresh) {
      posts.clear();
      hasMore.value = true;
      _page = 0;
    }
    if (!hasMore.value) return;

    isLoading.value = true;
    _page++;
    try {
      final data = await ApiService.fetchPosts(page: _page, limit: _limit);
      if (data.isEmpty) {
        hasMore.value = false;
      } else {
        for (var postJson in data) {
          final user = await ApiService.fetchUser(postJson['userId']);
          final post = Post.fromJson(postJson, user['name']);
          posts.add(post);
        }
        await box.put('cached_posts', posts.map((e) => e.toMap()).toList());
      }
    } catch (e) {
      _page--;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLike(Post post) {
    post.liked.value = !post.liked.value;
    post.likes.value += post.liked.value ? 1 : -1;
    box.put('cached_posts', posts.map((e) => e.toMap()).toList());
  }
}
