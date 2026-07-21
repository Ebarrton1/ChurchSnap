import 'firebase_collection_names.dart';

class FirebasePaths {
  static String church(String churchId) =>
      '${FirebaseCollectionNames.churches}/$churchId';
  static String members(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.members}';
  static String sermons(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.sermons}';
  static String events(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.events}';
  static String prayerRequests(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.prayerRequests}';
  static String announcements(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.announcements}';
  static String ministries(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.ministries}';
  static String givingFunds(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.givingFunds}';
  static String givingSubmissions(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.givingSubmissions}';
  static String donations(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.donations}';
  static String settings(String churchId) =>
      '${church(churchId)}/${FirebaseCollectionNames.settings}/app';
}
