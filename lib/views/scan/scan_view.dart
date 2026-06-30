import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/scan_viewmodel.dart';

// View: dumb widget for picking a food photo, classifying it, and
// confirming the save. Watches ScanViewModel, calls its methods only.
class ScanView extends StatelessWidget {
  final String userId;

  const ScanView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ScanViewModel>();

    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage!)),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Log Food')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: viewModel.selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    viewModel.selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.status == ScanStatus.success && viewModel.lastLoggedEntry != null)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logged: ${viewModel.lastLoggedEntry!.label}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text('${viewModel.lastLoggedEntry!.calories.toStringAsFixed(0)} kcal'),
                      Text(
                        'Confidence: ${(viewModel.lastLoggedEntry!.confidence * 100).toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: viewModel.isBusy
                        ? null
                        : () => viewModel.pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: viewModel.isBusy
                        ? null
                        : () => viewModel.pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (viewModel.selectedImage == null || viewModel.isBusy)
                    ? null
                    : () => viewModel.logSelectedFood(userId),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: viewModel.isBusy
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Classify & Log'),
              ),
            ),
            if (viewModel.status == ScanStatus.success)
              TextButton(
                onPressed: viewModel.reset,
                child: const Text('Log another item'),
              ),
          ],
        ),
      ),
    );
  }
}