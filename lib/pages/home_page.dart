import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_feed/controller/authController.dart';
import 'package:social_feed/controller/feedController.dart';
import 'package:social_feed/model/post_model.dart';
import 'package:social_feed/pages/post_details_page.dart';

class HomePage extends StatelessWidget {
  final feed = Get.find<FeedController>();
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final scroll = ScrollController();

    scroll.addListener(() {
      if (scroll.position.pixels >= scroll.position.maxScrollExtent - 100) {
        feed.fetchPosts();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(onPressed: auth.logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: Obx(() {
        if (feed.isLoading.value && feed.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => feed.fetchPosts(refresh: true),
          child: ListView.builder(
            controller: scroll,
            itemCount: feed.posts.length + (feed.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == feed.posts.length) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final post = feed.posts[index];
              return PostCard(post: post);
            },
          ),
        );
      }),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final feed = Get.find<FeedController>();

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Hero(
            tag: 'post_${post.id}',
            child: Text(post.userName.toString().toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title.toString().capitalizeFirst ?? '',
                style: const TextStyle(fontWeight: FontWeight.normal)),
            // const SizedBox(height: 8),
            Text(post.body.toString().capitalizeFirst ?? ''),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => IconButton(
                      icon: Icon(
                          post.liked.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: post.liked.value ? Colors.red : null),
                      onPressed: () => feed.toggleLike(post),
                    )),
                Obx(() => Text('${post.comments.value} Comments')),
              ],
            ),
          ],
        ),
        onTap: () => Get.to(() => PostDetailsPage(post: post)),
      ),
    );
  }
}
