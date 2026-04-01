import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/driver_backend_config.dart';
import '../../core/theme/app_colors.dart';

class DriverRegisteredImagesScreen extends StatefulWidget {
  const DriverRegisteredImagesScreen({super.key});

  @override
  State<DriverRegisteredImagesScreen> createState() => _DriverRegisteredImagesScreenState();
}

class _DriverRegisteredImagesScreenState extends State<DriverRegisteredImagesScreen> {
  late Future<_RegisteredImagesVm> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RegisteredImagesVm> _load() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'driver_token');
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no disponible');
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: DriverBackendConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final res = await dio.get<Map<String, dynamic>>('/api/v2/driver/registered-images');
    final root = res.data;
    if (root == null || root['success'] != true) {
      throw Exception(root?['message']?.toString() ?? 'No se pudo cargar imágenes');
    }
    final data = root['data'];
    if (data is! Map) {
      throw Exception('Formato inválido');
    }
    return _RegisteredImagesVm.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imágenes registradas'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          )
        ],
      ),
      body: FutureBuilder<_RegisteredImagesVm>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  snapshot.error.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final vm = snapshot.data!;
          if (vm.documents.isEmpty && vm.vehicles.isEmpty) {
            return const Center(
              child: Text('No hay imágenes registradas para mostrar.'),
            );
          }
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'Documentos'),
                      Tab(text: 'Vehículos'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView(
                        padding: const EdgeInsets.all(14),
                        children: vm.documents.map((d) => _DocCard(doc: d)).toList(),
                      ),
                      ListView(
                        padding: const EdgeInsets.all(14),
                        children: vm.vehicles.map((v) => _VehicleCard(vehicle: v)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc});

  final _DocumentVm doc;

  @override
  Widget build(BuildContext context) {
    final title = doc.definitionCode == 'DRIVER_IDENTITY'
        ? 'Documento de identidad'
        : doc.definitionCode == 'DRIVER_LICENSE'
            ? 'Licencia de conducir'
            : doc.definitionCode;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title · ${doc.status}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (doc.submittedAt.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(doc.submittedAt, style: const TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 10),
            _ImagesWrap(images: doc.images),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final _VehicleVm vehicle;

  @override
  Widget build(BuildContext context) {
    final missing = vehicle.missingVehicleKeys;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vehicle.label.isNotEmpty ? vehicle.label : 'Vehículo',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                const _Pill(label: 'Frente', keyName: 'vehicle_front'),
                const _Pill(label: 'Atrás', keyName: 'vehicle_back'),
                const _Pill(label: 'Lado izq.', keyName: 'vehicle_left'),
                const _Pill(label: 'Lado der.', keyName: 'vehicle_right'),
              ].map((pill) {
                final miss = missing.contains(pill.keyName);
                return _Pill(
                  label: pill.label,
                  keyName: pill.keyName,
                  missing: miss,
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            _ImagesWrap(images: vehicle.images),
          ],
        ),
      ),
    );
  }
}

