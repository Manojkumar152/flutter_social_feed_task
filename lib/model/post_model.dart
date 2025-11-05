import 'package:get/get.dart';

class Post {
  String id;
  String author;
  String content;
  DateTime createdAt;
  RxInt likes = 0.obs;
  RxBool liked = false.obs;

  Post({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    int initialLikes = 0,
  }) {
    likes.value = initialLikes;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes.value,
        'liked': liked.value,
      };

  factory Post.fromJson(Map<String, dynamic> json) {
    final p = Post(
      id: json['id'],
      author: json['author'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      initialLikes: (json['likes'] ?? 0) as int,
    );
    p.liked.value = json['liked'] ?? false;
    return p;
  }
}
