import 'package:cloud_firestore/cloud_firestore.dart';

enum ChurchResourceCategory {
  songBook,
  sundaySchool,
  sabbathSchool,
  bibleStudy,
  youth,
  children,
  ministry,
  other,
}

extension ChurchResourceCategoryDetails on ChurchResourceCategory {
  String get storageValue => switch (this) {
    ChurchResourceCategory.songBook => 'songBook',
    ChurchResourceCategory.sundaySchool => 'sundaySchool',
    ChurchResourceCategory.sabbathSchool => 'sabbathSchool',
    ChurchResourceCategory.bibleStudy => 'bibleStudy',
    ChurchResourceCategory.youth => 'youth',
    ChurchResourceCategory.children => 'children',
    ChurchResourceCategory.ministry => 'ministry',
    ChurchResourceCategory.other => 'other',
  };

  String get label => switch (this) {
    ChurchResourceCategory.songBook => 'Song Book',
    ChurchResourceCategory.sundaySchool => 'Sunday School',
    ChurchResourceCategory.sabbathSchool => 'Sabbath School',
    ChurchResourceCategory.bibleStudy => 'Bible Study',
    ChurchResourceCategory.youth => 'Youth',
    ChurchResourceCategory.children => 'Children',
    ChurchResourceCategory.ministry => 'Ministry',
    ChurchResourceCategory.other => 'Other',
  };

  static ChurchResourceCategory fromStorageValue(Object? value) {
    final normalized = value?.toString().trim() ?? '';

    return ChurchResourceCategory.values.firstWhere(
      (category) => category.storageValue == normalized,
      orElse: () => ChurchResourceCategory.other,
    );
  }
}

enum ChurchResourceKind { file, link }

extension ChurchResourceKindDetails on ChurchResourceKind {
  String get storageValue => switch (this) {
    ChurchResourceKind.file => 'file',
    ChurchResourceKind.link => 'link',
  };

  String get label => switch (this) {
    ChurchResourceKind.file => 'Uploaded file',
    ChurchResourceKind.link => 'External link',
  };

  static ChurchResourceKind fromStorageValue(Object? value) {
    return value?.toString().trim() == 'link'
        ? ChurchResourceKind.link
        : ChurchResourceKind.file;
  }
}

class ChurchResource {
  const ChurchResource({
    this.id = '',
    required this.title,
    this.description = '',
    this.category = ChurchResourceCategory.other,
    this.kind = ChurchResourceKind.file,
    this.downloadUrl = '',
    this.externalUrl = '',
    this.storagePath = '',
    this.fileName = '',
    this.contentType = '',
    this.sizeBytes = 0,
    this.published = true,
    this.uploadedBy = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final ChurchResourceCategory category;
  final ChurchResourceKind kind;
  final String downloadUrl;
  final String externalUrl;
  final String storagePath;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final bool published;
  final String uploadedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get openUrl =>
      kind == ChurchResourceKind.link ? externalUrl.trim() : downloadUrl.trim();

  bool get canOpen => openUrl.isNotEmpty;

  bool get isPdf {
    if (contentType.trim().toLowerCase() == 'application/pdf') {
      return true;
    }

    if (fileName.trim().toLowerCase().endsWith('.pdf')) {
      return true;
    }

    final uri = Uri.tryParse(openUrl);

    return uri?.path.toLowerCase().endsWith('.pdf') ?? false;
  }

  String get sizeLabel {
    if (sizeBytes <= 0) {
      return '';
    }

    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    }

    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory ChurchResource.fromMap(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    final rawUpdatedAt = data['updatedAt'];
    final rawSize = data['sizeBytes'];

    return ChurchResource(
      id: id,
      title: (data['title'] as String? ?? '').trim(),
      description: (data['description'] as String? ?? '').trim(),
      category: ChurchResourceCategoryDetails.fromStorageValue(
        data['category'],
      ),
      kind: ChurchResourceKindDetails.fromStorageValue(data['kind']),
      downloadUrl: (data['downloadUrl'] as String? ?? '').trim(),
      externalUrl: (data['externalUrl'] as String? ?? '').trim(),
      storagePath: (data['storagePath'] as String? ?? '').trim(),
      fileName: (data['fileName'] as String? ?? '').trim(),
      contentType: (data['contentType'] as String? ?? '').trim(),
      sizeBytes: rawSize is num ? rawSize.toInt() : 0,
      published: data['published'] as bool? ?? false,
      uploadedBy: (data['uploadedBy'] as String? ?? '').trim(),
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'category': category.storageValue,
      'kind': kind.storageValue,
      'downloadUrl': downloadUrl.trim(),
      'externalUrl': externalUrl.trim(),
      'storagePath': storagePath.trim(),
      'fileName': fileName.trim(),
      'contentType': contentType.trim(),
      'sizeBytes': sizeBytes,
      'published': published,
      'uploadedBy': uploadedBy.trim(),
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}
