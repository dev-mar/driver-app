#!/usr/bin/env node
/**
 * Extrae métodos _build*Step del flow screen a widgets en widgets/steps/.
 * Ejecutar desde texi_driver_app: node tool/extract_registration_steps.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const screenPath = path.join(
  root,
  'lib/features/registration/driver_registration_flow_screen.dart',
);
const stepsDir = path.join(root, 'lib/features/registration/widgets/steps');

const steps = [
  {
    file: 'registration_step_personal.dart',
    className: 'RegistrationStepPersonal',
    method: '_buildPersonalStep',
    extraParams: 'DriverRegistrationFlowState flow, DriverRegistrationFlowController notifier',
    watchFlow: true,
  },
  {
    file: 'registration_step_identity.dart',
    className: 'RegistrationStepIdentity',
    method: '_buildIdentityStep',
    extraParams: '',
    watchFlow: false,
  },
  {
    file: 'registration_step_license.dart',
    className: 'RegistrationStepLicense',
    method: '_buildLicenseStep',
    extraParams: '',
    watchFlow: true,
  },
  {
    file: 'registration_step_access.dart',
    className: 'RegistrationStepAccess',
    method: '_buildAccessBridgeStep',
    extraParams: 'DriverRegistrationFlowState flow',
    watchFlow: false,
  },
  {
    file: 'registration_step_vehicle.dart',
    className: 'RegistrationStepVehicle',
    method: '_buildVehicleStep',
    extraParams:
      'DriverRegistrationFlowState flow, DriverRegistrationFlowController notifier',
    watchFlow: true,
    needsInternalTools: true,
  },
  {
    file: 'registration_step_vehicle_photos.dart',
    className: 'RegistrationStepVehiclePhotos',
    method: '_buildVehiclePhotosStep',
    extraParams: '',
    watchFlow: false,
  },
];

const screen = fs.readFileSync(screenPath, 'utf8');

function extractMethod(name) {
  const start = screen.indexOf(`Widget ${name}(`);
  if (start < 0) throw new Error(`Method ${name} not found`);
  let i = screen.indexOf('{', start);
  let depth = 0;
  const bodyStart = i + 1;
  for (; i < screen.length; i++) {
    const ch = screen[i];
    if (ch === '{') depth++;
    else if (ch === '}') {
      depth--;
      if (depth === 0) return screen.slice(bodyStart, i).trim();
    }
  }
  throw new Error(`Unbalanced braces for ${name}`);
}

function transformBody(body, step) {
  let b = body;
  // Remove local l10n/flow/notifier declarations when widget will provide them
  b = b.replace(/^\s*final l10n = AppLocalizations\.of\(context\);\s*/m, '');
  if (step.watchFlow) {
    b = b.replace(
      /^\s*final flow = ref\.watch\(driverRegistrationFlowControllerProvider\);\s*/m,
      '',
    );
  }
  b = b.replace(/^\s*final notifier = ref\.read\(driverRegistrationFlowControllerProvider\.notifier\);\s*/m, '');

  const replacements = [
    [/\b_formPersonal\b/g, 'bindings.formPersonal'],
    [/\b_formId\b/g, 'bindings.formId'],
    [/\b_formLicense\b/g, 'bindings.formLicense'],
    [/\b_formVehicle\b/g, 'bindings.formVehicle'],
    [/\b_firstNameCtrl\b/g, 'bindings.firstNameCtrl'],
    [/\b_lastNameCtrl\b/g, 'bindings.lastNameCtrl'],
    [/\b_emailCtrl\b/g, 'bindings.emailCtrl'],
    [/\b_phoneLocalCtrl\b/g, 'bindings.phoneLocalCtrl'],
    [/\b_birthDateCtrl\b/g, 'bindings.birthDateCtrl'],
    [/\b_addressCtrl\b/g, 'bindings.addressCtrl'],
    [/\b_passwordCtrl\b/g, 'bindings.passwordCtrl'],
    [/\b_passwordConfirmCtrl\b/g, 'bindings.passwordConfirmCtrl'],
    [/\b_docNumberCtrl\b/g, 'bindings.docNumberCtrl'],
    [/\b_docExpireCtrl\b/g, 'bindings.docExpireCtrl'],
    [/\b_licenseExpireCtrl\b/g, 'bindings.licenseExpireCtrl'],
    [/\b_vehicleBrandCtrl\b/g, 'bindings.vehicleBrandCtrl'],
    [/\b_vehicleModelCtrl\b/g, 'bindings.vehicleModelCtrl'],
    [/\b_vehicleYearCtrl\b/g, 'bindings.vehicleYearCtrl'],
    [/\b_vehicleColorCtrl\b/g, 'bindings.vehicleColorCtrl'],
    [/\b_vehicleVinCtrl\b/g, 'bindings.vehicleVinCtrl'],
    [/\b_vehiclePlateCtrl\b/g, 'bindings.vehiclePlateCtrl'],
    [/\b_vehicleInsuranceCtrl\b/g, 'bindings.vehicleInsuranceCtrl'],
    [/\b_vehicleTitleCtrl\b/g, 'bindings.vehicleTitleCtrl'],
    [/\b_genderValue\b/g, 'bindings.genderValue'],
    [/\b_licenseCategory\b/g, 'bindings.licenseCategory'],
    [/\b_idFrontB64\b/g, 'bindings.idFrontB64'],
    [/\b_idBackB64\b/g, 'bindings.idBackB64'],
    [/\b_faceB64\b/g, 'bindings.faceB64'],
    [/\b_licFrontB64\b/g, 'bindings.licFrontB64'],
    [/\b_licBackB64\b/g, 'bindings.licBackB64'],
    [/\b_carFrontB64\b/g, 'bindings.carFrontB64'],
    [/\b_carBackB64\b/g, 'bindings.carBackB64'],
    [/\b_carLeftB64\b/g, 'bindings.carLeftB64'],
    [/\b_carRightB64\b/g, 'bindings.carRightB64'],
    [/\b_showStepValidationErrors\b/g, 'showValidationErrors'],
    [/\b_registrationInputTheme\b/g, 'registrationInputTheme'],
    [/\b_genderChoices\b/g, 'registrationGenderChoices'],
    [/\b_carColorSuggestions\b/g, 'registrationCarColorSuggestions'],
    [/\b_localizedColor\b/g, 'localizedRegistrationColor'],
    [/\b_colorFromName\b/g, 'registrationColorFromName'],
    [/\b_composeFullPhone\b/g, 'composeRegistrationFullPhone(bindings, flow)'],
    [/\b_formatServiceLocation\b/g, 'formatRegistrationServiceLocation'],
    [/\b_useIntegratedCatalogVehicleFields\b/g, 'useIntegratedCatalogVehicleFields'],
    [/\b_UpperCasePlateFormatter\b/g, 'RegistrationUpperCasePlateFormatter'],
    [/\b_pickDateToField\b/g, 'actions.pickDateToField'],
    [/\b_applyPickedImage\b/g, 'actions.applyPickedImage'],
    [/\b_persistDraft\b/g, 'actions.persistDraft'],
    [/\b_vehicleCatalogAfterBrandModelFields\b/g, '_vehicleCatalogAfterBrandModelFields'],
  ];

  for (const [re, to] of replacements) {
    b = b.replace(re, to);
  }

  // setState patterns
  b = b.replace(
    /setState\(\(\) => bindings\.genderValue = v\);/g,
    'bindings.genderValue = v;\n                    actions.onFormChanged();',
  );
  b = b.replace(
    /setState\(\(\) => bindings\.licenseCategory = v\);/g,
    'bindings.licenseCategory = v;\n                    actions.onFormChanged();',
  );
  b = b.replace(/setState\(\(\) \{\}\);/g, 'actions.onFormChanged();');
  b = b.replace(/setState\(\(\) => \{\}\);/g, 'actions.onFormChanged();');
  b = b.replace(
    /setState\(\(\) \{\s*bindings\.vehicleBrandCtrl\.text = manufacturerName;\s*bindings\.vehicleModelCtrl\.text = entry\.name;\s*final y = entry\.modelYearEnd \?\? entry\.modelYearStart;\s*if \(y != null\) bindings\.vehicleYearCtrl\.text = '\$y';\s*\}\);/g,
    `onPickCatalogModel(manufacturerName, entry);`,
  );
  b = b.replace(/unawaited\(actions\.persistDraft\(\)\);/g, 'unawaited(actions.persistDraft());');
  b = b.replace(
    /setState\(\(\) \{\}\);\s*unawaited\(actions\.persistDraft\(\)\);/g,
    'actions.onFormChanged();\n                  unawaited(actions.persistDraft());',
  );
  b = b.replace(
    /notifier\.selectCountry\(v\);\s*setState\(\(\) \{\}\);/g,
    'notifier.selectCountry(v);\n                          actions.onFormChanged();',
  );
  b = b.replace(
    /notifier\.selectDepartment\(v\);\s*setState\(\(\) \{\}\);/g,
    'notifier.selectDepartment(v);\n                          actions.onFormChanged();',
  );
  b = b.replace(
    /notifier\.selectLocality\(loc\);\s*setState\(\(\) \{\}\);/g,
    'notifier.selectLocality(loc);\n                              actions.onFormChanged();',
  );
  b = b.replace(
    /bindings\.genderValue = v;\s*unawaited\(actions\.persistDraft\(\)\);/g,
    'bindings.genderValue = v;\n                    actions.onFormChanged();\n                    unawaited(actions.persistDraft());',
  );

  return b;
}

