// Model: plain data class, no business logic. Represents one logged
// food entry, used across Hive (local cache) and Firestore (cloud).
class FoodEntry {
  final String id;
  final String userId;
  final String label;
  final double confidence;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String? imageUrl;
  final String? localImagePath;
  final DateTime loggedAt;
  final bool isSynced;

  FoodEntry({
    required this.id,
    required this.userId,
    required this.label,
    required this.confidence,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.imageUrl,
    this.localImagePath,
    required this.loggedAt,
    this.isSynced = false,
  });

  FoodEntry copyWith({
    String? imageUrl,
    bool? isSynced,
  }) {
    return FoodEntry(
      id: id,
      userId: userId,
      label: label,
      confidence: confidence,
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath,
      loggedAt: loggedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'label': label,
      'confidence': confidence,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'imageUrl': imageUrl,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  factory FoodEntry.fromFirestore(String id, Map<String, dynamic> data) {
    return FoodEntry(
      id: id,
      userId: data['userId'] as String,
      label: data['label'] as String,
      confidence: (data['confidence'] as num).toDouble(),
      calories: (data['calories'] as num).toDouble(),
      proteinG: (data['proteinG'] as num).toDouble(),
      carbsG: (data['carbsG'] as num).toDouble(),
      fatG: (data['fatG'] as num).toDouble(),
      imageUrl: data['imageUrl'] as String?,
      loggedAt: DateTime.parse(data['loggedAt'] as String),
      isSynced: true,
    );
  }

  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'confidence': confidence,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'loggedAt': loggedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory FoodEntry.fromHiveMap(Map<dynamic, dynamic> map) {
    return FoodEntry(
      id: map['id'] as String,
      userId: map['userId'] as String,
      label: map['label'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      calories: (map['calories'] as num).toDouble(),
      proteinG: (map['proteinG'] as num).toDouble(),
      carbsG: (map['carbsG'] as num).toDouble(),
      fatG: (map['fatG'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String?,
      localImagePath: map['localImagePath'] as String?,
      loggedAt: DateTime.parse(map['loggedAt'] as String),
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }
}