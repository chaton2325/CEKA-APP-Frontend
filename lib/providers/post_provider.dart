import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Post> _posts = [];
  bool _isLoading = false;

  PostProvider(this._apiService);

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getPosts();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _posts = (data['posts'] as List).map((p) => Post.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('Fetch posts error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPost(String? content, {List<File>? mediaFiles}) async {
    try {
      final baseResponse = await _apiService.createPost(content, mediaFiles);
      http.Response response;
      if (baseResponse is http.StreamedResponse) {
        response = await http.Response.fromStream(baseResponse);
      } else {
        response = baseResponse as http.Response;
      }
      
      if (response.statusCode == 201) {
        await fetchPosts();
        return true;
      }
    } catch (e) {
      debugPrint('Create post error: $e');
    }
    return false;
  }

  Future<Post?> getPostDetail(int postId) async {
    try {
      final response = await _apiService.getPost(postId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data['post']);
      }
    } catch (e) {
      debugPrint('Get post detail error: $e');
    }
    return null;
  }

  Future<void> togglePostLike(int postId, bool currentlyLiked) async {
    try {
      final response = currentlyLiked
          ? await _apiService.unlikePost(postId)
          : await _apiService.likePost(postId);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedPost = Post.fromJson(data['post']);
        
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Toggle post like error: $e');
    }
  }

  Future<bool> addComment(int postId, String content, {int? parentId}) async {
    try {
      final response = await _apiService.commentPost(postId, content, parentId: parentId);
      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('Add comment error: $e');
    }
    return false;
  }

  Future<void> toggleCommentLike(int commentId, bool currentlyLiked) async {
    try {
      final response = currentlyLiked
          ? await _apiService.unlikeComment(commentId)
          : await _apiService.likeComment(commentId);
      
      if (response.statusCode == 200) {
        // Comment like/unlike doesn't return the updated post/comment object.
      }
    } catch (e) {
      debugPrint('Toggle comment like error: $e');
    }
  }
}
