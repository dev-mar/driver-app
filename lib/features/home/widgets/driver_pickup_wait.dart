import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_state.dart';

enum DriverPickupWaitPhase { waiting, grace, eligible }

class DriverPickupWaitSpec {
  const DriverPickupWaitSpec({
    required this.arrivedAt,
    required this.waitSec,
    required this.waitGraceSec,
  });

  final DateTime arrivedAt;
  final int waitSec;
  final int waitGraceSec;

  static DriverPickupWaitSpec? tryParse(Map<dynamic, dynamic>? json) {
    if (json == null) return null;
    final arrived = DateTime.tryParse(
      '${json['arrivedAt'] ?? json['arrived_at'] ?? ''}',
    );
    if (arrived == null) return null;
    final waitMap = json['pickupWait'] ?? json['pickup_wait'];
    Map<String, dynamic>? wait;
    if (waitMap is Map) {
      wait = Map<String, dynamic>.from(waitMap);
    }
    int parseInt(dynamic v, int fallback) {
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? fallback;
    }

    final waitSec = parseInt(
      json['waitSec'] ?? json['wait_sec'] ?? wait?['waitSec'] ?? wait?['wait_sec'],
      300,
    );
    final graceSec = parseInt(
      json['waitGraceSec'] ??
          json['wait_grace_sec'] ??
          wait?['waitGraceSec'] ??
          wait?['wait_grace_sec'],
      120,
    );
    return DriverPickupWaitSpec(
      arrivedAt: arrived.toUtc(),
      waitSec: waitSec.clamp(60, 3600),
      waitGraceSec: graceSec.clamp(0, 1800),
    );
  }
}

class DriverPickupWaitView {
  const DriverPickupWaitView({
    required this.phase,
    required this.remainingSec,
  });

  final DriverPickupWaitPhase phase;
  final int remainingSec;
}

DriverPickupWaitView computeDriverPickupWait(
  DriverPickupWaitSpec spec, {
  DateTime? now,
}) {
  final nowUtc = (now ?? DateTime.now()).toUtc();
  final elapsed = nowUtc.difference(spec.arrivedAt).inSeconds;
  final waitEnd = spec.waitSec;
  final graceEnd = spec.waitSec + spec.waitGraceSec;
  if (elapsed < waitEnd) {
    return DriverPickupWaitView(
      phase: DriverPickupWaitPhase.waiting,
      remainingSec: (waitEnd - elapsed).clamp(0, 24 * 3600),
    );
  }
  if (elapsed < graceEnd) {
    return DriverPickupWaitView(
      phase: DriverPickupWaitPhase.grace,
      remainingSec: (graceEnd - elapsed).clamp(0, 24 * 3600),
    );
  }
  return const DriverPickupWaitView(
    phase: DriverPickupWaitPhase.eligible,
    remainingSec: 0,
  );
}

String formatDriverPickupWaitClock(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final m = s ~/ 60;
  final r = s % 60;
  return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
}

String driverPickupWaitLabel(AppLocalizations l10n, DriverPickupWaitView view) {
  switch (view.phase) {
    case DriverPickupWaitPhase.waiting:
      return l10n.driverPickupWaitWaiting(
        formatDriverPickupWaitClock(view.remainingSec),
      );
    case DriverPickupWaitPhase.grace:
      return l10n.driverPickupWaitGrace(
        formatDriverPickupWaitClock(view.remainingSec),
      );
    case DriverPickupWaitPhase.eligible:
      return l10n.driverPickupWaitEnded;
  }
}

int? _driverWaitInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  return int.tryParse('$raw');
}

DriverPickupWaitSpec? pickupWaitSpecOf(DriverActiveTrip trip) {
  if (trip.status != 'arrived' || trip.arrivedAt == null) return null;
  return DriverPickupWaitSpec(
    arrivedAt: trip.arrivedAt!.toUtc(),
    waitSec: (trip.waitSec ?? 300).clamp(60, 3600),
    waitGraceSec: (trip.waitGraceSec ?? 120).clamp(0, 1800),
  );
}

DriverActiveTrip applyPickupWaitFromPayload(
  DriverActiveTrip trip,
  Map<dynamic, dynamic> data,
) {
  final spec = DriverPickupWaitSpec.tryParse(data);
  final waitMap = data['pickupWait'] ?? data['pickup_wait'];
  Map<dynamic, dynamic>? wait;
  if (waitMap is Map) wait = waitMap;
  final waitSec = _driverWaitInt(
        data['waitSec'] ??
            data['wait_sec'] ??
            wait?['waitSec'] ??
            wait?['wait_sec'],
      ) ??
      spec?.waitSec;
  final waitGraceSec = _driverWaitInt(
        data['waitGraceSec'] ??
            data['wait_grace_sec'] ??
            wait?['waitGraceSec'] ??
            wait?['wait_grace_sec'],
      ) ??
      spec?.waitGraceSec;
  final sentAt = DateTime.tryParse(
    '${data['passengerEnRouteAt'] ?? data['sentAt'] ?? ''}',
  );
  return trip.copyWith(
    arrivedAt: spec?.arrivedAt ?? trip.arrivedAt,
    waitSec: waitSec ?? trip.waitSec,
    waitGraceSec: waitGraceSec ?? trip.waitGraceSec,
    passengerEnRouteAt: sentAt ?? trip.passengerEnRouteAt,
  );
}

class DriverPickupWaitClock extends StatefulWidget {
  const DriverPickupWaitClock({super.key, required this.spec});

  final DriverPickupWaitSpec spec;

  @override
  State<DriverPickupWaitClock> createState() => _DriverPickupWaitClockState();
}

class _DriverPickupWaitClockState extends State<DriverPickupWaitClock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = computeDriverPickupWait(widget.spec);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_bottom_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              driverPickupWaitLabel(l10n, view),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
