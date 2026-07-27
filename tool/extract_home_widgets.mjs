import fs from 'fs';
import path from 'path';

const home = path.resolve('lib/features/login/driver_home_screen.dart');
const widgetsDir = path.resolve('lib/features/home/widgets');
fs.mkdirSync(widgetsDir, { recursive: true });
const lines = fs.readFileSync(home, 'utf8').split(/\n/);

const slices = [
  {
    file: 'driver_home_mini_profile_avatar.dart',
    start: 44,
    end: 103,
    header: `import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/texi_circular_avatar.dart';
import '../../login/driver_realtime_state.dart';

`,
    transform: (s) =>
      s.replace(
        'Widget _buildMiniProfileAvatar',
        'Widget buildDriverHomeMiniProfileAvatar',
      ),
  },
  {
    file: 'driver_connection_phase_chip.dart',
    start: 2005,
    end: 2044,
    header: `import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

`,
    transform: (s) =>
      s.replace(
        'Widget _connectionPhaseChip',
        'Widget driverConnectionPhaseChip',
      ),
  },
  {
    file: 'driver_trip_rating_sheet.dart',
    start: 2045,
    end: 2513,
    header: `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/theme/app_motion.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_state.dart';

`,
    transform: (s) =>
      s
        .replaceAll('_RatingSheetContentState', 'DriverTripRatingSheetState')
        .replaceAll('_RatingSheetContent', 'DriverTripRatingSheet'),
  },
  {
    file: 'driver_active_trip_sheet.dart',
    start: 2514,
    end: 3507,
    header: `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_state.dart';

`,
    transform: (s) =>
      s
        .replaceAll('_AssistedTripNavButtonsState', 'DriverAssistedTripNavButtonsState')
        .replaceAll('_AssistedTripNavButtons', 'DriverAssistedTripNavButtons')
        .replaceAll('_RetractableTripCard', 'DriverRetractableTripCard')
        .replaceAll('_ActiveTripCard', 'DriverActiveTripCard'),
  },
  {
    file: 'driver_offer_card.dart',
    start: 3508,
    end: lines.length,
    header: `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_offer.dart';

`,
    transform: (s) =>
      s
        .replaceAll('_CompactAddressLine', 'DriverOfferCompactAddressLine')
        .replaceAll('_OriginRow', 'DriverOfferOriginRow')
        .replaceAll('_OfferMetricChip', 'DriverOfferMetricChip')
        .replaceAll('_TripOfferCard', 'DriverTripOfferCard'),
  },
];

for (const sl of slices) {
  let body = lines.slice(sl.start, sl.end).join('\n');
  if (sl.transform) body = sl.transform(body);
  fs.writeFileSync(path.join(widgetsDir, sl.file), `${sl.header}${body}\n`, 'utf8');
  console.log('wrote', sl.file, 'lines', sl.end - sl.start);
}

const newHome = `${lines.slice(0, 2004).join('\n')}\n`;
fs.writeFileSync(home, newHome, 'utf8');
console.log('home screen now', 2004, 'lines');
