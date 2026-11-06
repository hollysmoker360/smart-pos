import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow_design_system/scanflow_design_system.dart';

import '../data/business_models.dart';
import 'business_app.dart';

const _employeeRoles = [
  'BUSINESS_ADMIN',
  'BRANCH_MANAGER',
  'CASHIER',
  'INVENTORY_OFFICER',
  'FINANCE_OFFICER',
  'AUDITOR',
];

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  ConsumerState<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState
    extends ConsumerState<BusinessDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(businessAppControllerProvider);
    final business = controller.currentUser!.business;
    final user = controller.currentUser!.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(business.name),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: controller.isBusy
                ? null
                : () => ref.read(businessAppControllerProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(businessAppControllerProvider).refreshDashboard(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Business workspace',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text('${user.fullName} · ${user.role.replaceAll('_', ' ')}'),
              const SizedBox(height: 16),
              if (controller.errorMessage != null) ...[
                _ErrorMessage(message: controller.errorMessage!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: _WorkspaceCard(
                      icon: Icons.store_mall_directory_outlined,
                      label: 'Branches',
                      value: controller.branches.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _WorkspaceCard(
                      icon: Icons.verified_user_outlined,
                      label: 'Account status',
                      value: business.status,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Branches',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh branches',
                    onPressed: controller.isBusy
                        ? null
                        : () => ref
                            .read(businessAppControllerProvider)
                            .refreshDashboard(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (controller.isBusy && controller.branches.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (controller.branches.isEmpty)
                const ScanFlowEmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'No branches yet',
                  message: 'Create a branch to start setting up your store.',
                )
              else
                ...controller.branches.map(_BranchCard.new),
              if (controller.canCreateBranches) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.isBusy ? null : _createBranch,
                  icon: const Icon(Icons.add_business),
                  label: const Text('Add branch'),
                ),
              ],
              if (controller.canManageBusiness) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: controller.isBusy || controller.branches.isEmpty
                      ? null
                      : _inviteEmployee,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Invite employee'),
                ),
              ],
              if (controller.lastInvitation case final invitation?) ...[
                const SizedBox(height: 20),
                _InvitationCard(invitation: invitation),
              ],
              const SizedBox(height: 24),
              Text(
                'Business data and actions are loaded from the ScanFlow API. '
                'Pricing, permissions, and branch ownership remain server-controlled.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createBranch() async {
    final request = await showDialog<_BranchFormData>(
      context: context,
      builder: (context) => const _CreateBranchDialog(),
    );
    if (request == null) return;
    final controller = ref.read(businessAppControllerProvider);
    final created = await controller.createBranch(
      name: request.name,
      currency: request.currency,
      timezone: request.timezone,
    );
    if (!mounted || created) return;
    _showError(controller.errorMessage);
  }

  Future<void> _inviteEmployee() async {
    final request = await showDialog<_EmployeeInviteFormData>(
      context: context,
      builder: (context) => _InviteEmployeeDialog(
        branches: ref.read(businessAppControllerProvider).branches,
      ),
    );
    if (request == null) return;
    final controller = ref.read(businessAppControllerProvider);
    final invitation = await controller.inviteEmployee(
      fullName: request.fullName,
      email: request.email,
      phone: request.phone,
      role: request.role,
      branchIds: request.branchIds,
    );
    if (!mounted || invitation != null) return;
    _showError(controller.errorMessage);
  }

  void _showError(String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: ScanFlowColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _BranchCard extends StatelessWidget {
  const _BranchCard(this.branch);

  final BranchSummary branch;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: ScanFlowColors.mint,
            child:
                Icon(Icons.storefront_outlined, color: ScanFlowColors.forest),
          ),
          title: Text(branch.name),
          subtitle: Text('${branch.currency} · ${branch.timezone}'),
          trailing: Chip(
            label: Text(branch.active ? 'Active' : 'Inactive'),
            backgroundColor: branch.active
                ? ScanFlowColors.mint
                : ScanFlowColors.errorSurface,
          ),
        ),
      );
}

class _CreateBranchDialog extends StatefulWidget {
  const _CreateBranchDialog();

  @override
  State<_CreateBranchDialog> createState() => _CreateBranchDialogState();
}

class _CreateBranchDialogState extends State<_CreateBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _currency = TextEditingController(text: 'KES');
  final _timezone = TextEditingController(text: 'Africa/Nairobi');

  @override
  void dispose() {
    _name.dispose();
    _currency.dispose();
    _timezone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Create branch'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('branchName'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'Branch name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('branchCurrency'),
                controller: _currency,
                maxLength: 3,
                decoration: const InputDecoration(labelText: 'Currency code'),
                validator: (value) {
                  if (value == null || value.trim().length != 3) {
                    return 'Enter a 3-letter currency code';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('branchTimezone'),
                controller: _timezone,
                decoration: const InputDecoration(labelText: 'Time zone'),
                validator: _required,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.pop(
                context,
                _BranchFormData(
                  _name.text.trim(),
                  _currency.text.trim().toUpperCase(),
                  _timezone.text.trim(),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      );
}

class _BranchFormData {
  const _BranchFormData(this.name, this.currency, this.timezone);

  final String name;
  final String currency;
  final String timezone;
}

class _InviteEmployeeDialog extends StatefulWidget {
  const _InviteEmployeeDialog({required this.branches});

  final List<BranchSummary> branches;

  @override
  State<_InviteEmployeeDialog> createState() => _InviteEmployeeDialogState();
}

class _InviteEmployeeDialogState extends State<_InviteEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _selectedBranchIds = <String>{};
  String _role = 'CASHIER';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Invite employee'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('employeeName'),
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('employeeEmail'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('employeePhone'),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('employeeRole'),
                    initialValue: _role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: _employeeRoles
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.replaceAll('_', ' ')),
                          ),
                        )
                        .toList(),
                    onChanged: (role) {
                      if (role != null) setState(() => _role = role);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Branch access',
                      style: Theme.of(context).textTheme.titleSmall),
                  for (final branch in widget.branches)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _selectedBranchIds.contains(branch.id),
                      title: Text(branch.name),
                      onChanged: (selected) => setState(() {
                        if (selected == true) {
                          _selectedBranchIds.add(branch.id);
                        } else {
                          _selectedBranchIds.remove(branch.id);
                        }
                      }),
                    ),
                  if (widget.branches.isEmpty)
                    const Text('Create a branch before inviting employees.'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: widget.branches.isEmpty
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    if (_selectedBranchIds.isEmpty) return;
                    Navigator.pop(
                      context,
                      _EmployeeInviteFormData(
                        fullName: _name.text.trim(),
                        email: _email.text.trim(),
                        phone: _phone.text.trim(),
                        role: _role,
                        branchIds: _selectedBranchIds.toList(),
                      ),
                    );
                  },
            child: const Text('Send invitation'),
          ),
        ],
      );
}

class _EmployeeInviteFormData {
  const _EmployeeInviteFormData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.branchIds,
  });

  final String fullName;
  final String email;
  final String phone;
  final String role;
  final List<String> branchIds;
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});

  final EmployeeInvitation invitation;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invitation created for ${invitation.email}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(invitation.invitationUrl),
              const SizedBox(height: 8),
              Text(
                'Expires ${invitation.expiresAt.toLocal()} · '
                '${invitation.role.replaceAll('_', ' ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Share this one-time link with the employee using your approved channel.',
              ),
            ],
          ),
        ),
      );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ScanFlowColors.errorSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          style: const TextStyle(color: ScanFlowColors.error),
        ),
      );
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;
