// GENERATED — editar con cuidado; regenerar: node tool/extract_registration_steps.mjs
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_foundation.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../driver_registration_controller.dart';
import '../../registration_flow_bindings.dart';
import '../../registration_flow_helpers.dart';
import '../../registration_step_actions.dart';
import '../registration_flow_chrome.dart';
import '../registration_section_card.dart';
import '../registration_soft_info_row.dart';

class RegistrationStepPersonal extends ConsumerWidget {
  const RegistrationStepPersonal({
    super.key,
    required this.bindings,
    required this.actions,
    required this.showValidationErrors,
    required this.flow,
    required this.notifier,
  });

  final RegistrationFlowBindings bindings;
  final RegistrationStepActions actions;
  final bool showValidationErrors;
  final DriverRegistrationFlowState flow;
  final DriverRegistrationFlowController notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

        return Theme(
          data: registrationInputTheme(context),
          child: Form(
            key: bindings.formPersonal,
            autovalidateMode: showValidationErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegistrationStepIntroBanner(
                  message: l10n.driverRegIntroPersonal,
                ),
                const SizedBox(height: 10),
                RegistrationSoftInfoRow(text: l10n.driverRegAgeRequirementHint),
                const SizedBox(height: 16),
                if (flow.loading && flow.countries.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (flow.countries.isEmpty)
                  OutlinedButton.icon(
                    onPressed: () => notifier.loadCountries(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.driverRegRetryLoadCountries),
                  ),
                if (flow.boliviaOnlyMessage != null) ...[
                  const SizedBox(height: 8),
                  RegistrationSoftInfoRow(text: flow.boliviaOnlyMessage!),
                ],
                const SizedBox(height: 12),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionOperationRegion,
                  icon: Icons.public_rounded,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey<String>('country-${flow.selectedCountryName ?? 'none'}'),
                      initialValue: flow.selectedCountryName,
                      decoration: InputDecoration(labelText: l10n.driverRegFieldCountry),
                      items: flow.countries
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.name,
                              child: Text('${c.name}  (+${c.phoneCode})'),
                            ),
                          )
                          .toList(),
                      onChanged: flow.loading
                          ? null
                          : (v) {
                              notifier.selectCountry(v);
                              actions.onFormChanged();
                              unawaited(actions.persistDraft());
                            },
                      validator: (v) => v == null || v.isEmpty ? l10n.driverRegValidationSelectCountry : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey<String>(
                        'dept-${flow.selectedCountryName ?? 'x'}-${flow.selectedDepartmentName ?? 'x'}',
                      ),
                      initialValue: flow.selectedDepartmentName,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldDepartment,
                        hintText: flow.isBoliviaSelected
                            ? null
                            : l10n.driverRegNoCoverageInCountry,
                      ),
                      items: flow.departments
                          .map((d) => DropdownMenuItem(value: d.name, child: Text(d.name)))
                          .toList(),
                      onChanged: (!flow.isBoliviaSelected || flow.departments.isEmpty)
                          ? null
                          : (v) {
                              notifier.selectDepartment(v);
                              actions.onFormChanged();
                              unawaited(actions.persistDraft());
                            },
                      validator: (v) {
                        if (!flow.isBoliviaSelected) return null;
                        return v == null || v.isEmpty ? l10n.driverRegValidationSelectDepartment : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final locs = notifier.localitiesForSelectedDepartment();
                        final locOk = flow.selectedLocalityId != null &&
                            locs.any((l) => l.id == flow.selectedLocalityId);
                        return DropdownButtonFormField<int>(
                          key: ValueKey<String>(
                            'loc-${flow.selectedDepartmentName ?? 'x'}-${flow.selectedLocalityId ?? 0}',
                          ),
                          initialValue: locOk ? flow.selectedLocalityId : null,
                          decoration: InputDecoration(
                            labelText: l10n.driverRegFieldLocality,
                            hintText: flow.isBoliviaSelected && locs.isEmpty
                                ? l10n.driverRegChooseDepartmentFirst
                                : (!flow.isBoliviaSelected ? l10n.driverRegNoCoverageInCountry : null),
                          ),
                          items: locs
                              .map(
                                (l) => DropdownMenuItem(
                                  value: l.id,
                                  child: Text(l.name),
                                ),
                              )
                              .toList(),
                          onChanged: locs.isEmpty
                              ? null
                              : (id) {
                                  if (id == null) return;
                                  final loc = locs.firstWhere((e) => e.id == id);
                                  notifier.selectLocality(loc);
                                  actions.onFormChanged();
                                  unawaited(actions.persistDraft());
                                },
                          validator: (v) {
                            if (!flow.isBoliviaSelected) return null;
                            return v == null ? l10n.driverRegValidationSelectLocality : null;
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppFoundation.spacingLg),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionPersonalData,
                  icon: Icons.person_outline_rounded,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: bindings.firstNameCtrl,
                            decoration: InputDecoration(labelText: l10n.driverRegFieldFirstName),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: bindings.lastNameCtrl,
                            decoration: InputDecoration(labelText: l10n.driverRegFieldLastName),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bindings.birthDateCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.driverProfileFieldBirthDate,
                        helperText: l10n.driverRegAgeRequirementFieldHelper,
                        helperMaxLines: 2,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today_rounded),
                          onPressed: () => actions.pickDateToField(
                            bindings.birthDateCtrl,
                            birthDate: true,
                          ),
                        ),
                      ),
                      onTap: () => actions.pickDateToField(
                        bindings.birthDateCtrl,
                        birthDate: true,
                      ),
                      validator: (v) {
                        final raw = v?.trim() ?? '';
                        if (raw.isEmpty) return l10n.driverRegValidationRequired;
                        if (DateTime.tryParse(raw) == null) {
                          return l10n.driverRegValidationRequired;
                        }
                        if (registrationBirthDateIsUnderMinAge(raw)) {
                          return l10n.driverRegValidationMinAge18;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: bindings.genderValue,
                      decoration: InputDecoration(labelText: l10n.driverProfileFieldGender),
                      items: registrationGenderChoices(l10n)
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        bindings.genderValue = v;
                        actions.onFormChanged();
                        unawaited(actions.persistDraft());
                      },
                      validator: (v) => v == null ? l10n.driverRegValidationSelectOption : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bindings.emailCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldEmail,
                        hintText: l10n.driverRegHintOptional,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
                const SizedBox(height: AppFoundation.spacingLg),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionContact,
                  icon: Icons.phone_android_rounded,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Text(
                            flow.selectedCountryPhoneCode != null
                                ? '+${flow.selectedCountryPhoneCode}'
                                : '—',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: bindings.phoneLocalCtrl,
                            enabled: flow.selectedCountryPhoneCode != null,
                            decoration: InputDecoration(
                              labelText: l10n.driverRegFieldPhoneNumber,
                              hintText: flow.selectedCountryPhoneCode != null
                                  ? l10n.driverRegHintLocalDigitsOnly
                                  : l10n.driverRegChooseCountryFirst,
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) {
                              if (flow.selectedCountryPhoneCode == null) {
                                return l10n.driverRegValidationSelectCountry;
                              }
                              final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                              if (d.length < 6) return l10n.driverRegValidationIncompleteNumber;
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionAddress,
                  icon: Icons.home_work_outlined,
                  children: [
                    TextFormField(
                      controller: bindings.addressCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldAddress,
                        hintText: l10n.driverRegHintAddressReference,
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionPassword,
                  icon: Icons.lock_outline_rounded,
                  children: [
                    TextFormField(
                      controller: bindings.passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.driverLoginPassword,
                        hintText: l10n.driverRegHintMin8Chars,
                      ),
                      validator: (v) =>
                          v == null || v.length < 8 ? l10n.driverRegValidationMin8Chars : null,
                    ),
                    const SizedBox(height: AppFoundation.spacingMd),
                    TextFormField(
                      controller: bindings.passwordConfirmCtrl,
                      obscureText: true,
                      decoration: InputDecoration(labelText: l10n.driverRegFieldConfirmPassword),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.driverRegValidationRequired;
                        if (v != bindings.passwordCtrl.text) return l10n.driverRegSnackPasswordsMismatch;
                        return null;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }

}
