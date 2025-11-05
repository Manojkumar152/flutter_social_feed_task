import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart'
    show GetxController;
import 'package:hive/hive.dart';
import 'package:social_feed/model/post_model.dart';

class FeedController extends GetxController {
  final posts = <Post>[].obs;
  final box = Hive.box('appBox');
  static const _feedKey = 'feed_posts';

  @override
  void onInit() {
    super.onInit();
    _loadFromHive();

    if (posts.isEmpty) {
      posts.addAll([
        Post(
          id: 'p1',
          author: 'Alice',
          content: 'Welcome to Mini Social Feed! 🎉',
          createdAt: DateTime.now().subtract(Duration(minutes: 10)),
          initialLikes: 3,
        ),
        Post(
          id: 'p2',
          author: 'Bob',
          content: 'This app now uses Hive for local caching.',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          initialLikes: 1,
        )
      ]);
      _saveToHive();
    }
  }

  void addPost(String author, String content) {
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: author,
      content: content,
      createdAt: DateTime.now(),
    );
    posts.insert(0, newPost);
    _saveToHive();
  }

  void toggleLike(Post p) {
    if (p.liked.value) {
      p.liked.value = false;
      p.likes.value = p.likes.value - 1;
    } else {
      p.liked.value = true;
      p.likes.value = p.likes.value + 1;
    }
    _saveToHive();
  }

  void _saveToHive() {
    final serial = posts.map((p) => p.toJson()).toList();
    box.put(_feedKey, jsonEncode(serial));
  }

  void _loadFromHive() {
    final raw = box.get(_feedKey);
    if (raw is String) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        posts.clear();
        for (final item in decoded) {
          posts.add(Post.fromJson(Map<String, dynamic>.from(item)));
        }
      } catch (_) {}
    }
  }
}
