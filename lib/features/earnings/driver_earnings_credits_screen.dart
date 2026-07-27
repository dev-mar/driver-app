import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/network/driver_api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../gen_l10n/app_localizations.dart';
import '../login/driver_trip_history_screen.dart'
    show DriverTripHistoryItem, DriverTripHistoryResponse;

/// Ingresos por viajes completados, saldo de créditos y movimientos — con filtros por fecha.
class DriverEarningsCreditsScreen extends StatefulWidget {
  const DriverEarningsCreditsScreen({super.key});

  @override
  State<DriverEarningsCreditsScreen> createState() =>
      _DriverEarningsCreditsScreenState();
}

class _DriverEarningsCreditsScreenState extends State<DriverEarningsCreditsScreen> {
  static const _storage = FlutterSecureStorage();
  static const _kRangeKey = 'driver_earnings_date_range';
  static const _kCustomFromKey = 'driver_earnings_custom_from';
  static const _kCustomToKey = 'driver_earnings_custom_to';

  String _dateRange = '30d';
  DateTimeRange? _customRange;
  bool _loading = true;
  String? _error;

  _EarningsSummary? _earnings;
  _AppCreditsPayload? _credits;
  List<_LedgerRow> _ledger = const [];
  List<DriverTripHistoryItem> _trips = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _restoreFilters();
    if (mounted) await _load();
  }

  Future<void> _restoreFilters() async {
    final stored = await _storage.read(key: _kRangeKey);
    final fromS = await _storage.read(key: _kCustomFromKey);
    final toS = await _storage.read(key: _kCustomToKey);
    final from = fromS != null ? DateTime.tryParse(fromS) : null;
    final to = toS != null ? DateTime.tryParse(toS) : null;
    if (!mounted) return;
    setState(() {
      _dateRange = (stored == null || stored.isEmpty) ? '30d' : stored;
      _customRange =
          (from != null && to != null) ? DateTimeRange(start: from, end: to) : null;
      if (_dateRange == 'custom' && _customRange == null) {
        _dateRange = '30d';
      }
    });
  }

  Future<void> _persistFilters() async {
    await _storage.write(key: _kRangeKey, value: _dateRange);
    await _storage.write(
      key: _kCustomFromKey,
      value: _customRange?.start.toIso8601String() ?? '',
    );
    await _storage.write(
      key: _kCustomToKey,
      value: _customRange?.end.toIso8601String() ?? '',
    );
  }

  DateTime? _fromBoundary() {
    if (_dateRange == 'custom') return _customRange?.start;
    final now = DateTime.now();
    if (_dateRange == 'today') {
      return DateTime(now.year, now.month, now.day);
    }
    if (_dateRange == '7d') return now.subtract(const Duration(days: 7));
    if (_dateRange == '30d') return now.subtract(const Duration(days: 30));
    return null;
  }

  DateTime? _toBoundary() {
    if (_dateRange == 'custom') {
      final end = _customRange?.end;
      if (end == null) return null;
      return DateTime(end.year, end.month, end.day, 23, 59, 59);
    }
    if (_dateRange == 'today') {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
    return null;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = DriverApiClient();
      final from = _fromBoundary();
      final to = _toBoundary();
      final qp = <String, dynamic>{
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      };

      final results = await Future.wait([
        client.getWithRetry<Map<String, dynamic>>(
          path: '/drivers/me/earnings-summary',
          flow: 'driver_earnings_summary',
          maxAttempts: 2,
          queryParameters: qp,
        ),
        client.getWithRetry<Map<String, dynamic>>(
          path: '/api/v2/driver/app-credits',
          flow: 'driver_app_credits',
          maxAttempts: 2,
        ),
        client.getWithRetry<Map<String, dynamic>>(
          path: '/api/v2/driver/app-credits/ledger',
          flow: 'driver_credits_ledger',
          maxAttempts: 2,
          queryParameters: {
            ...qp,
            'limit': 100,
          },
        ),
        client.getWithRetry<Map<String, dynamic>>(
          path: '/drivers/me/trips',
          flow: 'driver_earnings_trips',
          maxAttempts: 2,
          queryParameters: {
            'status': 'completed',
            'limit': 40,
            'offset': 0,
            ...qp,
          },
        ),
      ]);

      _EarningsSummary? earn;
      final eroot = results[0].data;
      if (eroot != null && eroot['success'] == true && eroot['data'] is Map) {
        earn = _EarningsSummary.fromJson(
          Map<String, dynamic>.from(eroot['data'] as Map),
        );
      }

      _AppCreditsPayload? cred;
      final croot = results[1].data;
      if (croot != null && croot['success'] == true && croot['data'] is Map) {
        cred = _AppCreditsPayload.fromJson(
          Map<String, dynamic>.from(croot['data'] as Map),
        );
      }

      var ledger = <_LedgerRow>[];
      final lroot = results[2].data;
      if (lroot != null && lroot['success'] == true && lroot['data'] is Map) {
        final d = Map<String, dynamic>.from(lroot['data'] as Map);
        final items = d['items'];
        if (items is List) {
          ledger = items
              .whereType<Map>()
              .map((e) => _LedgerRow.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      var trips = <DriverTripHistoryItem>[];
      final troot = results[3].data;
      if (troot != null && troot['success'] == true && troot['data'] is Map) {
        final tr = DriverTripHistoryResponse.fromJson(
          Map<String, dynamic>.from(troot['data'] as Map),
        );
        trips = tr.trips;
      }

      if (!mounted) return;
      setState(() {
        _earnings = earn;
        _credits = cred;
        _ledger = ledger;
        _trips = trips;
        _loading = false;
      });
    } on DriverApiSessionException {
      if (!mounted) return;
      setState(() {
        _error = 'NO_SESSION';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'LOAD';
        _loading = false;
      });
    }
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
    );
    if (picked == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      _customRange = picked;
      _dateRange = 'custom';
    });
    await _persistFilters();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driverEarningsCreditsTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.driverEarningsCreditsFilterHint,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _RangeChip(
                            label: l10n.driverTripHistoryDateAll,
                            selected: _dateRange == 'all',
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _dateRange = 'all');
                              _persistFilters();
                              _load();
                            },
                          ),
                          _RangeChip(
                            label: l10n.driverTripHistoryDateToday,
                            selected: _dateRange == 'today',
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _dateRange = 'today');
                              _persistFilters();
                              _load();
                            },
                          ),
                          _RangeChip(
                            label: l10n.driverTripHistoryDate7d,
                            selected: _dateRange == '7d',
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _dateRange = '7d');
                              _persistFilters();
                              _load();
                            },
                          ),
                          _RangeChip(
                            label: l10n.driverTripHistoryDate30d,
                            selected: _dateRange == '30d',
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _dateRange = '30d');
                              _persistFilters();
                              _load();
                            },
                          ),
                          _RangeChip(
                            label: l10n.driverTripHistoryDateCustom,
                            selected: _dateRange == 'custom',
                            onTap: _pickCustomRange,
                          ),
                        ],
                      ),
                    ),
                    if (_dateRange == 'custom' && _customRange != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.driverTripHistoryCustomRangeLabel}: '
                        '${_customRange!.start.day}/${_customRange!.start.month}/${_customRange!.start.year} — '
                        '${_customRange!.end.day}/${_customRange!.end.month}/${_customRange!.end.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _error == 'NO_SESSION'
                        ? l10n.driverTripHistoryNoSession
                        : l10n.driverEarningsCreditsLoadError,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SummaryGrid(
                    l10n: l10n,
                    earnings: _earnings,
                    credits: _credits,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    l10n.driverEarningsCreditsLedgerSection,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (_ledger.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.driverEarningsCreditsLedgerEmpty,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: _ledger.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _LedgerTile(row: _ledger[i], l10n: l10n),
                    );
                  },
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    l10n.driverEarningsCreditsTripsSection,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (_trips.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.driverEarningsCreditsTripsEmpty,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: _trips.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _CompletedTripTile(trip: _trips[i], l10n: l10n),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatPercent(double v) {
  if (v == v.roundToDouble()) return v.round().toString();
  return v.toStringAsFixed(2);
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.28)
            : AppColors.surfaceCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.l10n,
    required this.earnings,
    required this.credits,
  });

  final AppLocalizations l10n;
  final _EarningsSummary? earnings;
  final _AppCreditsPayload? credits;

  @override
  Widget build(BuildContext context) {
    final cc = earnings?.currencyCode ?? 'BOB';
    final trips = earnings?.completedTripCount ?? 0;
    final gross = earnings?.grossEarningsTotal ?? 0;
    final commission = earnings?.creditsCommissionTotal ?? 0;
    final balance = credits?.balance ?? 0;
    final cr = credits;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryHighlightCard(
                icon: Icons.route_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                title: l10n.driverEarningsCreditsStatTrips,
                value: '$trips',
                subtitle: l10n.driverEarningsCreditsStatTripsHint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryHighlightCard(
                icon: Icons.payments_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                title: l10n.driverEarningsCreditsStatGross,
                value: formatMoney(gross, currencyCode: cc),
                subtitle: l10n.driverEarningsCreditsStatGrossHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryHighlightCard(
                icon: Icons.account_balance_wallet_rounded,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.95),
                    const Color(0xFF6A1B9A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                title: l10n.driverEarningsCreditsStatBalance,
                value: formatMoney(balance, currencyCode: cc),
                subtitle: credits?.programEnabled == true
                    ? l10n.driverAppCreditsProgramOn
                    : l10n.driverAppCreditsProgramOff,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryHighlightCard(
                icon: Icons.percent_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4E342E), Color(0xFFBF360C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                title: l10n.driverEarningsCreditsStatCommission,
                value: formatMoney(commission, currencyCode: cc),
                subtitle: l10n.driverEarningsCreditsStatCommissionHint,
              ),
            ),
          ],
        ),
        if (cr != null && cr.programEnabled) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              cr.deductionMode == 'fixed'
                  ? l10n.driverAppCreditsDetailFixed(
                      cr.fixedAmount.toStringAsFixed(2),
                    )
                  : l10n.driverAppCreditsDetailPercent(
                      _formatPercent(cr.percentValue),
                    ),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.95),
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryHighlightCard extends StatelessWidget {
  const _SummaryHighlightCard({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Gradient gradient;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.92), size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.82),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.25,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.row, required this.l10n});

  final _LedgerRow row;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isCredit = (row.amountDelta ?? 0) > 0;
    final icon = isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline;
    final color = isCredit ? AppColors.success : AppColors.error;
    final kindLabel = switch (row.entryKind) {
      'grant' => l10n.driverEarningsCreditsLedgerGrant,
      'trip_commission' => l10n.driverEarningsCreditsLedgerCommission,
      _ => row.entryKind,
    };
    final when = row.createdAt.toString();
    return Material(
      color: AppColors.surfaceCard.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kindLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    when.length > 19 ? when.substring(0, 19) : when,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                    ),
                  ),
                  if (row.tripId != null)
                    Text(
                      '${l10n.driverEarningsCreditsTripIdShort} ${row.tripId!.substring(0, 8)}…',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '${row.amountDelta != null && row.amountDelta! > 0 ? '+' : ''}'
              '${row.amountDelta?.toStringAsFixed(2) ?? '—'}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedTripTile extends StatelessWidget {
  const _CompletedTripTile({required this.trip, required this.l10n});

  final DriverTripHistoryItem trip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final price = trip.finalPrice ?? trip.estimatedPrice;
    final cc = trip.currencyCode ?? 'BOB';
    final priceLabel = price != null
        ? formatMoney(price, currencyCode: cc)
        : l10n.driverTripHistoryPricePending;
    final when = trip.createdAt.toString();
    return Material(
      color: AppColors.surface.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.driverTripHistoryStatusCompleted,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    when.length > 19 ? when.substring(0, 19) : when,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              priceLabel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsSummary {
  _EarningsSummary({
    required this.completedTripCount,
    required this.grossEarningsTotal,
    required this.creditsCommissionTotal,
    required this.currencyCode,
  });

  final int completedTripCount;
  final double grossEarningsTotal;
  final double creditsCommissionTotal;
  final String currencyCode;

  factory _EarningsSummary.fromJson(Map<String, dynamic> j) {
    return _EarningsSummary(
      completedTripCount: (j['completedTripCount'] as num?)?.toInt() ?? 0,
      grossEarningsTotal: (j['grossEarningsTotal'] as num?)?.toDouble() ?? 0,
      creditsCommissionTotal:
          (j['creditsCommissionTotal'] as num?)?.toDouble() ?? 0,
      currencyCode: j['currencyCode']?.toString() ?? 'BOB',
    );
  }
}

class _AppCreditsPayload {
  _AppCreditsPayload({
    required this.balance,
    required this.programEnabled,
    required this.deductionMode,
    required this.percentValue,
    required this.fixedAmount,
  });

  final double balance;
  final bool programEnabled;
  final String deductionMode;
  final double percentValue;
  final double fixedAmount;

  factory _AppCreditsPayload.fromJson(Map<String, dynamic> j) {
    return _AppCreditsPayload(
      balance: (j['balance'] as num?)?.toDouble() ?? 0,
      programEnabled: j['programEnabled'] == true,
      deductionMode: j['deductionMode']?.toString() == 'fixed' ? 'fixed' : 'percent',
      percentValue: (j['percentValue'] as num?)?.toDouble() ?? 0,
      fixedAmount: (j['fixedAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class _LedgerRow {
  _LedgerRow({
    required this.entryKind,
    required this.amountDelta,
    required this.tripId,
    required this.createdAt,
  });

  final String entryKind;
  final double? amountDelta;
  final String? tripId;
  final DateTime createdAt;

  factory _LedgerRow.fromJson(Map<String, dynamic> j) {
    final ca = j['createdAt'];
    DateTime dt;
    if (ca is String) {
      dt = DateTime.tryParse(ca) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      dt = DateTime.fromMillisecondsSinceEpoch(0);
    }
    return _LedgerRow(
      entryKind: j['entryKind']?.toString() ?? '',
      amountDelta: (j['amountDelta'] as num?)?.toDouble(),
      tripId: j['tripId']?.toString(),
      createdAt: dt,
    );
  }
}
