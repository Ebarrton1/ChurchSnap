import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/giving_currency.dart';

class GivingCurrencyRepository {
  GivingCurrencyRepository({
    required String churchId,
    FirebaseFirestore? firestore,
  }) : _churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  final String _churchId;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _document => _firestore
      .collection('churches')
      .doc(_churchId)
      .collection('settings')
      .doc('givingCurrency');

  Stream<GivingCurrencySettings> watchSettings() {
    return _document.snapshots().map((snapshot) {
      return GivingCurrencySettings.fromMap(snapshot.data());
    });
  }

  Future<void> saveSettings(GivingCurrencySettings settings) async {
    await _document.set({
      ...settings.normalized().toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Compatibility for older screens while installed builds migrate.
  Stream<GivingCurrency> watchCurrency() {
    return watchSettings().map((settings) => settings.defaultCurrency);
  }

  Future<void> saveCurrency(GivingCurrency currency) {
    return saveSettings(
      GivingCurrencySettings(
        defaultCurrencyCode: currency.code,
        enabledCurrencyCodes: [currency.code],
      ),
    );
  }
}
