import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/driver_backend_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../gen_l10n/app_localizations.dart';

class DriverTripHistoryScreen extends StatefulWidget {
  const DriverTripHistoryScreen({super.key});

  @override
  State<DriverTripHistoryScreen> createState() =>
      _DriverTripHistoryScreenState();
}

class _DriverTripHistoryScreenState extends State<DriverTripHistoryScreen> {
  static const _storage = FlutterSecureStorage();
  static const _kStatusKey = 'driver_trip_history_status';
  static const _kDateRangeKey = 'driver_trip_history_date_range';
  static const _kCustomFromKey = 'driver_trip_history_custom_from';
  static const _kCustomToKey = 'driver_trip_history_custom_to';
  static const _statusOptions = <String?>[
    null,
    'completed',
    'cancelled',
    'started',
  ];
  static const _pageSize = 20;

  bool _loading = true;
  String? _error;
  String? _status;
  String _dateRange = '7d';
  int _activeTimeIndex = 0;
  DateTimeRange? _customRange;
  int _offset = 0;
  DriverTripHistoryResponse? _response;
  late final PageController _timePageController;

  Future<String?> _token() => _storage.read(key: 'driver_token');

  @override
  void initState() {
    super.initState();
    _timePageController = PageController(
      viewportFraction: 0.44,
      initialPage: _activeTimeIndex,
    );
    _bootstrap();
  }

  @override
  void dispose() {
    _timePageController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _restoreFilters();
    if (!mounted) {
      return;
    }
    await _load();
  }

  Future<void> _restoreFilters() async {
    final storedStatus = await _storage.read(key: _kStatusKey);
    final storedDateRange = await _storage.read(key: _kDateRangeKey);
    final storedFrom = await _storage.read(key: _kCustomFromKey);
    final storedTo = await _storage.read(key: _kCustomToKey);
    final parsedFrom = storedFrom != null ? DateTime.tryParse(storedFrom) : null;
    final parsedTo = storedTo != null ? DateTime.tryParse(storedTo) : null;
    if (!mounted) {
      return;
    }
    setState(() {
      _status = (storedStatus == null || storedStatus.isEmpty) ? null : storedStatus;
      _dateRange = (storedDateRange == null || storedDateRange.isEmpty) ? '7d' : storedDateRange;
      _activeTimeIndex = _timeIndexForRange(_dateRange);
      _customRange = (parsedFrom != null && parsedTo != null)
          ? DateTimeRange(start: parsedFrom, end: parsedTo)
          : null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timePageController.jumpToPage(_activeTimeIndex);
    });
  }

