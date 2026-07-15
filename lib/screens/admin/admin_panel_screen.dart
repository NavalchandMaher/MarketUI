import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api/auth_service.dart';
import '../../services/api/v3_api_service.dart';
import '../../service_locator.dart';
import '../../state/auth_state.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _isLoading = false;
  String? _error;
  List<dynamic> _users = [];
  List<dynamic> _strategies = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = getIt<AuthService>();
      final v3Service = getIt<V3ApiService>();

      final users = await authService.getUsers();
      final strategies = await v3Service.getStrategies(forceRefresh: true);

      setState(() {
        _users = users;
        _strategies = strategies;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUserStatus(Map<String, dynamic> user) async {
    final authService = getIt<AuthService>();
    final userId = user['id'] as String;
    final currentStatus = (user['status'] ?? 'ACTIVE').toString().toUpperCase();
    final newStatus = currentStatus == 'ACTIVE' ? 'DISABLED' : 'ACTIVE';

    try {
      await authService.updateUser(userId, {'status': newStatus});
      await _loadAdminData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User status updated to $newStatus.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user status: $e')),
        );
      }
    }
  }

  Future<void> _toggleStrategyPublished(String id, bool published) async {
    final v3Service = getIt<V3ApiService>();
    try {
      await v3Service.putRequest(
        '/v3/strategies/$id/publish',
        body: {'published': !published},
      );
      await _loadAdminData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Strategy publish set to ${!published}.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update publish state: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    if (authState.userRole.toLowerCase() != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(child: Text('Access denied')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Users',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = _users[index] as Map<String, dynamic>;
                        final status = (user['status'] ?? 'ACTIVE')
                            .toString()
                            .toUpperCase();
                        return ListTile(
                          title: Text(
                            user['full_name'] ?? user['email'] ?? 'Unnamed',
                          ),
                          subtitle: Text(
                            '${user['email']} · ${user['role']} · $status',
                          ),
                          trailing: ElevatedButton(
                            onPressed:
                                user['role'] == 'Admin' &&
                                    user['email'] == authState.userEmail
                                ? null
                                : () => _toggleUserStatus(user),
                            child: Text(
                              status == 'ACTIVE' ? 'Disable' : 'Activate',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Strategies',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _strategies.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final strategy =
                            _strategies[index] as Map<String, dynamic>;
                        final isSystem =
                            (strategy['strategy_type'] ?? '')
                                .toString()
                                .toLowerCase() ==
                            'system';
                        final published = strategy['published'] == true;
                        final strategyId =
                            strategy['id']?.toString() ??
                            strategy['_id']?.toString() ??
                            '';

                        return ListTile(
                          title: Text(strategy['strategy_name'] ?? 'Unnamed'),
                          subtitle: Text(
                            '${strategy['strategy_type']} · Published: $published',
                          ),
                          trailing: isSystem
                              ? ElevatedButton(
                                  onPressed: () => _toggleStrategyPublished(
                                    strategyId,
                                    published,
                                  ),
                                  child: Text(
                                    published ? 'Unpublish' : 'Publish',
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