function buildWidget(step, body) {
  const params = [
    'required this.bindings',
    'required this.actions',
    'required this.showValidationErrors',
  ];
  if (step.extraParams.includes('flow')) params.push('required this.flow');
  if (step.extraParams.includes('notifier')) params.push('required this.notifier');
  if (step.needsInternalTools) params.push('required this.showTechnicalCatalogs');

  const fields = [
    'final RegistrationFlowBindings bindings;',
    'final RegistrationStepActions actions;',
    'final bool showValidationErrors;',
  ];
  if (step.extraParams.includes('flow')) {
    fields.push('final DriverRegistrationFlowState flow;');
  }
  if (step.extraParams.includes('notifier')) {
    fields.push('final DriverRegistrationFlowController notifier;');
  }
  if (step.needsInternalTools) {
    fields.push('final bool showTechnicalCatalogs;');
  }

  const imports = [
    "import 'dart:async';",
    "import 'package:flutter/material.dart';",
    "import 'package:flutter/services.dart';",
    "import 'package:flutter_riverpod/flutter_riverpod.dart';",
    '',
    "import '../../../../core/theme/app_colors.dart';",
    "import '../../../../core/theme/app_foundation.dart';",
    "import '../../../../core/ui/horizontal_edge_fade.dart';",
    "import '../../../../gen_l10n/app_localizations.dart';",
    "import '../../driver_registration_controller.dart';",
    "import '../../driver_registration_models.dart';",
    "import '../../registration_flow_bindings.dart';",
    "import '../../registration_flow_helpers.dart';",
    "import '../../registration_image_helper.dart';",
    "import '../../registration_step_actions.dart';",
    "import '../driver_vehicle_catalog_section.dart';",
    "import '../registration_flow_chrome.dart';",
    "import '../registration_section_card.dart';",
    "import '../registration_soft_info_row.dart';",
  ];

  let extraMethods = '';
  if (step.className === 'RegistrationStepVehicle') {
    extraMethods = `
  List<Widget> _vehicleCatalogAfterBrandModelFields(
    AppLocalizations l10n,
    DriverRegistrationFlowState flow,
  ) {
    return [
      const SizedBox(height: 14),
      TextFormField(
        controller: bindings.vehicleYearCtrl,
        decoration: InputDecoration(labelText: l10n.driverRegFieldYear),
        keyboardType: TextInputType.number,
        inputFormatters: vehicleYearInputFormatters,
        validator: (v) => validateVehicleModelYear(v, l10n),
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: bindings.vehicleColorCtrl,
        decoration: InputDecoration(
          labelText: l10n.driverRegFieldColor,
          hintText: l10n.driverRegHintTypeOrPickColor,
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
      ),
      const SizedBox(height: AppFoundation.spacingSm),
      SizedBox(
        height: 38,
        child: HorizontalEdgeFade(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: registrationCarColorSuggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppFoundation.spacingSm),
            itemBuilder: (context, index) {
              final c = registrationCarColorSuggestions[index];
              return RegistrationColorChoicePill(
                label: localizedRegistrationColor(context, c),
                color: registrationColorFromName(c),
                selected: bindings.vehicleColorCtrl.text.trim() == c,
                onTap: () {
                  HapticFeedback.selectionClick();
                  bindings.vehicleColorCtrl.text = c;
                  actions.onFormChanged();
                  unawaited(actions.persistDraft());
                },
              );
            },
          ),
        ),
      ),
    ];
  }

  void onPickCatalogModel(String manufacturerName, dynamic entry) {
    bindings.vehicleBrandCtrl.text = manufacturerName;
    bindings.vehicleModelCtrl.text = entry.name as String;
    final y = entry.modelYearEnd ?? entry.modelYearStart;
    if (y != null) bindings.vehicleYearCtrl.text = '\$y';
    actions.onFormChanged();
  }
`;
  }

  const watchBlock = step.watchFlow
    ? ''
    : '';

  return `// GENERATED — editar con cuidado; regenerar: node tool/extract_registration_steps.mjs
${imports.join('\n')}

class ${step.className} extends ConsumerWidget {
  const ${step.className}({
    super.key,
    ${params.join(',\n    ')},
  });

  ${fields.join('\n  ')}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
${watchBlock}
    ${body.split('\n').map((l) => (l ? '    ' + l : '')).join('\n')}
  }
${extraMethods}
}
`;
}

fs.mkdirSync(stepsDir, { recursive: true });

for (const step of steps) {
  const raw = extractMethod(step.method);
  const body = transformBody(raw, step);
  const content = buildWidget(step, body);
  fs.writeFileSync(path.join(stepsDir, step.file), content);
  console.log('Wrote', step.file);
}

console.log('Done.');
