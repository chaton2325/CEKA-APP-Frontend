import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
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
        final data = jsonDecode(response.body);
        final newPost = Post.fromJson(data['post']);
        // Insert at the beginning for immediate visibility
        _posts.insert(0, newPost);
        notifyListeners();
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

  Future<void> togglePostLike(int postId, bool currentlyLiked, {int? userId}) async {
    // Optimistic update
    final index = _posts.indexWhere((p) => p.id == postId);
    Post? originalPost;
    if (index != -1) {
      originalPost = _posts[index];
      // Create a temporary updated post for the UI
      // Note: This is a simplified version, ideally we'd update likedBy and likesCount properly
      _posts[index] = Post(
        id: originalPost.id,
        content: originalPost.content,
        author: originalPost.author,
        media: originalPost.media,
        likesCount: currentlyLiked ? originalPost.likesCount - 1 : originalPost.likesCount + 1,
        likedBy: currentlyLiked 
          ? originalPost.likedBy.where((u) => u.id != userId).toList()
          : [...originalPost.likedBy, if (userId != null) originalPost.author], // Dummy user for UI
        comments: originalPost.comments,
        createdAt: originalPost.createdAt,
        updatedAt: originalPost.updatedAt,
      );
      notifyListeners();
    }

    try {
      final response = currentlyLiked
          ? await _apiService.unlikePost(postId)
          : await _apiService.likePost(postId);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedPost = Post.fromJson(data['post']);
        
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
      } else if (originalPost != null && index != -1) {
        // Rollback on failure
        _posts[index] = originalPost;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Toggle post like error: $e');
      if (originalPost != null && index != -1) {
        _posts[index] = originalPost;
        notifyListeners();
      }
    }
  }

  Future<List<Post>> fetchUserPosts(int userId) async {
    try {
      final response = await _apiService.getUserPosts(userId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['posts'] as List).map((p) => Post.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('Fetch user posts error: $e');
    }
    return [];
  }

  Future<bool> updatePost(int postId, {String? content, List<File>? mediaFiles, bool? replaceMedia}) async {
    try {
      final baseResponse = await _apiService.updatePost(postId, content: content, mediaFiles: mediaFiles, replaceMedia: replaceMedia);
      http.Response response;
      if (baseResponse is http.StreamedResponse) {
        response = await http.Response.fromStream(baseResponse);
      } else {
        response = baseResponse as http.Response;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedPost = Post.fromJson(data['post']);
        
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('Update post error: $e');
    }
    return false;
  }

  Future<bool> deletePost(int postId) async {
    try {
      final response = await _apiService.deletePost(postId);
      if (response.statusCode == 200) {
        _posts.removeWhere((p) => p.id == postId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Delete post error: $e');
    }
    return false;
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
