import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:churchsnap/features/resources/models/church_resource.dart';

void main() {
  group('ChurchResource', () {
    test('maps category labels and storage values', () {
      expect(
        ChurchResourceCategory.sabbathSchool.storageValue,
        'sabbathSchool',
      );
      expect(ChurchResourceCategory.sabbathSchool.label, 'Sabbath School');
      expect(
        ChurchResourceCategoryDetails.fromStorageValue('songBook'),
        ChurchResourceCategory.songBook,
      );
    });

    test('reads an uploaded resource from Firestore data', () {
      final createdAt = DateTime(2026, 7, 16, 8, 30);

      final resource = ChurchResource.fromMap('resource-1', {
        'title': 'Church Hymnal',
        'description': 'Songs for worship',
        'category': 'songBook',
        'kind': 'file',
        'downloadUrl': 'https://example.com/hymnal.pdf',
        'storagePath': 'churches/demo-church/resources/1/hymnal.pdf',
        'fileName': 'hymnal.pdf',
        'contentType': 'application/pdf',
        'sizeBytes': 1048576,
        'published': true,
        'uploadedBy': 'admin-1',
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(resource.id, 'resource-1');
      expect(resource.category, ChurchResourceCategory.songBook);
      expect(resource.kind, ChurchResourceKind.file);
      expect(resource.openUrl, 'https://example.com/hymnal.pdf');
      expect(resource.sizeLabel, '1.0 MB');
      expect(resource.createdAt, createdAt);
      expect(resource.published, isTrue);
    });

    test('uses external URL for link resources', () {
      const resource = ChurchResource(
        title: 'Quarterly Lesson',
        category: ChurchResourceCategory.sabbathSchool,
        kind: ChurchResourceKind.link,
        externalUrl: 'https://example.com/lesson',
      );

      expect(resource.openUrl, 'https://example.com/lesson');
      expect(resource.canOpen, isTrue);
    });

    test('detects uploaded and linked PDF resources', () {
      const uploadedPdf = ChurchResource(
        title: 'Church Hymnal',
        contentType: 'application/pdf',
        fileName: 'church-hymnal.pdf',
        downloadUrl: 'https://example.com/church-hymnal.pdf?token=abc',
      );

      const linkedPdf = ChurchResource(
        title: 'Lesson Guide',
        kind: ChurchResourceKind.link,
        externalUrl: 'https://example.com/lessons/quarterly.pdf',
      );

      const wordDocument = ChurchResource(
        title: 'Ministry Notes',
        contentType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        fileName: 'notes.docx',
        downloadUrl: 'https://example.com/notes.docx',
      );

      expect(uploadedPdf.isPdf, isTrue);
      expect(linkedPdf.isPdf, isTrue);
      expect(wordDocument.isPdf, isFalse);
    });
  });
}
