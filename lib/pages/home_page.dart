import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_feed/controller/authController.dart';
import 'package:social_feed/controller/feedController.dart';

class HomePage extends StatelessWidget {
  final auth = Get.find<AuthController>();
  final feed = Get.find<FeedController>();
  final newPostController = TextEditingController();

  void _openNewPostDialog(BuildContext context) {
    newPostController.clear();
    Get.dialog(
      AlertDialog(
        title: Text('Create Post'),
        content: TextField(
          controller: newPostController,
          maxLines: 3,
          decoration: InputDecoration(hintText: 'What\'s on your mind?'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final text = newPostController.text.trim();
              if (text.isNotEmpty) {
                feed.addPost(auth.userEmail.value, text);
                Get.back();
              }
            },
            child: Text('Post'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        actions: [
          IconButton(onPressed: () => auth.logout(), icon: Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNewPostDialog(context),
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        if (feed.posts.isEmpty) return Center(child: Text('No posts yet'));
        return ListView.builder(
          itemCount: feed.posts.length,
          itemBuilder: (context, index) {
            final post = feed.posts[index];
            return Card(
              margin: EdgeInsets.all(12),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Text(post.author[0].toUpperCase())),
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(post.author,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Obx(() => IconButton(
                              icon: Icon(
                                  post.liked.value
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: post.liked.value ? Colors.red : null),
                              onPressed: () => feed.toggleLike(post),
                            )),
                        Obx(() => Text('${post.likes.value}')),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(post.content),
                    SizedBox(height: 4),
                    Text(_timeAgo(post.createdAt),
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
