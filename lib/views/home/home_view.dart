import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/scan_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../scan/scan_view.dart';
import '../history/history_view.dart';

// View: shell with bottom navigation between Scan and History. Created
// only once the user is authenticated, so userId is always available.
class HomeView extends StatefulWidget {
  final String userId;

  const HomeView({super.key, required this.userId});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScanViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel(userId: widget.userId)),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            ScanView(userId: widget.userId),
            const HistoryView(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Scan'),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          ],
        ),
      ),
    );
  }
}
