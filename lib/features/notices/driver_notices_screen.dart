import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_notices_repository.dart';

class DriverNoticesScreen extends ConsumerStatefulWidget {
  const DriverNoticesScreen({super.key, this.highlightId});

  final String? highlightId;

  @override
  ConsumerState<DriverNoticesScreen> createState() => _DriverNoticesScreenState();
}

class _DriverNoticesScreenState extends ConsumerState<DriverNoticesScreen> {
  final _repo = DriverNoticesRepository();
  DriverNoticesSnapshot _snap = const DriverNoticesSnapshot();
  bool _loading = true;
  String? _openId;

  @override
  void initState() {
    super.initState();
    _openId = widget.highlightId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reload(markHighlight: true);
    });
  }

  Future<void> _reload({bool markHighlight = false}) async {
    final snap = await _repo.fetchInbox();
    if (!mounted) return;
    setState(() {
      _snap = snap;
      _loading = false;
    });
    ref.invalidate(driverNoticesUnreadProvider);
    final hid = widget.highlightId?.trim();
    if (markHighlight && hid != null && hid.isNotEmpty) {
      await _repo.markRead(hid);
      if (!mounted) return;
      await _reload();
    }
  }

  Future<void> _open(DriverNoticeItem item) async {
    HapticFeedback.lightImpact();
    setState(() => _openId = _openId == item.id ? null : item.id);
    if (item.unread) {
      await _repo.markRead(item.id);
      if (!mounted) return;
      await _reload();
    }
  }

  String _when(DateTime? at) {
    if (at == null) return '';
    final now = DateTime.now();
    final local = at.toLocal();
    final sameDay =
        now.year == local.year && now.month == local.month && now.day == local.day;
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    if (sameDay) return '$hh:$mm';
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.noticesInboxTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRouter.home);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _snap.unreadCount > 0
                ? () async {
                    HapticFeedback.lightImpact();
                    await _repo.markAllRead();
                    if (!mounted) return;
                    await _reload();
                  }
                : null,
            child: Text(l10n.noticesMarkAll),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2.4))
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppFoundation.spacingLg,
                  8,
                  AppFoundation.spacingLg,
                  28,
                ),
                itemCount: _snap.items.isEmpty ? 1 : _snap.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (_snap.items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 42,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noticesEmpty,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final item = _snap.items[index];
                  final open = _openId == item.id;
                  return Material(
                    color: item.unread
                        ? AppColors.surfaceCard
                        : AppColors.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
                      onTap: () => _open(item),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 6, right: 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item.unread
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  border: item.unread
                                      ? null
                                      : Border.all(color: AppColors.border),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: item.unread
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _when(item.sentAt),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.body,
                                      maxLines: open ? 12 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        height: 1.35,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
