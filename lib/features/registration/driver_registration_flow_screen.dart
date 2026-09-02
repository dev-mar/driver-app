import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../gen_l10n/app_localizations.dart';
import 'driver_registration_controller.dart';
import 'registration_flow_bindings.dart';
import 'registration_flow_bootstrap.dart';
import 'registration_flow_draft_service.dart';
import 'registration_flow_form_interactions.dart';
import 'registration_flow_mode.dart';
import 'registration_flow_navigation.dart';
import 'registration_flow_primary_actions.dart';
import 'registration_step_actions.dart';
import 'widgets/registration_flow_scaffold.dart';

/// Flujo completo de registro de conductor (geo + usuario + documentos + vehículo).
class DriverRegistrationFlowScreen extends ConsumerStatefulWidget {
  const DriverRegistrationFlowScreen({
    super.key,
    this.resumeAfterLogin = false,
    this.addVehicleOnly = false,
    this.completeVehicleGalleryForAssetId,
    this.openFromProfileStep,
    this.profilePreselectedCountryId,
    this.profileSectionUiStatus,
  });

  /// Si es true: sesión ya iniciada; se consulta `GET /api/v2/driver/registration` y se salta a la etapa faltante.
  final bool resumeAfterLogin;

  /// Desde home: alta de un vehículo adicional (pasos vehículo + fotos) con sesión activa.
  final bool addVehicleOnly;

  /// `vehicle_asset_id` existente: solo subir las 4 fotos (p. ej. tras error en paso 2 o listado "Mis vehículos").
  final String? completeVehicleGalleryForAssetId;

  /// Desde [DriverProfile] / menú: abre un paso fijo (0=datos … 5=fotos) con sesión ya autenticada.
  final int? openFromProfileStep;

  /// Alinea país (catálogo geo) al `registration_country_id` del perfil cuando exista.
  final int? profilePreselectedCountryId;

  /// `ui_status` del bloque tocado en perfil (controla solo lectura vs edición).
  final String? profileSectionUiStatus;

  @override
  ConsumerState<DriverRegistrationFlowScreen> createState() =>
      _DriverRegistrationFlowScreenState();
}

class _DriverRegistrationFlowScreenState
    extends ConsumerState<DriverRegistrationFlowScreen> {
  late final RegistrationFlowBindings _form = RegistrationFlowBindings();
  late final RegistrationFlowDraftService _draftService = RegistrationFlowDraftService(
    form: _form,
    readFlow: () => ref.read(driverRegistrationFlowControllerProvider),
    isMounted: () => mounted,
  );

  bool _showStepValidationErrors = false;
  int _validationStepScope = 0;

  RegistrationFlowMode get _mode => RegistrationFlowMode.fromLaunchParams(
        resumeAfterLogin: widget.resumeAfterLogin,
        addVehicleOnly: widget.addVehicleOnly,
        completeVehicleGalleryForAssetId: widget.completeVehicleGalleryForAssetId,
        openFromProfileStep: widget.openFromProfileStep,
        profilePreselectedCountryId: widget.profilePreselectedCountryId,
        profileSectionUiStatus: widget.profileSectionUiStatus,
      );

  RegistrationStepActions get _stepActions => RegistrationStepActions(
        onFormChanged: () => setState(() {}),
        persistDraft: _draftService.persist,
        pickDateToField: (c, {bool future = false, bool birthDate = false}) =>
            pickRegistrationDateToField(
          context: context,
          controller: c,
          setState: setState,
          persistDraft: _draftService.persist,
          isMounted: () => mounted,
          future: future,
          birthDate: birthDate,
        ),
        applyPickedImage: (b64, assign) => applyRegistrationPickedImage(
          b64: b64,
          assign: assign,
          setState: setState,
          persistDraft: _draftService.persist,
        ),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrap());
    });
  }

  @override
  void didUpdateWidget(DriverRegistrationFlowScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final modeChanged = oldWidget.addVehicleOnly != widget.addVehicleOnly ||
        oldWidget.resumeAfterLogin != widget.resumeAfterLogin ||
        oldWidget.completeVehicleGalleryForAssetId !=
            widget.completeVehicleGalleryForAssetId ||
        oldWidget.openFromProfileStep != widget.openFromProfileStep;
    if (modeChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_bootstrap());
      });
    }
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    await bootstrapRegistrationFlow(
      context: context,
      ref: ref,
      mode: _mode,
      form: _form,
      draftService: _draftService,
      setState: setState,
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    unawaited(_draftService.flushOnDispose());
    _form.dispose();
    super.dispose();
  }

  void _onInvalidStepValidation() {
    if (!_showStepValidationErrors) {
      setState(() => _showStepValidationErrors = true);
    }
    HapticFeedback.mediumImpact();
  }

  Future<void> _onPrimaryAction() async {
    final l10n = AppLocalizations.of(context);
    await handleRegistrationPrimaryAction(
      context: context,
      ref: ref,
      l10n: l10n,
      mode: _mode,
      form: _form,
      draftService: _draftService,
      onInvalidStepValidation: _onInvalidStepValidation,
      isMounted: () => mounted,
    );
  }

  void _goBack() {
    final l10n = AppLocalizations.of(context);
    final flow = ref.read(driverRegistrationFlowControllerProvider);
    final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);
    handleRegistrationGoBackSync(
      context: context,
      ref: ref,
      l10n: l10n,
      mode: _mode,
      flow: flow,
      notifier: notifier,
      form: _form,
      persistDraft: _draftService.persist,
      refreshUi: () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(driverRegistrationFlowControllerProvider);
    if (_validationStepScope != flow.step) {
      _validationStepScope = flow.step;
      _showStepValidationErrors = false;
    }

    return RegistrationFlowScaffold(
      mode: _mode,
      form: _form,
      actions: _stepActions,
      showValidationErrors: _showStepValidationErrors,
      onBack: _goBack,
      onContinue: () => unawaited(_onPrimaryAction()),
    );
  }
}
