import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_entry.dart';
import '../repositories/food_repository.dart';

enum ScanStatus { idle, classifying, saving, success, error }

// ViewModel: holds state for the scan/log-food flow. Views watch this
// and call its methods — never touch FoodRepository or image_picker directly.
class ScanViewModel extends ChangeNotifier {
  final FoodRepository _foodRepository;
  final ImagePicker _imagePicker = ImagePicker();

  ScanViewModel({FoodRepository? foodRepository})
      : _foodRepository = foodRepository ?? FoodRepository();

  ScanStatus _status = ScanStatus.idle;
  String? _errorMessage;
  File? _selectedImage;
  FoodEntry? _lastLoggedEntry;

  ScanStatus get status => _status;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;
  FoodEntry? get lastLoggedEntry => _lastLoggedEntry;
  bool get isBusy => _status == ScanStatus.classifying || _status == ScanStatus.saving;

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(source: source, maxWidth: 1024);
      if (picked == null) return; // user cancelled
      _selectedImage = File(picked.path);
      _status = ScanStatus.idle;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _status = ScanStatus.error;
      _errorMessage = 'Could not access camera/gallery: $e';
      notifyListeners();
    }
  }

  Future<void> logSelectedFood(String userId) async {
    if (_selectedImage == null) return;

    _status = ScanStatus.classifying;
    _errorMessage = null;
    notifyListeners();

    try {
      _status = ScanStatus.saving;
      notifyListeners();

      final entry = await _foodRepository.logFood(
        imageFile: _selectedImage!,
        userId: userId,
      );

      _lastLoggedEntry = entry;
      _status = ScanStatus.success;
      notifyListeners();
    } catch (e) {
      _status = ScanStatus.error;
      _errorMessage = 'Could not classify or save: $e';
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _lastLoggedEntry = null;
    _status = ScanStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}