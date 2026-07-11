import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/learning_logs_provider.dart';

/// ===============================================================
/// Learning Logs Screen
/// ===============================================================
class LearningLogsScreen extends StatefulWidget {
  const LearningLogsScreen({super.key});

  @override
  State<LearningLogsScreen> createState() => _LearningLogsScreenState();
}

class _LearningLogsScreenState extends State<LearningLogsScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String _selectedCategory = 'lesson';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningLogsProvider>().loadLogs();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Logs'), elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateLogDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<LearningLogsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.logs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No learning logs yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateLogDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Log'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadLogs(forceRefresh: true),
            child: ListView.builder(
              itemCount: provider.logs.length,
              itemBuilder: (context, index) {
                final log = provider.logs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb),
                    title: Text(log['title'] ?? 'Untitled'),
                    subtitle: Text(
                      log['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showEditLogDialog(context, log);
                        } else if (value == 'delete') {
                          await provider.deleteLog(log['id']);
                        }
                      },
                    ),
                    onTap: () => _showLogDetail(context, log),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateLogDialog(BuildContext context) {
    _titleCtrl.clear();
    _descriptionCtrl.clear();
    _selectedCategory = 'lesson';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Learning Log'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionCtrl,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'lesson', child: Text('Lesson')),
                  DropdownMenuItem(value: 'mistake', child: Text('Mistake')),
                  DropdownMenuItem(value: 'insight', child: Text('Insight')),
                ],
                onChanged: (value) =>
                    setState(() => _selectedCategory = value ?? 'lesson'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<LearningLogsProvider>().createLog(
                title: _titleCtrl.text,
                description: _descriptionCtrl.text,
                category: _selectedCategory,
              );
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditLogDialog(BuildContext context, dynamic log) {
    _titleCtrl.text = log['title'] ?? '';
    _descriptionCtrl.text = log['description'] ?? '';
    _selectedCategory = log['category'] ?? 'lesson';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Learning Log'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionCtrl,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'lesson', child: Text('Lesson')),
                  DropdownMenuItem(value: 'mistake', child: Text('Mistake')),
                  DropdownMenuItem(value: 'insight', child: Text('Insight')),
                ],
                onChanged: (value) =>
                    setState(() => _selectedCategory = value ?? 'lesson'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<LearningLogsProvider>().updateLog(
                logId: log['id'],
                title: _titleCtrl.text,
                description: _descriptionCtrl.text,
                category: _selectedCategory,
              );
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLogDetail(BuildContext context, dynamic log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log['title'] ?? 'Log'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(label: Text(log['category'] ?? 'uncategorized')),
              const SizedBox(height: 12),
              Text(log['description'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
