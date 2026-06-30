import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/history_viewmodel.dart';

// View: dumb widget showing the list of logged food entries plus a
// simple "today's calories" summary. Watches HistoryViewModel only.
class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green[50],
            child: Column(
              children: [
                const Text('Today', style: TextStyle(color: Colors.grey)),
                Text(
                  '${viewModel.todayCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: viewModel.entries.isEmpty
                ? const Center(child: Text('No food logged yet'))
                : ListView.builder(
              itemCount: viewModel.entries.length,
              itemBuilder: (context, index) {
                final entry = viewModel.entries[index];
                return Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => viewModel.deleteEntry(entry.id),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.restaurant)),
                    title: Text(entry.label),
                    subtitle: Text(
                      DateFormat('MMM d, h:mm a').format(entry.loggedAt),
                    ),
                    trailing: Text(
                      '${entry.calories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
