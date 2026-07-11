import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/account_model.dart';
import '../../state/account_provider.dart';

/// ===============================================================
/// Account Settings Screen
/// ===============================================================
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late TextEditingController _brokerController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _countryController = TextEditingController();
    _brokerController = TextEditingController();

    // Load initial account data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccount();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _brokerController.dispose();
    super.dispose();
  }

  void _updateFormFields(AccountModel? account) {
    if (account != null) {
      _nameController.text = account.fullName;
      _phoneController.text = account.phone ?? '';
      _countryController.text = account.country ?? '';
      _brokerController.text = account.brokerName ?? '';
    }
  }

  Future<void> _saveChanges() async {
    final provider = context.read<AccountProvider>();
    final success = await provider.updateAccount(
      fullName: _nameController.text,
      phone: _phoneController.text,
      country: _countryController.text,
      brokerName: _brokerController.text,
    );

    if (success) {
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account updated successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update account'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings'), elevation: 0),
      body: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.account == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final account = provider.account;
          if (account == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48),
                  const SizedBox(height: 16),
                  const Text('Failed to load account'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadAccount(forceRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Update form fields when account loads
          if (!_isEditing && _nameController.text.isEmpty) {
            _updateFormFields(account);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!_isEditing)
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    setState(() => _isEditing = true),
                              ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 12),
                        _buildInfoRow('Account ID', account.id),
                        _buildInfoRow('Email', account.email),
                        _buildInfoRow(
                          'Account Tier',
                          account.accountTier.toUpperCase(),
                        ),
                        _buildInfoRow(
                          'Initial Balance',
                          '\$${account.initialBalance.toStringAsFixed(2)}',
                        ),
                        _buildInfoRow(
                          'Current Balance',
                          '\$${account.currentBalance.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Form
                if (_isEditing)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _countryController,
                            decoration: const InputDecoration(
                              labelText: 'Country',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _brokerController,
                            decoration: const InputDecoration(
                              labelText: 'Broker Name',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  setState(() => _isEditing = false);
                                  _updateFormFields(account);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: provider.isLoading
                                    ? null
                                    : _saveChanges,
                                child: provider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(),
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Broker Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Broker Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 12),
                        if (account.brokerName != null)
                          _buildInfoRow('Broker', account.brokerName!)
                        else
                          const Text(
                            'No broker connected',
                            style: TextStyle(color: Colors.grey),
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to broker management
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Broker management coming soon'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.link),
                          label: const Text('Manage Broker'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
