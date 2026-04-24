import 'dart:convert';

import '../../core/storage/local_storage.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

enum PostsDataSource { server, cache }

class PostsResult {
  final List<PostModel> posts;
  final PostsDataSource source;

  const PostsResult({required this.posts, required this.source});
}

class PostRepository {
  final PostService postService;

  PostRepository({required this.postService});

  Future<PostsResult> getPosts() async {
    try {
      final posts = await postService.fetchPosts();
      final jsonString = jsonEncode(
        posts.map((post) => post.toJson()).toList(),
      );
      await LocalStorage.saveCachedPosts(jsonString);
      return PostsResult(posts: posts, source: PostsDataSource.server);
    } catch (_) {
      final cachedData = await LocalStorage.getCachedPosts();
      if (cachedData != null) {
        final List<dynamic> jsonData = jsonDecode(cachedData) as List<dynamic>;
        final cachedPosts = jsonData
            .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return PostsResult(posts: cachedPosts, source: PostsDataSource.cache);
      }

      rethrow;
    }
  }
}
