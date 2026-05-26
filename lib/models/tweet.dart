class Tweet {
  final int? id;
  final String text;
  final String? imageUrl;
  final String? username;
  final String? motoMarca;
  final String? motoModelo;
  final int? motoCilindrada;
  final int? userId;
  final String? createdAt;

  Tweet({
    this.id,
    required this.text,
    this.imageUrl,
    this.username,
    this.motoMarca,
    this.motoModelo,
    this.motoCilindrada,
    this.userId,
    this.createdAt,
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawUserId = json['userId'];
    final rawCil = json['motoCilindrada'] ?? json['cilindrada'];

    return Tweet(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? ''),
      text: (json['text'] ?? json['tweet'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['imagenUrl'] ?? json['imagen_url'])?.toString(),
      username: json['username']?.toString(),
      motoMarca: json['motoMarca']?.toString(),
      motoModelo: json['motoModelo']?.toString(),
      motoCilindrada: rawCil is int ? rawCil : int.tryParse(rawCil?.toString() ?? ''),
      userId: rawUserId is int ? rawUserId : int.tryParse(rawUserId?.toString() ?? ''),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'username': username,
      'motoMarca': motoMarca,
      'motoModelo': motoModelo,
      'motoCilindrada': motoCilindrada,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() => 'Tweet(id: $id, text: $text)';
}
