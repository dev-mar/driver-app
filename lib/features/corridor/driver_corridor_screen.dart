import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_corridor_repository.dart';

class DriverCorridorScreen extends StatefulWidget {
  const DriverCorridorScreen({super.key});

  @override
  State<DriverCorridorScreen> createState() => _DriverCorridorScreenState();
}

class _DriverCorridorScreenState extends State<DriverCorridorScreen> {
  final _repo = DriverCorridorRepository();
  final _code = TextEditingController();
  bool _loading = true;
  bool _busy = false;
  bool _active = false;
  String? _notice;
  List<DriverCorridorTrip> _trips = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _notice = null;
    });
    try {
      final active = await _repo.dutyActive();
      final trips = active ? await _repo.trips() : const <DriverCorridorTrip>[];
      if (!mounted) return;
      setState(() {
        _active = active;
        _trips = trips;
        _loading = false;
        _busy = false;
      });
    } on DriverCorridorException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _busy = false;
        _notice = error.message;
      });
    }
  }

  Future<void> _enter() async {
    final l10n = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text(l10n.driverTexiRutaConfirmTitle),
        content: Text(l10n.driverTexiRutaConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.driverTexiRutaConfirmAction)),
        ],
      ),
    );
    if (yes != true) return;
    await _run(() => _repo.enter());
  }

  Future<void> _leave() async {
    final l10n = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text(l10n.driverTexiRutaLeave),
        content: Text(l10n.driverTexiRutaLeaveBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.driverTexiRutaLeave)),
        ],
      ),
    );
    if (yes != true) return;
    await _run(() => _repo.leave());
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      await _load();
    } on DriverCorridorException catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _notice = error.message.isEmpty ? l10n.driverTexiRutaNetwork : error.message;
        _busy = false;
        _loading = false;
      });
    }
  }

  String _status(AppLocalizations l10n, String status) {
    switch (status) {
      case 'scheduled':
        return l10n.driverTexiRutaStatusScheduled;
      case 'available':
        return l10n.driverTexiRutaStatusAvailable;
      case 'boarding':
        return l10n.driverTexiRutaStatusBoarding;
      case 'in_progress':
        return l10n.driverTexiRutaStatusProgress;
      case 'delayed':
        return l10n.driverTexiRutaStatusDelayed;
      case 'confirmed':
        return l10n.driverTexiRutaBookingConfirmed;
      case 'boarded':
        return l10n.driverTexiRutaBookingBoarded;
      case 'no_show':
        return l10n.driverTexiRutaBookingNoShow;
      default:
        return status;
    }
  }

  String _when(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(l10n.driverTexiRutaTitle),
        actions: [
          if (_active)
            TextButton(
              onPressed: _busy ? null : _leave,
              child: Text(l10n.driverTexiRutaLeave),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(l10n.driverTexiRutaIntro, style: const TextStyle(color: AppColors.textSecondary)),
                if (_notice != null) ...[
                  const SizedBox(height: 12),
                  Text(_notice!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: AppFoundation.spacingLg),
                if (!_active)
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      onPressed: _busy ? null : _enter,
                      child: Text(l10n.driverTexiRutaSwitch),
                    ),
                  )
                else if (_trips.isEmpty)
                  Text(l10n.driverTexiRutaNoTrips, style: const TextStyle(color: AppColors.textPrimary))
                else
                  ..._trips.map((trip) => _tripCard(l10n, trip)),
              ],
            ),
    );
  }

  Widget _tripCard(AppLocalizations l10n, DriverCorridorTrip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(trip.routeName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${_when(trip.departureAt)} · ${_status(l10n, trip.status)}', style: const TextStyle(color: AppColors.primary)),
          if (trip.stops.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(trip.stops.join(' → '), style: const TextStyle(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 12),
          Text(l10n.driverTexiRutaBookings, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          if (trip.bookings.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l10n.driverTexiRutaNoBookings, style: const TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...trip.bookings.map((item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${item.givenName.isEmpty ? l10n.driverTexiRutaPassenger : item.givenName} · ${l10n.driverTexiRutaSeats(item.seatCount)} · ${item.publicCode} · ${_status(l10n, item.status)}',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                )),
          if (trip.status == 'scheduled' || trip.status == 'available') ...[
            const SizedBox(height: 12),
            _action(l10n.driverTexiRutaOpen, () => _run(() => _repo.openBoarding(trip.tripId))),
          ],
          if (trip.status == 'boarding') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.driverTexiRutaCode,
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.inputFill,
              ),
            ),
            const SizedBox(height: 8),
            _action(l10n.driverTexiRutaConfirmBoard, () {
              final code = _code.text.trim();
              return _run(() => _repo.confirmBoarding(trip.tripId, code));
            }),
            const SizedBox(height: 8),
            _action(l10n.driverTexiRutaClose, () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surfaceCard,
                  title: Text(l10n.driverTexiRutaClose),
                  content: Text(l10n.driverTexiRutaCloseBody),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.driverTexiRutaClose)),
                  ],
                ),
              );
              if (yes == true) await _run(() => _repo.closeBoarding(trip.tripId));
            }),
          ],
        ],
      ),
    );
  }

  Widget _action(String label, Future<void> Function() onPressed) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
        onPressed: _busy ? null : () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Text(label),
      ),
    );
  }
}
