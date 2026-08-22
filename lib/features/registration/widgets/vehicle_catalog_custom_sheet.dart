import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../registration_flow_helpers.dart';

class VehicleCatalogCustomDraft {
  const VehicleCatalogCustomDraft({
    required this.manufacturerName,
    required this.modelName,
    required this.year,
  });

  final String manufacturerName;
  final String modelName;
  final int year;
}

Future<VehicleCatalogCustomDraft?> showVehicleCatalogCustomSheet(
  BuildContext context, {
  required bool manufacturerEditable,
  String? manufacturerName,
  String? modelName,
  String? yearText,
}) {
  return showModalBottomSheet<VehicleCatalogCustomDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surfaceCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return _VehicleCatalogCustomSheetBody(
        manufacturerEditable: manufacturerEditable,
        manufacturerName: manufacturerName,
        modelName: modelName,
        yearText: yearText,
      );
    },
  );
}

class _VehicleCatalogCustomSheetBody extends StatefulWidget {
  const _VehicleCatalogCustomSheetBody({
    required this.manufacturerEditable,
    this.manufacturerName,
    this.modelName,
    this.yearText,
  });

  final bool manufacturerEditable;
  final String? manufacturerName;
  final String? modelName;
  final String? yearText;

  @override
  State<_VehicleCatalogCustomSheetBody> createState() =>
      _VehicleCatalogCustomSheetBodyState();
}

class _VehicleCatalogCustomSheetBodyState
    extends State<_VehicleCatalogCustomSheetBody> {
  late final TextEditingController _mfr;
  late final TextEditingController _model;
  late final TextEditingController _year;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mfr = TextEditingController(text: widget.manufacturerName ?? '');
    _model = TextEditingController(text: widget.modelName ?? '');
    _year = TextEditingController(text: widget.yearText ?? '');
  }

  @override
  void dispose() {
    _mfr.dispose();
    _model.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + inset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.driverRegCatalogCustomTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.driverRegCatalogCustomHint,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mfr,
              enabled: widget.manufacturerEditable,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.driverRegCatalogCustomManufacturer,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _model,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.driverRegCatalogCustomModel,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _year,
              keyboardType: TextInputType.number,
              inputFormatters: vehicleYearInputFormatters,
              decoration: InputDecoration(
                labelText: l10n.driverRegCatalogCustomYear,
              ),
              validator: (v) => validateVehicleModelYear(v, l10n),
            ),
            const SizedBox(height: AppFoundation.spacingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      Navigator.of(context).pop(
                        VehicleCatalogCustomDraft(
                          manufacturerName: _mfr.text.trim(),
                          modelName: _model.text.trim(),
                          year: int.parse(_year.text.trim()),
                        ),
                      );
                    },
                    child: Text(l10n.driverRegCatalogCustomSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
