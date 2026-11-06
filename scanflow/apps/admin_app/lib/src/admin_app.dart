import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow_design_system/scanflow_design_system.dart';

import 'admin_api.dart';
import 'admin_controller.dart';

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(adminControllerProvider);
    return switch (controller.status) {
      AdminStatus.initializing => const _StartupScreen(),
      AdminStatus.signedOut => const _AdminSignInScreen(),
      AdminStatus.signedIn => const _AdminWorkspace(),
    };
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _AdminSignInScreen extends ConsumerStatefulWidget {
  const _AdminSignInScreen();

  @override
  ConsumerState<_AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends ConsumerState<_AdminSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(adminControllerProvider);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 44,
                      color: ScanFlowColors.emerald,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ScanFlow Admin',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in with a platform administrator account.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (controller.errorMessage != null) ...[
                      _ErrorBanner(message: controller.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      key: const Key('adminEmail'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value == null || !value.trim().contains('@')
                          ? 'Enter a valid email address'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('adminPassword'),
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password'
                          : null,
                      onFieldSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: controller.isBusy ? null : _signIn,
                      child: controller.isBusy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(adminControllerProvider).signIn(_email.text, _password.text);
  }
}

class _AdminSection {
  const _AdminSection(this.title, this.icon, this.description);

  final String title;
  final IconData icon;
  final String description;
}

const _sections = [
  _AdminSection('Overview', Icons.grid_view_outlined, 'Platform overview'),
  _AdminSection(
    'Businesses & Branches',
    Icons.store_mall_directory_outlined,
    'Business onboarding and tenant management',
  ),
  _AdminSection(
    'Products & Pricing',
    Icons.inventory_2_outlined,
    'Shared catalogue and pricing controls',
  ),
  _AdminSection(
    'Inventory',
    Icons.warehouse_outlined,
    'Stock and replenishment',
  ),
  _AdminSection(
    'Orders & Sessions',
    Icons.receipt_long_outlined,
    'Shopping sessions and orders',
  ),
  _AdminSection(
    'SmartTrolleys & Devices',
    Icons.devices_outlined,
    'Registered devices and status',
  ),
  _AdminSection(
    'Payments & Finance',
    Icons.payments_outlined,
    'Payments, settlements, and finance',
  ),
  _AdminSection(
    'Customers & Loyalty',
    Icons.people_outline,
    'Customer accounts and loyalty',
  ),
  _AdminSection(
    'Staff & Permissions',
    Icons.badge_outlined,
    'Staff access and permissions',
  ),
  _AdminSection(
    'Reports & Analytics',
    Icons.query_stats_outlined,
    'Platform reporting and analytics',
  ),
  _AdminSection(
    'Security & Audit',
    Icons.security_outlined,
    'Security and audit events',
  ),
  _AdminSection(
    'Settings & Integrations',
    Icons.settings_outlined,
    'Platform settings and integrations',
  ),
];

class _AdminWorkspace extends ConsumerStatefulWidget {
  const _AdminWorkspace();

  @override
  ConsumerState<_AdminWorkspace> createState() => _AdminWorkspaceState();
}

class _AdminWorkspaceState extends ConsumerState<_AdminWorkspace> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(adminControllerProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        return Scaffold(
          appBar: AppBar(
            title: Text(_sections[_selectedIndex].title),
            leading: wide
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.qr_code_2, color: Colors.white),
                  )
                : null,
            actions: [
              if (wide)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      controller.user?.fullName ?? 'Platform administrator',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              IconButton(
                tooltip: 'Sign out',
                onPressed: controller.isBusy
                    ? null
                    : () => ref.read(adminControllerProvider).signOut(),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          drawer: wide ? null : Drawer(child: _navigationDrawer()),
          body: Row(
            children: [
              if (wide) _navigationRail(),
              Expanded(
                child: ColoredBox(
                  color: ScanFlowColors.background,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: _selectedIndex == 0
                          ? _overview(controller)
                          : _selectedIndex == 1
                          ? _businessManagement(controller)
                          : _notAvailable(_sections[_selectedIndex]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navigationRail() => Container(
    width: 248,
    color: ScanFlowColors.forest,
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Row(
            children: [
              Icon(Icons.qr_code_2, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'ScanFlow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _sections.length,
            itemBuilder: (context, index) => _navigationItem(index),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.admin_panel_settings_outlined),
          ),
          title: Text(
            ref.watch(adminControllerProvider).user?.fullName ??
                'Administrator',
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: const Text(
            'Platform Admin',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );

  Widget _navigationDrawer() => ColoredBox(
    color: ScanFlowColors.forest,
    child: SafeArea(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.qr_code_2, color: Colors.white, size: 30),
            title: Text(
              'ScanFlow Admin',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (context, index) => _navigationItem(index),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _navigationItem(int index) {
    final section = _sections[index];
    final selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        key: Key(
          'adminNav${section.title.replaceAll(RegExp(r'[^A-Za-z]'), '')}',
        ),
        selected: selected,
        selectedTileColor: ScanFlowColors.emerald,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(section.icon, color: Colors.white),
        title: Text(
          section.title,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          if (MediaQuery.sizeOf(context).width < 1000) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _overview(AdminController controller) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      Text(
        'Platform overview',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 6),
      Text(
        'Administration tools for ScanFlow platform operators.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _OverviewCard(
            icon: Icons.verified_user_outlined,
            title: 'Administrator',
            value: controller.user?.fullName ?? 'Signed in',
            detail: controller.user?.email ?? '',
          ),
          const _OverviewCard(
            icon: Icons.lock_outline,
            title: 'Access level',
            value: 'Platform Admin',
            detail: 'Role verified by ScanFlow API',
          ),
          const _OverviewCard(
            icon: Icons.cloud_done_outlined,
            title: 'Backend connection',
            value: 'Connected',
            detail: 'Authenticated session is active',
          ),
        ],
      ),
      const SizedBox(height: 24),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business onboarding',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a secure, time-limited owner invitation. Business '
                'and branch records are managed by the backend.',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('openBusinessInvitation'),
                onPressed: controller.isBusy ? null : _showBusinessInvite,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Invite business owner'),
              ),
            ],
          ),
        ),
      ),
      if (controller.errorMessage != null) ...[
        const SizedBox(height: 16),
        _ErrorBanner(message: controller.errorMessage!),
      ],
    ],
  );

  Widget _businessManagement(AdminController controller) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      Text(
        'Businesses & Branches',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 6),
      const Text(
        'Platform-level business creation is available. Tenant and branch '
        'listing APIs are not implemented yet.',
      ),
      const SizedBox(height: 20),
      Card(
        child: ListTile(
          leading: const Icon(
            Icons.add_business,
            color: ScanFlowColors.emerald,
          ),
          title: const Text('Invite a business owner'),
          subtitle: const Text(
            'The owner completes setup using a one-time invitation link.',
          ),
          trailing: FilledButton(
            onPressed: controller.isBusy ? null : _showBusinessInvite,
            child: const Text('Create invitation'),
          ),
        ),
      ),
      if (controller.errorMessage != null) ...[
        const SizedBox(height: 16),
        _ErrorBanner(message: controller.errorMessage!),
      ],
      if (controller.lastInvitation case final invitation?) ...[
        const SizedBox(height: 16),
        _InvitationCard(invitation: invitation),
      ],
    ],
  );

  Widget _notAvailable(_AdminSection section) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      Text(section.title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 6),
      Text(section.description),
      const SizedBox(height: 20),
      ScanFlowEmptyState(
        icon: section.icon,
        title: 'Not available yet',
        message: 'This area will be enabled when its authenticated backend API is available. No sample or unverified business data is shown.',
      ),
    ],
  );

  Future<void> _showBusinessInvite() async {
    final request = await showDialog<_BusinessInviteRequest>(
      context: context,
      builder: (context) => const _BusinessInviteDialog(),
    );
    if (request == null) return;
    final controller = ref.read(adminControllerProvider);
    final invitation = await controller.inviteBusiness(
      businessName: request.businessName,
      ownerName: request.ownerName,
      ownerEmail: request.ownerEmail,
      ownerPhone: request.ownerPhone,
    );
    if (!mounted || invitation == null) return;
    setState(() => _selectedIndex = 1);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Owner invitation created')));
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ScanFlowColors.emerald),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
  );
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});

  final BusinessInvitation invitation;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitation created',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('${invitation.businessName} · ${invitation.ownerEmail}'),
          const SizedBox(height: 8),
          SelectableText(invitation.invitationUrl),
          const SizedBox(height: 4),
          Text(
            'Expires ${invitation.expiresAt.toLocal()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: invitation.invitationUrl),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invitation link copied')),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy invitation link'),
          ),
          const SizedBox(height: 4),
          Text(
            'Share this link with the invited owner through an approved '
            'channel. ScanFlow does not send email or SMS yet.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _BusinessInviteRequest {
  const _BusinessInviteRequest({
    required this.businessName,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
  });

  final String businessName;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;
}

class _BusinessInviteDialog extends StatefulWidget {
  const _BusinessInviteDialog();

  @override
  State<_BusinessInviteDialog> createState() => _BusinessInviteDialogState();
}

class _BusinessInviteDialogState extends State<_BusinessInviteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _business = TextEditingController();
  final _owner = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _business.dispose();
    _owner.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Invite business owner'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('businessName'),
                controller: _business,
                decoration: const InputDecoration(labelText: 'Business name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('ownerName'),
                controller: _owner,
                decoration: const InputDecoration(labelText: 'Owner name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('ownerEmail'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Owner email'),
                validator: (value) =>
                    value == null || !value.trim().contains('@')
                    ? 'Enter a valid email address'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('ownerPhone'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Owner phone'),
                validator: _required,
              ),
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
        key: const Key('createInvitation'),
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            _BusinessInviteRequest(
              businessName: _business.text.trim(),
              ownerName: _owner.text.trim(),
              ownerEmail: _email.text.trim(),
              ownerPhone: _phone.text.trim(),
            ),
          );
        },
        child: const Text('Create invitation'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Material(
    color: ScanFlowColors.errorSurface,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    ),
  );
}