class _ImagesWrap extends StatelessWidget {
  const _ImagesWrap({required this.images});
  final List<_ImageVm> images;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: images
          .map(
            (img) => SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () => _openPreview(context, img),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildImageThumb(img.imageUrl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _prettyKey(img.key),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _copyQaMeta(context, img),
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        tooltip: 'Copiar metadatos QA',
                        icon: const Icon(Icons.copy_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  String _prettyKey(String k) {
    switch (k) {
      case 'front_image':
        return 'Frente documento';
      case 'back_image':
        return 'Reverso documento';
      case 'face_image':
        return 'Rostro';
      case 'vehicle_front':
        return 'Frente vehículo';
      case 'vehicle_back':
        return 'Atrás vehículo';
      case 'vehicle_left':
        return 'Lateral izquierdo';
      case 'vehicle_right':
        return 'Lateral derecho';
      default:
        return k;
    }
  }

  Widget _buildImageThumb(String raw) {
    if (raw.startsWith('data:') && raw.contains('base64,')) {
      try {
        final i = raw.indexOf('base64,');
        final bytes = base64Decode(raw.substring(i + 7));
        return Image(
          image: ResizeImage(MemoryImage(bytes), width: 420),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        );
      } catch (_) {
        return const ColoredBox(
          color: AppColors.surfaceCard,
          child: Center(child: Icon(Icons.broken_image_rounded)),
        );
      }
    }
    return Image.network(
      raw,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      cacheWidth: 420,
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: AppColors.surfaceCard,
        child: Center(child: Icon(Icons.broken_image_rounded)),
      ),
    );
  }

  Future<void> _copyQaMeta(BuildContext context, _ImageVm img) async {
    final text = 'key=${img.key}; source=${img.source}; storage_kind=${img.storageKind}; expires_at=${img.expiresAt}; url=${img.imageUrl}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Metadatos QA copiados')),
    );
  }

  void _openPreview(BuildContext context, _ImageVm img) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _prettyKey(img.key),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyQaMeta(ctx, img),
                      icon: const Icon(Icons.copy_rounded),
                      tooltip: 'Copiar metadatos QA',
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  width: double.infinity,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: _buildImageFull(img.imageUrl),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'source: ${img.source} · storage: ${img.storageKind}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageFull(String raw) {
    if (raw.startsWith('data:') && raw.contains('base64,')) {
      try {
        final i = raw.indexOf('base64,');
        final bytes = base64Decode(raw.substring(i + 7));
        return Image.memory(bytes, fit: BoxFit.contain);
      } catch (_) {
        return const Icon(Icons.broken_image_rounded, color: Colors.white70);
      }
    }
    return Image.network(
      raw,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_rounded, color: Colors.white70),
    );
  }
}

class _RegisteredImagesVm {
  _RegisteredImagesVm({required this.documents, required this.vehicles});
  final List<_DocumentVm> documents;
  final List<_VehicleVm> vehicles;

  factory _RegisteredImagesVm.fromJson(Map<String, dynamic> json) {
    final docsRaw = json['documents'];
    final vehRaw = json['vehicles'];
    return _RegisteredImagesVm(
      documents: docsRaw is List
          ? docsRaw.whereType<Map>().map((e) => _DocumentVm.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      vehicles: vehRaw is List
          ? vehRaw.whereType<Map>().map((e) => _VehicleVm.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
    );
  }
}

class _DocumentVm {
  _DocumentVm({
    required this.definitionCode,
    required this.status,
    required this.submittedAt,
    required this.images,
  });
  final String definitionCode;
  final String status;
  final String submittedAt;
  final List<_ImageVm> images;

  factory _DocumentVm.fromJson(Map<String, dynamic> json) {
    final imgs = json['images'];
    return _DocumentVm(
      definitionCode: json['definition_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      submittedAt: json['submitted_at']?.toString() ?? '',
      images: imgs is List
          ? imgs.whereType<Map>().map((e) => _ImageVm.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
    );
  }
}

class _VehicleVm {
  _VehicleVm({
    required this.label,
    required this.images,
    required this.missingVehicleKeys,
  });
  final String label;
  final List<_ImageVm> images;
  final List<String> missingVehicleKeys;

  factory _VehicleVm.fromJson(Map<String, dynamic> json) {
    final imgs = json['images'];
    final missing = json['missing_vehicle_keys'];
    return _VehicleVm(
      label: json['label']?.toString() ?? '',
      images: imgs is List
          ? imgs.whereType<Map>().map((e) => _ImageVm.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      missingVehicleKeys: missing is List ? missing.map((e) => e.toString()).toList() : const [],
    );
  }
}

class _ImageVm {
  _ImageVm({
    required this.key,
    required this.imageUrl,
    required this.source,
    required this.storageKind,
    required this.expiresAt,
  });
  final String key;
  final String imageUrl;
  final String source;
  final String storageKind;
  final String expiresAt;

  factory _ImageVm.fromJson(Map<String, dynamic> json) {
    return _ImageVm(
      key: json['key']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      source: json['source']?.toString() ?? 'unknown',
      storageKind: json['storage_kind']?.toString() ?? 'unknown',
      expiresAt: json['image_expires_at']?.toString() ?? '',
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.keyName,
    this.missing = false,
  });
  final String label;
  final String keyName;
  final bool missing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: missing ? Colors.red.withValues(alpha: 0.12) : Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        missing ? '$label · falta' : '$label · OK',
        style: TextStyle(
          fontSize: 12,
          color: missing ? Colors.red.shade700 : Colors.green.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

