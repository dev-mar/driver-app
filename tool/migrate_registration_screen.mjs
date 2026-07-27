#!/usr/bin/env node
/**
 * Migra driver_registration_flow_screen.dart a bindings + step router.
 * Ejecutar: node tool/migrate_registration_screen.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const screenPath = path.join(
  rootDir(__dirname),
  'lib/features/registration/driver_registration_flow_screen.dart',
);

function rootDir(from) {
  return path.join(from, '..');
}

let s = fs.readFileSync(screenPath, 'utf8');

// Remove moved top-level classes
s = s.replace(
  /\/\/\/ Fuerza MAYÚSCULAS[\s\S]*?^}\n\n\/\/\/ Congela `ref`[\s\S]*?^}\n\n/m,
  '',
);

// Add imports after existing registration imports
if (!s.includes('registration_flow_bindings.dart')) {
  s = s.replace(
    "import 'widgets/registration_flow_chrome.dart';\n",
    `import 'registration_flow_bindings.dart';
import 'registration_flow_draft.dart';
import 'registration_flow_helpers.dart';
import 'registration_step_actions.dart';
import 'widgets/registration_flow_chrome.dart';
import 'widgets/registration_flow_step_router.dart';
`,
  );
}

// Replace field block with bindings + UI state
s = s.replace(
  /  final _formPersonal[\s\S]*?  final Map<String, String\?> _draftImagePaths = <String, String\?>{};\n\n/,
  `  late final RegistrationFlowBindings _form = RegistrationFlowBindings();
  bool _suppressDraftSave = false;
  bool _showStepValidationErrors = false;
  int _validationStepScope = 0;

`,
);

// initState: bindings se inicializa en declaración late final

// dispose: reemplazar disposición de controllers
s = s.replace(
  /    _form\.firstNameCtrl\.dispose\(\);[\s\S]*?    _form\.vehicleTitleCtrl\.dispose\(\);\n/,
  '    _form.dispose();\n',
);
// Fallback si aún no se migraron nombres de campo
s = s.replace(
  /    _firstNameCtrl\.dispose\(\);[\s\S]*?    _vehicleTitleCtrl\.dispose\(\);\n/,
  '    _form.dispose();\n',
);

const fieldMap = {
  _formPersonal: '_form.formPersonal',
  _formId: '_form.formId',
  _formLicense: '_form.formLicense',
  _formVehicle: '_form.formVehicle',
  _firstNameCtrl: '_form.firstNameCtrl',
  _lastNameCtrl: '_form.lastNameCtrl',
  _emailCtrl: '_form.emailCtrl',
  _phoneLocalCtrl: '_form.phoneLocalCtrl',
  _birthDateCtrl: '_form.birthDateCtrl',
  _addressCtrl: '_form.addressCtrl',
  _passwordCtrl: '_form.passwordCtrl',
  _passwordConfirmCtrl: '_form.passwordConfirmCtrl',
  _docNumberCtrl: '_form.docNumberCtrl',
  _docExpireCtrl: '_form.docExpireCtrl',
  _licenseExpireCtrl: '_form.licenseExpireCtrl',
  _vehicleBrandCtrl: '_form.vehicleBrandCtrl',
  _vehicleModelCtrl: '_form.vehicleModelCtrl',
  _vehicleYearCtrl: '_form.vehicleYearCtrl',
  _vehicleColorCtrl: '_form.vehicleColorCtrl',
  _vehicleVinCtrl: '_form.vehicleVinCtrl',
  _vehiclePlateCtrl: '_form.vehiclePlateCtrl',
  _vehicleInsuranceCtrl: '_form.vehicleInsuranceCtrl',
  _vehicleTitleCtrl: '_form.vehicleTitleCtrl',
  _genderValue: '_form.genderValue',
  _licenseCategory: '_form.licenseCategory',
  _idFrontB64: '_form.idFrontB64',
  _idBackB64: '_form.idBackB64',
  _faceB64: '_form.faceB64',
  _licFrontB64: '_form.licFrontB64',
  _licBackB64: '_form.licBackB64',
  _carFrontB64: '_form.carFrontB64',
  _carBackB64: '_form.carBackB64',
  _carLeftB64: '_form.carLeftB64',
  _carRightB64: '_form.carRightB64',
  _draftImagePaths: '_form.draftImagePaths',
};

for (const [from, to] of Object.entries(fieldMap)) {
  s = s.replaceAll(from, to);
}

// Draft snapshot
s = s.replace(
  /_DraftPersistSnapshot _captureDraftSnapshot\(\) \{[\s\S]*?^\s{2}\}/m,
  `RegistrationDraftPersistSnapshot _captureDraftSnapshot() {
    final flow = ref.read(driverRegistrationFlowControllerProvider);
    return captureRegistrationDraftSnapshot(flow: flow, form: _form);
  }`,
);

s = s.replace(/_DraftPersistSnapshot/g, 'RegistrationDraftPersistSnapshot');

// Helpers
s = s.replace(/\b_localizedFlowError\b/g, 'localizedRegistrationFlowError');
s = s.replace(/\b_composeFullPhone\b/g, 'composeRegistrationFullPhone');
s = s.replace(/\b_formatServiceLocation\b/g, 'formatRegistrationServiceLocation');
s = s.replace(/\b_registrationInputTheme\b/g, 'registrationInputTheme');
s = s.replace(/\b_genderChoices\b/g, 'registrationGenderChoices');
s = s.replace(/\b_carColorSuggestions\b/g, 'registrationCarColorSuggestions');
s = s.replace(/\b_localizedColor\b/g, 'localizedRegistrationColor');
s = s.replace(/\b_colorFromName\b/g, 'registrationColorFromName');
s = s.replace(/\b_useIntegratedCatalogVehicleFields\b/g, 'useIntegratedCatalogVehicleFields');
s = s.replace(/\b_UpperCasePlateFormatter\b/g, 'RegistrationUpperCasePlateFormatter');

// Fix composeFullPhone calls - need (form, flow) args
s = s.replace(
  /composeRegistrationFullPhone\(flow\)/g,
  'composeRegistrationFullPhone(_form, flow)',
);

// _clearVehicleOnlyFields
s = s.replace(
  /void _clearVehicleOnlyFields\(\) \{[\s\S]*?^\s{2}\}/m,
  `void _clearVehicleOnlyFields() {
    _form.clearVehicleOnlyFields();
  }`,
);

// Remove helper methods block (_genderChoices through _registrationInputTheme)
s = s.replace(
  /  List<MapEntry<String, String>> registrationGenderChoices[\s\S]*?^  ThemeData registrationInputTheme\(BuildContext context\) \{[\s\S]*?^  \}\n\n/m,
  '',
);

// Remove _useIntegratedCatalogVehicleFields and _vehicleCatalogAfterBrandModelFields if still present
s = s.replace(
  /  bool useIntegratedCatalogVehicleFields\(DriverRegistrationFlowState flow\) \{[\s\S]*?^  \}\n\n/m,
  '',
);
s = s.replace(
  /  List<Widget> _vehicleCatalogAfterBrandModelFields\([\s\S]*?^  \}\n\n/m,
  '',
);

// Replace _buildStep
s = s.replace(
  /  Widget _buildStep\(DriverRegistrationFlowState flow, DriverRegistrationFlowController notifier\) \{[\s\S]*?^  \}\n\n  String localizedRegistrationFlowError/m,
  `  RegistrationStepActions get _stepActions => RegistrationStepActions(
        onFormChanged: () => setState(() {}),
        persistDraft: _persistDraft,
        pickDateToField: _pickDateToField,
        applyPickedImage: _applyPickedImage,
      );

  Widget _buildStep(
    DriverRegistrationFlowState flow,
    DriverRegistrationFlowController notifier,
  ) {
    final showTechnicalCatalogs =
        ref.watch(driverInternalToolsVisibleProvider).valueOrNull == true;
    return RegistrationFlowStepRouter(
      flow: flow,
      notifier: notifier,
      bindings: _form,
      actions: _stepActions,
      showValidationErrors: _showStepValidationErrors,
      showTechnicalCatalogs: showTechnicalCatalogs,
    );
  }

  String localizedRegistrationFlowError`,
);

// Remove step builder methods and _localizedFlowError duplicate if we keep inline - actually remove localizedRegistrationFlowError method too since it's in helpers
s = s.replace(
  /  String localizedRegistrationFlowError\(String raw, AppLocalizations l10n\) \{[\s\S]*?^  \}\n\n  Widget _buildPersonalStep/m,
  '',
);

// Remove all _build*Step methods until end of class before closing brace
const buildPersonalStart = s.indexOf('  Widget _buildPersonalStep');
const classEnd = s.lastIndexOf('\n}');
if (buildPersonalStart >= 0 && classEnd > buildPersonalStart) {
  s = s.slice(0, buildPersonalStart) + s.slice(classEnd);
}

// Remove unused imports if horizontal_edge_fade only used in removed code - analyze will tell us

fs.writeFileSync(screenPath, s);
console.log('Migrated screen. LOC:', s.split('\n').length);
