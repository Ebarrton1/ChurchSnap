import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCollectionRepository<T> {
  FirestoreCollectionRepository({
    FirebaseFirestore? firestore,
    required this.collectionPath,
    required this.fromMap,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String collectionPath;
  final T Function(String id, Map<String, dynamic> data) fromMap;

  Stream<List<T>> watchPublished({
    String publishedField = 'published',
    String? dateField,
    bool descending = false,
  }) {
    return _firestore
        .collection(collectionPath)
        .where(publishedField, isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => fromMap(doc.id, doc.data()))
              .toList();

          final dataByItem = Map<T, Map<String, dynamic>>.identity();

          for (var index = 0; index < items.length; index++) {
            dataByItem[items[index]] = snapshot.docs[index].data();
          }

          if (dateField != null) {
            items.sort((a, b) {
              final aData = dataByItem[a]!;
              final bData = dataByItem[b]!;

              final aDate = aData[dateField] as Timestamp?;
              final bDate = bData[dateField] as Timestamp?;

              final aTime =
                  aDate?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bTime =
                  bDate?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);

              return descending
                  ? bTime.compareTo(aTime)
                  : aTime.compareTo(bTime);
            });
          }

          return items;
        });
  }
}
