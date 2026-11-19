import 'package:dio/dio.dart';

import '../../../core/network/driver_api_client.dart';

class DriverCorridorTrip {
  const DriverCorridorTrip({
    required this.tripId,
    required this.routeName,
    required this.departureAt,
    required this.status,
    required this.stops,
    required this.bookings,
  });

  final String tripId;
  final String routeName;
  final DateTime? departureAt;
  final String status;
  final List<String> stops;
  final List<DriverCorridorBooking> bookings;

  factory DriverCorridorTrip.fromJson(Map<String, dynamic> json) {
    final rawStops = json['stops'];
    final rawBookings = json['bookings'];
    return DriverCorridorTrip(
      tripId: json['tripId']?.toString() ?? '',
      routeName: json['routeName']?.toString() ?? '',
      departureAt: DateTime.tryParse(json['departureAt']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      stops: rawStops is List ? rawStops.map((item) => item.toString()).toList() : const [],
      bookings: rawBookings is List
          ? rawBookings
              .whereType<Map>()
              .map((item) => DriverCorridorBooking.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class DriverCorridorBooking {
  const DriverCorridorBooking({
    required this.givenName,
    required this.seatCount,
    required this.status,
    required this.publicCode,
  });

  final String givenName;
  final int seatCount;
  final String status;
  final String publicCode;

  factory DriverCorridorBooking.fromJson(Map<String, dynamic> json) {
    return DriverCorridorBooking(
      givenName: json['givenName']?.toString() ?? '',
      seatCount: json['seatCount'] is num ? (json['seatCount'] as num).toInt() : 0,
      status: json['status']?.toString() ?? '',
      publicCode: json['publicCode']?.toString() ?? '',
    );
  }
}

class DriverCorridorRepository {
  DriverCorridorRepository({DriverApiClient? client}) : _client = client ?? DriverApiClient();

  final DriverApiClient _client;

  Future<bool> dutyActive() async {
    final data = await _get('/api/v2/corridor/duty');
    return data['active'] == true;
  }

  Future<void> enter() async {
    await _post('/api/v2/corridor/duty');
  }

  Future<void> leave() async {
    await _post('/api/v2/corridor/duty/release');
  }

  Future<List<DriverCorridorTrip>> trips() async {
    final data = await _get('/api/v2/corridor/driver/trips');
    final items = data['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((item) => DriverCorridorTrip.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> openBoarding(String tripId) async {
    await _post('/api/v2/corridor/driver/trips/$tripId/boarding');
  }

  Future<void> confirmBoarding(String tripId, String code) async {
    await _post('/api/v2/corridor/driver/trips/$tripId/boarding/confirm', {'code': code});
  }

  Future<void> closeBoarding(String tripId) async {
    await _post('/api/v2/corridor/driver/trips/$tripId/boarding/close');
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: path,
        flow: 'driver_corridor',
        maxAttempts: 1,
      );
      return DriverApiClient.parseSuccessData(res.data);
    } catch (error) {
      throw DriverCorridorException(_message(error));
    }
  }

  Future<void> _post(String path, [Map<String, dynamic>? body]) async {
    try {
      final res = await _client.postWithRetry<Map<String, dynamic>>(
        path: path,
        flow: 'driver_corridor',
        data: body,
        maxAttempts: 1,
      );
      DriverApiClient.parseSuccessData(res.data);
    } catch (error) {
      throw DriverCorridorException(_message(error));
    }
  }

  String _message(Object error) {
    if (error is DriverApiResponseException) return error.code;
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
    }
    return '';
  }
}

class DriverCorridorException implements Exception {
  const DriverCorridorException(this.message);
  final String message;
}
