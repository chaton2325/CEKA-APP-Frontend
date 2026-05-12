import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import '../utils/constants.dart';

class ApiService {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<http.Response> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'registration_code': AppConstants.registrationCode,
      }),
    );
    return response;
  }

  Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return response;
  }

  Future<http.Response> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/password/forgot'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    return response;
  }

  Future<http.Response> resetPassword(String email, String code, String newPassword) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/password/reset'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );
    return response;
  }

  Future<http.Response> changePassword(String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/auth/me/password'),
      headers: _headers,
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    return response;
  }

  Future<http.Response> getMe() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/auth/me'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> getPosts({int? page, int? limit}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/posts').replace(
      queryParameters: {
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
      },
    );
    final response = await http.get(
      uri,
      headers: _headers,
    );
    return response;
  }

  Future<http.BaseResponse> createPost(String? content, List<File>? mediaFiles) async {
    // If no media, use JSON as supported by the schema
    if (mediaFiles == null || mediaFiles.isEmpty) {
      return await http.post(
        Uri.parse('${AppConstants.baseUrl}/posts'),
        headers: _headers,
        body: jsonEncode({'content': content}),
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/posts'),
    );

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    if (content != null) request.fields['content'] = content;

    for (var file in mediaFiles) {
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final typeSplit = mimeType.split('/');
      
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        'media',
        stream,
        length,
        filename: basename(file.path),
        contentType: MediaType(typeSplit[0], typeSplit[1]),
      );
      request.files.add(multipartFile);
    }

    return await request.send();
  }

  Future<http.Response> likePost(int postId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/posts/$postId/likes'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> unlikePost(int postId) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/posts/$postId/likes'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> getPost(int postId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/posts/$postId'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> commentPost(int postId, String content, {int? parentId}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/posts/$postId/comments'),
      headers: _headers,
      body: jsonEncode({
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      }),
    );
    return response;
  }

  Future<http.Response> likeComment(int commentId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/comments/$commentId/likes'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> unlikeComment(int commentId) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/comments/$commentId/likes'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> getUserProfile(int userId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/users/$userId'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> getUserProfileByUsername(String username) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/users/by-username/$username'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> getUserPosts(int userId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/users/$userId/posts'),
      headers: _headers,
    );
    return response;
  }

  Future<http.BaseResponse> updatePost(
    int postId, {
    String? content,
    List<File>? mediaFiles,
    bool? replaceMedia,
  }) async {
    // If no media, use JSON as supported by the schema
    if (mediaFiles == null || mediaFiles.isEmpty) {
      return await http.patch(
        Uri.parse('${AppConstants.baseUrl}/posts/$postId'),
        headers: _headers,
        body: jsonEncode({
          if (content != null) 'content': content,
          if (replaceMedia != null) 'replace_media': replaceMedia,
        }),
      );
    }

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('${AppConstants.baseUrl}/posts/$postId'),
    );

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    if (content != null) request.fields['content'] = content;
    if (replaceMedia != null) {
      request.fields['replace_media'] = replaceMedia.toString();
    }

    for (var file in mediaFiles) {
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final typeSplit = mimeType.split('/');

      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        'media',
        stream,
        length,
        filename: basename(file.path),
        contentType: MediaType(typeSplit[0], typeSplit[1]),
      );
      request.files.add(multipartFile);
    }

    return await request.send();
  }

  Future<http.Response> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/posts/$postId'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> getNotifications({bool? unreadOnly}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/notifications').replace(
      queryParameters: unreadOnly != null ? {'unread_only': unreadOnly.toString()} : null,
    );
    final response = await http.get(
      uri,
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> markNotificationAsRead(int notificationId) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/notifications/$notificationId/read'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> markAllNotificationsAsRead() async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/notifications/read-all'),
      headers: _headers,
    );
    return response;
  }

  Future<http.Response> searchUsers(String query, {int? limit}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/users/search').replace(
      queryParameters: {
        'q': query,
        if (limit != null) 'limit': limit.toString(),
      },
    );
    final response = await http.get(
      uri,
      headers: _headers,
    );
    return response;
  }

  Future<http.StreamedResponse> updateProfile({
    String? username,
    String? bio,
    File? profilePhoto,
    File? bannerPhoto,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${AppConstants.baseUrl}/auth/me/profile'),
    );

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    if (username != null) request.fields['username'] = username;
    if (bio != null) request.fields['bio'] = bio;

    if (profilePhoto != null) {
      final mimeType = lookupMimeType(profilePhoto.path) ?? 'image/jpeg';
      final typeSplit = mimeType.split('/');
      
      final stream = http.ByteStream(profilePhoto.openRead());
      final length = await profilePhoto.length();
      final multipartFile = http.MultipartFile(
        'profile_photo',
        stream,
        length,
        filename: basename(profilePhoto.path),
        contentType: MediaType(typeSplit[0], typeSplit[1]),
      );
      request.files.add(multipartFile);
    }

    if (bannerPhoto != null) {
      final mimeType = lookupMimeType(bannerPhoto.path) ?? 'image/jpeg';
      final typeSplit = mimeType.split('/');

      final stream = http.ByteStream(bannerPhoto.openRead());
      final length = await bannerPhoto.length();
      final multipartFile = http.MultipartFile(
        'banner_photo',
        stream,
        length,
        filename: basename(bannerPhoto.path),
        contentType: MediaType(typeSplit[0], typeSplit[1]),
      );
      request.files.add(multipartFile);
    }

    return await request.send();
  }
}
