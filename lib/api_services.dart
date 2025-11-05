import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> fetchPosts({int page = 1, int limit = 10}) async {
    return await get('/posts?_page=$page&_limit=$limit');
  }

  static Future<Map<String, dynamic>> fetchUser(int userId) async {
    return await get('/users/$userId');
  }

  static Future<List<dynamic>> fetchComments(int postId) async {
    return await get('/comments?postId=$postId');
  }

  static Future<Map<String, dynamic>> addComment(
      int postId, String name, String email, String body) async {
    return {
      'postId': postId,
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'email': email,
      'body': body,
    };
  }
}
