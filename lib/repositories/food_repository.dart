import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/food_entry.dart';
import '../services/ml_classifier_service.dart';
import '../services/firestore_service.dart';

// Simple nutrition lookup table. In a full version this would be a much
// larger database or a nutrition API; for now it covers common categories
// found in the model's label set, with a sensible default fallback.
class NutritionInfo {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const NutritionInfo({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
}

// Repository: combines the ML classifier and Firestore service into a
// single clean API. Decides how a logged photo becomes a saved FoodEntry.
// ViewModels only ever call this — never the services directly.
class FoodRepository {
  final MlClassifierService _mlService;
  final FirestoreService _firestoreService;
  final Uuid _uuid = const Uuid();

  FoodRepository({
    MlClassifierService? mlService,
    FirestoreService? firestoreService,
  })  : _mlService = mlService ?? MlClassifierService(),
        _firestoreService = firestoreService ?? FirestoreService();

  Future<void> initMl() async {
    if (!_mlService.isReady) {
      await _mlService.loadModel();
    }
  }

  // Fallback nutrition estimate when we don't have a specific lookup for
  // the classified label. Average plate-sized portion assumption.
  static const NutritionInfo _defaultNutrition = NutritionInfo(
    calories: 350,
    proteinG: 15,
    carbsG: 40,
    fatG: 12,
  );

  NutritionInfo _lookupNutrition(String label) {
    // A small starter table — extendable over time without touching
    // any other layer of the app.
    final table = <String, NutritionInfo>{
      'Hamburger': const NutritionInfo(calories: 540, proteinG: 25, carbsG: 40, fatG: 29),
      'Hot dog': const NutritionInfo(calories: 290, proteinG: 10, carbsG: 24, fatG: 18),
      'Pizza': const NutritionInfo(calories: 285, proteinG: 12, carbsG: 36, fatG: 10),
      'Sushi': const NutritionInfo(calories: 200, proteinG: 8, carbsG: 38, fatG: 1),
      'Apple pie': const NutritionInfo(calories: 296, proteinG: 2, carbsG: 43, fatG: 14),
      'Fried chicken': const NutritionInfo(calories: 320, proteinG: 28, carbsG: 12, fatG: 19),
      'Caesar salad': const NutritionInfo(calories: 180, proteinG: 6, carbsG: 8, fatG: 15),
      'French toast': const NutritionInfo(calories: 250, proteinG: 8, carbsG: 30, fatG: 10),
      'Pancake': const NutritionInfo(calories: 220, proteinG: 6, carbsG: 38, fatG: 6),
      'Waffle': const NutritionInfo(calories: 260, proteinG: 6, carbsG: 38, fatG: 9),
      'Ramen': const NutritionInfo(calories: 380, proteinG: 14, carbsG: 56, fatG: 11),
      'Chocolate chip cookie': const NutritionInfo(calories: 160, proteinG: 2, carbsG: 22, fatG: 8),
      'Cheesecake': const NutritionInfo(calories: 320, proteinG: 6, carbsG: 28, fatG: 22),
      'Steak sandwich': const NutritionInfo(calories: 450, proteinG: 30, carbsG: 35, fatG: 20),
    };
    return table[label] ?? _defaultNutrition;
  }

  // Classifies the photo, looks up nutrition, and saves the entry to
  // Firestore. Returns the saved entry so the UI can show a confirmation.
  Future<FoodEntry> logFood({
    required File imageFile,
    required String userId,
  }) async {
    await initMl();
    final classification = await _mlService.classify(imageFile);
    final nutrition = _lookupNutrition(classification.label);

    final entry = FoodEntry(
      id: _uuid.v4(),
      userId: userId,
      label: classification.label,
      confidence: classification.confidence,
      calories: nutrition.calories,
      proteinG: nutrition.proteinG,
      carbsG: nutrition.carbsG,
      fatG: nutrition.fatG,
      loggedAt: DateTime.now(),
      isSynced: true,
    );

    await _firestoreService.addEntry(entry);
    return entry;
  }

  Stream<List<FoodEntry>> getHistory(String userId) {
    return _firestoreService.watchEntries(userId);
  }

  Future<void> deleteEntry(String userId, String entryId) {
    return _firestoreService.deleteEntry(userId, entryId);
  }

  void dispose() {
    _mlService.dispose();
  }
}