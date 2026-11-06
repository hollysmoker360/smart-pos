import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pos_app.dart';
import 'pos_controller.dart';
import 'pos_models.dart';

class PosSignInScreen extends ConsumerStatefulWidget {
  const PosSignInScreen({super.key});

  @override
  ConsumerState<PosSignInScreen> createState() => _PosSignInScreenState();
}

class _PosSignInScreenState extends ConsumerState<PosSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(posControllerProvider).signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(posControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.point_of_sale, size: 52),
                        const SizedBox(height: 12),
                        Text(
                          'ScanFlow POS',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in with your authorized staff account.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          key: const Key('posEmail'),
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) => value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')
                              ? 'Enter a valid email address.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('posPassword'),
                          controller: _password,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Password is required.'
                              : null,
                          onFieldSubmitted: (_) => _signIn(),
                        ),
                        if (controller.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          _ErrorBanner(message: controller.errorMessage!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          key: const Key('posSignIn'),
                          onPressed: controller.isBusy ? null : _signIn,
                          child: controller.isBusy
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
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
        ),
      ),
    );
  }
}

class PosCheckoutScreen extends ConsumerStatefulWidget {
  const PosCheckoutScreen({super.key});

  @override
  ConsumerState<PosCheckoutScreen> createState() => _PosCheckoutScreenState();
}

class _PosCheckoutScreenState extends ConsumerState<PosCheckoutScreen> {
  final _scanController = TextEditingController();
  final _cashController = TextEditingController();
  final _searchController = TextEditingController();
  final _scanFocus = FocusNode();

