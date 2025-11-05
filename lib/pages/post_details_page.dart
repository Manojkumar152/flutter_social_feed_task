import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_feed/api_services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

import 'package:social_feed/model/post_model.dart';

class PostDetailsPage extends StatefulWidget {
  final Post post;
  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final Box box = Hive.box('appBox');
  final commentController = TextEditingController();
  final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
     
      final cached = box.get('comments_post_${widget.post.id}');

      if (cached != null) {
        comments.assignAll(List<Map<String, dynamic>>.from(cached));
      }

      
      final fetched = await ApiService.fetchComments(widget.post.id);
      comments.assignAll(List<Map<String, dynamic>>.from(fetched));

      
      await box.put('comments_post_${widget.post.id}', comments);
    } catch (e) {
      final cached = box.get('comments_post_${widget.post.id}');
      if (cached != null) {
        comments.assignAll(List<Map<String, dynamic>>.from(cached));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment() async {
    if (commentController.text.isEmpty) return;
    final box = await Hive.openBox('appBox');
    final userEmail = box.get('userEmail');

    final newComment = await ApiService.addComment(
      widget.post.id,
      'You',
      userEmail,
      commentController.text,
    );

    comments.insert(0, newComment); //   updates list
    await box.put('comments_post_${widget.post.id}', comments);

    widget.post.comments.value++; //  updates Home feed count

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            comment['name'].toString().toUpperCase() ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              comment['body'].toString().capitalizeFirst ?? ''),
                          trailing: Text(comment['email'] ?? ''),
                        ),
                      );
                    },
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: addComment,
                  )
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
