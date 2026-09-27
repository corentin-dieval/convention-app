import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/convention.dart';
import '../../../core/database/database_helper.dart';

// ─── Modèles de données internes ────────────────────────────────────────────

class _ConventionStats {
  final int nbClients;
  final double totalRevenue;
  final double avgCart;
  final double cashRevenue;
  final double cardRevenue;
  final int cashCount;
  final int cardCount;

  const _ConventionStats({
    required this.nbClients,
    required this.totalRevenue,
    required this.avgCart,
    required this.cashRevenue,
    required this.cardRevenue,
    required this.cashCount,
    required this.cardCount,
  });
}

class _TopItem {
  final String name;
  final int qty;
  final double revenue;
  const _TopItem({required this.name, required this.qty, required this.revenue});
}

// ─── Écran principal ─────────────────────────────────────────────────────────

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Convention> _conventions = [];
  Convention? _selected; // null = toutes conventions
  _ConventionStats? _stats;
  List<_TopItem> _topItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('conventions', orderBy: 'start_date DESC');
    final conventions = rows.map(Convention.fromMap).toList();
    if (!mounted) return;
    setState(() => _conventions = conventions);
    await _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final db = await DatabaseHelper.instance.database;
      final convFilter = _selected?.id?.toString();

      final where = convFilter != null
          ? 'WHERE cc.isPaid = 1 AND cc.conventionId = ?'
          : 'WHERE cc.isPaid = 1';
      final whereArgs = convFilter != null ? [convFilter] : <Object>[];

      // Stats globales
      final statsResult = await db.rawQuery('''
        SELECT
          COUNT(*)                                                        AS nb_clients,
          COALESCE(SUM(cc.totalAmount), 0)                                AS total_revenue,
          COALESCE(AVG(cc.totalAmount), 0)                                AS avg_cart,
          COALESCE(SUM(CASE WHEN cc.paymentMethod = 'cash' THEN cc.totalAmount ELSE 0 END), 0) AS cash_revenue,
          COALESCE(SUM(CASE WHEN cc.paymentMethod = 'card' THEN cc.totalAmount ELSE 0 END), 0) AS card_revenue,
          COUNT(CASE WHEN cc.paymentMethod = 'cash' THEN 1 END)          AS cash_count,
          COUNT(CASE WHEN cc.paymentMethod = 'card' THEN 1 END)          AS card_count
        FROM client_carts cc
        $where
      ''', whereArgs);

      final r = statsResult.first;
      final stats = _ConventionStats(
        nbClients:    (r['nb_clients']    as int?    ?? 0),
        totalRevenue: (r['total_revenue'] as num?    ?? 0).toDouble(),
        avgCart:      (r['avg_cart']      as num?    ?? 0).toDouble(),
        cashRevenue:  (r['cash_revenue']  as num?    ?? 0).toDouble(),
        cardRevenue:  (r['card_revenue']  as num?    ?? 0).toDouble(),
        cashCount:    (r['cash_count']    as int?    ?? 0),
        cardCount:    (r['card_count']    as int?    ?? 0),
      );

      // Top articles
      final topWhere = where;

      final topResult = await db.rawQuery('''
        SELECT i.name,
               SUM(ci.quantity)                    AS total_qty,
               SUM(ci.quantity * ci.priceSnapshot) AS revenue
        FROM cart_items ci
        JOIN items i        ON i.id = CAST(ci.itemId AS INTEGER)
        JOIN client_carts cc ON cc.id = ci.cartId
        $topWhere
        GROUP BY ci.itemId, i.name
        ORDER BY total_qty DESC
        LIMIT 10
      ''', whereArgs);

      final topItems = topResult
          .map((row) => _TopItem(
                name:    row['name']     as String? ?? '?',
                qty:     row['total_qty'] as int?   ?? 0,
                revenue: (row['revenue'] as num?    ?? 0).toDouble(),
              ))
          .toList();

      if (!mounted) return;
      setState(() {
        _stats    = stats;
        _topItems = topItems;
        _loading  = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur analytics: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analyticsStatistics),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSelector(l10n),
                  const SizedBox(height: 12),
                  if (_selected != null) _buildConventionBadge(l10n),
                  if (_stats != null) ...[
                    _buildSummaryGrid(l10n, _stats!),
                    const SizedBox(height: 16),
                    _buildPaymentCard(l10n, _stats!),
                    const SizedBox(height: 16),
                    _buildTopItemsCard(l10n),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
    );
  }

  // ── Sélecteur de convention ──────────────────────────────────────────────

  Widget _buildSelector(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButton<Convention?>(
          isExpanded: true,
          underline: const SizedBox.shrink(),
          value: _selected,
          hint: Text(l10n.allConventions),
          items: [
            DropdownMenuItem<Convention?>(
              value: null,
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, size: 18, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(l10n.allConventions),
                ],
              ),
            ),
            ..._conventions.map(
              (c) => DropdownMenuItem<Convention?>(
                value: c,
                child: Row(
                  children: [
                    Icon(
                      c.isClosed ? Icons.lock : Icons.lock_open,
                      size: 18,
                      color: c.isClosed ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (c) {
            setState(() => _selected = c);
            _loadStats();
          },
        ),
      ),
    );
  }

  // ── Badge convention sélectionnée ────────────────────────────────────────

  Widget _buildConventionBadge(AppLocalizations l10n) {
    final c = _selected!;
    return Card(
      color: c.isClosed ? Colors.red.shade50 : Colors.green.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          c.isClosed ? Icons.lock : Icons.lock_open,
          color: c.isClosed ? Colors.red : Colors.green,
        ),
        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(c.isClosed ? l10n.conventionClosed : l10n.conventionOpen),
        trailing: Text(
          c.isClosed ? l10n.conventionClosed : l10n.conventionOpen,
          style: TextStyle(
            color: c.isClosed ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Grille 2×2 de KPIs ───────────────────────────────────────────────────

  Widget _buildSummaryGrid(AppLocalizations l10n, _ConventionStats s) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _StatCard(
          icon: Icons.euro,
          label: l10n.totalRevenue,
          value: '€${s.totalRevenue.toStringAsFixed(2)}',
          color: Colors.deepPurple,
        ),
        _StatCard(
          icon: Icons.people,
          label: l10n.clients,
          value: '${s.nbClients}',
          color: Colors.blue,
        ),
        _StatCard(
          icon: Icons.shopping_cart,
          label: l10n.averageCart,
          value: '€${s.avgCart.toStringAsFixed(2)}',
          color: Colors.green,
        ),
        _StatCard(
          icon: Icons.receipt_long,
          label: l10n.totalTransactions,
          value: '${s.nbClients}',
          color: Colors.orange,
        ),
      ],
    );
  }

  // ── Répartition paiements ────────────────────────────────────────────────

  Widget _buildPaymentCard(AppLocalizations l10n, _ConventionStats s) {
    final total = s.cashRevenue + s.cardRevenue;
    final cashPct = total > 0 ? s.cashRevenue / total : 0.0;
    final cardPct = total > 0 ? s.cardRevenue / total : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.paymentBreakdown,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _PaymentRow(
              icon: Icons.money,
              label: l10n.cashRevenue,
              amount: s.cashRevenue,
              count: s.cashCount,
              pct: cashPct,
              color: Colors.green,
            ),
            const Divider(height: 24),
            _PaymentRow(
              icon: Icons.credit_card,
              label: l10n.cardRevenue,
              amount: s.cardRevenue,
              count: s.cardCount,
              pct: cardPct,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  // ── Top articles ─────────────────────────────────────────────────────────

  Widget _buildTopItemsCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.topItems,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_topItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.noData, style: const TextStyle(color: Colors.grey)),
                ),
              )
            else ...[
              // Entête
              Row(
                children: [
                  const SizedBox(width: 36),
                  Expanded(
                    flex: 3,
                    child: Text(l10n.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(l10n.quantity,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(l10n.revenue,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
              const Divider(),
              ..._topItems.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(item.name, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text('${item.qty}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text('€${item.revenue.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Widgets réutilisables ────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final int count;
  final double pct;
  final Color color;

  const _PaymentRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.count,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '$count transaction${count != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 15),
            ),
            Text(
              '${(pct * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

