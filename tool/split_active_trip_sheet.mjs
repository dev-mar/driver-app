import fs from 'node:fs';

const path =
  'd:/projects-developers/tx/proyectos/wss/texi_driver_app/lib/features/home/widgets/driver_active_trip_sheet.dart';
const lines = fs.readFileSync(path, 'utf8').split(/\r?\n/);
const cardStart = lines.findIndex((l) => l.startsWith('class DriverActiveTripCard'));
const cardLines = lines.slice(cardStart);
let card = cardLines.join('\n');
card = card.replace(
  /String _statusLabel\(AppLocalizations l10n, String status\) \{[\s\S]*?  \}\n\n  Color _statusAccentColor[\s\S]*?  \}\n\n  double _statusProgress[\s\S]*?  \}\n\n  /,
  '',
);
card = card.replace(/_statusLabel\(/g, 'driverActiveTripStatusLabel(');
card = card.replace(/_statusAccentColor\(/g, 'driverActiveTripStatusAccentColor(');
card = card.replace(/_statusProgress\(/g, 'driverActiveTripStatusProgress(');

const header = `import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_state.dart';
import 'driver_active_trip_nav_buttons.dart';
import 'driver_active_trip_status_helpers.dart';

`;

fs.writeFileSync(
  'd:/projects-developers/tx/proyectos/wss/texi_driver_app/lib/features/home/widgets/driver_active_trip_card.dart',
  header + card,
);

let sheet = lines.slice(0, cardStart).join('\n');
sheet = sheet.replace("import 'package:flutter/services.dart';\n\n", '');
sheet = sheet.replace(
  /  String _statusLabel[\s\S]*?  \}\n\n  Color _statusAccentColor[\s\S]*?  \}\n\n/,
  '',
);
sheet = sheet.replace(/_statusLabel\(/g, 'driverActiveTripStatusLabel(');
sheet = sheet.replace(/_statusAccentColor\(/g, 'driverActiveTripStatusAccentColor(');
sheet = sheet.replace(
  /                                value: switch \(trip\.status\) \{[\s\S]*?                                \},/,
  '                                value: driverActiveTripStatusProgress(trip.status),',
);
sheet = sheet.replace(
  "import '../../login/driver_realtime_state.dart';\n",
  "import '../../login/driver_realtime_state.dart';\nimport 'driver_active_trip_card.dart';\nimport 'driver_active_trip_status_helpers.dart';\n",
);

fs.writeFileSync(path, sheet.trimEnd() + '\n');
console.log('split at line', cardStart + 1);
