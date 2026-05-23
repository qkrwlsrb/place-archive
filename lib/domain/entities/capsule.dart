class Capsule {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final String memo;
  final List<String> photoUrls;
  final bool isPublic;
  final DateTime createdAt;

  const Capsule({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.memo,
    required this.photoUrls,
    required this.isPublic,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
        'memo': memo,
        'photoUrls': photoUrls,
        'isPublic': isPublic,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Capsule.fromJson(Map<String, dynamic> json) => Capsule(
        id: json['id'] as String,
        userId: json['userId'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        memo: json['memo'] as String,
        photoUrls: List<String>.from(json['photoUrls'] as List),
        isPublic: json['isPublic'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
