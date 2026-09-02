import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/ui/driver_secondary_scaffold.dart';
import '../../core/utils/service_type_display.dart';
import '../../core/utils/vehicle_type_display.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_registration_controller.dart';
import 'driver_registration_models.dart';
import 'driver_registration_repository.dart';

/// Lista resumida de vehículos del conductor (sin imágenes); desde aquí se abre el alta v2.
class DriverMyVehiclesScreen extends ConsumerStatefulWidget {
  const DriverMyVehiclesScreen({super.key});

  @override
  ConsumerState<DriverMyVehiclesScreen> createState() => _DriverMyVehiclesScreenState();
}

class _DriverMyVehiclesScreenState extends ConsumerState<DriverMyVehiclesScreen> {
  List<DriverVehicleSummary>? _items;
  String? _error;
  bool _loading = true;

  bool get _hasRegisteredVehicle => (_items?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(driverRegistrationRepositoryProvider);
      final list = await repo.fetchMyVehicleSummaries();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } on DriverRegistrationException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _items = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _items = null;
        _loading = false;
      });
    }
  }

  Future<void> _showAddVehicleLockedDialog(AppLocalizations l10n) async {
    HapticFeedback.selectionClick();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.lock_outline_rounded,
          color: AppColors.primary.withValues(alpha: 0.95),
          size: 28,
        ),
        title: Text(l10n.driverMyVehiclesAddLockedTitle),
        content: Text(l10n.driverMyVehiclesAddLockedBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.driverMyVehiclesAddLockedCta),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddVehiclePressed() async {
    final l10n = AppLocalizations.of(context);
    if (_hasRegisteredVehicle) {
      await _showAddVehicleLockedDialog(l10n);
      return;
    }
    await context.pushNamed(
      AppRouter.register,
      extra: <String, dynamic>{'addVehicleOnly': true},
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final addLocked = _hasRegisteredVehicle;
    return DriverSecondaryScaffold(
      title: l10n.driverMyVehiclesTitle,
      actions: [
        IconButton(
          tooltip: l10n.driverMyVehiclesRefreshTooltip,
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _onAddVehiclePressed,
        backgroundColor: addLocked
            ? AppColors.primary.withValues(alpha: 0.42)
            : null,
        foregroundColor: addLocked
            ? AppColors.onPrimary.withValues(alpha: 0.9)
            : null,
        icon: Icon(addLocked ? Icons.lock_outline_rounded : Icons.add_rounded),
        label: Text(l10n.driverMyVehiclesAddFab),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading && _items == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.35,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppFoundation.spacingLg),
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.textSecondary),
          SizedBox(height: AppFoundation.spacingMd),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: AppFoundation.spacingLg),
          FilledButton(
            onPressed: _load,
            child: Text(l10n.driverMyVehiclesRetry),
          ),
        ],
      );
    }
    final items = _items ?? const <DriverVehicleSummary>[];
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppFoundation.spacingLg),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
          Icon(Icons.directions_car_outlined, size: 56, color: AppColors.textSecondary),
          SizedBox(height: AppFoundation.spacingMd),
          Text(
            l10n.driverMyVehiclesEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          SizedBox(height: AppFoundation.spacingLg),
          Center(
            child: FilledButton.icon(
              onPressed: _onAddVehiclePressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.driverMyVehiclesAddFab),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppFoundation.spacingMd,
        AppFoundation.spacingMd,
        AppFoundation.spacingMd,
        88,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: AppFoundation.spacingSm),
      itemBuilder: (context, i) {
        final v = items[i];
        return _VehicleSummaryCard(
          summary: v,
          onFlowClosed: _load,
        );
      },
    );
  }
}

class _VehicleSummaryCard extends StatelessWidget {
  const _VehicleSummaryCard({
    required this.summary,
    required this.onFlowClosed,
  });

  final DriverVehicleSummary summary;
  final Future<void> Function() onFlowClosed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final plate = (summary.licensePlate != null && summary.licensePlate!.trim().isNotEmpty)
        ? summary.licensePlate!.trim()
        : '—';
    final brandModel = [summary.brand.trim(), summary.model.trim()]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final yearBit = summary.year != null ? ' · ${summary.year}' : '';
    final typeBits = <String?>[
      displayVehicleTypeLabel(
        fallbackLabel: summary.vehicleTypeLabel,
        l10n: l10n,
      ),
      summary.vehicleCategoryLabel,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' · ');
    final services = displayEnabledServiceLabels(
      summary.enabledServiceLabels,
      l10n,
    );
    final status = summary.status.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppFoundation.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (status.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (brandModel.isNotEmpty || yearBit.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: AppFoundation.spacingXs),
                child: Text(
                  '$brandModel$yearBit',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            if (typeBits.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: AppFoundation.spacingXs),
                child: Text(
                  typeBits,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            if (services.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: AppFoundation.spacingXs),
                child: Text(
                  services,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            if (summary.needsGalleryCompletion) ...[
              SizedBox(height: AppFoundation.spacingSm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.driverMyVehiclesPhotosPendingBadge(
                    summary.galleryUploadedCount,
                    summary.galleryRequiredCount,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: AppFoundation.spacingSm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () async {
                    await context.pushNamed(
                      AppRouter.register,
                      extra: <String, dynamic>{
                        'completeVehicleGalleryForAssetId': summary.vehicleAssetId,
                      },
                    );
                    await onFlowClosed();
                  },
                  child: Text(l10n.driverMyVehiclesCompletePhotosCta),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