  Future<void> _persistFilters() async {
    await _storage.write(key: _kStatusKey, value: _status ?? '');
    await _storage.write(key: _kDateRangeKey, value: _dateRange);
    await _storage.write(
      key: _kCustomFromKey,
      value: _customRange?.start.toIso8601String() ?? '',
    );
    await _storage.write(
      key: _kCustomToKey,
      value: _customRange?.end.toIso8601String() ?? '',
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _token();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'NO_SESSION';
          _loading = false;
        });
        return;
      }
      final dio = Dio(
        BaseOptions(
          baseUrl: DriverBackendConfig.baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      final res = await dio.get<Map<String, dynamic>>(
        '/drivers/me/trips',
        queryParameters: {
          if (_status != null && _status!.isNotEmpty) 'status': _status,
          if (_fromDateForRange(_dateRange) != null)
            'from': _fromDateForRange(_dateRange)!.toIso8601String(),
          if (_toDateForRange(_dateRange) != null)
            'to': _toDateForRange(_dateRange)!.toIso8601String(),
          'limit': _pageSize,
          'offset': _offset,
        },
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'] is Map
          ? Map<String, dynamic>.from(root['data'])
          : <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        _response = DriverTripHistoryResponse.fromJson(data);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'LOAD_FAILED';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trips = _response?.trips ?? const <DriverTripHistoryItem>[];
    final total = _response?.total ?? 0;
    final canPrev = _offset > 0;
    final canNext = _offset + _pageSize < total;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.driverTripHistoryTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                minHeight: 72,
                maxHeight: 186,
                builder: (context, shrinkOffset, overlapsContent) {
                  final compact = shrinkOffset > 72;
                  final elevated = compact || overlapsContent;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: elevated
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : const [],
                      border: Border(
                        bottom: BorderSide(
                          color: elevated
                              ? Theme.of(context).colorScheme.outlineVariant
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: _FiltersPanelDriver(
                      l10n: l10n,
                      status: _status,
                      dateRange: _dateRange,
                      customRange: _customRange,
                      statusOptions: _statusOptions,
                      statusIcon: _statusIcon,
                      rangeIcon: _rangeIcon,
                      timePageController: _timePageController,
                      activeTimeIndex: _activeTimeIndex,
                      fmtDate: _fmtDate,
                      statusLabel: _statusLabel(l10n, _status),
                      dateRangeLabel: _dateRangeLabel(l10n, _dateRange),
                      compact: compact,
                      onStatusTap: (status) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _status = status;
                          _offset = 0;
                        });
                        _persistFilters();
                        _load();
                      },
                      onRangeTap: (range) async {
                        HapticFeedback.lightImpact();
                        if (range == 'custom') {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDateRange: _customRange,
                          );
                          if (picked == null) return;
                          setState(() {
                            _customRange = picked;
                            _dateRange = 'custom';
                              _activeTimeIndex = 0;
                            _offset = 0;
                          });
                          _persistFilters();
                          _load();
                          return;
                        }
                        setState(() {
                          _dateRange = range;
                            _activeTimeIndex = _timeIndexForRange(range);
                          _offset = 0;
                        });
                        _persistFilters();
                        _load();
                      },
                      onTimePageChanged: (index) {
                        final range = _rangeForTimeIndex(index);
                        if (_dateRange == range) return;
                        setState(() {
                          _activeTimeIndex = index;
                          _dateRange = range;
                          _offset = 0;
                        });
                        _persistFilters();
                        _load();
                      },
                      onTimeCardTap: (index) async {
                        if (_timePageController.hasClients) {
                          await _timePageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                          );
                        }
                        final range = _rangeForTimeIndex(index);
                        if (_dateRange == range) {
                          return;
                        }
                        setState(() {
                          _activeTimeIndex = index;
                          _dateRange = range;
                          _offset = 0;
                        });
                        _persistFilters();
                        _load();
                      },
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _loading
                      ? const _LoadingSkeletonList(key: ValueKey('loading'))
                      : _error != null
                          ? Card(
                              key: const ValueKey('error'),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _error == 'NO_SESSION'
                                      ? l10n.driverTripHistoryNoSession
                                      : l10n.driverTripHistoryLoadError,
                                ),
                              ),
                            )
                          : trips.isEmpty
                              ? Card(
                                  key: const ValueKey('empty'),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.history_toggle_off_rounded, size: 34),
                                        const SizedBox(height: 8),
                                        Text(l10n.driverTripHistoryEmpty),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  key: const ValueKey('list'),
                                  children: [
                                    ..._buildGroupedTripWidgets(trips, l10n),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: canPrev
                                                ? () {
                                                    setState(() {
                                                      _offset = (_offset - _pageSize).clamp(0, 1 << 30);
                                                    });
                                                    _load();
                                                  }
                                                : null,
                                            child: Text(l10n.driverTripHistoryPrevPage),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: canNext
                                                ? () {
                                                    setState(() {
                                                      _offset += _pageSize;
                                                    });
                                                    _load();
                                                  }
                                                : null,
                                            child: Text(l10n.driverTripHistoryNextPage),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String? status) {
    switch (status) {
      case null:
        return l10n.driverTripHistoryFilterAll;
      case 'completed':
        return l10n.driverTripHistoryFilterCompleted;
      case 'cancelled':
        return l10n.driverTripHistoryFilterCancelled;
      case 'started':
        return l10n.driverTripHistoryFilterInProgress;
      default:
        return status;
    }
  }

  String _dateRangeLabel(AppLocalizations l10n, String range) {
    switch (range) {
      case 'today':
        return l10n.driverTripHistoryDateToday;
      case '7d':
        return l10n.driverTripHistoryDate7d;
      case '30d':
        return l10n.driverTripHistoryDate30d;
      case 'all':
      case 'custom':
      default:
        return range == 'custom'
            ? l10n.driverTripHistoryDateCustom
            : l10n.driverTripHistoryDateAll;
    }
  }

  DateTime? _fromDateForRange(String range) {
    if (range == 'custom') {
      return _customRange?.start;
    }
    final now = DateTime.now();
    if (range == 'today') return DateTime(now.year, now.month, now.day);
    if (range == '7d') return now.subtract(const Duration(days: 7));
    if (range == '30d') return now.subtract(const Duration(days: 30));
    return null;
  }

  DateTime? _toDateForRange(String range) {
    if (range == 'custom') {
      final end = _customRange?.end;
      if (end == null) {
        return null;
      }
      return DateTime(end.year, end.month, end.day, 23, 59, 59);
    }
    if (range == 'today') {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
    return null;
  }

  String _fmtDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'started':
        return Icons.directions_car_filled_outlined;
      default:
        return Icons.filter_list_rounded;
    }
  }

  IconData _rangeIcon(String range) {
    switch (range) {
      case 'today':
        return Icons.today_outlined;
      case '7d':
      case '30d':
        return Icons.date_range_outlined;
      case 'custom':
        return Icons.edit_calendar_outlined;
      default:
        return Icons.all_inclusive_rounded;
    }
  }

  int _timeIndexForRange(String range) {
    switch (range) {
      case '30d':
        return 1;
      case 'today':
        return 2;
      case '7d':
      default:
        return 0;
    }
  }

  String _rangeForTimeIndex(int index) {
    const ranges = <String>['7d', '30d', 'today'];
    return ranges[index.clamp(0, ranges.length - 1)];
  }

  List<Widget> _buildGroupedTripWidgets(
    List<DriverTripHistoryItem> trips,
    AppLocalizations l10n,
  ) {
    final widgets = <Widget>[];
    String? lastBucket;
    for (final trip in trips) {
      final bucket = _dateBucket(trip.createdAt);
      if (bucket != lastBucket) {
        widgets.add(_DateSectionHeader(title: _bucketLabel(l10n, bucket)));
        lastBucket = bucket;
      }
      widgets.add(_DriverTripTile(trip: trip, l10n: l10n));
    }
    return widgets;
  }

  String _dateBucket(DateTime? date) {
    if (date == null) return 'older';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(tripDay).inDays;
    if (diff <= 0) return 'today';
    if (diff == 1) return 'yesterday';
    return 'older';
  }

  String _bucketLabel(AppLocalizations l10n, String bucket) {
    switch (bucket) {
      case 'today':
        return l10n.driverTripHistorySectionToday;
      case 'yesterday':
        return l10n.driverTripHistorySectionYesterday;
      default:
        return l10n.driverTripHistorySectionOlder;
    }
  }
}

