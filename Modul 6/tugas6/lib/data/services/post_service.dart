import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class PostService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<PostModel>> fetchPosts() async {
    final response = await http.get(Uri.parse('$_baseUrl/posts'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch posts');
    }

    final List<dynamic> jsonData = jsonDecode(response.body) as List<dynamic>;
    return jsonData
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
