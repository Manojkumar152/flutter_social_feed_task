import 'package:get/get.dart';

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String userName;

  RxBool liked = false.obs;
  RxInt likes = 0.obs;
  RxInt comments = 0.obs;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.userName,
    bool liked = false,
    int likes = 0,
    int comments = 0,
  }) {
    this.liked.value = liked;
    this.likes.value = likes;
    this.comments.value = comments;
  }

  factory Post.fromJson(Map<String, dynamic> json, String userName) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      userName: userName,
      comments: (json['id'] ?? 0) % 5 + 1,
    );
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      body: map['body'],
      userName: map['userName'],
      liked: map['liked'] ?? false,
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'userName': userName,
      'liked': liked.value,
      'likes': likes.value,
      'comments': comments.value,
    };
  }
}
