import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'driver_club_models.dart';
import 'driver_club_repository.dart';

class DriverClubState {
  const DriverClubState({
    this.loading = true,
    this.claiming = false,
    this.hub,
    this.error,
  });

  final bool loading;
  final bool claiming;
  final DriverClubHub? hub;
  final String? error;

  DriverClubState copyWith({
    bool? loading,
    bool? claiming,
    DriverClubHub? hub,
    String? error,
    bool clearError = false,
  }) {
    return DriverClubState(
      loading: loading ?? this.loading,
      claiming: claiming ?? this.claiming,
      hub: hub ?? this.hub,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DriverClubController extends StateNotifier<DriverClubState> {
  DriverClubController({DriverClubRepository? repository})
      : _repo = repository ?? DriverClubRepository(),
        super(const DriverClubState()) {
    unawaited(load());
  }

  final DriverClubRepository _repo;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final hub = await _repo.fetchHub();
      state = state.copyWith(loading: false, hub: hub, clearError: true);
    } on DriverClubException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> claim(String code) async {
    state = state.copyWith(claiming: true, clearError: true);
    try {
      await _repo.claimCode(code);
      final hub = await _repo.fetchHub();
      state = state.copyWith(claiming: false, hub: hub, clearError: true);
      return true;
    } on DriverClubException catch (e) {
      state = state.copyWith(claiming: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(claiming: false, error: e.toString());
      return false;
    }
  }
}

final driverClubControllerProvider =
    StateNotifierProvider.autoDispose<DriverClubController, DriverClubState>(
  (ref) => DriverClubController(),
);
