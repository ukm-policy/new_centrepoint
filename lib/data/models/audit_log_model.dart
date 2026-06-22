class AuditLogModel {
  final String id;
  final String adminId;
  final String adminNama;
  final String aksi;
  final String tipe;
  final String? entityId;
  final String? entityType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const AuditLogModel({
    required this.id,
    required this.adminId,
    required this.adminNama,
    required this.aksi,
    required this.tipe,
    this.entityId,
    this.entityType,
    this.metadata,
    required this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      adminId: json['admin_id'] as String? ?? '',
      adminNama: json['admin_nama'] as String? ?? 'Admin',
      aksi: json['aksi'] as String? ?? '',
      tipe: json['tipe'] as String? ?? 'Sistem',
      entityId: json['entity_id'] as String?,
      entityType: json['entity_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