class _FiltersPanelDriver extends StatelessWidget {
  const _FiltersPanelDriver({
    required this.l10n,
    required this.status,
    required this.dateRange,
    required this.customRange,
    required this.statusOptions,
    required this.statusIcon,
    required this.rangeIcon,
    required this.timePageController,
    required this.activeTimeIndex,
    required this.fmtDate,
    required this.statusLabel,
    required this.dateRangeLabel,
    required this.compact,
    required this.onStatusTap,
    required this.onRangeTap,
    required this.onTimePageChanged,
    required this.onTimeCardTap,
  });

  final AppLocalizations l10n;
  final String? status;
  final String dateRange;
  final DateTimeRange? customRange;
  final List<String?> statusOptions;
  final IconData Function(String?) statusIcon;
  final IconData Function(String) rangeIcon;
  final PageController timePageController;
  final int activeTimeIndex;
  final String Function(DateTime) fmtDate;
  final String statusLabel;
  final String dateRangeLabel;
  final bool compact;
  final ValueChanged<String?> onStatusTap;
  final ValueChanged<String> onRangeTap;
  final ValueChanged<int> onTimePageChanged;
  final ValueChanged<int> onTimeCardTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedBg = scheme.primary.withValues(alpha: 0.2);
    final unselectedBg = scheme.surfaceContainerHighest.withValues(alpha: 0.7);
    final selectedFg = scheme.primary;
    final unselectedFg = AppColors.textSecondary;
    final selectedBorder = scheme.primary.withValues(alpha: 0.5);
    final unselectedBorder = scheme.outlineVariant.withValues(alpha: 0.8);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.tune_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${l10n.driverTripHistoryActiveFilters}: $statusLabel • $dateRangeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: compact ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final range in const <String>['today', '7d', '30d', 'custom']) ...[
                      ChoiceChip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: unselectedBg,
                        selectedColor: selectedBg,
                        side: BorderSide(
                          color: dateRange == range ? selectedBorder : unselectedBorder,
                        ),
                        iconTheme: IconThemeData(
                          color: dateRange == range ? selectedFg : unselectedFg,
                        ),
                        avatar: Icon(rangeIcon(range), size: 15),
                        label: Text(
                          _rangeText(l10n, range),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: dateRange == range ? selectedFg : AppColors.textPrimary,
                          ),
                        ),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        selected: dateRange == range,
                        onSelected: (_) => onRangeTap(range),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: statusOptions
                      .map((it) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: unselectedBg,
                              selectedColor: selectedBg,
                              side: BorderSide(
                                color: status == it ? selectedBorder : unselectedBorder,
                              ),
                              iconTheme: IconThemeData(
                                color: status == it ? selectedFg : unselectedFg,
                              ),
                              avatar: Icon(statusIcon(it), size: 15),
                              label: Text(
                                _statusText(l10n, it),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: status == it
                                      ? selectedFg
                                      : AppColors.textPrimary,
                                ),
                              ),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              selected: status == it,
                              onSelected: (_) => onStatusTap(it),
                            ),
                          ))
                      .toList(growable: false),
                ),
              ),
              if (dateRange == 'custom' && customRange != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${l10n.driverTripHistoryCustomRangeLabel}: ${fmtDate(customRange!.start)} - ${fmtDate(customRange!.end)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _statusText(AppLocalizations l10n, String? status) {
    switch (status) {
      case null:
        return l10n.driverTripHistoryFilterAll;
      case 'completed':
        return l10n.driverTripHistoryFilterCompleted;
      case 'cancelled':
        return l10n.driverTripHistoryFilterCancelled;
      default:
        return l10n.driverTripHistoryFilterInProgress;
    }
  }

  String _rangeText(AppLocalizations l10n, String range) {
    switch (range) {
      case 'today':
        return l10n.driverTripHistoryDateToday;
      case '7d':
        return l10n.driverTripHistoryDate7d;
      case '30d':
        return l10n.driverTripHistoryDate30d;
      case 'custom':
        return l10n.driverTripHistoryDateCustom;
      default:
        return l10n.driverTripHistoryDateAll;
    }
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyHeaderDelegate({required this.minHeight, required this.maxHeight, required this.builder});

  final double minHeight;
  final double maxHeight;
  final Widget Function(BuildContext, double, bool) builder;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => builder(context, shrinkOffset, overlapsContent);
  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight || maxHeight != oldDelegate.maxHeight;
  }
}

class _LoadingSkeletonList extends StatelessWidget {
  const _LoadingSkeletonList({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        4,
        (_) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 220),
                SizedBox(height: 8),
                _SkeletonLine(width: 140),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatefulWidget {
  const _SkeletonLine({required this.width});
  final double width;
  @override
  State<_SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<_SkeletonLine> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final base = Theme.of(context).colorScheme.surfaceContainerHighest;
        return Container(
          width: widget.width,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment(-1 + (_controller.value * 2), 0),
              end: Alignment(1 + (_controller.value * 2), 0),
              colors: [base, base.withValues(alpha: 0.45), base],
            ),
          ),
        );
      },
    );
  }
}

