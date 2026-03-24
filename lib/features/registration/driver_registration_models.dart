class GeoCountry {
  const GeoCountry({
    required this.id,
    required this.name,
    required this.isoCode,
    required this.phoneCode,
  });

  final int id;
  final String name;
  final String isoCode;
  final String phoneCode;

  static GeoCountry? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name']?.toString();
    if (id is! int || name == null || name.isEmpty) return null;
    return GeoCountry(
      id: id,
      name: name,
      isoCode: json['iso_code']?.toString() ?? '',
      phoneCode: json['phone_code']?.toString() ?? '',
    );
  }
}

class GeoLocality {
  const GeoLocality({required this.id, required this.name});

  final int id;
  final String name;

  static GeoLocality? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name']?.toString();
    if (id is! int || name == null || name.isEmpty) return null;
    return GeoLocality(id: id, name: name);
  }
}

class GeoDepartment {
  const GeoDepartment({required this.name, required this.localities});

  final String name;
  final List<GeoLocality> localities;

  static GeoDepartment? fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString();
    if (name == null || name.isEmpty) return null;
    final raw = json['localities'];
    final list = <GeoLocality>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          final loc = GeoLocality.fromJson(e);
          if (loc != null) list.add(loc);
        }
      }
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return GeoDepartment(name: name, localities: list);
  }
}

/// Categorías de licencia (document_type en paso licencia). Hasta que exista endpoint.
class DriverLicenseCategory {
  const DriverLicenseCategory({required this.id, required this.label});

  final int id;
  final String label;

  static const List<DriverLicenseCategory> all = [
    DriverLicenseCategory(id: 2, label: 'A'),
    DriverLicenseCategory(id: 3, label: 'B'),
    DriverLicenseCategory(id: 4, label: 'C'),
    DriverLicenseCategory(id: 7, label: 'M'),
    DriverLicenseCategory(id: 8, label: 'Internacional'),
  ];
}