  @override
  void dispose() {
    _scanController.dispose();
    _cashController.dispose();
    _searchController.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  Future<void> _addIdentifier(String value) async {
    final identifier = value.trim();
    if (identifier.isEmpty) return;
    final added = await ref.read(posControllerProvider).addProduct(identifier);
    if (!mounted || !added) return;
    _scanController.clear();
    _scanFocus.requestFocus();
  }

  Future<void> _checkout() async {
    final controller = ref.read(posControllerProvider);
    final complete = await controller.completeCashSale(_cashController.text);
    if (!mounted || !complete) return;
    final receipt = controller.receipt;
    if (receipt == null) return;
    _cashController.clear();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sale complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt ${receipt.orderNumber}'),
            const SizedBox(height: 8),
            Text('Total: ${_money(receipt.currency, receipt.total)}'),
            Text(
              'Cash received: ${_money(receipt.currency, receipt.cashReceived)}',
            ),
            Text('Change due: ${_money(receipt.currency, receipt.changeDue)}'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('New sale'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    controller.clearReceipt();
    _scanFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(posControllerProvider);
    final branch = controller.selectedBranch;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanFlow POS'),
        actions: [
          if (controller.user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  '${controller.user!.fullName} · ${controller.user!.role.replaceAll('_', ' ')}',
                ),
              ),
            ),
          IconButton(
            key: const Key('posSignOut'),
            tooltip: 'Sign out',
            onPressed: controller.isBusy
                ? null
                : () => ref.read(posControllerProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.errorMessage != null) ...[
                _ErrorBanner(message: controller.errorMessage!),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  const Icon(Icons.storefront_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const Key('posBranch'),
                      initialValue: controller.selectedBranchId,
                      decoration: const InputDecoration(
                        labelText: 'Authorized branch',
                        isDense: true,
                      ),
                      items: controller.branches
                          .map(
                            (branch) => DropdownMenuItem(
                              value: branch.id,
                              child: Text(branch.name),
                            ),
                          )
                          .toList(),
                      onChanged: controller.isBusy
                          ? null
                          : (id) {
                              if (id != null) {
                                ref
                                    .read(posControllerProvider)
                                    .selectBranch(id);
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Refresh catalogue',
                    onPressed: controller.isBusy
                        ? null
                        : () =>
                            ref.read(posControllerProvider).refreshProducts(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 1000) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 5, child: _cataloguePanel(controller)),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: _basketPanel(controller, branch),
                          ),
                        ],
                      );
                    }
                    return ListView(
                      children: [
                        SizedBox(
                          height: 420,
                          child: _cataloguePanel(controller),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 560,
                          child: _basketPanel(controller, branch),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cataloguePanel(PosController controller) {
    final query = _searchController.text.trim().toLowerCase();
    final products = controller.products.where((product) {
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query) ||
          (product.barcode?.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scan or search',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('posScanInput'),
              controller: _scanController,
              focusNode: _scanFocus,
              autofocus: true,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: const InputDecoration(
                labelText: 'Scan barcode or enter SKU',
                prefixIcon: Icon(Icons.qr_code_scanner),
                helperText:
                    'USB barcode scanners can type here and press Enter.',
              ),
              onSubmitted: _addIdentifier,
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('posProductSearch'),
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Filter loaded products',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: controller.isBusy && controller.products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? const Center(
                          child: Text('No matching products in the catalogue.'),
                        )
                      : ListView.separated(
                          itemCount: products.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(product.name),
                              subtitle: Text(
                                '${product.sku} · ${product.stock} in stock',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _money(
                                      controller.selectedBranch?.currency ??
                                          'KES',
                                      product.price,
                                    ),
                                  ),
                                  IconButton(
                                    key: Key('add-${product.sku}'),
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Add ${product.name}',
                                    onPressed:
                                        controller.isBusy || product.stock <= 0
                                            ? null
                                            : () => _addIdentifier(product.sku),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basketPanel(PosController controller, PosBranch? branch) {
    final quote = controller.quote;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Current sale',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text('${controller.cart.length} lines'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: controller.cart.isEmpty
                  ? const Center(child: Text('Scan an item to start a sale.'))
                  : ListView(
                      children: controller.cart.map((line) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(line.product.name),
                          subtitle: Text(line.product.sku),
                          trailing: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IconButton(
                                tooltip: 'Remove one',
                                onPressed: controller.isBusy
                                    ? null
                                    : () => ref
                                        .read(posControllerProvider)
                                        .updateQuantity(
                                          line.product.id,
                                          line.quantity - 1,
                                        ),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${line.quantity}'),
                              IconButton(
                                tooltip: 'Add one',
                                onPressed: controller.isBusy ||
                                        line.quantity >= line.product.stock
                                    ? null
                                    : () => ref
                                        .read(posControllerProvider)
                                        .updateQuantity(
                                          line.product.id,
                                          line.quantity + 1,
                                        ),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            if (quote != null) ...[
              const Divider(),
              _AmountRow('Subtotal', _money(quote.currency, quote.subtotal)),
              _AmountRow('Tax', _money(quote.currency, quote.tax)),
              _AmountRow(
                'Amount due',
                _money(quote.currency, quote.total),
                emphasize: true,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('cashReceived'),
                controller: _cashController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cash received',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('completeCashSale'),
                onPressed:
                    controller.isBusy || branch == null ? null : _checkout,
                icon: const Icon(Icons.receipt_long),
                label: Text(
                  controller.isBusy ? 'Processing…' : 'Complete cash sale',
                ),
              ),
            ] else if (controller.cart.isNotEmpty) ...[
              const Divider(),
              FilledButton.tonal(
                onPressed: controller.isBusy
                    ? null
                    : () => ref.read(posControllerProvider).refreshQuote(),
                child: const Text('Refresh server quote'),
              ),
              const Text(
                'Totals are available only from the server quote.',
                textAlign: TextAlign.center,
              ),
            ],
            if (controller.receipt case final receipt?) ...[
              const SizedBox(height: 12),
              Text(
                'Last sale: ${receipt.orderNumber}',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(this.label, this.amount, {this.emphasize = false});

  final String label;
  final String amount;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    emphasize ? Theme.of(context).textTheme.titleMedium : null,
              ),
            ),
            Text(
              amount,
              style: emphasize
                  ? Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)
                  : null,
            ),
          ],
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            message,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer),
          ),
        ),
      );
}

String _money(String currency, num amount) =>
    '$currency ${amount.toStringAsFixed(2)}';