class _DriverTripTile extends StatefulWidget {
  const _DriverTripTile({required this.trip, required this.l10n});

  final DriverTripHistoryItem trip;
  final AppLocalizations l10n;

  @override
  State<_DriverTripTile> createState() => _DriverTripTileState();
}

class _DriverTripTileState extends State<_DriverTripTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final l10n = widget.l10n;
    final created = trip.createdAt;
    final when = created == null
        ? l10n.commonLoading
        : '${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}';
    final price = trip.finalPrice ?? trip.estimatedPrice;
    final amount = price != null
        ? formatMoney(price, currencyCode: trip.currencyCode)
        : l10n.driverTripHistoryPricePending;
    final statusText = _statusText(l10n, trip.status);
    final statusColor = _statusColor(trip.status);
    return Card(
      child: ExpansionTile(
        onExpansionChanged: (value) {
          setState(() {
            _expanded = value;
          });
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text('${l10n.driverTripInProgressTitle} • $statusText'),
        subtitle: Row(
          children: [
            Expanded(
              child: Text('$when • ${trip.id.substring(0, trip.id.length > 8 ? 8 : trip.id.length)}'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        trailing: Text(
          amount,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
        ),
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.diagonal3Values(1, _expanded ? 1 : 0.98, 1),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('ID: ${trip.id}\n${l10n.driverTripHistoryStatusLabel}: $statusText'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(AppLocalizations l10n, String status) {
    switch (status) {
      case 'completed':
        return l10n.driverTripHistoryStatusCompleted;
      case 'cancelled':
        return l10n.driverTripHistoryStatusCancelled;
      case 'started':
      case 'accepted':
      case 'arrived':
      case 'in_trip':
        return l10n.driverTripHistoryStatusInProgress;
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      case 'started':
      case 'accepted':
      case 'arrived':
      case 'in_trip':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ],
      ),
    );
  }
}

class DriverTripHistoryResponse {
  const DriverTripHistoryResponse({required this.trips, required this.total});

  final List<DriverTripHistoryItem> trips;
  final int total;

  factory DriverTripHistoryResponse.fromJson(Map<String, dynamic> json) {
    final tripsRaw = json['trips'] as List<dynamic>? ?? const [];
    final totalRaw = json['total'];
    return DriverTripHistoryResponse(
      trips: tripsRaw
          .whereType<Map>()
          .map(
            (e) => DriverTripHistoryItem.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(growable: false),
      total: totalRaw is num
          ? totalRaw.toInt()
          : int.tryParse('$totalRaw') ?? 0,
    );
  }
}

class DriverTripHistoryItem {
  const DriverTripHistoryItem({
    required this.id,
    required this.status,
    this.estimatedPrice,
    this.finalPrice,
    this.createdAt,
    this.currencyCode,
  });

  final String id;
  final String status;
  final double? estimatedPrice;
  final double? finalPrice;
  final DateTime? createdAt;
  final String? currencyCode;

  factory DriverTripHistoryItem.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return DriverTripHistoryItem(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      estimatedPrice: parseNum(json['estimatedPrice']),
      finalPrice: parseNum(json['finalPrice']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse('${json['createdAt']}')
          : null,
      currencyCode: (json['currencyCode'] ?? json['currency'])?.toString(),
    );
  }
}
