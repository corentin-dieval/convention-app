import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/convention.dart';
import '../../../core/models/item.dart';
import '../../../core/models/client_cart.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/repositories/client_cart_repository.dart';
import '../../../core/repositories/item_repository.dart';
import '../convention_provider.dart';
import '../../refill/refill_provider.dart';

const _uuid = Uuid();

class ConventionDetailScreen extends StatefulWidget {
  final int conventionId;
  const ConventionDetailScreen({super.key, required this.conventionId});

  @override
  State<ConventionDetailScreen> createState() => _ConventionDetailScreenState();
}

class _ConventionDetailScreenState extends State<ConventionDetailScreen> {
  final _cartRepo = ClientCartRepository();
  final _cartItemRepo = CartItemRepository();
  final _itemRepo = ItemRepository();

  List<ClientCart> _carts = [];
  String? _selectedCartId;
  List<CartItem> _cartItems = [];
  List<Item> _catalogue = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConventionProvider>().loadConventions();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final conventionIdStr = widget.conventionId.toString();
    final carts = await _cartRepo.getCartsByConvention(conventionIdStr);
    final catalogue = await _itemRepo.getAll();
    // Garder seulement les paniers non payés
    final activeCarts = carts.where((c) => !c.isPaid).toList();
    setState(() {
      _carts = activeCarts;
      _catalogue = catalogue;
      _loading = false;
      if (_selectedCartId == null && activeCarts.isNotEmpty) {
        _selectedCartId = activeCarts.first.id;
      }
    });
    if (_selectedCartId != null) await _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    if (_selectedCartId == null) return;
    final items = await _cartItemRepo.getCartItems(_selectedCartId!);
    setState(() => _cartItems = items);
  }

  Future<void> _newCart() async {
    final conventionIdStr = widget.conventionId.toString();
    final nextNum = await _cartRepo.getNextCartNumber(conventionIdStr);
    final cart = ClientCart(
      id: _uuid.v4(),
      conventionId: conventionIdStr,
      cartNumber: nextNum,
      createdAt: DateTime.now(),
    );
    await _cartRepo.createCart(cart);
    setState(() {
      _carts.add(cart);
      _selectedCartId = cart.id;
      _cartItems = [];
    });
  }

  Future<void> _selectCart(String cartId) async {
    setState(() => _selectedCartId = cartId);
    await _loadCartItems();
  }

  Future<void> _addItem(Item item) async {
    if (_selectedCartId == null) {
      _showSnack('Créez d\'abord un client');
      return;
    }
    // Vérifier si l'article est déjà dans le panier
    final existing = _cartItems.where((ci) => ci.itemId == item.id.toString()).toList();
    if (existing.isNotEmpty) {
      // Incrémenter la quantité
      final ci = existing.first;
      await _cartItemRepo.updateItemQuantity(ci.id, ci.quantity + 1);
    } else {
      final ci = CartItem(
        id: _uuid.v4(),
        cartId: _selectedCartId!,
        itemId: item.id.toString(),
        quantity: 1,
        priceSnapshot: item.unitPrice,
        createdAt: DateTime.now(),
      );
      await _cartItemRepo.addItemToCart(ci);
    }
    await _loadCartItems();
    await _updateCartTotal();
  }

  Future<void> _updateQty(CartItem ci, int delta) async {
    final newQty = ci.quantity + delta;
    await _cartItemRepo.updateItemQuantity(ci.id, newQty);
    await _loadCartItems();
    await _updateCartTotal();
  }

  Future<void> _removeItem(CartItem ci) async {
    await _cartItemRepo.removeItemFromCart(ci.id);
    await _loadCartItems();
    await _updateCartTotal();
  }

  Future<void> _updateCartTotal() async {
    if (_selectedCartId == null) return;
    final total = _cartItems.fold<double>(
        0, (s, ci) => s + ci.priceSnapshot * ci.quantity);
    await _cartRepo.updateCartTotal(_selectedCartId!, total);
  }

  double get _cartTotal =>
      _cartItems.fold(0, (s, ci) => s + ci.priceSnapshot * ci.quantity);

  Map<String, String> get _itemNameById {
    return {for (final i in _catalogue) i.id.toString(): i.name};
  }

  Future<void> _validateCart() async {
    if (_selectedCartId == null || _cartItems.isEmpty) return;

    // Étape 1 : choix du mode de paiement
    final paymentMethod = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mode de paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total : €${_cartTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Comment règle le client ?'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'cash'),
                  icon: const Icon(Icons.money),
                  label: const Text('Espèces'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'card'),
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Carte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (paymentMethod == null || !mounted) return;

    // Décrémenter le stock pour chaque article
    for (final ci in _cartItems) {
      final itemId = int.tryParse(ci.itemId);
      if (itemId != null) {
        await _itemRepo.decrementStock(itemId, ci.quantity);
      }
    }

    // Marquer le panier comme payé avec le mode de paiement
    await _cartRepo.markCartAsPaid(_selectedCartId!, paymentMethod: paymentMethod);

    // Recharger le catalogue depuis la DB pour refléter les nouveaux stocks
    final updatedCatalogue = await _itemRepo.getAll();

    // Supprimer le panier de la liste active
    setState(() {
      _catalogue = updatedCatalogue;
      _carts.removeWhere((c) => c.id == _selectedCartId);
      _cartItems = [];
      _selectedCartId = _carts.isNotEmpty ? _carts.first.id : null;
    });

    if (_selectedCartId != null) await _loadCartItems();

    // Notifier le RefillProvider pour rafraîchir le stock dans l'onglet Refill
    if (mounted) {
      context.read<RefillProvider>().loadItems();
    }

    if (mounted) {
      final label = paymentMethod == 'cash' ? 'Espèces 💵' : 'Carte 💳';
      _showSnack('✅ Paiement validé ($label) ! Stock mis à jour.', color: Colors.green);
    }
  }

  Future<void> _deleteCart(String cartId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le panier ?'),
        content: const Text('Les articles non payés seront perdus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await _cartRepo.deleteCart(cartId);
    setState(() {
      _carts.removeWhere((c) => c.id == cartId);
      if (_selectedCartId == cartId) {
        _selectedCartId = _carts.isNotEmpty ? _carts.first.id : null;
        _cartItems = [];
      }
    });
    if (_selectedCartId != null) await _loadCartItems();
  }

  void _showSnack(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Convention? get _convention {
    try {
      return context
          .read<ConventionProvider>()
          .conventions
          .firstWhere((c) => c.id == widget.conventionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final convention = _convention;

    return Scaffold(
      appBar: AppBar(
        title: Text(convention?.name ?? 'Convention'),
        actions: [
          if (convention != null) ...[
            IconButton(
              icon: Icon(convention.isClosed ? Icons.lock : Icons.lock_open),
              tooltip: convention.isClosed ? 'Rouvrir la convention' : 'Fermer la convention',
              onPressed: () async {
                await context.read<ConventionProvider>().toggleClose(convention);
                setState(() {}); // rafraîchit l'icône
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: () =>
                  context.push('/convention/${convention.id}/edit'),
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildClientBar(),
                const Divider(height: 1),
                Expanded(
                  child: _selectedCartId == null
                      ? _buildEmptyState()
                      : _buildPOSView(),
                ),
              ],
            ),
    );
  }

  Widget _buildClientBar() {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.people_alt_outlined, size: 18),
          const SizedBox(width: 6),
          const Text('Clients :', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._carts.map((cart) => _ClientTab(
                        cart: cart,
                        isSelected: cart.id == _selectedCartId,
                        onTap: () => _selectCart(cart.id),
                        onDelete: () => _deleteCart(cart.id),
                      )),
                  const SizedBox(width: 4),
                  FilledButton.icon(
                    onPressed: _newCart,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nouveau'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Aucun client actif',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Appuyez sur "Nouveau" pour créer un panier client',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _newCart,
            icon: const Icon(Icons.add),
            label: const Text('Nouveau client'),
          ),
        ],
      ),
    );
  }

  Widget _buildPOSView() {
    return Column(
      children: [
        // Panier actuel
        Expanded(
          flex: 5,
          child: _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text('Panier vide',
                          style: TextStyle(color: Colors.grey)),
                      const Text('Ajoutez des articles ci-dessous',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _cartItems.length,
                  itemBuilder: (ctx, i) {
                    final ci = _cartItems[i];
                    final name =
                        _itemNameById[ci.itemId] ?? 'Article #${ci.itemId}';
                    return _CartItemRow(
                      cartItem: ci,
                      itemName: name,
                      onIncrease: () => _updateQty(ci, 1),
                      onDecrease: () => _updateQty(ci, -1),
                      onRemove: () => _removeItem(ci),
                    );
                  },
                ),
        ),
        // Barre catalogue (boutons articles)
        const Divider(height: 1),
        _buildCatalogueBar(),
        // Barre total + payer
        _buildTotalBar(),
      ],
    );
  }

  Widget _buildCatalogueBar() {
    final inStock = _catalogue.where((i) => i.stockQuantity > 0).toList();
    if (inStock.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Aucun article en stock', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      height: 100,
      color: Theme.of(context).colorScheme.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: inStock.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final item = inStock[i];
          return _CatalogueButton(
            item: item,
            onTap: () => _addItem(item),
          );
        },
      ),
    );
  }

  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border(
            top: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3)))
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('TOTAL',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                '€${_cartTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _cartItems.isEmpty ? null : _validateCart,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('PAYER',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _ClientTab extends StatelessWidget {
  final ClientCart cart;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ClientTab({
    required this.cart,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: isSelected ? Colors.white : null,
                ),
                const SizedBox(width: 4),
                Text(
                  'Client #${cart.cartNumber}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem cartItem;
  final String itemName;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.cartItem,
    required this.itemName,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = cartItem.priceSnapshot * cartItem.quantity;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '€${cartItem.priceSnapshot.toStringAsFixed(2)} / unité',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _QtyBtn(icon: Icons.remove, onPressed: onDecrease),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${cartItem.quantity}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            _QtyBtn(icon: Icons.add, onPressed: onIncrease),
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: Text(
                '€${lineTotal.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QtyBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton.filled(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}

class _CatalogueButton extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const _CatalogueButton({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '€${item.unitPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              'Stock: ${item.stockQuantity}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
