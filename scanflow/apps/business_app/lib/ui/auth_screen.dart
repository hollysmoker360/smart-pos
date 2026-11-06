import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow_design_system/scanflow_design_system.dart';

import 'business_app.dart';

enum _AuthMode { signIn, register, acceptInvitation }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _invitationToken = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;

  @override
  void dispose() {
    _businessName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _invitationToken.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(businessAppControllerProvider);
    switch (_mode) {
      case _AuthMode.signIn:
        await controller.signIn(_email.text, _password.text);
      case _AuthMode.register:
        await controller.registerBusiness(
          businessName: _businessName.text,
          ownerName: _ownerName.text,
          email: _email.text,
          phone: _phone.text,
          password: _password.text,
        );
      case _AuthMode.acceptInvitation:
        await controller.acceptBusinessInvitation(
          _invitationToken.text,
          _password.text,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(businessAppControllerProvider);
    final isRegistering = _mode == _AuthMode.register;
    final isAcceptingInvitation = _mode == _AuthMode.acceptInvitation;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.storefront,
                          size: 44,
                          color: ScanFlowColors.emerald,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ScanFlow Business',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isRegistering
                              ? 'Create a business owner account'
                              : isAcceptingInvitation
                                  ? 'Accept your business invitation'
                                  : 'Sign in to manage your business',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        if (_mode == _AuthMode.signIn) ...[
                          _emailField(),
                          const SizedBox(height: 12),
                        ],
                        if (isRegistering) ...[
                          _textField(
                            controller: _businessName,
                            label: 'Business name',
                            keyName: 'businessName',
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            controller: _ownerName,
                            label: 'Owner full name',
                            keyName: 'ownerName',
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            controller: _phone,
                            label: 'Phone number',
                            keyName: 'phone',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _emailField(),
                          const SizedBox(height: 12),
                        ],
                        if (isAcceptingInvitation) ...[
                          _textField(
                            controller: _invitationToken,
                            label: 'Invitation token',
                            keyName: 'invitationToken',
                          ),
                          const SizedBox(height: 12),
                        ],
                        _textField(
                          controller: _password,
                          label: isRegistering || isAcceptingInvitation
                              ? 'Create password'
                              : 'Password',
                          keyName: 'password',
                          obscureText: true,
                        ),
                        if (isRegistering) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Direct registration is disabled in production. '
                            'Production businesses are onboarded by invitation.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (controller.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _ErrorMessage(message: controller.errorMessage!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          key: const Key('submit'),
                          onPressed: controller.isBusy ? null : _submit,
                          child: controller.isBusy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isRegistering
                                      ? 'Create business'
                                      : isAcceptingInvitation
                                          ? 'Accept invitation'
                                          : 'Sign in',
                                ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: controller.isBusy
                                  ? null
                                  : () => setState(
                                        () => _mode = _AuthMode.signIn,
                                      ),
                              child: const Text('Sign in'),
                            ),
                            TextButton(
                              onPressed: controller.isBusy
                                  ? null
                                  : () => setState(
                                        () => _mode = _AuthMode.register,
                                      ),
                              child: const Text('Register business'),
                            ),
                            TextButton(
                              onPressed: controller.isBusy
                                  ? null
                                  : () => setState(
                                        () =>
                                            _mode = _AuthMode.acceptInvitation,
                                      ),
                              child: const Text('Have an invitation?'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField() => _textField(
        controller: _email,
        label: 'Email address',
        keyName: 'email',
        keyboardType: TextInputType.emailAddress,
      );

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String keyName,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) =>
      TextFormField(
        key: Key(keyName),
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofillHints: switch (keyName) {
          'email' => const [AutofillHints.email],
          'password' => const [AutofillHints.password],
          _ => null,
        },
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          if (keyName == 'email' && !value.contains('@')) {
            return 'Enter a valid email address';
          }
          if (keyName == 'password' && value.length < 12) {
            return 'Use at least 12 characters';
          }
          return null;
        },
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
