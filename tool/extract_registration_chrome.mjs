import fs from 'node:fs';
import path from 'node:path';

const root =
  'd:/projects-developers/tx/proyectos/wss/texi_driver_app/lib/features/registration';
const screenPath = path.join(root, 'driver_registration_flow_screen.dart');
const chromePath = path.join(root, 'widgets/registration_flow_chrome.dart');

const lines = fs.readFileSync(screenPath, 'utf8').split(/\r?\n/);
const chromeStart = lines.findIndex((l) =>
  l.startsWith('class _RegistrationBottomBar'),
);

if (chromeStart < 0) {
  console.error('chrome start not found');
  process.exit(1);
}

const renameMap = [
  ['_RegistrationBottomBar', 'RegistrationBottomBar'],
  ['_StepIntroBanner', 'RegistrationStepIntroBanner'],
  ['_SoftStatusChip', 'RegistrationSoftStatusChip'],
  ['_StepHeroCard', 'RegistrationStepHeroCard'],
  ['_ColorChoicePill', 'RegistrationColorChoicePill'],
  ['_InfoTileRow', 'RegistrationInfoTileRow'],
  ['_CarnetUploadTile', 'RegistrationCarnetUploadTile'],
  ['_CarnetUploadTileState', 'RegistrationCarnetUploadTileState'],
  ['_MiniCarnetIllustration', 'RegistrationMiniCarnetIllustration'],
  ['_ProfilePhotoCircleSlot', 'RegistrationProfilePhotoCircleSlot'],
  ['_ProfilePhotoCircleSlotState', 'RegistrationProfilePhotoCircleSlotState'],
  ['_PhotoSlot', 'RegistrationPhotoSlot'],
  ['_PhotoSlotState', 'RegistrationPhotoSlotState'],
  ['_CarAngleCard', 'RegistrationCarAngleCard'],
  ['_CarAngleCardState', 'RegistrationCarAngleCardState'],
];

let chromeBody = lines.slice(chromeStart).join('\n');
for (const [from, to] of renameMap) {
  chromeBody = chromeBody.replaceAll(new RegExp(from, 'g'), to);
}

const chromeHeader = `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../registration_image_helper.dart';

`;

fs.writeFileSync(chromePath, chromeHeader + chromeBody.trimEnd() + '\n');

let mainBody = lines.slice(0, chromeStart).join('\n');
for (const [from, to] of renameMap) {
  mainBody = mainBody.replaceAll(new RegExp(from, 'g'), to);
}

const importChrome = `import 'widgets/registration_flow_chrome.dart';\n`;
if (!mainBody.includes(importChrome.trim())) {
  mainBody = mainBody.replace(
    "import 'widgets/registration_soft_info_row.dart';\n",
    "import 'widgets/registration_soft_info_row.dart';\n" + importChrome,
  );
}

fs.writeFileSync(screenPath, mainBody.trimEnd() + '\n');
console.log('chrome lines', lines.length - chromeStart, 'main lines', chromeStart);
