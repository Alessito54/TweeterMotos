import '../models/tweet.dart';
import 'dart:typed_data';

/// Abstract interface for Twitter repository operations
/// Follows the Dependency Inversion Principle (DIP)
/// Allows for different implementations (HTTP, local cache, mock, etc.)
abstract class ITweetRepository {
  /// Fetch all tweets
  Future<List<Tweet>> fetchTweets();

  /// Create a new tweet
  Future<Tweet> createTweet({
    required String text,
    String? motoMarca,
    String? motoModelo,
    int? motoCilindrada,
    Uint8List? imageBytes,
    String? imageName,
  });

  /// Delete a tweet by ID
  Future<void> deleteTweet(int id);

  /// Cleanup resources
  void dispose();
}
