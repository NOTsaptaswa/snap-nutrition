import 'package:flutter/foundation.dart';
import '../models/food_entry.dart';
import '../repositories/food_repository.dart';

// ViewModel: holds the list of logged food entries for the history screen.
// Subscribes to the repository's stream and exposes simple getters.
class HistoryViewModel extends ChangeNotifier {
  final FoodRepository _foodRepository;
  final String userId;

  List<FoodEntry> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;

  HistoryViewModel({
    required this.userId,
    FoodRepository? foodRepository,
  }) : _foodRepository = foodRepository ?? FoodRepository() {
    _subscribe();
  }

  List<FoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get todayCalories {
    final now = DateTime.now();
    return _entries
        .where((e) =>
    e.loggedAt.year == now.year &&
        e.loggedAt.month == now.month &&
        e.loggedAt.day == now.day)
        .fold(0.0, (sum, e) => sum + e.calories);
  }

  void _subscribe() {
    _foodRepository.getHistory(userId).listen(
          (entries) {
        _entries = entries;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Could not load history: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> deleteEntry(String entryId) async {
    await _foodRepository.deleteEntry(userId, entryId);
  }
}
