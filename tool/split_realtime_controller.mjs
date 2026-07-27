#!/usr/bin/env node
/**
 * Extrae session + trips del orquestador realtime a parts.
 * node tool/split_realtime_controller.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), '..');
const file = path.join(root, 'lib/features/login/driver_realtime_controller.dart');
let src = fs.readFileSync(file, 'utf8');

const sessionMarkers = [
  'void _applyProfileFromAck',
  'bool _isAuthSocketErrorCode',
  'Future<void> setOnline',
  'Future<void> refreshGoOnlineGuards',
  'Future<void> _goOnline',
  'Future<void> _performGoOnline',
  'Future<void> _syncDriverForegroundSession',
  'Future<void> _goOffline',
  'Future<void> _refreshDriverAppCreditsBalance',
  'DriverTripOffer _tripOfferFromFcmPayload',
  'Future<bool> onNotificationOpenedWithTripOffer',
  'void resyncForegroundService',
  'Future<void> syncActiveTripFromApi',
];

const tripsMarkers = [
  'void _clearOfferErrorForTrip',
  'void _setOfferErrorForTrip',
  'bool _shouldIgnoreRestoreTrip',
  'void sendTripChatTemplate',
  'void sendArrivalReminder',
  'Future<void> submitTripRating',
  'void markArrived',
  'Future<void> acceptOffer',
];

function extractMethod(name) {
  let lastStart = -1;
  let searchFrom = 0;
  while (searchFrom < src.length) {
    const pos = src.indexOf(name, searchFrom);
    if (pos < 0) break;
    let start = src.lastIndexOf('\n', pos);
    start = start < 0 ? 0 : start + 1;
    const closeSync = src.indexOf(') {', pos);
    const closeAsync = src.indexOf(') async {', pos);
    const close = closeAsync >= 0 ? closeAsync + ') async {'.length - 1
      : closeSync >= 0 ? closeSync + ') {'.length - 1 : -1;
    const isDef = close >= 0 && src.slice(start, close + 1).includes(`${name}(`);
    if (isDef) {
      // Tipo de retorno en la línea anterior (firma multilínea).
      const prevNl = src.lastIndexOf('\n', start - 2);
      if (prevNl >= 0) {
        const prevLine = src.slice(prevNl + 1, start - 1);
        if (/^  Future</.test(prevLine)) start = prevNl + 1;
      }
      lastStart = start;
    }
    searchFrom = pos + name.length;
  }
  if (lastStart < 0) throw new Error(`Method not found: ${name}`);
  const anchor = src.indexOf(name, lastStart);
  let i = src.indexOf('{', anchor);
  let depth = 0;
  const bodyStart = i;
  for (; i < src.length; i++) {
    if (src[i] === '{') depth++;
    else if (src[i] === '}') {
      depth--;
      if (depth === 0) return src.slice(lastStart, i + 1);
    }
  }
  throw new Error(`Unbalanced: ${name}`);
}

function toMixinMethod(block) {
  return block
    .replace(/^  /gm, '')
    .replace(/\b_socket\b/g, '_rt._socket')
    .replace(/\b_tripRest\b/g, '_rt._tripRest')
    .replace(/\b_disposed\b/g, '_rt._disposed')
    .replace(/\b_goOnlineRun\b/g, '_rt._goOnlineRun')
    .replace(/\b_positionSub\b/g, '_rt._positionSub')
    .replace(/\b_userRequestedOffline\b/g, '_rt._userRequestedOffline')
    .replace(/\b_suppressNextDisconnectHandling\b/g, '_rt._suppressNextDisconnectHandling')
    .replace(/\b_availabilitySessionDesired\b/g, '_rt._availabilitySessionDesired')
    .replace(/\b_tripReconnectTimer\b/g, '_rt._tripReconnectTimer')
    .replace(/\b_availabilityReconnectTimer\b/g, '_rt._availabilityReconnectTimer')
    .replace(/\b_presenceHeartbeatTimer\b/g, '_rt._presenceHeartbeatTimer')
    .replace(/\b_reconnectJitterRandom\b/g, '_rt._reconnectJitterRandom')
    .replace(/\b_availabilityReconnectAttempts\b/g, '_rt._availabilityReconnectAttempts')
    .replace(/\b_tripReconnectAttempts\b/g, '_rt._tripReconnectAttempts')
    .replace(/\b_tripRatingInFlight\b/g, '_rt._tripRatingInFlight')
    .replace(/\b_ratingCatalogInFlight\b/g, '_rt._ratingCatalogInFlight')
    .replace(/\b_lastTouchReconnect\b/g, '_rt._lastTouchReconnect')
    .replace(/\b_pendingTripCompletedTripId\b/g, '_rt._pendingTripCompletedTripId')
    .replace(/\b_isRefreshingDriverPhoto\b/g, '_rt._isRefreshingDriverPhoto')
    .replace(/\b_lastDriverPhotoRefreshAt\b/g, '_rt._lastDriverPhotoRefreshAt')
    .replace(/\b_lastLocationEmittedAt\b/g, '_rt._lastLocationEmittedAt')
    .replace(/\b_locationPermissionCachedAt\b/g, '_rt._locationPermissionCachedAt')
    .replace(/\b_locationPermissionCached\b/g, '_rt._locationPermissionCached')
    .replace(/\b_logVerbose\b/g, '_rt._logVerbose')
    .replace(/\b_cancelTripReconnectLoop\b/g, '_rt._cancelTripReconnectLoop')
    .replace(/\b_cancelAvailabilityReconnectLoop\b/g, '_rt._cancelAvailabilityReconnectLoop')
    .replace(/\b_cancelPresenceHeartbeat\b/g, '_rt._cancelPresenceHeartbeat')
    .replace(/\b_ensureTripReconnectLoop\b/g, '_rt._ensureTripReconnectLoop')
    .replace(/\b_ensureAvailabilityReconnectLoop\b/g, '_rt._ensureAvailabilityReconnectLoop')
    .replace(/\b_startGpsTracking\b/g, '_rt._startGpsTracking')
    .replace(/\b_bindDriverRealtimeSocketHandlers\b/g, '_rt._bindDriverRealtimeSocketHandlers')
    .replace(/\b_ensureLocationPermissionForSocket\b/g, '_rt._ensureLocationPermissionForSocket')
    .replace(/\b_ensureLocationServiceEnabled\b/g, '_rt._ensureLocationServiceEnabled')
    .replace(/\b_ensureNotificationPermissionForTripOffers\b/g, '_rt._ensureNotificationPermissionForTripOffers')
    .replace(/\b_emitAvailabilityOnBreakBeforeDisconnect\b/g, '_rt._emitAvailabilityOnBreakBeforeDisconnect')
    .replace(/\b_setAvailability\b/g, '_rt._setAvailability')
    .replace(/\btouchReconnectIfWantedOnline\b/g, '_rt.touchReconnectIfWantedOnline');
}

const sessionBlocks = [];
for (const m of [
  '_applyProfileFromAck',
  '_isAuthSocketErrorCode',
  '_tryRefreshDriverSession',
  '_stopRealtimeAndInvalidateSession',
  '_shouldRefreshDriverPhoto',
  '_refreshDriverPhotoFromProfile',
  'setOnline',
  'refreshGoOnlineGuards',
  '_goOnline',
  '_performGoOnline',
  '_syncDriverForegroundSession',
  '_goOffline',
  '_refreshDriverAppCreditsBalance',
  '_tripOfferFromFcmPayload',
  'onNotificationOpenedWithTripOffer',
  'resyncForegroundService',
  'syncActiveTripFromApi',
]) {
  sessionBlocks.push(extractMethod(m));
}

const tripsBlocks = [];
for (const m of [
  '_clearOfferErrorForTrip',
  '_setOfferErrorForTrip',
  '_shouldIgnoreRestoreTrip',
  'sendTripChatTemplate',
  'sendTripChatText',
  'sendArrivalReminder',
  'submitTripRating',
  'fetchDriverRatingFeedbackCatalog',
  '_fetchDriverRatingFeedbackCatalogInternal',
  'markArrived',
  'startTrip',
  'completeTrip',
  'clearActiveTrip',
  'clearTripPendingRating',
  'acceptOffer',
  'rejectOffer',
]) {
  tripsBlocks.push(extractMethod(m));
}

for (const b of [...sessionBlocks, ...tripsBlocks]) {
  src = src.replace(b, '');
}

// clean duplicate blank lines
src = src.replace(/\n{3,}/g, '\n\n');

if (!src.includes('part \'driver_realtime_controller.session.dart\';')) {
  src = src.replace(
    "part 'driver_realtime_controller.socket.dart';\n",
    "part 'driver_realtime_controller.session.dart';\npart 'driver_realtime_controller.trips.dart';\npart 'driver_realtime_controller.socket.dart';\n",
  );
}

src = src.replace(
  /class DriverRealtimeController extends StateNotifier<DriverRealtimeState>\s+with\s+_DriverRealtimeLocationMixin,\s+_DriverRealtimeReconnectMixin,\s+_DriverRealtimeSocketMixin \{/,
  `class DriverRealtimeController extends StateNotifier<DriverRealtimeState>
    with
        _DriverRealtimeLocationMixin,
        _DriverRealtimeReconnectMixin,
        _DriverRealtimeSocketMixin,
        _DriverRealtimeSessionMixin,
        _DriverRealtimeTripsMixin {`,
);

const sessionPart = `part of 'driver_realtime_controller.dart';

mixin _DriverRealtimeSessionMixin on StateNotifier<DriverRealtimeState> {
  DriverRealtimeController get _rt => this as DriverRealtimeController;

${sessionBlocks.map((b) => toMixinMethod(b)).join('\n\n')}
}
`;

const tripsPart = `part of 'driver_realtime_controller.dart';

mixin _DriverRealtimeTripsMixin on StateNotifier<DriverRealtimeState> {
  DriverRealtimeController get _rt => this as DriverRealtimeController;

${tripsBlocks.map((b) => toMixinMethod(b)).join('\n\n')}
}
`;

fs.writeFileSync(file, src);
fs.writeFileSync(
  path.join(root, 'lib/features/login/driver_realtime_controller.session.dart'),
  sessionPart,
);
fs.writeFileSync(
  path.join(root, 'lib/features/login/driver_realtime_controller.trips.dart'),
  tripsPart,
);

console.log('Main LOC:', src.split('\n').length);
console.log('Session LOC:', sessionPart.split('\n').length);
console.log('Trips LOC:', tripsPart.split('\n').length);
