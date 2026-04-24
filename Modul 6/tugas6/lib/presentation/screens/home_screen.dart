import 'package:flutter/material.dart';

import '../../core/storage/local_storage.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/services/post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final PostRepository _postRepository = PostRepository(
    postService: PostService(),
  );

  String savedUsername = 'Belum ada data';
  List<PostModel> posts = [];
  bool isLoadingUsername = true;
  bool isLoadingPosts = true;
  String dataSourceLabel = '-';
  String? postsError;

  @override
  void initState() {
    super.initState();
    loadUsername();
    loadPosts();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> loadUsername() async {
    final username = await LocalStorage.getUsername();
    if (!mounted) {
      return;
    }

    setState(() {
      savedUsername = username ?? 'Belum ada data';
      isLoadingUsername = false;
    });
  }

  Future<void> saveUsername() async {
    await LocalStorage.saveUsername(_usernameController.text.trim());
    _usernameController.clear();
    await loadUsername();
  }

  Future<void> loadPosts() async {
    setState(() {
      isLoadingPosts = true;
      postsError = null;
    });

    try {
      final result = await _postRepository.getPosts();
      if (!mounted) {
        return;
      }

      setState(() {
        posts = result.posts;
        dataSourceLabel = result.source == PostsDataSource.server
            ? 'Server'
            : 'Cache';
        isLoadingPosts = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        postsError = error.toString();
        isLoadingPosts = false;
        dataSourceLabel = '-';
        posts = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage & Cache Demo'),
        actions: [
          IconButton(onPressed: loadPosts, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Penyimpanan Lokal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Masukkan username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: saveUsername,
                      child: const Text('Simpan Username'),
                    ),
                    const SizedBox(height: 12),
                    isLoadingUsername
                        ? const LinearProgressIndicator()
                        : Text('Username tersimpan: $savedUsername'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cache Data API',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Chip(label: Text('Sumber: $dataSourceLabel')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoadingPosts)
                      const Center(child: CircularProgressIndicator())
                    else if (postsError != null && posts.isEmpty)
                      Text('Gagal memuat posts: $postsError')
                    else
                      Column(
                        children: [
                          if (postsError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Request gagal, menampilkan cache lama.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: posts.length > 5 ? 5 : posts.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(post.body),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
