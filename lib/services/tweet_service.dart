import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/tweet.dart';
import '../models/tweet_response.dart';
import '../repositories/tweet_repository.dart';
import 'auth_service.dart';

class TweetService implements ITweetRepository {
  static final TweetService _instance = TweetService._internal();

  late final http.Client _httpClient;
  late final AuthService _authService;
  late final String _baseUrl;

  TweetService._internal() {
    _httpClient = http.Client();
    _authService = AuthService();
    _baseUrl = _resolveBaseUrl();
  }

  factory TweetService() => _instance;

  static TweetService getInstance() => _instance;

  String _resolveBaseUrl() {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000/api';
      default:
        return 'http://localhost:3000/api';
    }
  }

  Future<void> _ensureAuth() async {
    await _authService.init();
  }

  Map<String, String> _getJsonHeaders() {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = _authService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print('[DEBUG] No token found in auth service');
    }

    return headers;
  }

  Map<String, String> _getMultipartHeaders() {
    final headers = <String, String>{'Accept': 'application/json'};
    final token = _authService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('[DEBUG] Token added to multipart headers');
    } else {
      print('[DEBUG] No token found for multipart request');
    }
    return headers;
  }

  @override
  Future<List<Tweet>> fetchTweets() async {
    await _ensureAuth();

    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/tweets'),
      headers: _getJsonHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final tweetResponse = TweetResponse.fromJson(Map<String, dynamic>.from(decoded as Map));
      return tweetResponse.content;
    }

    throw Exception('Failed to load tweets. Status code: ${response.statusCode}');
  }

  @override
  Future<Tweet> createTweet({
    required String text,
    String? motoMarca,
    String? motoModelo,
    int? motoCilindrada,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    await _ensureAuth();

    final token = _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found. Please log in again.');
    }

    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/tweets'))
      ..fields['text'] = text;

    if (motoMarca != null && motoMarca.isNotEmpty) {
      request.fields['motoMarca'] = motoMarca;
    }
    if (motoModelo != null && motoModelo.isNotEmpty) {
      request.fields['motoModelo'] = motoModelo;
    }
    if (motoCilindrada != null) {
      request.fields['motoCilindrada'] = motoCilindrada.toString();
    }
    if (imageBytes != null && imageName != null && imageName.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagen',
          imageBytes,
          filename: imageName,
        ),
      );
    }

    request.headers.addAll(_getMultipartHeaders());

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);

    print('[DEBUG] Tweet creation response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Tweet.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
    }

    throw Exception('Failed to create tweet. Status: ${response.statusCode}. Message: ${response.body}');
  }

  @override
  Future<void> deleteTweet(int id) async {
    await _ensureAuth();

    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/tweets/$id'),
      headers: _getJsonHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete tweet. Status code: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    // Intentionally left open: this singleton is reused across screens.
  }
}
