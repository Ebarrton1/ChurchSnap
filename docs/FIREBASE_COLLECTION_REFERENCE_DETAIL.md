# ChurchSnap Firebase Collection Reference Detail

Generated: 2026-07-19 10:11:59

Branch: `churchsnap-testing-stabilization`

This report lists exact source references for collections highlighted by the first Firebase data-structure audit.

## giving_submissions

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 23 | `.collection('giving_submissions');` |
| `firestore.rules` | 661 | `match /giving_submissions/{submissionId} {` |

## donations

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/giving/repositories/giving_repository.dart` | 18 | `CollectionReference<Map<String, dynamic>> get _donations =>` |
| `lib/features/giving/repositories/giving_repository.dart` | 19 | `_firestore.collection(FirebasePaths.donations(churchId));` |
| `lib/features/giving/repositories/giving_repository.dart` | 204 | `Stream<List<DonationRecord>> watchMemberDonations(String memberId) {` |
| `lib/features/giving/repositories/giving_repository.dart` | 210 | `return _donations` |
| `lib/features/giving/repositories/giving_repository.dart` | 214 | `final donations = snapshot.docs` |
| `lib/features/giving/repositories/giving_repository.dart` | 221 | `donations.sort(_newestDonationFirst);` |
| `lib/features/giving/repositories/giving_repository.dart` | 222 | `return donations;` |
| `lib/features/giving/repositories/giving_repository.dart` | 226 | `Stream<List<DonationRecord>> watchAllDonations() {` |
| `lib/features/giving/repositories/giving_repository.dart` | 227 | `return _donations.snapshots().map((snapshot) {` |
| `lib/features/giving/repositories/giving_repository.dart` | 228 | `final donations = snapshot.docs` |
| `lib/features/giving/repositories/giving_repository.dart` | 234 | `donations.sort(_newestDonationFirst);` |
| `lib/features/giving/repositories/giving_repository.dart` | 235 | `return donations;` |
| `lib/features/giving/repositories/giving_repository.dart` | 244 | `return _donations.add({` |
| `lib/features/giving/repositories/giving_repository.dart` | 261 | `return _donations.doc(donationId).update({` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 348 | `stream: church.collection('donations').snapshots(),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 628 | `.collection('donations')` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 36 | `List<WebAdminActionSource> _donations = const [];` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 41 | `bool _donationsLoaded = false;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 47 | `_prayerLoaded && _eventsLoaded && _membersLoaded && _donationsLoaded;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 99 | `.collection('donations')` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 104 | `assign: (items) => _donations = items,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 105 | `markLoaded: () => _donationsLoaded = true,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 160 | `donations: _donations,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 27 | `List<WebAdminReportSource> _donations = const [];` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 32 | `bool _donationsLoaded = false;` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 37 | `_membersLoaded && _prayerLoaded && _eventsLoaded && _donationsLoaded;` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 89 | `.collection('donations')` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 94 | `assign: (items) => _donations = items,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 95 | `markLoaded: () => _donationsLoaded = true,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 152 | `donations: _donations,` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 12 | `required Iterable<WebAdminActionSource> donations,` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 20 | `..._givingItems(donations),` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 12 | `required Iterable<WebAdminReportSource> donations,` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 80 | `const excludedDonationStatuses = {` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 89 | `for (final source in donations) {` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 95 | `if (excludedDonationStatuses.contains(status)) {` |
| `lib/firebase/firebase_collection_names.dart` | 12 | `static const donations = 'donations';` |
| `lib/firebase/firebase_paths.dart` | 20 | `static String donations(String churchId) =>` |
| `lib/firebase/firebase_paths.dart` | 21 | `'${church(churchId)}/${FirebaseCollectionNames.donations}';` |
| `lib/screens/admin/admin_giving_screen.dart` | 168 | `stream: repository.watchAllDonations(),` |
| `lib/screens/profile/giving_history_screen.dart` | 27 | `stream: repository.watchMemberDonations(memberId),` |
| `firestore.rules` | 759 | `match /donations/{donationId} {` |

## giving

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/auth/screens/guest_account_screen.dart` | 26 | `'Published sermons, media, announcements, events, and giving '` |
| `lib/features/giving/models/donation_record.dart` | 40 | `fundName: map['fundName'] as String? ?? 'General Giving',` |
| `lib/features/giving/models/giving_currency.dart` | 1 | `class GivingCurrency {` |
| `lib/features/giving/models/giving_currency.dart` | 2 | `const GivingCurrency({` |
| `lib/features/giving/models/giving_currency.dart` | 14 | `static const usd = GivingCurrency(` |
| `lib/features/giving/models/giving_currency.dart` | 20 | `static const supported = <GivingCurrency>[` |
| `lib/features/giving/models/giving_currency.dart` | 22 | `GivingCurrency(code: 'JMD', name: 'Jamaican Dollar', symbol: r'J$'),` |
| `lib/features/giving/models/giving_currency.dart` | 23 | `GivingCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: r'CA$'),` |
| `lib/features/giving/models/giving_currency.dart` | 24 | `GivingCurrency(code: 'GBP', name: 'British Pound', symbol: '\u00A3'),` |
| `lib/features/giving/models/giving_currency.dart` | 25 | `GivingCurrency(code: 'EUR', name: 'Euro', symbol: '\u20AC'),` |
| `lib/features/giving/models/giving_currency.dart` | 26 | `GivingCurrency(` |
| `lib/features/giving/models/giving_currency.dart` | 31 | `GivingCurrency(code: 'BSD', name: 'Bahamian Dollar', symbol: r'B$'),` |
| `lib/features/giving/models/giving_currency.dart` | 32 | `GivingCurrency(code: 'BBD', name: 'Barbadian Dollar', symbol: r'Bds$'),` |
| `lib/features/giving/models/giving_currency.dart` | 33 | `GivingCurrency(code: 'XCD', name: 'East Caribbean Dollar', symbol: r'EC$'),` |
| `lib/features/giving/models/giving_currency.dart` | 34 | `GivingCurrency(code: 'GYD', name: 'Guyanese Dollar', symbol: r'G$'),` |
| `lib/features/giving/models/giving_currency.dart` | 35 | `GivingCurrency(code: 'NGN', name: 'Nigerian Naira', symbol: '\u20A6'),` |
| `lib/features/giving/models/giving_currency.dart` | 36 | `GivingCurrency(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH\u20B5'),` |
| `lib/features/giving/models/giving_currency.dart` | 37 | `GivingCurrency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),` |
| `lib/features/giving/models/giving_currency.dart` | 40 | `static GivingCurrency byCode(String? rawCode) {` |
| `lib/features/giving/models/giving_currency.dart` | 52 | `static GivingCurrency fromMap(Map<String, dynamic>? data) {` |
| `lib/features/giving/models/giving_currency.dart` | 105 | `class GivingCurrencySettings {` |
| `lib/features/giving/models/giving_currency.dart` | 106 | `const GivingCurrencySettings({` |
| `lib/features/giving/models/giving_currency.dart` | 114 | `static const defaults = GivingCurrencySettings(` |
| `lib/features/giving/models/giving_currency.dart` | 119 | `GivingCurrency get defaultCurrency =>` |
| `lib/features/giving/models/giving_currency.dart` | 120 | `GivingCurrency.byCode(defaultCurrencyCode);` |
| `lib/features/giving/models/giving_currency.dart` | 122 | `List<GivingCurrency> get enabledCurrencies {` |
| `lib/features/giving/models/giving_currency.dart` | 123 | `final currencies = <GivingCurrency>[];` |
| `lib/features/giving/models/giving_currency.dart` | 127 | `final currency = GivingCurrency.byCode(code);` |
| `lib/features/giving/models/giving_currency.dart` | 135 | `return [GivingCurrency.usd];` |
| `lib/features/giving/models/giving_currency.dart` | 146 | `GivingCurrencySettings normalized() {` |
| `lib/features/giving/models/giving_currency.dart` | 149 | `? GivingCurrency.byCode(defaultCurrencyCode).code` |
| `lib/features/giving/models/giving_currency.dart` | 152 | `return GivingCurrencySettings(` |
| `lib/features/giving/models/giving_currency.dart` | 158 | `static GivingCurrencySettings fromMap(Map<String, dynamic>? data) {` |
| `lib/features/giving/models/giving_currency.dart` | 176 | `return GivingCurrencySettings(` |
| `lib/features/giving/models/giving_fund.dart` | 1 | `class GivingFund {` |
| `lib/features/giving/models/giving_fund.dart` | 2 | `const GivingFund({` |
| `lib/features/giving/models/giving_fund.dart` | 16 | `factory GivingFund.fromMap(String id, Map<String, dynamic> map) {` |
| `lib/features/giving/models/giving_fund.dart` | 17 | `return GivingFund(` |
| `lib/features/giving/models/giving_fund.dart` | 19 | `name: map['name'] as String? ?? 'General Giving',` |
| `lib/features/giving/models/giving_submission.dart` | 3 | `import 'giving_currency.dart';` |
| `lib/features/giving/models/giving_submission.dart` | 5 | `enum GivingSubmissionStatus {` |
| `lib/features/giving/models/giving_submission.dart` | 10 | `static GivingSubmissionStatus fromValue(Object? value) {` |
| `lib/features/giving/models/giving_submission.dart` | 13 | `return GivingSubmissionStatus.values.firstWhere(` |
| `lib/features/giving/models/giving_submission.dart` | 15 | `orElse: () => GivingSubmissionStatus.pending,` |
| `lib/features/giving/models/giving_submission.dart` | 20 | `class GivingSubmission {` |
| `lib/features/giving/models/giving_submission.dart` | 21 | `const GivingSubmission({` |
| `lib/features/giving/models/giving_submission.dart` | 50 | `final GivingSubmissionStatus status;` |
| `lib/features/giving/models/giving_submission.dart` | 59 | `GivingCurrency get submittedCurrency => GivingCurrency.byCode(currencyCode);` |
| `lib/features/giving/models/giving_submission.dart` | 61 | `GivingCurrency get confirmedCurrency =>` |
| `lib/features/giving/models/giving_submission.dart` | 62 | `GivingCurrency.byCode(confirmedCurrencyCode ?? currencyCode);` |
| `lib/features/giving/models/giving_submission.dart` | 77 | `static GivingSubmission fromDocument(` |
| `lib/features/giving/models/giving_submission.dart` | 90 | `return GivingSubmission(` |
| `lib/features/giving/models/giving_submission.dart` | 95 | `fundName: (data['fundName'] as String?)?.trim() ?? 'General Giving',` |
| `lib/features/giving/models/giving_submission.dart` | 100 | `status: GivingSubmissionStatus.fromValue(data['status']),` |
| `lib/features/giving/models/standard_giving_funds.dart` | 1 | `import 'giving_fund.dart';` |
| `lib/features/giving/models/standard_giving_funds.dart` | 3 | `class StandardGivingFunds {` |
| `lib/features/giving/models/standard_giving_funds.dart` | 4 | `const StandardGivingFunds._();` |
| `lib/features/giving/models/standard_giving_funds.dart` | 6 | `static const tithe = GivingFund(` |
| `lib/features/giving/models/standard_giving_funds.dart` | 13 | `static const offering = GivingFund(` |
| `lib/features/giving/models/standard_giving_funds.dart` | 21 | `static const donation = GivingFund(` |
| `lib/features/giving/models/standard_giving_funds.dart` | 29 | `static const fallbackFunds = <GivingFund>[` |
| `lib/features/giving/models/standard_giving_funds.dart` | 33 | `GivingFund(` |
| `lib/features/giving/models/standard_giving_funds.dart` | 39 | `GivingFund(` |
| `lib/features/giving/models/standard_giving_funds.dart` | 45 | `GivingFund(` |
| `lib/features/giving/models/standard_giving_funds.dart` | 53 | `static List<GivingFund> separateLegacyFund(Iterable<GivingFund> source) {` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 3 | `import '../models/giving_currency.dart';` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 5 | `class GivingCurrencyRepository {` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 6 | `GivingCurrencyRepository({` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 19 | `.doc('givingCurrency');` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 21 | `Stream<GivingCurrencySettings> watchSettings() {` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 23 | `return GivingCurrencySettings.fromMap(snapshot.data());` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 27 | `Future<void> saveSettings(GivingCurrencySettings settings) async {` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 35 | `Stream<GivingCurrency> watchCurrency() {` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 39 | `Future<void> saveCurrency(GivingCurrency currency) {` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 41 | `GivingCurrencySettings(` |
| `lib/features/giving/repositories/giving_repository.dart` | 5 | `import '../models/giving_fund.dart';` |
| `lib/features/giving/repositories/giving_repository.dart` | 6 | `import '../models/standard_giving_funds.dart';` |
| `lib/features/giving/repositories/giving_repository.dart` | 8 | `class GivingRepository {` |
| `lib/features/giving/repositories/giving_repository.dart` | 9 | `GivingRepository({FirebaseFirestore? firestore, required this.churchId})` |
| `lib/features/giving/repositories/giving_repository.dart` | 16 | `_firestore.collection(FirebasePaths.givingFunds(churchId));` |
| `lib/features/giving/repositories/giving_repository.dart` | 21 | `Stream<List<GivingFund>> watchActiveFunds() async* {` |
| `lib/features/giving/repositories/giving_repository.dart` | 26 | `.map((document) => GivingFund.fromMap(document.id, document.data()))` |
| `lib/features/giving/repositories/giving_repository.dart` | 30 | `return StandardGivingFunds.separateLegacyFund(funds);` |
| `lib/features/giving/repositories/giving_repository.dart` | 46 | `if (StandardGivingFunds.isTithe(id: document.id, name: name)) {` |
| `lib/features/giving/repositories/giving_repository.dart` | 50 | `if (StandardGivingFunds.isOffering(id: document.id, name: name)) {` |
| `lib/features/giving/repositories/giving_repository.dart` | 53 | `if (StandardGivingFunds.isDonation(id: document.id, name: name)) {` |
| `lib/features/giving/repositories/giving_repository.dart` | 57 | `if (StandardGivingFunds.isLegacyCombinedFund(` |
| `lib/features/giving/repositories/giving_repository.dart` | 73 | `batch.set(_funds.doc(StandardGivingFunds.tithe.id), {` |
| `lib/features/giving/repositories/giving_repository.dart` | 74 | `...StandardGivingFunds.tithe.toMap(),` |
| `lib/features/giving/repositories/giving_repository.dart` | 82 | `batch.set(_funds.doc(StandardGivingFunds.offering.id), {` |
| `lib/features/giving/repositories/giving_repository.dart` | 83 | `...StandardGivingFunds.offering.toMap(),` |
| `lib/features/giving/repositories/giving_repository.dart` | 90 | `batch.set(_funds.doc(StandardGivingFunds.donation.id), {` |
| `lib/features/giving/repositories/giving_repository.dart` | 91 | `...StandardGivingFunds.donation.toMap(),` |
| `lib/features/giving/repositories/giving_repository.dart` | 115 | `// administrator who opens Giving completes the Firestore migration.` |
| `lib/features/giving/repositories/giving_repository.dart` | 122 | `Stream<List<GivingFund>> watchAllFunds() {` |
| `lib/features/giving/repositories/giving_repository.dart` | 125 | `.map((document) => GivingFund.fromMap(document.id, document.data()))` |
| `lib/features/giving/repositories/giving_repository.dart` | 138 | `Future<void> addFund(GivingFund fund) {` |
| `lib/features/giving/repositories/giving_repository.dart` | 146 | `Future<void> updateFund(GivingFund fund) {` |
| `lib/features/giving/repositories/giving_repository.dart` | 168 | `const starterFunds = <String, GivingFund>{` |
| `lib/features/giving/repositories/giving_repository.dart` | 169 | `'tithe-offering': GivingFund(` |
| `lib/features/giving/repositories/giving_repository.dart` | 174 | `'missions': GivingFund(` |
| `lib/features/giving/repositories/giving_repository.dart` | 179 | `'building-fund': GivingFund(` |
| `lib/features/giving/repositories/giving_repository.dart` | 184 | `'youth-ministry': GivingFund(` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 4 | `import '../models/giving_currency.dart';` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 5 | `import '../models/giving_submission.dart';` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 7 | `class GivingSubmissionRepository {` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 8 | `GivingSubmissionRepository({` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 23 | `.collection('giving_submissions');` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 25 | `Stream<List<GivingSubmission>> watchAll() {` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 28 | `.map(GivingSubmission.fromDocument)` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 43 | `Stream<List<GivingSubmission>> watchForGiver(String giverId) {` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 47 | `return Stream.value(const <GivingSubmission>[]);` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 55 | `.map(GivingSubmission.fromDocument)` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 77 | `required GivingCurrency currency,` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 108 | `'status': GivingSubmissionStatus.pending.name,` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 116 | `required GivingSubmission submission,` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 118 | `required GivingCurrency confirmedCurrency,` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 136 | `'status': GivingSubmissionStatus.confirmed.name,` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 147 | `required GivingSubmission submission,` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 157 | `'status': GivingSubmissionStatus.rejected.name,` |
| `lib/features/web_admin/models/web_admin_action_item.dart` | 1 | `enum WebAdminActionKind { prayer, event, member, giving }` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 32 | `required this.givingByCurrency,` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 33 | `required this.givingByFund,` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 45 | `final Map<String, double> givingByCurrency;` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 46 | `final Map<String, double> givingByFund;` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 45 | `onOpenGiving: () => _selectPage(4),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 50 | `_WebGivingPage(churchId: _churchId),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 56 | `onOpenGiving: () => _selectPage(4),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 149 | `label: Text('Giving'),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 198 | `label: 'Giving',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 302 | `required this.onOpenGiving,` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 309 | `final VoidCallback onOpenGiving;` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 346 | `label: 'Giving Records',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 349 | `onTap: onOpenGiving,` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 618 | `class _WebGivingPage extends StatelessWidget {` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 619 | `const _WebGivingPage({required this.churchId});` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 632 | `title: 'Giving Records',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 635 | `emptyMessage: 'No giving records are available.',` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 16 | `required this.onOpenGiving,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 23 | `final VoidCallback onOpenGiving;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 193 | `'follow-up, and giving exceptions.',` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 236 | `label: 'Giving',` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 237 | `count: _count(items, WebAdminActionKind.giving),` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 239 | `selected: _selectedKind == WebAdminActionKind.giving,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 241 | `setState(() => _selectedKind = WebAdminActionKind.giving),` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 304 | `WebAdminActionKind.giving => widget.onOpenGiving,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 388 | `WebAdminActionKind.giving => Icons.payments_rounded,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 394 | `WebAdminActionKind.giving => 'Giving',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 174 | `'Read-only ministry, membership, giving, prayer, and '` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 184 | `labelText: 'Giving period',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 275 | `detail: _givingSummary(report.givingByCurrency),` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 282 | `title: 'Giving by currency',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 284 | `child: _MoneyBreakdown(values: report.givingByCurrency),` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 288 | `title: 'Giving by fund',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 290 | `child: _MoneyBreakdown(values: report.givingByFund),` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 349 | `WebAdminReportPeriod.allTime => 'All recorded giving',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 353 | `static String _givingSummary(Map<String, double> values) {` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 489 | `return const _EmptyBreakdown(message: 'No qualifying giving records.');` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 20 | `..._givingItems(donations),` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 187 | `static Iterable<WebAdminActionItem> _givingItems(` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 226 | `kind: WebAdminActionKind.giving,` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 17 | `final givingStart = _periodStart(period, reference);` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 18 | `final givingByCurrency = <String, double>{};` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 19 | `final givingByFund = <String, double>{};` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 105 | `if (givingStart != null &&` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 106 | `(createdAt == null \|\| createdAt.isBefore(givingStart))) {` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 127 | `givingByCurrency.update(` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 132 | `givingByFund.update(` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 194 | `givingByCurrency: _sortedDoubleMap(givingByCurrency),` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 195 | `givingByFund: _sortedDoubleMap(givingByFund),` |
| `lib/firebase/firebase_collection_names.dart` | 11 | `static const givingFunds = 'giving_funds';` |
| `lib/firebase/firebase_paths.dart` | 18 | `static String givingFunds(String churchId) =>` |
| `lib/firebase/firebase_paths.dart` | 19 | `'${church(churchId)}/${FirebaseCollectionNames.givingFunds}';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 30 | `import 'admin_giving_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 31 | `import 'admin_giving_currency_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 32 | `import 'admin_giving_confirmations_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 226 | `title: 'Giving',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 228 | `screen: AdminGivingScreen(churchId: churchId),` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 232 | `title: 'Giving Currencies',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 234 | `screen: AdminGivingCurrencyScreen(churchId: churchId),` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 240 | `screen: AdminGivingConfirmationsScreen(churchId: churchId),` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 5 | `import 'package:churchsnap/features/giving/models/giving_currency.dart';` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 6 | `import 'package:churchsnap/features/giving/models/giving_submission.dart';` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 7 | `import 'package:churchsnap/features/giving/repositories/giving_currency_repository.dart';` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 8 | `import 'package:churchsnap/features/giving/repositories/giving_submission_repository.dart';` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 10 | `class AdminGivingConfirmationsScreen extends StatelessWidget {` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 11 | `const AdminGivingConfirmationsScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 17 | `final repository = GivingSubmissionRepository(churchId: churchId);` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 18 | `final currencyRepository = GivingCurrencyRepository(churchId: churchId);` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 21 | `child: StreamBuilder<GivingCurrencySettings>(` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 23 | `initialData: GivingCurrencySettings.defaults,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 26 | `(settingsSnapshot.data ?? GivingCurrencySettings.defaults)` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 29 | `return StreamBuilder<List<GivingSubmission>>(` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 32 | `final submissions = snapshot.data ?? const <GivingSubmission>[];` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 36 | `submission.status == GivingSubmissionStatus.pending,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 42 | `submission.status != GivingSubmissionStatus.pending,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 126 | `GivingSubmissionRepository repository,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 127 | `GivingSubmission submission,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 128 | `GivingCurrencySettings settings,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 145 | `final selectedCurrency = GivingCurrency.byCode(selectedCode);` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 262 | `confirmedCurrency: GivingCurrency.byCode(result.currencyCode),` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 282 | `GivingSubmissionRepository repository,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 283 | `GivingSubmission submission,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 353 | `final GivingSubmission submission;` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 361 | `GivingSubmissionStatus.pending => 'Awaiting confirmation',` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 362 | `GivingSubmissionStatus.confirmed => 'Confirmed',` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 363 | `GivingSubmissionStatus.rejected => 'Rejected',` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 382 | `GivingSubmissionStatus.pending => Icons.pending_actions_rounded,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 383 | `GivingSubmissionStatus.confirmed => Icons.verified_rounded,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 384 | `GivingSubmissionStatus.rejected => Icons.cancel_rounded,` |
| `lib/screens/admin/admin_giving_confirmations_screen.dart` | 401 | `if (submission.status == GivingSubmissionStatus.pending) ...[` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 4 | `import 'package:churchsnap/features/giving/models/giving_currency.dart';` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 5 | `import 'package:churchsnap/features/giving/repositories/giving_currency_repository.dart';` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 7 | `class AdminGivingCurrencyScreen extends StatefulWidget {` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 8 | `const AdminGivingCurrencyScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 13 | `State<AdminGivingCurrencyScreen> createState() =>` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 14 | `_AdminGivingCurrencyScreenState();` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 17 | `class _AdminGivingCurrencyScreenState extends State<AdminGivingCurrencyScreen> {` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 22 | `GivingCurrencyRepository get _repository =>` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 23 | `GivingCurrencyRepository(churchId: widget.churchId);` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 28 | `child: StreamBuilder<GivingCurrencySettings>(` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 30 | `initialData: GivingCurrencySettings.defaults,` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 32 | `final saved = (snapshot.data ?? GivingCurrencySettings.defaults)` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 39 | `final enabledCurrencies = GivingCurrency.supported` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 44 | `enabledCodes.add(GivingCurrency.usd.code);` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 45 | `enabledCurrencies.add(GivingCurrency.usd);` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 52 | `final defaultCurrency = GivingCurrency.byCode(_defaultCode);` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 55 | `title: 'Giving Currencies',` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 80 | `labelText: 'Default giving currency',` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 102 | `...GivingCurrency.supported.map((currency) {` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 144 | `_defaultCode = GivingCurrency.supported` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 185 | `label: Text(_saving ? 'Saving...' : 'Save Giving Currencies'),` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 216 | `GivingCurrencySettings(` |
| `lib/screens/admin/admin_giving_currency_screen.dart` | 226 | `).showSnackBar(const SnackBar(content: Text('Giving currencies saved.')));` |
| `lib/screens/admin/admin_giving_screen.dart` | 5 | `import '../../features/giving/models/donation_record.dart';` |
| `lib/screens/admin/admin_giving_screen.dart` | 6 | `import '../../features/giving/models/giving_fund.dart';` |
| `lib/screens/admin/admin_giving_screen.dart` | 7 | `import '../../features/giving/repositories/giving_repository.dart';` |
| `lib/screens/admin/admin_giving_screen.dart` | 9 | `class AdminGivingScreen extends StatelessWidget {` |
| `lib/screens/admin/admin_giving_screen.dart` | 10 | `const AdminGivingScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_giving_screen.dart` | 16 | `final repository = GivingRepository(churchId: churchId);` |
| `lib/screens/admin/admin_giving_screen.dart` | 20 | `title: 'Giving Administration',` |
| `lib/screens/admin/admin_giving_screen.dart` | 35 | `const SectionTitle(title: 'Giving Funds'),` |
| `lib/screens/admin/admin_giving_screen.dart` | 67 | `StreamBuilder<List<GivingFund>>(` |
| `lib/screens/admin/admin_giving_screen.dart` | 80 | `title: const Text('Unable to load giving funds'),` |
| `lib/screens/admin/admin_giving_screen.dart` | 86 | `final funds = snapshot.data ?? const <GivingFund>[];` |
| `lib/screens/admin/admin_giving_screen.dart` | 92 | `title: Text('No giving funds configured'),` |
| `lib/screens/admin/admin_giving_screen.dart` | 254 | `GivingRepository repository, {` |
| `lib/screens/admin/admin_giving_screen.dart` | 255 | `GivingFund? existingFund,` |
| `lib/screens/admin/admin_giving_screen.dart` | 264 | `final fund = GivingFund(` |
| `lib/screens/admin/admin_giving_screen.dart` | 284 | `? 'Giving fund added.'` |
| `lib/screens/admin/admin_giving_screen.dart` | 285 | `: 'Giving fund updated.',` |
| `lib/screens/admin/admin_giving_screen.dart` | 291 | `_showError(context, 'Unable to save giving fund: $error');` |
| `lib/screens/admin/admin_giving_screen.dart` | 297 | `GivingRepository repository,` |
| `lib/screens/admin/admin_giving_screen.dart` | 298 | `GivingFund fund,` |
| `lib/screens/admin/admin_giving_screen.dart` | 303 | `title: const Text('Delete Giving Fund?'),` |
| `lib/screens/admin/admin_giving_screen.dart` | 333 | `).showSnackBar(const SnackBar(content: Text('Giving fund deleted.')));` |
| `lib/screens/admin/admin_giving_screen.dart` | 336 | `_showError(context, 'Unable to delete giving fund: $error');` |
| `lib/screens/admin/admin_giving_screen.dart` | 342 | `GivingRepository repository, {` |
| `lib/screens/admin/admin_giving_screen.dart` | 444 | `final GivingFund? existingFund;` |
| `lib/screens/admin/admin_giving_screen.dart` | 555 | `final List<GivingFund> funds;` |
| `lib/screens/admin/admin_giving_screen.dart` | 572 | `List<GivingFund> get _availableFunds {` |
| `lib/screens/admin/admin_giving_screen.dart` | 576 | `GivingFund(` |
| `lib/screens/admin/admin_giving_screen.dart` | 578 | `name: 'General Giving',` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 58 | `'It does not delete the account, giving history, attendance, '` |
| `lib/screens/giving/giving_screen.dart` | 6 | `import 'package:churchsnap/features/giving/models/giving_currency.dart';` |
| `lib/screens/giving/giving_screen.dart` | 7 | `import 'package:churchsnap/features/giving/models/giving_fund.dart';` |
| `lib/screens/giving/giving_screen.dart` | 8 | `import 'package:churchsnap/features/giving/models/standard_giving_funds.dart';` |
| `lib/screens/giving/giving_screen.dart` | 9 | `import 'package:churchsnap/features/giving/repositories/giving_currency_repository.dart';` |
| `lib/screens/giving/giving_screen.dart` | 10 | `import 'package:churchsnap/features/giving/repositories/giving_repository.dart';` |
| `lib/screens/giving/giving_screen.dart` | 11 | `import 'package:churchsnap/features/giving/repositories/giving_submission_repository.dart';` |
| `lib/screens/giving/giving_screen.dart` | 12 | `import 'package:churchsnap/screens/profile/giving_history_screen.dart';` |
| `lib/screens/giving/giving_screen.dart` | 14 | `class GivingScreen extends StatefulWidget {` |
| `lib/screens/giving/giving_screen.dart` | 15 | `const GivingScreen({super.key, required this.authController});` |
| `lib/screens/giving/giving_screen.dart` | 20 | `State<GivingScreen> createState() => _GivingScreenState();` |
| `lib/screens/giving/giving_screen.dart` | 23 | `class _GivingScreenState extends State<GivingScreen> {` |
| `lib/screens/giving/giving_screen.dart` | 26 | `static const _fallbackFunds = StandardGivingFunds.fallbackFunds;` |
| `lib/screens/giving/giving_screen.dart` | 63 | `final givingRepository = GivingRepository(churchId: _churchId);` |
| `lib/screens/giving/giving_screen.dart` | 64 | `final currencyRepository = GivingCurrencyRepository(churchId: _churchId);` |
| `lib/screens/giving/giving_screen.dart` | 66 | `return StreamBuilder<GivingCurrencySettings>(` |
| `lib/screens/giving/giving_screen.dart` | 68 | `initialData: GivingCurrencySettings.defaults,` |
| `lib/screens/giving/giving_screen.dart` | 71 | `(currencySnapshot.data ?? GivingCurrencySettings.defaults)` |
| `lib/screens/giving/giving_screen.dart` | 77 | `? GivingCurrency.byCode(requestedCode)` |
| `lib/screens/giving/giving_screen.dart` | 82 | `title: 'Giving',` |
| `lib/screens/giving/giving_screen.dart` | 83 | `subtitle: 'Choose the amount, fund, and currency you are giving.',` |
| `lib/screens/giving/giving_screen.dart` | 90 | `'assets/icons/giving.png',` |
| `lib/screens/giving/giving_screen.dart` | 117 | `'Choose the currency you are actually giving. An '` |
| `lib/screens/giving/giving_screen.dart` | 212 | `StreamBuilder<List<GivingFund>>(` |
| `lib/screens/giving/giving_screen.dart` | 213 | `stream: givingRepository.watchActiveFunds(),` |
| `lib/screens/giving/giving_screen.dart` | 232 | `labelText: 'Giving fund',` |
| `lib/screens/giving/giving_screen.dart` | 323 | `builder: (_) => GivingHistoryScreen(` |
| `lib/screens/giving/giving_screen.dart` | 333 | `? 'Giving History is for members'` |
| `lib/screens/giving/giving_screen.dart` | 334 | `: 'Giving History',` |
| `lib/screens/giving/giving_screen.dart` | 361 | `GivingFund fund,` |
| `lib/screens/giving/giving_screen.dart` | 362 | `GivingCurrency currency,` |
| `lib/screens/giving/giving_screen.dart` | 422 | `final repository = GivingSubmissionRepository(churchId: _churchId);` |
| `lib/screens/home/churchsnap_shell.dart` | 11 | `import '../giving/giving_screen.dart';` |
| `lib/screens/home/churchsnap_shell.dart` | 99 | `GivingScreen(authController: widget.authController),` |
| `lib/screens/home/churchsnap_shell.dart` | 135 | `label: 'Giving',` |
| `lib/screens/home/churchsnap_shell.dart` | 136 | `assetName: 'giving',` |
| `lib/screens/home/home_screen.dart` | 99 | `onGiving: () => onSelectTab(5),` |
| `lib/screens/home/home_screen.dart` | 589 | `required this.onGiving,` |
| `lib/screens/home/home_screen.dart` | 595 | `final VoidCallback onGiving;` |
| `lib/screens/home/home_screen.dart` | 603 | `_HomeAction(label: 'Giving', assetName: 'giving', onTap: onGiving),` |
| `lib/screens/profile/giving_history_screen.dart` | 4 | `import '../../features/giving/models/donation_record.dart';` |
| `lib/screens/profile/giving_history_screen.dart` | 5 | `import '../../features/giving/repositories/giving_repository.dart';` |
| `lib/screens/profile/giving_history_screen.dart` | 7 | `class GivingHistoryScreen extends StatelessWidget {` |
| `lib/screens/profile/giving_history_screen.dart` | 8 | `const GivingHistoryScreen({` |
| `lib/screens/profile/giving_history_screen.dart` | 19 | `final repository = GivingRepository(churchId: churchId);` |
| `lib/screens/profile/giving_history_screen.dart` | 23 | `title: 'Giving History',` |
| `lib/screens/profile/giving_history_screen.dart` | 39 | `title: const Text('Unable to load giving history'),` |
| `lib/screens/profile/profile_screen.dart` | 7 | `import 'giving_history_screen.dart';` |
| `lib/screens/profile/profile_screen.dart` | 236 | `'Giving History',` |
| `lib/screens/profile/profile_screen.dart` | 245 | `builder: (_) => GivingHistoryScreen(` |
| `lib/screens/profile/profile_screen.dart` | 321 | `'announcements, and giving information. Member records, RSVP, '` |
| `lib/screens/profile/profile_screen.dart` | 322 | `'check-in, schedules, giving history, and admin tools stay private.',` |
| `firestore.rules` | 592 | `match /settings/givingCurrency {` |
| `firestore.rules` | 661 | `match /giving_submissions/{submissionId} {` |
| `firestore.rules` | 754 | `match /giving_funds/{fundId} {` |
| `firestore.rules` | 770 | `match /giving/{givingId} {` |

## giving_funds

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/giving/repositories/giving_repository.dart` | 6 | `import '../models/standard_giving_funds.dart';` |
| `lib/firebase/firebase_collection_names.dart` | 11 | `static const givingFunds = 'giving_funds';` |
| `lib/screens/giving/giving_screen.dart` | 8 | `import 'package:churchsnap/features/giving/models/standard_giving_funds.dart';` |
| `firestore.rules` | 754 | `match /giving_funds/{fundId} {` |

## prayer_requests

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 342 | `stream: church.collection('prayer_requests').snapshots(),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 571 | `.collection('prayer_requests')` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 60 | `.collection('prayer_requests')` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 63 | `.collection('prayer_requests')` |
| `lib/firebase/firebase_collection_names.dart` | 6 | `static const prayerRequests = 'prayer_requests';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 24 | `import 'admin_prayer_requests_screen.dart';` |
| `firestore.rules` | 439 | `match /prayer_requests/{prayerId} {` |

## eventCheckIns

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 17 | `.collection('eventCheckIns');` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 67 | `final checkInRef = _churchRef.collection('eventCheckIns').doc(checkInId);` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 19 | `.collection('eventCheckIns');` |
| `lib/features/dashboard/repositories/dashboard_repository.dart` | 63 | `.collection('eventCheckIns')` |
| `firestore.rules` | 454 | `match /eventCheckIns/{checkInId} {` |

## attendance

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/attendance/models/attendance_record.dart` | 3 | `class AttendanceRecord {` |
| `lib/features/attendance/models/attendance_record.dart` | 4 | `const AttendanceRecord({` |
| `lib/features/attendance/models/attendance_record.dart` | 22 | `factory AttendanceRecord.fromMap(` |
| `lib/features/attendance/models/attendance_record.dart` | 37 | `return AttendanceRecord(` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 3 | `import '../models/attendance_record.dart';` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 5 | `class AttendanceHistoryRepository {` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 6 | `AttendanceHistoryRepository({` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 22 | `Stream<List<AttendanceRecord>> watchMemberAttendance(String memberId) {` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 26 | `return Stream.value(const <AttendanceRecord>[]);` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 41 | `final records = await Future.wait<AttendanceRecord>(` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 66 | `return AttendanceRecord.fromMap(` |
| `lib/screens/admin/admin_attendance_screen.dart` | 10 | `class AdminAttendanceScreen extends StatefulWidget {` |
| `lib/screens/admin/admin_attendance_screen.dart` | 11 | `const AdminAttendanceScreen({super.key, this.churchId = 'demo-church'});` |
| `lib/screens/admin/admin_attendance_screen.dart` | 16 | `State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();` |
| `lib/screens/admin/admin_attendance_screen.dart` | 19 | `class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {` |
| `lib/screens/admin/admin_attendance_screen.dart` | 44 | `title: 'Attendance & Check-ins',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 57 | `'Clearing check-ins permanently removes the selected attendance '` |
| `lib/screens/admin/admin_attendance_screen.dart` | 89 | `return _buildAttendanceContent(checkIns);` |
| `lib/screens/admin/admin_attendance_screen.dart` | 97 | `Widget _buildAttendanceContent(List<CheckInRecord> checkIns) {` |
| `lib/screens/admin/admin_attendance_screen.dart` | 352 | `'Choose exactly which attendance records to remove.',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 417 | `'The attendance entry for $displayName will be permanently removed.',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 456 | `'The selected attendance records will be permanently removed.',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 573 | `'This permanently deletes every attendance check-in for '` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 6 | `import 'admin_attendance_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 192 | `title: 'Attendance',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 194 | `screen: AdminAttendanceScreen(churchId: churchId),` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 252 | `subtitle: 'Scan member QR codes and record attendance',` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 58 | `'It does not delete the account, giving history, attendance, '` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 128 | `title: Text('Attendance History'),` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 5 | `import '../../features/attendance/services/qr_check_in_service.dart';` |
| `lib/screens/profile/attendance_history_screen.dart` | 4 | `import '../../features/attendance/models/attendance_record.dart';` |
| `lib/screens/profile/attendance_history_screen.dart` | 5 | `import '../../features/attendance/repositories/attendance_history_repository.dart';` |
| `lib/screens/profile/attendance_history_screen.dart` | 7 | `class AttendanceHistoryScreen extends StatelessWidget {` |
| `lib/screens/profile/attendance_history_screen.dart` | 8 | `const AttendanceHistoryScreen({` |
| `lib/screens/profile/attendance_history_screen.dart` | 19 | `final repository = AttendanceHistoryRepository(churchId: churchId);` |
| `lib/screens/profile/attendance_history_screen.dart` | 23 | `title: 'Attendance History',` |
| `lib/screens/profile/attendance_history_screen.dart` | 26 | `StreamBuilder<List<AttendanceRecord>>(` |
| `lib/screens/profile/attendance_history_screen.dart` | 27 | `stream: repository.watchMemberAttendance(memberId),` |
| `lib/screens/profile/attendance_history_screen.dart` | 39 | `title: const Text('Unable to load attendance history'),` |
| `lib/screens/profile/attendance_history_screen.dart` | 45 | `final records = snapshot.data ?? <AttendanceRecord>[];` |
| `lib/screens/profile/attendance_history_screen.dart` | 51 | `title: Text('No attendance records found'),` |
| `lib/screens/profile/profile_screen.dart` | 6 | `import 'attendance_history_screen.dart';` |
| `lib/screens/profile/profile_screen.dart` | 179 | `'Attendance History',` |
| `lib/screens/profile/profile_screen.dart` | 188 | `builder: (_) => AttendanceHistoryScreen(` |
| `firestore.rules` | 110 | `function ownsAttendanceRecord(data) {` |
| `firestore.rules` | 118 | `function validSelfAttendanceRecord(data) {` |
| `firestore.rules` | 458 | `&& ownsAttendanceRecord(resource.data)` |
| `firestore.rules` | 464 | `&& validSelfAttendanceRecord(request.resource.data)` |
| `firestore.rules` | 470 | `match /attendance/{attendanceId} {` |
| `firestore.rules` | 474 | `&& ownsAttendanceRecord(resource.data)` |
| `firestore.rules` | 480 | `&& validSelfAttendanceRecord(request.resource.data)` |

## media

| File | Line | Source |
| --- | ---: | --- |
| `lib/core/auth/app_roles.dart` | 48 | `static bool canManageMedia(String role) {` |
| `lib/core/demo/demo_data.dart` | 81 | `'Serve through music, media, sound, and Sunday/Sabbath worship support.',` |
| `lib/core/utils/churchsnap_date_formatter.dart` | 45 | `alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),` |
| `lib/features/auth/screens/guest_account_screen.dart` | 26 | `'Published sermons, media, announcements, events, and giving '` |
| `lib/features/dashboard/providers/dashboard_providers.dart` | 25 | `final mediaCountProvider = StreamProvider<int>((ref) {` |
| `lib/features/dashboard/providers/dashboard_providers.dart` | 26 | `return ref.read(dashboardRepositoryProvider).watchMediaCount();` |
| `lib/features/dashboard/providers/dashboard_providers.dart` | 74 | `final mediaCountByChurchProvider = StreamProvider.family<int, String>((` |
| `lib/features/dashboard/providers/dashboard_providers.dart` | 80 | `.watchMediaCount();` |
| `lib/features/dashboard/repositories/dashboard_repository.dart` | 53 | `Stream<int> watchMediaCount() {` |
| `lib/features/dashboard/repositories/dashboard_repository.dart` | 55 | `.collection('media')` |
| `lib/features/media/models/media_item.dart` | 3 | `class MediaItem {` |
| `lib/features/media/models/media_item.dart` | 7 | `final String mediaType;` |
| `lib/features/media/models/media_item.dart` | 11 | `final String mediaUrl;` |
| `lib/features/media/models/media_item.dart` | 18 | `const MediaItem({` |
| `lib/features/media/models/media_item.dart` | 22 | `this.mediaType = 'video',` |
| `lib/features/media/models/media_item.dart` | 26 | `this.mediaUrl = '',` |
| `lib/features/media/models/media_item.dart` | 34 | `factory MediaItem.fromMap(String id, Map<String, dynamic> map) {` |
| `lib/features/media/models/media_item.dart` | 35 | `return MediaItem(` |
| `lib/features/media/models/media_item.dart` | 39 | `mediaType: map['mediaType'] ?? 'video',` |
| `lib/features/media/models/media_item.dart` | 43 | `mediaUrl: map['mediaUrl'] ?? '',` |
| `lib/features/media/models/media_item.dart` | 56 | `'mediaType': mediaType,` |
| `lib/features/media/models/media_item.dart` | 60 | `'mediaUrl': mediaUrl,` |
| `lib/features/media/providers/media_providers.dart` | 3 | `import '../repositories/media_repository.dart';` |
| `lib/features/media/providers/media_providers.dart` | 4 | `import '../services/media_service.dart';` |
| `lib/features/media/providers/media_providers.dart` | 5 | `import '../services/media_storage_service.dart';` |
| `lib/features/media/providers/media_providers.dart` | 7 | `final mediaRepositoryProvider = Provider<MediaRepository>(` |
| `lib/features/media/providers/media_providers.dart` | 8 | `(ref) => MediaRepository(),` |
| `lib/features/media/providers/media_providers.dart` | 11 | `final mediaServiceProvider = Provider<MediaService>(` |
| `lib/features/media/providers/media_providers.dart` | 12 | `(ref) => MediaService(ref.read(mediaRepositoryProvider)),` |
| `lib/features/media/providers/media_providers.dart` | 15 | `final mediaRepositoryByChurchProvider =` |
| `lib/features/media/providers/media_providers.dart` | 16 | `Provider.family<MediaRepository, String>((ref, churchId) {` |
| `lib/features/media/providers/media_providers.dart` | 17 | `return MediaRepository(churchId: churchId);` |
| `lib/features/media/providers/media_providers.dart` | 20 | `final mediaServiceByChurchProvider = Provider.family<MediaService, String>((` |
| `lib/features/media/providers/media_providers.dart` | 24 | `return MediaService(ref.read(mediaRepositoryByChurchProvider(churchId)));` |
| `lib/features/media/providers/media_providers.dart` | 27 | `final mediaStorageServiceProvider = Provider<MediaStorageService>(` |
| `lib/features/media/providers/media_providers.dart` | 28 | `(ref) => MediaStorageService(),` |
| `lib/features/media/repositories/media_repository.dart` | 3 | `import '../models/media_item.dart';` |
| `lib/features/media/repositories/media_repository.dart` | 5 | `class MediaRepository {` |
| `lib/features/media/repositories/media_repository.dart` | 6 | `MediaRepository({FirebaseFirestore? firestore, this.churchId = 'demo-church'})` |
| `lib/features/media/repositories/media_repository.dart` | 12 | `CollectionReference<Map<String, dynamic>> get _media =>` |
| `lib/features/media/repositories/media_repository.dart` | 13 | `_firestore.collection('churches').doc(churchId).collection('media');` |
| `lib/features/media/repositories/media_repository.dart` | 15 | `Stream<List<MediaItem>> watchMedia() {` |
| `lib/features/media/repositories/media_repository.dart` | 16 | `return _media` |
| `lib/features/media/repositories/media_repository.dart` | 23 | `(document) => MediaItem.fromMap(document.id, document.data()),` |
| `lib/features/media/repositories/media_repository.dart` | 29 | `Future<void> addMedia(MediaItem item) {` |
| `lib/features/media/repositories/media_repository.dart` | 30 | `return _media.add(item.toMap());` |
| `lib/features/media/repositories/media_repository.dart` | 33 | `Future<void> updateMedia(MediaItem item) {` |
| `lib/features/media/repositories/media_repository.dart` | 34 | `return _media.doc(item.id).update(item.toMap());` |
| `lib/features/media/repositories/media_repository.dart` | 37 | `Future<void> deleteMedia(String id) {` |
| `lib/features/media/repositories/media_repository.dart` | 38 | `return _media.doc(id).delete();` |
| `lib/features/media/services/media_service.dart` | 1 | `import '../models/media_item.dart';` |
| `lib/features/media/services/media_service.dart` | 2 | `import '../repositories/media_repository.dart';` |
| `lib/features/media/services/media_service.dart` | 4 | `class MediaService {` |
| `lib/features/media/services/media_service.dart` | 5 | `MediaService(this._repository);` |
| `lib/features/media/services/media_service.dart` | 7 | `final MediaRepository _repository;` |
| `lib/features/media/services/media_service.dart` | 9 | `Stream<List<MediaItem>> watchMedia() {` |
| `lib/features/media/services/media_service.dart` | 10 | `return _repository.watchMedia();` |
| `lib/features/media/services/media_service.dart` | 13 | `Future<void> addMedia(MediaItem item) {` |
| `lib/features/media/services/media_service.dart` | 14 | `return _repository.addMedia(item);` |
| `lib/features/media/services/media_service.dart` | 17 | `Future<void> updateMedia(MediaItem item) {` |
| `lib/features/media/services/media_service.dart` | 18 | `return _repository.updateMedia(item);` |
| `lib/features/media/services/media_service.dart` | 21 | `Future<void> deleteMedia(String id) {` |
| `lib/features/media/services/media_service.dart` | 22 | `return _repository.deleteMedia(id);` |
| `lib/features/media/services/media_storage_service.dart` | 5 | `class MediaStorageService {` |
| `lib/features/media/services/media_storage_service.dart` | 8 | `Future<String> uploadMediaFile({` |
| `lib/features/media/services/media_storage_service.dart` | 11 | `required String mediaType,` |
| `lib/features/media/services/media_storage_service.dart` | 15 | `'churches/$churchId/media/$mediaType/${DateTime.now().millisecondsSinceEpoch}_$fileName';` |
| `lib/features/media/services/media_storage_service.dart` | 24 | `Future<void> deleteMediaFile(String url) async {` |
| `lib/features/web_admin/widgets/web_admin_responsive_navigation.dart` | 19 | `final width = MediaQuery.sizeOf(context).width;` |
| `lib/screens/admin/admin_church_connection_screen.dart` | 471 | `'the church website, and social media.',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 19 | `import 'admin_media_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 84 | `title: 'Media',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 86 | `value: ref.watch(mediaCountByChurchProvider(churchId)).value ?? 0,` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 149 | `title: 'Media',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 151 | `screen: AdminMediaScreen(churchId: churchId),` |
| `lib/screens/admin/admin_media_screen.dart` | 5 | `import '../../features/media/models/media_item.dart';` |
| `lib/screens/admin/admin_media_screen.dart` | 6 | `import '../../features/media/providers/media_providers.dart';` |
| `lib/screens/admin/admin_media_screen.dart` | 8 | `class AdminMediaScreen extends ConsumerWidget {` |
| `lib/screens/admin/admin_media_screen.dart` | 9 | `const AdminMediaScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_media_screen.dart` | 15 | `final mediaService = ref.read(mediaServiceByChurchProvider(churchId));` |
| `lib/screens/admin/admin_media_screen.dart` | 19 | `title: 'Media Library',` |
| `lib/screens/admin/admin_media_screen.dart` | 20 | `subtitle: 'Manage media for $churchId.',` |
| `lib/screens/admin/admin_media_screen.dart` | 26 | `builder: (_) => _MediaDialog(churchId: churchId),` |
| `lib/screens/admin/admin_media_screen.dart` | 30 | `label: const Text('Add Media'),` |
| `lib/screens/admin/admin_media_screen.dart` | 33 | `StreamBuilder<List<MediaItem>>(` |
| `lib/screens/admin/admin_media_screen.dart` | 34 | `stream: mediaService.watchMedia(),` |
| `lib/screens/admin/admin_media_screen.dart` | 44 | `child: Text('Unable to load media: ${snapshot.error}'),` |
| `lib/screens/admin/admin_media_screen.dart` | 48 | `final media = snapshot.data ?? <MediaItem>[];` |
| `lib/screens/admin/admin_media_screen.dart` | 50 | `if (media.isEmpty) {` |
| `lib/screens/admin/admin_media_screen.dart` | 52 | `child: Text('No published media uploaded yet.'),` |
| `lib/screens/admin/admin_media_screen.dart` | 57 | `children: media.map((item) {` |
| `lib/screens/admin/admin_media_screen.dart` | 58 | `final icon = switch (item.mediaType.toLowerCase()) {` |
| `lib/screens/admin/admin_media_screen.dart` | 75 | `'${item.mediaType} • ${item.category}\n'` |
| `lib/screens/admin/admin_media_screen.dart` | 94 | `class _MediaDialog extends ConsumerStatefulWidget {` |
| `lib/screens/admin/admin_media_screen.dart` | 95 | `const _MediaDialog({required this.churchId});` |
| `lib/screens/admin/admin_media_screen.dart` | 100 | `ConsumerState<_MediaDialog> createState() => _MediaDialogState();` |
| `lib/screens/admin/admin_media_screen.dart` | 103 | `class _MediaDialogState extends ConsumerState<_MediaDialog> {` |
| `lib/screens/admin/admin_media_screen.dart` | 107 | `late final TextEditingController _mediaUrlController;` |
| `lib/screens/admin/admin_media_screen.dart` | 111 | `String _mediaType = 'video';` |
| `lib/screens/admin/admin_media_screen.dart` | 125 | `_mediaUrlController = TextEditingController();` |
| `lib/screens/admin/admin_media_screen.dart` | 135 | `_mediaUrlController.dispose();` |
| `lib/screens/admin/admin_media_screen.dart` | 144 | `title: const Text('Add Media'),` |
| `lib/screens/admin/admin_media_screen.dart` | 171 | `initialValue: _mediaType,` |
| `lib/screens/admin/admin_media_screen.dart` | 172 | `decoration: const InputDecoration(labelText: 'Media Type'),` |
| `lib/screens/admin/admin_media_screen.dart` | 191 | `_mediaType = value;` |
| `lib/screens/admin/admin_media_screen.dart` | 229 | `controller: _mediaUrlController,` |
| `lib/screens/admin/admin_media_screen.dart` | 233 | `labelText: 'Media URL',` |
| `lib/screens/admin/admin_media_screen.dart` | 302 | `onPressed: _saving ? null : _saveMedia,` |
| `lib/screens/admin/admin_media_screen.dart` | 316 | `Future<void> _saveMedia() async {` |
| `lib/screens/admin/admin_media_screen.dart` | 321 | `_errorMessage = 'Enter a media title.';` |
| `lib/screens/admin/admin_media_screen.dart` | 332 | `final service = ref.read(mediaServiceByChurchProvider(widget.churchId));` |
| `lib/screens/admin/admin_media_screen.dart` | 334 | `await service.addMedia(` |
| `lib/screens/admin/admin_media_screen.dart` | 335 | `MediaItem(` |
| `lib/screens/admin/admin_media_screen.dart` | 339 | `mediaType: _mediaType,` |
| `lib/screens/admin/admin_media_screen.dart` | 341 | `mediaUrl: _mediaUrlController.text.trim(),` |
| `lib/screens/admin/admin_media_screen.dart` | 355 | `debugPrint('Media saving failed: $error');` |
| `lib/screens/admin/admin_media_screen.dart` | 364 | `_errorMessage = 'Unable to save media: $error';` |
| `lib/screens/admin/admin_notifications_screen.dart` | 328 | `DropdownMenuItem(value: 'media', child: Text('Media')),` |
| `lib/screens/admin/admin_notifications_screen.dart` | 409 | `'This will immediately queue "$title" for:\n\n$audience',` |
| `lib/screens/admin/admin_resources_screen.dart` | 385 | `title: const Text('Publish immediately'),` |
| `lib/screens/home/churchsnap_shell.dart` | 12 | `import '../media/media_screen.dart';` |
| `lib/screens/home/churchsnap_shell.dart` | 84 | `MediaScreen(churchId: _churchId),` |
| `lib/screens/home/churchsnap_shell.dart` | 120 | `label: 'Media',` |
| `lib/screens/media/media_detail_screen.dart` | 5 | `import '../../features/media/models/media_item.dart';` |
| `lib/screens/media/media_detail_screen.dart` | 7 | `class MediaDetailScreen extends StatelessWidget {` |
| `lib/screens/media/media_detail_screen.dart` | 8 | `final MediaItem item;` |
| `lib/screens/media/media_detail_screen.dart` | 10 | `const MediaDetailScreen({super.key, required this.item});` |
| `lib/screens/media/media_detail_screen.dart` | 12 | `Future<void> _openMedia(BuildContext context) async {` |
| `lib/screens/media/media_detail_screen.dart` | 13 | `final rawUrl = item.mediaUrl.trim();` |
| `lib/screens/media/media_detail_screen.dart` | 16 | `_showMessage(context, 'No media URL was saved for this item.');` |
| `lib/screens/media/media_detail_screen.dart` | 23 | `'This media uses a Firebase Storage gs:// address. '` |
| `lib/screens/media/media_detail_screen.dart` | 34 | `_showMessage(context, 'The saved media URL is invalid.');` |
| `lib/screens/media/media_detail_screen.dart` | 46 | `_showMessage(context, 'The media URL must begin with https://');` |
| `lib/screens/media/media_detail_screen.dart` | 58 | `_showMessage(context, 'ChurchSnap could not open this media URL.');` |
| `lib/screens/media/media_detail_screen.dart` | 61 | `debugPrint('Media launch failed: $error');` |
| `lib/screens/media/media_detail_screen.dart` | 64 | `_showMessage(context, 'Unable to open media: $error');` |
| `lib/screens/media/media_detail_screen.dart` | 78 | `final icon = switch (item.mediaType.toLowerCase()) {` |
| `lib/screens/media/media_detail_screen.dart` | 118 | `onPressed: () => _openMedia(context),` |
| `lib/screens/media/media_detail_screen.dart` | 121 | `item.mediaType.toLowerCase() == 'pdf'` |
| `lib/screens/media/media_detail_screen.dart` | 123 | `: 'Play Media',` |
| `lib/screens/media/media_screen.dart` | 5 | `import '../../features/media/models/media_item.dart';` |
| `lib/screens/media/media_screen.dart` | 6 | `import '../../features/media/providers/media_providers.dart';` |
| `lib/screens/media/media_screen.dart` | 7 | `import 'media_detail_screen.dart';` |
| `lib/screens/media/media_screen.dart` | 9 | `class MediaScreen extends ConsumerWidget {` |
| `lib/screens/media/media_screen.dart` | 10 | `const MediaScreen({super.key, required this.churchId});` |
| `lib/screens/media/media_screen.dart` | 16 | `final mediaService = ref.read(mediaServiceByChurchProvider(churchId));` |
| `lib/screens/media/media_screen.dart` | 19 | `title: 'Media',` |
| `lib/screens/media/media_screen.dart` | 22 | `StreamBuilder<List<MediaItem>>(` |
| `lib/screens/media/media_screen.dart` | 23 | `stream: mediaService.watchMedia(),` |
| `lib/screens/media/media_screen.dart` | 35 | `final media = (snapshot.data ?? [])` |
| `lib/screens/media/media_screen.dart` | 39 | `if (media.isEmpty) {` |
| `lib/screens/media/media_screen.dart` | 40 | `return const AppCard(child: Text('No media available yet.'));` |
| `lib/screens/media/media_screen.dart` | 43 | `final featured = media` |
| `lib/screens/media/media_screen.dart` | 53 | `...featured.map((item) => _MediaCard(item: item)),` |
| `lib/screens/media/media_screen.dart` | 56 | `...media.map((item) => _MediaCard(item: item)),` |
| `lib/screens/media/media_screen.dart` | 66 | `class _MediaCard extends StatelessWidget {` |
| `lib/screens/media/media_screen.dart` | 67 | `final MediaItem item;` |
| `lib/screens/media/media_screen.dart` | 69 | `const _MediaCard({required this.item});` |
| `lib/screens/media/media_screen.dart` | 73 | `final icon = switch (item.mediaType.toLowerCase()) {` |
| `lib/screens/media/media_screen.dart` | 95 | `MaterialPageRoute(builder: (_) => MediaDetailScreen(item: item)),` |
| `lib/screens/prayer/prayer_screen.dart` | 143 | `MediaQuery.of(context).viewInsets.bottom + 28,` |
| `lib/screens/profile/profile_screen.dart` | 320 | `'You can view published sermons, media, events, prayer updates, '` |
| `lib/screens/sermons/sermon_detail_screen.dart` | 189 | `title: Text('Media not available'),` |
| `firestore.rules` | 447 | `match /media/{mediaId} {` |

## sermons

| File | Line | Source |
| --- | ---: | --- |
| `lib/core/demo/demo_data.dart` | 10 | `static const sermons = [` |
| `lib/core/providers/repository_providers.dart` | 1 | `import '../../features/sermons/repositories/sermon_repository.dart';` |
| `lib/features/auth/screens/guest_account_screen.dart` | 26 | `'Published sermons, media, announcements, events, and giving '` |
| `lib/features/sermons/providers/sermon_providers.dart` | 13 | `final sermonServiceProvider = Provider<SermonService>((ref) {` |
| `lib/features/sermons/providers/sermon_providers.dart` | 14 | `return SermonService(ref.watch(sermonRepositoryProvider));` |
| `lib/features/sermons/providers/sermon_providers.dart` | 17 | `final sermonsProvider = StreamProvider<List<Sermon>>((ref) {` |
| `lib/features/sermons/providers/sermon_providers.dart` | 18 | `return ref.watch(sermonServiceProvider).watchPublishedSermons();` |
| `lib/features/sermons/providers/sermon_providers.dart` | 21 | `final adminSermonsProvider = StreamProvider<List<Sermon>>((ref) {` |
| `lib/features/sermons/providers/sermon_providers.dart` | 22 | `return ref.watch(sermonServiceProvider).watchAllSermons();` |
| `lib/features/sermons/providers/sermon_providers.dart` | 30 | `final sermonServiceByChurchProvider = Provider.family<SermonService, String>((` |
| `lib/features/sermons/providers/sermon_providers.dart` | 34 | `return SermonService(ref.watch(sermonRepositoryByChurchProvider(churchId)));` |
| `lib/features/sermons/providers/sermon_providers.dart` | 37 | `final sermonsByChurchProvider = StreamProvider.family<List<Sermon>, String>((` |
| `lib/features/sermons/providers/sermon_providers.dart` | 42 | `.watch(sermonServiceByChurchProvider(churchId))` |
| `lib/features/sermons/providers/sermon_providers.dart` | 43 | `.watchPublishedSermons();` |
| `lib/features/sermons/providers/sermon_providers.dart` | 46 | `final adminSermonsByChurchProvider =` |
| `lib/features/sermons/providers/sermon_providers.dart` | 49 | `.watch(sermonServiceByChurchProvider(churchId))` |
| `lib/features/sermons/providers/sermon_providers.dart` | 50 | `.watchAllSermons();` |
| `lib/features/sermons/repositories/sermon_bookmark_repository.dart` | 52 | `throw StateError('Sign in to save sermons.');` |
| `lib/features/sermons/repositories/sermon_bookmark_repository.dart` | 72 | `throw StateError('Sign in to manage saved sermons.');` |
| `lib/features/sermons/repositories/sermon_download_repository.dart` | 13 | `'${appDirectory.path}${Platform.pathSeparator}sermons',` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 14 | `collectionPath: FirebasePaths.sermons(churchId),` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 23 | `_firestore.collection(FirebasePaths.sermons(churchId));` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 25 | `Stream<List<Sermon>> watchPublishedSermons() {` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 32 | `Stream<List<Sermon>> watchAllSermons() {` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 34 | `final sermons = snapshot.docs.map((document) {` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 38 | `sermons.sort((first, second) {` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 51 | `return sermons;` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 92 | `final featuredSermons = await _collection` |
| `lib/features/sermons/repositories/sermon_repository.dart` | 98 | `for (final document in featuredSermons.docs) {` |
| `lib/features/sermons/services/sermon_service.dart` | 4 | `class SermonService {` |
| `lib/features/sermons/services/sermon_service.dart` | 5 | `SermonService(this._repository);` |
| `lib/features/sermons/services/sermon_service.dart` | 9 | `Stream<List<Sermon>> watchPublishedSermons() {` |
| `lib/features/sermons/services/sermon_service.dart` | 10 | `return _repository.watchPublishedSermons();` |
| `lib/features/sermons/services/sermon_service.dart` | 13 | `Stream<List<Sermon>> watchAllSermons() {` |
| `lib/features/sermons/services/sermon_service.dart` | 14 | `return _repository.watchAllSermons();` |
| `lib/firebase/firebase_collection_names.dart` | 4 | `static const sermons = 'sermons';` |
| `lib/firebase/firebase_paths.dart` | 8 | `static String sermons(String churchId) =>` |
| `lib/firebase/firebase_paths.dart` | 9 | `'${church(churchId)}/${FirebaseCollectionNames.sermons}';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 26 | `import 'admin_sermons_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 142 | `title: 'Sermons',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 143 | `subtitle: 'Publish and manage church sermons',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 144 | `screen: AdminSermonsScreen(churchId: churchId),` |
| `lib/screens/admin/admin_media_screen.dart` | 112 | `String _category = 'Sermons';` |
| `lib/screens/admin/admin_media_screen.dart` | 201 | `DropdownMenuItem(value: 'Sermons', child: Text('Sermons')),` |
| `lib/screens/admin/admin_sermons_screen.dart` | 6 | `import '../../features/sermons/providers/sermon_providers.dart';` |
| `lib/screens/admin/admin_sermons_screen.dart` | 9 | `class AdminSermonsScreen extends ConsumerWidget {` |
| `lib/screens/admin/admin_sermons_screen.dart` | 10 | `const AdminSermonsScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_sermons_screen.dart` | 16 | `final sermonsAsync = ref.watch(adminSermonsByChurchProvider(churchId));` |
| `lib/screens/admin/admin_sermons_screen.dart` | 20 | `title: 'Manage Sermons',` |
| `lib/screens/admin/admin_sermons_screen.dart` | 21 | `subtitle: 'Publish and organize church sermons.',` |
| `lib/screens/admin/admin_sermons_screen.dart` | 32 | `sermonsAsync.when(` |
| `lib/screens/admin/admin_sermons_screen.dart` | 39 | `title: const Text('Unable to load sermons'),` |
| `lib/screens/admin/admin_sermons_screen.dart` | 43 | `data: (sermons) {` |
| `lib/screens/admin/admin_sermons_screen.dart` | 44 | `if (sermons.isEmpty) {` |
| `lib/screens/admin/admin_sermons_screen.dart` | 48 | `title: Text('No sermons have been added'),` |
| `lib/screens/admin/admin_sermons_screen.dart` | 57 | `children: sermons.map((sermon) {` |
| `lib/screens/admin/admin_sermons_screen.dart` | 211 | `.read(sermonServiceByChurchProvider(churchId))` |
| `lib/screens/admin/admin_sermons_screen.dart` | 241 | `.read(sermonServiceByChurchProvider(churchId))` |
| `lib/screens/admin/admin_sermons_screen.dart` | 300 | `.read(sermonServiceByChurchProvider(churchId))` |
| `lib/screens/admin/admin_sermons_screen.dart` | 487 | `'Published sermons are visible to members.',` |
| `lib/screens/admin/admin_sermons_screen.dart` | 579 | `final service = ref.read(sermonServiceByChurchProvider(widget.churchId));` |
| `lib/screens/home/churchsnap_shell.dart` | 15 | `import '../sermons/sermons_screen.dart';` |
| `lib/screens/home/churchsnap_shell.dart` | 83 | `SermonsScreen(churchId: _churchId),` |
| `lib/screens/home/churchsnap_shell.dart` | 115 | `label: 'Sermons',` |
| `lib/screens/home/churchsnap_shell.dart` | 116 | `assetName: 'sermons',` |
| `lib/screens/home/home_screen.dart` | 12 | `import '../../features/sermons/providers/sermon_providers.dart';` |
| `lib/screens/home/home_screen.dart` | 17 | `import '../sermons/sermon_detail_screen.dart';` |
| `lib/screens/home/home_screen.dart` | 96 | `onSermons: () => onSelectTab(1),` |
| `lib/screens/home/home_screen.dart` | 586 | `required this.onSermons,` |
| `lib/screens/home/home_screen.dart` | 592 | `final VoidCallback onSermons;` |
| `lib/screens/home/home_screen.dart` | 600 | `_HomeAction(label: 'Sermons', assetName: 'sermons', onTap: onSermons),` |
| `lib/screens/home/home_screen.dart` | 1035 | `final sermonsAsync = ref.watch(sermonsByChurchProvider(churchId));` |
| `lib/screens/home/home_screen.dart` | 1042 | `sermonsAsync.when(` |
| `lib/screens/home/home_screen.dart` | 1046 | `title: 'Unable to load sermons',` |
| `lib/screens/home/home_screen.dart` | 1049 | `data: (sermons) {` |
| `lib/screens/home/home_screen.dart` | 1050 | `if (sermons.isEmpty) {` |
| `lib/screens/home/home_screen.dart` | 1054 | `subtitle: 'Published sermons will appear here.',` |
| `lib/screens/home/home_screen.dart` | 1058 | `final sermon = sermons.firstWhere(` |
| `lib/screens/home/home_screen.dart` | 1060 | `orElse: () => sermons.first,` |
| `lib/screens/home/home_screen.dart` | 1115 | `'assets/icons/sermons.png',` |
| `lib/screens/profile/profile_screen.dart` | 320 | `'You can view published sermons, media, events, prayer updates, '` |
| `lib/screens/sermons/sermons_screen.dart` | 5 | `import '../../features/sermons/providers/sermon_providers.dart';` |
| `lib/screens/sermons/sermons_screen.dart` | 9 | `class SermonsScreen extends ConsumerStatefulWidget {` |
| `lib/screens/sermons/sermons_screen.dart` | 10 | `const SermonsScreen({super.key, required this.churchId});` |
| `lib/screens/sermons/sermons_screen.dart` | 15 | `ConsumerState<SermonsScreen> createState() => _SermonsScreenState();` |
| `lib/screens/sermons/sermons_screen.dart` | 18 | `class _SermonsScreenState extends ConsumerState<SermonsScreen> {` |
| `lib/screens/sermons/sermons_screen.dart` | 30 | `final sermonsAsync = ref.watch(sermonsByChurchProvider(widget.churchId));` |
| `lib/screens/sermons/sermons_screen.dart` | 40 | `title: 'Sermons',` |
| `lib/screens/sermons/sermons_screen.dart` | 47 | `labelText: 'Search sermons',` |
| `lib/screens/sermons/sermons_screen.dart` | 72 | `sermonsAsync.when(` |
| `lib/screens/sermons/sermons_screen.dart` | 78 | `title: const Text('Unable to load sermons'),` |
| `lib/screens/sermons/sermons_screen.dart` | 82 | `data: (sermons) {` |
| `lib/screens/sermons/sermons_screen.dart` | 83 | `final publishedSermons =` |
| `lib/screens/sermons/sermons_screen.dart` | 84 | `sermons.where((sermon) => sermon.published).toList()` |
| `lib/screens/sermons/sermons_screen.dart` | 97 | `final filteredSermons = publishedSermons.where((sermon) {` |
| `lib/screens/sermons/sermons_screen.dart` | 110 | `if (publishedSermons.isEmpty) {` |
| `lib/screens/sermons/sermons_screen.dart` | 114 | `title: Text('No sermons available yet'),` |
| `lib/screens/sermons/sermons_screen.dart` | 115 | `subtitle: Text('Published sermons will appear here.'),` |
| `lib/screens/sermons/sermons_screen.dart` | 120 | `if (filteredSermons.isEmpty) {` |
| `lib/screens/sermons/sermons_screen.dart` | 124 | `title: Text('No matching sermons'),` |
| `lib/screens/sermons/sermons_screen.dart` | 132 | `final featuredSermon = filteredSermons.firstWhere(` |
| `lib/screens/sermons/sermons_screen.dart` | 134 | `orElse: () => filteredSermons.first,` |
| `lib/screens/sermons/sermons_screen.dart` | 145 | `const SectionTitle(title: 'Recent Sermons'),` |
| `lib/screens/sermons/sermons_screen.dart` | 146 | `...filteredSermons.map((sermon) {` |
| `lib/screens/sermons/sermon_detail_screen.dart` | 8 | `import '../../features/sermons/providers/sermon_providers.dart';` |
| `firestore.rules` | 432 | `match /sermons/{sermonId} {` |

## announcements

| File | Line | Source |
| --- | ---: | --- |
| `lib/core/demo/demo_data.dart` | 59 | `static const announcements = [` |
| `lib/core/providers/repository_providers.dart` | 4 | `import '../../features/announcements/repositories/announcement_repository.dart';` |
| `lib/features/admin/providers/admin_providers.dart` | 3 | `import '../../announcements/repositories/announcement_repository.dart';` |
| `lib/features/admin/providers/admin_providers.dart` | 8 | `final adminAnnouncementServiceProvider = Provider<AdminAnnouncementService>((` |
| `lib/features/admin/providers/admin_providers.dart` | 11 | `return AdminAnnouncementService(AnnouncementRepository());` |
| `lib/features/admin/providers/admin_providers.dart` | 14 | `final adminAnnouncementServiceByChurchProvider =` |
| `lib/features/admin/providers/admin_providers.dart` | 15 | `Provider.family<AdminAnnouncementService, String>((ref, churchId) {` |
| `lib/features/admin/providers/admin_providers.dart` | 16 | `return AdminAnnouncementService(` |
| `lib/features/admin/services/admin_announcement_service.dart` | 2 | `import '../../announcements/repositories/announcement_repository.dart';` |
| `lib/features/admin/services/admin_announcement_service.dart` | 4 | `class AdminAnnouncementService {` |
| `lib/features/admin/services/admin_announcement_service.dart` | 5 | `AdminAnnouncementService(this._repository);` |
| `lib/features/announcements/providers/announcement_providers.dart` | 7 | `final announcementsProvider = StreamProvider<List<Announcement>>((ref) {` |
| `lib/features/announcements/providers/announcement_providers.dart` | 9 | `return repository.watchPublishedAnnouncements();` |
| `lib/features/announcements/providers/announcement_providers.dart` | 17 | `final announcementsByChurchProvider =` |
| `lib/features/announcements/providers/announcement_providers.dart` | 23 | `return repository.watchPublishedAnnouncements();` |
| `lib/features/announcements/repositories/announcement_repository.dart` | 14 | `collectionPath: FirebasePaths.announcements(churchId),` |
| `lib/features/announcements/repositories/announcement_repository.dart` | 23 | `_firestore.collection(FirebasePaths.announcements(churchId));` |
| `lib/features/announcements/repositories/announcement_repository.dart` | 25 | `Stream<List<Announcement>> watchPublishedAnnouncements() {` |
| `lib/features/auth/screens/guest_account_screen.dart` | 26 | `'Published sermons, media, announcements, events, and giving '` |
| `lib/firebase/firebase_collection_names.dart` | 7 | `static const announcements = 'announcements';` |
| `lib/firebase/firebase_paths.dart` | 14 | `static String announcements(String churchId) =>` |
| `lib/firebase/firebase_paths.dart` | 15 | `'${church(churchId)}/${FirebaseCollectionNames.announcements}';` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 6 | `import '../../features/announcements/providers/announcement_providers.dart';` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 10 | `class AdminAnnouncementsListScreen extends ConsumerWidget {` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 11 | `const AdminAnnouncementsListScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 17 | `final announcementsAsync = ref.watch(` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 18 | `announcementsByChurchProvider(churchId),` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 22 | `title: 'Announcements',` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 23 | `subtitle: 'Manage published announcements for $churchId.',` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 25 | `announcementsAsync.when(` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 29 | `const AppCard(child: Text('Unable to load announcements.')),` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 30 | `data: (announcements) {` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 31 | `if (announcements.isEmpty) {` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 32 | `return const AppCard(child: Text('No announcements yet.'));` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 36 | `children: announcements.map((announcement) {` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 139 | `.read(adminAnnouncementServiceByChurchProvider(churchId))` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 163 | `.read(adminAnnouncementServiceByChurchProvider(churchId))` |
| `lib/screens/admin/admin_announcements_screen.dart` | 6 | `import 'admin_announcements_list_screen.dart';` |
| `lib/screens/admin/admin_announcements_screen.dart` | 8 | `class AdminAnnouncementsScreen extends ConsumerStatefulWidget {` |
| `lib/screens/admin/admin_announcements_screen.dart` | 9 | `const AdminAnnouncementsScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_announcements_screen.dart` | 14 | `ConsumerState<AdminAnnouncementsScreen> createState() =>` |
| `lib/screens/admin/admin_announcements_screen.dart` | 15 | `_AdminAnnouncementsScreenState();` |
| `lib/screens/admin/admin_announcements_screen.dart` | 18 | `class _AdminAnnouncementsScreenState` |
| `lib/screens/admin/admin_announcements_screen.dart` | 19 | `extends ConsumerState<AdminAnnouncementsScreen> {` |
| `lib/screens/admin/admin_announcements_screen.dart` | 39 | `title: 'Announcements',` |
| `lib/screens/admin/admin_announcements_screen.dart` | 40 | `subtitle: 'Publish announcements for ${widget.churchId}.',` |
| `lib/screens/admin/admin_announcements_screen.dart` | 129 | `builder: (_) => AdminAnnouncementsListScreen(` |
| `lib/screens/admin/admin_announcements_screen.dart` | 136 | `label: const Text('Manage Existing Announcements'),` |
| `lib/screens/admin/admin_announcements_screen.dart` | 164 | `adminAnnouncementServiceByChurchProvider(widget.churchId),` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 5 | `import 'admin_announcements_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 130 | `title: 'Announcements',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 131 | `subtitle: 'Publish church announcements',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 132 | `screen: AdminAnnouncementsScreen(churchId: churchId),` |
| `lib/screens/home/home_screen.dart` | 7 | `import '../../features/announcements/providers/announcement_providers.dart';` |
| `lib/screens/home/home_screen.dart` | 48 | `final announcementsAsync = ref.watch(` |
| `lib/screens/home/home_screen.dart` | 49 | `announcementsByChurchProvider(churchId),` |
| `lib/screens/home/home_screen.dart` | 52 | `final announcementCount = announcementsAsync.maybeWhen(` |
| `lib/screens/home/home_screen.dart` | 53 | `data: (announcements) => announcements.length,` |
| `lib/screens/home/home_screen.dart` | 73 | `_showAnnouncements(context, churchId);` |
| `lib/screens/home/home_screen.dart` | 122 | `_showAnnouncements(context, churchId);` |
| `lib/screens/home/home_screen.dart` | 131 | `void _showAnnouncements(BuildContext context, String churchId) {` |
| `lib/screens/home/home_screen.dart` | 137 | `return _AnnouncementsSheet(churchId: churchId);` |
| `lib/screens/home/home_screen.dart` | 1261 | `final announcementsAsync = ref.watch(` |
| `lib/screens/home/home_screen.dart` | 1262 | `announcementsByChurchProvider(churchId),` |
| `lib/screens/home/home_screen.dart` | 1274 | `announcementsAsync.when(` |
| `lib/screens/home/home_screen.dart` | 1281 | `data: (announcements) {` |
| `lib/screens/home/home_screen.dart` | 1282 | `if (announcements.isEmpty) {` |
| `lib/screens/home/home_screen.dart` | 1286 | `subtitle: 'New announcements will appear here.',` |
| `lib/screens/home/home_screen.dart` | 1320 | `announcements.first.title,` |
| `lib/screens/home/home_screen.dart` | 1329 | `announcements.first.message,` |
| `lib/screens/home/home_screen.dart` | 1487 | `class _AnnouncementsSheet extends ConsumerWidget {` |
| `lib/screens/home/home_screen.dart` | 1488 | `const _AnnouncementsSheet({required this.churchId});` |
| `lib/screens/home/home_screen.dart` | 1494 | `final announcementsAsync = ref.watch(` |
| `lib/screens/home/home_screen.dart` | 1495 | `announcementsByChurchProvider(churchId),` |
| `lib/screens/home/home_screen.dart` | 1541 | `child: announcementsAsync.when(` |
| `lib/screens/home/home_screen.dart` | 1553 | `data: (announcements) {` |
| `lib/screens/home/home_screen.dart` | 1554 | `if (announcements.isEmpty) {` |
| `lib/screens/home/home_screen.dart` | 1562 | `itemCount: announcements.length,` |
| `lib/screens/home/home_screen.dart` | 1567 | `return _AnnouncementSheetCard(` |
| `lib/screens/home/home_screen.dart` | 1568 | `announcement: announcements[index],` |
| `lib/screens/home/home_screen.dart` | 1583 | `class _AnnouncementSheetCard extends StatelessWidget {` |
| `lib/screens/home/home_screen.dart` | 1584 | `const _AnnouncementSheetCard({required this.announcement});` |
| `lib/screens/profile/profile_screen.dart` | 321 | `'announcements, and giving information. Member records, RSVP, '` |
| `firestore.rules` | 382 | `match /announcements/{announcementId} {` |

## admin_audit_logs

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/web_admin/services/web_admin_audit_log_service.dart` | 22 | `.collection('admin_audit_logs')` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 28 | `.collection('admin_audit_logs');` |
| `firestore.rules` | 774 | `match /admin_audit_logs/{auditId} {` |

## memberPrivateProfiles

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/members/repositories/member_baptism_repository.dart` | 22 | `.collection('memberPrivateProfiles');` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 22 | `.collection('memberPrivateProfiles');` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 22 | `.collection('memberPrivateProfiles');` |
| `lib/features/members/repositories/member_repository.dart` | 21 | `.collection('memberPrivateProfiles');` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 37 | `.collection('memberPrivateProfiles')` |
| `firestore.rules` | 312 | `match /memberPrivateProfiles/{memberId} {` |

## members

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/attendance/services/qr_check_in_service.dart` | 49 | `final memberRef = _churchRef.collection('members').doc(cleanMemberId);` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 50 | `final memberSnapshot = await memberRef.get();` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 52 | `if (!memberSnapshot.exists) {` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 59 | `final memberData = memberSnapshot.data() ?? <String, dynamic>{};` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 343 | `.collection(FirebasePaths.members(churchId))` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 402 | `final defaultMemberSnapshot = await _firestore` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 403 | `.collection(FirebasePaths.members(defaultChurchId))` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 407 | `if (defaultMemberSnapshot.exists) {` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 445 | `.collection(FirebasePaths.members(user.churchId))` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 448 | `final memberSnapshot = await memberReference.get();` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 449 | `final existingData = memberSnapshot.data();` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 451 | `final savedRole = memberSnapshot.exists` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 455 | `final savedIsActive = memberSnapshot.exists` |
| `lib/features/auth/screens/auth_gate.dart` | 83 | `child: LiveMemberSession(` |
| `lib/features/auth/screens/live_member_session.dart` | 11 | `class LiveMemberSession extends StatefulWidget {` |
| `lib/features/auth/screens/live_member_session.dart` | 12 | `const LiveMemberSession({` |
| `lib/features/auth/screens/live_member_session.dart` | 26 | `State<LiveMemberSession> createState() => _LiveMemberSessionState();` |
| `lib/features/auth/screens/live_member_session.dart` | 29 | `class _LiveMemberSessionState extends State<LiveMemberSession> {` |
| `lib/features/auth/screens/live_member_session.dart` | 31 | `_memberSubscription;` |
| `lib/features/auth/screens/live_member_session.dart` | 43 | `void didUpdateWidget(covariant LiveMemberSession oldWidget) {` |
| `lib/features/auth/screens/live_member_session.dart` | 48 | `_memberSubscription?.cancel();` |
| `lib/features/auth/screens/live_member_session.dart` | 57 | `_memberSubscription?.cancel();` |
| `lib/features/auth/screens/live_member_session.dart` | 71 | `_memberSubscription = FirebaseFirestore.instance` |
| `lib/features/auth/screens/live_member_session.dart` | 74 | `.collection('members')` |
| `lib/features/auth/screens/live_member_session.dart` | 122 | `'ChurchSnap could not refresh your membership access. '` |
| `lib/features/auth/services/required_name_service.dart` | 40 | `.collection('members')` |
| `lib/features/dashboard/repositories/dashboard_repository.dart` | 3 | `import '../../members/models/member_count_summary.dart';` |
| `lib/features/dashboard/repositories/dashboard_repository.dart` | 19 | `.collection('members')` |
| `lib/features/giving/repositories/giving_repository.dart` | 113 | `// Members and visitors may read funds but cannot migrate them.` |
| `lib/features/members/models/member_demographics_summary.dart` | 10 | `required this.totalMembers,` |
| `lib/features/members/models/member_demographics_summary.dart` | 27 | `totalMembers: 0,` |
| `lib/features/members/models/member_demographics_summary.dart` | 63 | `final int totalMembers;` |
| `lib/features/members/models/member_demographics_summary.dart` | 79 | `if (totalMembers == 0) {` |
| `lib/features/members/models/member_demographics_summary.dart` | 83 | `return completeProfiles / totalMembers;` |
| `lib/features/members/models/member_demographics_summary.dart` | 113 | `required Map<String, Map<String, dynamic>> members,` |
| `lib/features/members/models/member_demographics_summary.dart` | 119 | `var totalMembers = 0;` |
| `lib/features/members/models/member_demographics_summary.dart` | 157 | `for (final entry in members.entries) {` |
| `lib/features/members/models/member_demographics_summary.dart` | 171 | `totalMembers += 1;` |
| `lib/features/members/models/member_demographics_summary.dart` | 237 | `totalMembers: totalMembers,` |
| `lib/features/members/models/member_profile_details.dart` | 14 | `this.membershipDate,` |
| `lib/features/members/models/member_profile_details.dart` | 32 | `final DateTime? membershipDate;` |
| `lib/features/members/models/member_profile_details.dart` | 77 | `membershipDate: _dateValue(map['membershipDate']),` |
| `lib/features/members/models/member_profile_details.dart` | 96 | `'membershipDate': _timestampValue(membershipDate),` |
| `lib/features/members/models/member_profile_details.dart` | 114 | `DateTime? membershipDate,` |
| `lib/features/members/models/member_profile_details.dart` | 130 | `membershipDate: membershipDate ?? this.membershipDate,` |
| `lib/features/members/models/member_self_profile.dart` | 4 | `class MemberSelfProfileSnapshot {` |
| `lib/features/members/models/member_self_profile.dart` | 5 | `const MemberSelfProfileSnapshot({` |
| `lib/features/members/models/member_self_profile.dart` | 25 | `factory MemberSelfProfileSnapshot.fromMaps({` |
| `lib/features/members/models/member_self_profile.dart` | 50 | `return MemberSelfProfileSnapshot(` |
| `lib/features/members/models/member_self_profile.dart` | 70 | `membershipDate: privateDetails.membershipDate,` |
| `lib/features/members/models/member_self_profile.dart` | 92 | `class MemberSelfProfileDraft {` |
| `lib/features/members/models/member_self_profile.dart` | 93 | `const MemberSelfProfileDraft({` |
| `lib/features/members/providers/member_providers.dart` | 10 | `final memberServiceProvider = Provider<MemberService>(` |
| `lib/features/members/providers/member_providers.dart` | 11 | `(ref) => MemberService(ref.read(memberRepositoryProvider)),` |
| `lib/features/members/providers/member_providers.dart` | 19 | `final memberServiceByChurchProvider = Provider.family<MemberService, String>((` |
| `lib/features/members/providers/member_providers.dart` | 23 | `return MemberService(ref.read(memberRepositoryByChurchProvider(churchId)));` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 16 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 17 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 26 | `StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSubscription;` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 30 | `var members = <String, Map<String, dynamic>>{};` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 32 | `var hasMembersSnapshot = false;` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 37 | `!hasMembersSnapshot \|\|` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 42 | `final records = members.entries` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 71 | `memberSubscription = _members.snapshots().listen((snapshot) {` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 72 | `members = <String, Map<String, dynamic>>{` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 75 | `hasMembersSnapshot = true;` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 90 | `await memberSubscription?.cancel();` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 16 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 17 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 26 | `StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSubscription;` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 30 | `var members = <String, Map<String, dynamic>>{};` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 32 | `var hasMembersSnapshot = false;` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 37 | `!hasMembersSnapshot \|\|` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 42 | `final profiles = members.entries` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 65 | `memberSubscription = _members.snapshots().listen((snapshot) {` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 66 | `members = <String, Map<String, dynamic>>{` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 69 | `hasMembersSnapshot = true;` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 84 | `await memberSubscription?.cancel();` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 14 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 15 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 18 | `return _members.snapshots().map(MemberCountSummary.fromSnapshot);` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 22 | `final snapshot = await _members.get();` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 16 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 17 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 26 | `StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSubscription;` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 30 | `var members = <String, Map<String, dynamic>>{};` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 32 | `var hasMembersSnapshot = false;` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 37 | `!hasMembersSnapshot \|\|` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 44 | `members: members,` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 52 | `memberSubscription = _members.snapshots().listen((snapshot) {` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 53 | `members = <String, Map<String, dynamic>>{` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 56 | `hasMembersSnapshot = true;` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 71 | `await memberSubscription?.cancel();` |
| `lib/features/members/repositories/member_directory_repository.dart` | 18 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_directory_repository.dart` | 19 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_directory_repository.dart` | 22 | `return _members.snapshots().map((snapshot) {` |
| `lib/features/members/repositories/member_directory_repository.dart` | 94 | `final reference = _members.doc(normalizedMemberId);` |
| `lib/features/members/repositories/member_repository.dart` | 15 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_repository.dart` | 16 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_repository.dart` | 23 | `Stream<List<ChurchMember>> watchMembers() {` |
| `lib/features/members/repositories/member_repository.dart` | 24 | `return _members.snapshots().map((snapshot) {` |
| `lib/features/members/repositories/member_repository.dart` | 25 | `final members = snapshot.docs` |
| `lib/features/members/repositories/member_repository.dart` | 29 | `members.sort(` |
| `lib/features/members/repositories/member_repository.dart` | 35 | `return members;` |
| `lib/features/members/repositories/member_repository.dart` | 58 | `return _members.doc(member.id).set(member.toMap());` |
| `lib/features/members/repositories/member_repository.dart` | 62 | `return _members.doc(member.id).update(member.toMap());` |
| `lib/features/members/repositories/member_repository.dart` | 93 | `batch.update(_members.doc(cleanMemberId), member.toMap());` |
| `lib/features/members/repositories/member_repository.dart` | 112 | `batch.delete(_members.doc(cleanMemberId));` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 9 | `class MemberSelfProfileRepository {` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 10 | `MemberSelfProfileRepository({` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 31 | `.collection('members')` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 40 | `Future<MemberSelfProfileSnapshot> load() async {` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 43 | `final memberSnapshot = await _memberReference.get();` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 45 | `if (!memberSnapshot.exists \|\| memberSnapshot.data() == null) {` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 53 | `return MemberSelfProfileSnapshot.fromMaps(` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 54 | `memberData: memberSnapshot.data()!,` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 60 | `required MemberSelfProfileDraft draft,` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 72 | `final memberSnapshot = await _memberReference.get();` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 74 | `if (!memberSnapshot.exists) {` |
| `lib/features/members/services/member_service.dart` | 5 | `class MemberService {` |
| `lib/features/members/services/member_service.dart` | 6 | `MemberService(this._repository);` |
| `lib/features/members/services/member_service.dart` | 10 | `Stream<List<ChurchMember>> watchMembers() {` |
| `lib/features/members/services/member_service.dart` | 11 | `return _repository.watchMembers();` |
| `lib/features/notifications/models/app_notification.dart` | 44 | `return 'All active members';` |
| `lib/features/notifications/services/notification_service.dart` | 142 | `.collection('members')` |
| `lib/features/sermons/repositories/sermon_bookmark_repository.dart` | 28 | `.collection('members')` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 26 | `required this.totalMembers,` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 27 | `required this.activeMembers,` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 34 | `required this.membersByRole,` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 39 | `final int totalMembers;` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 40 | `final int activeMembers;` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 47 | `final Map<String, int> membersByRole;` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 42 | `onOpenMembers: () => _selectPage(1),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 53 | `onOpenMembers: () => _selectPage(1),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 134 | `label: Text('Members'),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 183 | `label: 'Members',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 299 | `required this.onOpenMembers,` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 306 | `final VoidCallback onOpenMembers;` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 328 | `label: 'Members',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 330 | `stream: church.collection('members').snapshots(),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 331 | `onTap: onOpenMembers,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 13 | `required this.onOpenMembers,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 20 | `final VoidCallback onOpenMembers;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 35 | `List<WebAdminActionSource> _members = const [];` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 40 | `bool _membersLoaded = false;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 47 | `_prayerLoaded && _eventsLoaded && _membersLoaded && _donationsLoaded;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 86 | `.collection('members')` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 91 | `assign: (items) => _members = items,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 92 | `markLoaded: () => _membersLoaded = true,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 159 | `members: _members,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 303 | `WebAdminActionKind.member => widget.onOpenMembers,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 393 | `WebAdminActionKind.member => 'Members',` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 124 | `label: 'Members affected',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 24 | `List<WebAdminReportSource> _members = const [];` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 29 | `bool _membersLoaded = false;` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 37 | `_membersLoaded && _prayerLoaded && _eventsLoaded && _donationsLoaded;` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 50 | `.collection('members')` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 55 | `assign: (items) => _members = items,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 56 | `markLoaded: () => _membersLoaded = true,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 149 | `members: _members,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 174 | `'Read-only ministry, membership, giving, prayer, and '` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 249 | `label: 'Directory members',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 250 | `value: '${report.totalMembers}',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 251 | `detail: '${report.activeMembers} active',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 299 | `values: report.membersByRole,` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 83 | `stream: _service.watchMembers(),` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 93 | `final members = snapshot.data!;` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 94 | `final visibleMembers = _filterMembers(members);` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 127 | `members,` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 135 | `members,` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 143 | `members,` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 151 | `members,` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 168 | `labelText: 'Search members',` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 238 | `child: visibleMembers.isEmpty` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 242 | `itemCount: visibleMembers.length,` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 245 | `final member = visibleMembers[index];` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 265 | `List<WebAdminStaffMember> _filterMembers(List<WebAdminStaffMember> members) {` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 268 | `return members` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 565 | `'No matching members',` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 11 | `required Iterable<WebAdminActionSource> members,` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 19 | `..._memberItems(members),` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 9 | `required Iterable<WebAdminReportSource> members,` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 20 | `final membersByRole = <String, int>{};` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 24 | `var totalMembers = 0;` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 25 | `var activeMembers = 0;` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 31 | `for (final source in members) {` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 33 | `totalMembers++;` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 42 | `activeMembers++;` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 50 | `membersByRole.update(role, (total) => total + 1, ifAbsent: () => 1);` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 188 | `totalMembers: totalMembers,` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 189 | `activeMembers: activeMembers,` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 196 | `membersByRole: _sortedIntMap(membersByRole),` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 17 | `CollectionReference<Map<String, dynamic>> get _members {` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 21 | `.collection('members');` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 31 | `Stream<List<WebAdminStaffMember>> watchMembers() {` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 32 | `return _members.snapshots().map((snapshot) {` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 33 | `final members = snapshot.docs` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 42 | `sortMembers(members);` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 43 | `return List<WebAdminStaffMember>.unmodifiable(members);` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 69 | `final memberReference = _members.doc(member.id);` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 92 | `static void sortMembers(List<WebAdminStaffMember> members) {` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 93 | `members.sort((left, right) {` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 121 | `static int countRole(Iterable<WebAdminStaffMember> members, String role) {` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 122 | `return members.where((member) => member.role == role).length;` |
| `lib/firebase/firebase_collection_names.dart` | 3 | `static const members = 'members';` |
| `lib/firebase/firebase_paths.dart` | 6 | `static String members(String churchId) =>` |
| `lib/firebase/firebase_paths.dart` | 7 | `'${church(churchId)}/${FirebaseCollectionNames.members}';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 2 | `import 'package:churchsnap/features/members/providers/member_baptism_providers.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 55 | `title: 'Members',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 99 | `title: 'Members Count',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 100 | `subtitle: 'Exclude only members removed from the directory',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 163 | `subtitle: 'Search, remove, and restore directory members',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 181 | `subtitle: 'Record and review members baptized in the last 30 days',` |
| `lib/screens/admin/admin_events_screen.dart` | 221 | `? 'Church members can see this event.'` |
| `lib/screens/admin/admin_giving_screen.dart` | 31 | `'Members can only view their own verified contributions. Card and bank details must never be stored here.',` |
| `lib/screens/admin/admin_members_screen.dart` | 5 | `import '../../features/members/models/church_member.dart';` |
| `lib/screens/admin/admin_members_screen.dart` | 6 | `import '../../features/members/providers/member_providers.dart';` |
| `lib/screens/admin/admin_members_screen.dart` | 9 | `class AdminMembersScreen extends ConsumerWidget {` |
| `lib/screens/admin/admin_members_screen.dart` | 10 | `const AdminMembersScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_members_screen.dart` | 16 | `final memberService = ref.read(memberServiceByChurchProvider(churchId));` |
| `lib/screens/admin/admin_members_screen.dart` | 20 | `title: 'Members',` |
| `lib/screens/admin/admin_members_screen.dart` | 24 | `stream: memberService.watchMembers(),` |
| `lib/screens/admin/admin_members_screen.dart` | 36 | `title: const Text('Unable to load members'),` |
| `lib/screens/admin/admin_members_screen.dart` | 42 | `final members = snapshot.data ?? <ChurchMember>[];` |
| `lib/screens/admin/admin_members_screen.dart` | 44 | `if (members.isEmpty) {` |
| `lib/screens/admin/admin_members_screen.dart` | 45 | `return const AppCard(child: Text('No members found.'));` |
| `lib/screens/admin/admin_members_screen.dart` | 49 | `children: members.map((member) {` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 4 | `import '../../features/members/models/member_count_summary.dart';` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 5 | `import '../../features/members/repositories/member_count_management_repository.dart';` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 36 | `title: 'Members Count',` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 37 | `subtitle: 'Removed members are excluded automatically.',` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 43 | `'Only removed members leave the count',` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 48 | `'uses Remove from Directory. No additional members are hidden '` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 103 | `label: 'Current Members Count',` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 127 | `label: const Text('Recalculate Members Count'),` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 183 | `'Members count recalculated: ${summary.overviewCount}. '` |
| `lib/screens/admin/admin_member_count_management_screen.dart` | 195 | `SnackBar(content: Text('Unable to recalculate members count: $error')),` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 4 | `import 'package:churchsnap/features/members/models/member_demographics_summary.dart';` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 5 | `import 'package:churchsnap/features/members/repositories/member_demographics_repository.dart';` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 61 | `const SectionTitle(title: 'Membership Snapshot'),` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 65 | `label: 'Active Members',` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 66 | `value: summary.totalMembers,` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 88 | `total: summary.totalMembers,` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 93 | `total: summary.totalMembers,` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 98 | `total: summary.totalMembers,` |
| `lib/screens/admin/admin_member_demographics_screen.dart` | 108 | `total: summary.totalMembers,` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 7 | `import '../../features/members/models/member_directory_entry.dart';` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 8 | `import '../../features/members/providers/member_directory_providers.dart';` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 47 | `subtitle: 'View, search, remove, and restore directory members.',` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 140 | `labelText: 'Search members',` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 172 | `? 'No visible members found'` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 173 | `: 'No removed members'` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 174 | `: 'No matching members',` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 180 | `: 'Members removed from the directory can be restored here.'` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 349 | `'Moved, transferred membership, requested privacy...',` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 7 | `import '../../features/members/models/church_member.dart';` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 8 | `import '../../features/members/models/member_profile_details.dart';` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 9 | `import '../../features/members/providers/member_providers.dart';` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 47 | `final memberService = ref.read(` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 48 | `memberServiceByChurchProvider(widget.churchId),` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 65 | `stream: memberService.watchPrivateProfile(_member.id),` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 117 | `'Legal name, home address, membership dates, birth date, '` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 155 | `.read(memberServiceByChurchProvider(widget.churchId))` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 288 | `.read(memberServiceByChurchProvider(widget.churchId))` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 471 | `icon: Icons.card_membership_rounded,` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 472 | `label: 'Membership date',` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 473 | `value: _formatDate(context, details.membershipDate),` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 549 | `late DateTime? _membershipDate;` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 658 | `_membershipDate = widget.details.membershipDate;` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 811 | `icon: Icons.card_membership_rounded,` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 812 | `title: 'Membership date',` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 813 | `value: _membershipDate,` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 815 | `currentValue: _membershipDate,` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 816 | `helpText: 'Select membership date',` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 819 | `_membershipDate = date;` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 823 | `onClear: _membershipDate == null` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 827 | `_membershipDate = null;` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 1053 | `membershipDate: _membershipDate,` |
| `lib/screens/admin/admin_notifications_screen.dart` | 292 | `child: Text('All active members'),` |
| `lib/screens/admin/admin_notifications_screen.dart` | 403 | `? 'All active members'` |
| `lib/screens/admin/admin_recent_baptisms_screen.dart` | 6 | `import 'package:churchsnap/features/members/models/member_baptism_record.dart';` |
| `lib/screens/admin/admin_recent_baptisms_screen.dart` | 7 | `import 'package:churchsnap/features/members/providers/member_baptism_providers.dart';` |
| `lib/screens/admin/admin_recent_baptisms_screen.dart` | 22 | `subtitle: 'Members baptized during the last 30 days',` |
| `lib/screens/admin/admin_recent_baptisms_screen.dart` | 36 | `subtitle: 'Members baptized during the last 30 days',` |
| `lib/screens/admin/admin_recent_baptisms_screen.dart` | 52 | `subtitle: 'Members baptized during the last 30 days',` |
| `lib/screens/admin/admin_recent_baptisms_screen.dart` | 66 | `subtitle: const Text('Recently baptized members'),` |
| `lib/screens/admin/admin_recent_baptisms_screen.dart` | 99 | `const AppCard(child: Text('No active members are available.'))` |
| `lib/screens/admin/admin_resources_screen.dart` | 388 | `? 'Members can see this resource.'` |
| `lib/screens/admin/admin_role_management_screen.dart` | 8 | `import '../../features/members/models/church_member.dart';` |
| `lib/screens/admin/admin_role_management_screen.dart` | 9 | `import '../../features/members/providers/member_providers.dart';` |
| `lib/screens/admin/admin_role_management_screen.dart` | 18 | `final memberService = ref.read(memberServiceByChurchProvider(churchId));` |
| `lib/screens/admin/admin_role_management_screen.dart` | 39 | `stream: memberService.watchMembers(),` |
| `lib/screens/admin/admin_role_management_screen.dart` | 58 | `final members = snapshot.data ?? <ChurchMember>[];` |
| `lib/screens/admin/admin_role_management_screen.dart` | 60 | `if (members.isEmpty) {` |
| `lib/screens/admin/admin_role_management_screen.dart` | 61 | `return const AppCard(child: Text('No members found.'));` |
| `lib/screens/admin/admin_role_management_screen.dart` | 64 | `final activePrivilegedCount = members.where((member) {` |
| `lib/screens/admin/admin_role_management_screen.dart` | 69 | `children: members.map((member) {` |
| `lib/screens/admin/admin_role_management_screen.dart` | 215 | `.read(memberServiceByChurchProvider(churchId))` |
| `lib/screens/admin/admin_sermons_screen.dart` | 487 | `'Published sermons are visible to members.',` |
| `lib/screens/admin/admin_upcoming_celebrations_screen.dart` | 4 | `import 'package:churchsnap/features/members/models/upcoming_celebration.dart';` |
| `lib/screens/admin/admin_upcoming_celebrations_screen.dart` | 5 | `import 'package:churchsnap/features/members/repositories/member_celebration_repository.dart';` |
| `lib/screens/admin/admin_upcoming_celebrations_screen.dart` | 161 | `'anniversary dates for members.',` |
| `lib/screens/admin/admin_upcoming_celebrations_screen.dart` | 171 | `const AppCard(child: Text('No active members are available.'))` |
| `lib/screens/admin/admin_volunteer_schedule_screen.dart` | 5 | `import '../../features/members/models/church_member.dart';` |
| `lib/screens/admin/admin_volunteer_schedule_screen.dart` | 6 | `import '../../features/members/providers/member_providers.dart';` |
| `lib/screens/admin/admin_volunteer_schedule_screen.dart` | 186 | `final memberService = ref.read(` |
| `lib/screens/admin/admin_volunteer_schedule_screen.dart` | 187 | `memberServiceByChurchProvider(widget.churchId),` |
| `lib/screens/admin/admin_volunteer_schedule_screen.dart` | 224 | `stream: memberService.watchMembers(),` |
| `lib/screens/admin/admin_volunteer_schedule_screen.dart` | 226 | `final members = (snapshot.data ?? <ChurchMember>[])` |
| `lib/screens/admin/admin_volunteer_schedule_screen.dart` | 233 | `items: members.map((member) {` |
| `lib/screens/giving/giving_screen.dart` | 333 | `? 'Giving History is for members'` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 8 | `import '../../features/members/models/member_self_profile.dart';` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 9 | `import '../../features/members/repositories/member_self_profile_repository.dart';` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 29 | `late final MemberSelfProfileRepository _repository;` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 30 | `late final Future<MemberSelfProfileSnapshot> _profileFuture;` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 36 | `_repository = MemberSelfProfileRepository(` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 50 | `FutureBuilder<MemberSelfProfileSnapshot>(` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 74 | `return _MemberSelfProfileForm(` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 87 | `class _MemberSelfProfileForm extends StatefulWidget {` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 88 | `const _MemberSelfProfileForm({` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 94 | `final MemberSelfProfileRepository repository;` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 95 | `final MemberSelfProfileSnapshot snapshot;` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 99 | `State<_MemberSelfProfileForm> createState() => _MemberSelfProfileFormState();` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 102 | `class _MemberSelfProfileFormState extends State<_MemberSelfProfileForm> {` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 532 | `'Church role, active status, membership date, baptism records, '` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 562 | `if (bytes.length > MemberSelfProfileRepository.maximumPhotoBytes) {` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 620 | `final draft = MemberSelfProfileDraft(` |
| `firestore.rules` | 15 | `return /databases/$(database)/documents/churches/$(churchId)/members/$(memberId);` |
| `firestore.rules` | 74 | `/databases/$(database)/documents/churches/$(churchId)/members/$(request.auth.uid)` |
| `firestore.rules` | 172 | `match /members/{memberId} {` |
| `firestore.rules` | 336 | `'membershipDate',` |

## events

| File | Line | Source |
| --- | ---: | --- |
| `lib/core/demo/demo_data.dart` | 31 | `static const events = [` |
| `lib/core/providers/repository_providers.dart` | 5 | `import '../../features/events/repositories/event_repository.dart';` |
| `lib/features/admin/providers/admin_providers.dart` | 5 | `import '../../events/repositories/event_repository.dart';` |
| `lib/features/admin/providers/admin_providers.dart` | 21 | `final adminEventServiceProvider = Provider<AdminEventService>((ref) {` |
| `lib/features/admin/providers/admin_providers.dart` | 22 | `return AdminEventService(EventRepository());` |
| `lib/features/admin/providers/admin_providers.dart` | 25 | `final adminEventServiceByChurchProvider =` |
| `lib/features/admin/providers/admin_providers.dart` | 26 | `Provider.family<AdminEventService, String>((ref, churchId) {` |
| `lib/features/admin/providers/admin_providers.dart` | 27 | `return AdminEventService(EventRepository(churchId: churchId));` |
| `lib/features/admin/services/admin_event_service.dart` | 2 | `import '../../events/repositories/event_repository.dart';` |
| `lib/features/admin/services/admin_event_service.dart` | 4 | `class AdminEventService {` |
| `lib/features/admin/services/admin_event_service.dart` | 5 | `AdminEventService(this._repository);` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 19 | `CollectionReference<Map<String, dynamic>> get _events =>` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 20 | `_firestore.collection('churches').doc(churchId).collection('events');` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 51 | `final eventSnapshot = await _events.doc(eventId).get();` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 53 | `final eventData = eventSnapshot.data();` |
| `lib/features/auth/screens/guest_account_screen.dart` | 26 | `'Published sermons, media, announcements, events, and giving '` |
| `lib/features/dashboard/repositories/dashboard_repository.dart` | 30 | `.collection('events')` |
| `lib/features/events/providers/event_providers.dart` | 11 | `final eventServiceProvider = Provider<EventService>((ref) {` |
| `lib/features/events/providers/event_providers.dart` | 12 | `return EventService(ref.read(eventRepositoryProvider));` |
| `lib/features/events/providers/event_providers.dart` | 20 | `final eventServiceByChurchProvider = Provider.family<EventService, String>((` |
| `lib/features/events/providers/event_providers.dart` | 24 | `return EventService(ref.watch(eventRepositoryByChurchProvider(churchId)));` |
| `lib/features/events/providers/event_providers.dart` | 27 | `final publishedEventsByChurchProvider =` |
| `lib/features/events/providers/event_providers.dart` | 30 | `.watch(eventServiceByChurchProvider(churchId))` |
| `lib/features/events/providers/event_providers.dart` | 31 | `.watchPublishedEvents();` |
| `lib/features/events/providers/event_providers.dart` | 34 | `final adminEventsByChurchProvider =` |
| `lib/features/events/providers/event_providers.dart` | 36 | `return ref.watch(eventServiceByChurchProvider(churchId)).watchAllEvents();` |
| `lib/features/events/repositories/event_repository.dart` | 17 | `_firestore.collection(FirebasePaths.events(churchId));` |
| `lib/features/events/repositories/event_repository.dart` | 19 | `Stream<List<ChurchEvent>> watchPublishedEvents() {` |
| `lib/features/events/repositories/event_repository.dart` | 23 | `final events = snapshot.docs` |
| `lib/features/events/repositories/event_repository.dart` | 27 | `events.sort((first, second) {` |
| `lib/features/events/repositories/event_repository.dart` | 46 | `return events;` |
| `lib/features/events/repositories/event_repository.dart` | 50 | `Stream<List<ChurchEvent>> watchAllEvents() {` |
| `lib/features/events/repositories/event_repository.dart` | 51 | `return _watchEvents(includeUnpublished: true);` |
| `lib/features/events/repositories/event_repository.dart` | 54 | `Stream<List<ChurchEvent>> _watchEvents({required bool includeUnpublished}) {` |
| `lib/features/events/repositories/event_repository.dart` | 56 | `final events = snapshot.docs` |
| `lib/features/events/repositories/event_repository.dart` | 67 | `events.sort((first, second) {` |
| `lib/features/events/repositories/event_repository.dart` | 86 | `return events;` |
| `lib/features/events/services/event_service.dart` | 4 | `class EventService {` |
| `lib/features/events/services/event_service.dart` | 5 | `EventService(this._repository);` |
| `lib/features/events/services/event_service.dart` | 9 | `Stream<List<ChurchEvent>> watchPublishedEvents() {` |
| `lib/features/events/services/event_service.dart` | 10 | `return _repository.watchPublishedEvents();` |
| `lib/features/events/services/event_service.dart` | 13 | `Stream<List<ChurchEvent>> watchAllEvents() {` |
| `lib/features/events/services/event_service.dart` | 14 | `return _repository.watchAllEvents();` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 36 | `required this.upcomingEvents,` |
| `lib/features/web_admin/models/web_admin_report_snapshot.dart` | 49 | `final List<WebAdminReportEvent> upcomingEvents;` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 43 | `onOpenEvents: () => _selectPage(2),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 48 | `_WebEventsPage(churchId: _churchId),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 54 | `onOpenEvents: () => _selectPage(2),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 139 | `label: Text('Events'),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 188 | `label: 'Events',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 300 | `required this.onOpenEvents,` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 307 | `final VoidCallback onOpenEvents;` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 334 | `label: 'Events',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 336 | `stream: church.collection('events').snapshots(),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 337 | `onTap: onOpenEvents,` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 511 | `class _WebEventsPage extends StatelessWidget {` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 512 | `const _WebEventsPage({required this.churchId});` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 521 | `.collection('events')` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 525 | `title: 'Events',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 526 | `subtitle: 'Review events synchronized from ChurchSnap.',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 528 | `emptyMessage: 'No events are available.',` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 14 | `required this.onOpenEvents,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 21 | `final VoidCallback onOpenEvents;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 34 | `List<WebAdminActionSource> _events = const [];` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 39 | `bool _eventsLoaded = false;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 47 | `_prayerLoaded && _eventsLoaded && _membersLoaded && _donationsLoaded;` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 73 | `.collection('events')` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 78 | `assign: (items) => _events = items,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 79 | `markLoaded: () => _eventsLoaded = true,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 158 | `events: _events,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 192 | `'One live queue for pastoral care, upcoming events, member '` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 220 | `label: 'Events',` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 253 | `hintText: 'Search names, requests, events, funds, or statuses',` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 302 | `WebAdminActionKind.event => widget.onOpenEvents,` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 392 | `WebAdminActionKind.event => 'Events',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 26 | `List<WebAdminReportSource> _events = const [];` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 31 | `bool _eventsLoaded = false;` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 37 | `_membersLoaded && _prayerLoaded && _eventsLoaded && _donationsLoaded;` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 76 | `.collection('events')` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 81 | `assign: (items) => _events = items,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 82 | `markLoaded: () => _eventsLoaded = true,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 151 | `events: _events,` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 267 | `label: 'Upcoming events',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 268 | `value: '${report.upcomingEvents.length}',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 335 | `title: 'Upcoming events',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 337 | `child: _UpcomingEvents(events: report.upcomingEvents),` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 580 | `class _UpcomingEvents extends StatelessWidget {` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 581 | `const _UpcomingEvents({required this.events});` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 583 | `final List<WebAdminReportEvent> events;` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 587 | `if (events.isEmpty) {` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 589 | `message: 'No upcoming events during the next 30 days.',` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 594 | `children: events` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 10 | `required Iterable<WebAdminActionSource> events,` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 18 | `..._eventItems(events, reference),` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 11 | `required Iterable<WebAdminReportSource> events,` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 22 | `final upcomingEvents = <WebAdminReportEvent>[];` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 141 | `for (final source in events) {` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 167 | `upcomingEvents.add(` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 183 | `upcomingEvents.sort(` |
| `lib/features/web_admin/services/web_admin_report_builder.dart` | 198 | `upcomingEvents: List<WebAdminReportEvent>.unmodifiable(upcomingEvents),` |
| `lib/firebase/firebase_collection_names.dart` | 5 | `static const events = 'events';` |
| `lib/firebase/firebase_paths.dart` | 10 | `static String events(String churchId) =>` |
| `lib/firebase/firebase_paths.dart` | 11 | `'${church(churchId)}/${FirebaseCollectionNames.events}';` |
| `lib/screens/admin/admin_announcements_list_screen.dart` | 108 | `DropdownMenuItem(value: 'Events', child: Text('Events')),` |
| `lib/screens/admin/admin_announcements_screen.dart` | 76 | `DropdownMenuItem(value: 'Events', child: Text('Events')),` |
| `lib/screens/admin/admin_attendance_screen.dart` | 178 | `child: Text('All recent events'),` |
| `lib/screens/admin/admin_calendar_screen.dart` | 6 | `import '../../features/events/providers/event_providers.dart';` |
| `lib/screens/admin/admin_calendar_screen.dart` | 8 | `import 'admin_events_screen.dart';` |
| `lib/screens/admin/admin_calendar_screen.dart` | 36 | `final eventsAsync = ref.watch(adminEventsByChurchProvider(widget.churchId));` |
| `lib/screens/admin/admin_calendar_screen.dart` | 41 | `subtitle: 'View published events and drafts by month.',` |
| `lib/screens/admin/admin_calendar_screen.dart` | 77 | `AdminEventsScreen(churchId: widget.churchId),` |
| `lib/screens/admin/admin_calendar_screen.dart` | 82 | `label: const Text('Manage Events'),` |
| `lib/screens/admin/admin_calendar_screen.dart` | 86 | `eventsAsync.when(` |
| `lib/screens/admin/admin_calendar_screen.dart` | 97 | `data: (events) {` |
| `lib/screens/admin/admin_calendar_screen.dart` | 98 | `final monthEvents = events.where(_isInFocusedMonth).toList();` |
| `lib/screens/admin/admin_calendar_screen.dart` | 100 | `final undatedEvents = events` |
| `lib/screens/admin/admin_calendar_screen.dart` | 104 | `final publishedCount = monthEvents` |
| `lib/screens/admin/admin_calendar_screen.dart` | 108 | `final draftCount = monthEvents.length - publishedCount;` |
| `lib/screens/admin/admin_calendar_screen.dart` | 119 | `label: Text('${monthEvents.length} events'),` |
| `lib/screens/admin/admin_calendar_screen.dart` | 132 | `if (monthEvents.isEmpty)` |
| `lib/screens/admin/admin_calendar_screen.dart` | 137 | `'No events in '` |
| `lib/screens/admin/admin_calendar_screen.dart` | 141 | `subtitle: const Text('Use Manage Events to add one.'),` |
| `lib/screens/admin/admin_calendar_screen.dart` | 145 | `...monthEvents.map(` |
| `lib/screens/admin/admin_calendar_screen.dart` | 151 | `if (undatedEvents.isNotEmpty) ...[` |
| `lib/screens/admin/admin_calendar_screen.dart` | 153 | `const SectionTitle(title: 'Events Without a Date'),` |
| `lib/screens/admin/admin_calendar_screen.dart` | 154 | `...undatedEvents.map(` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 8 | `import 'admin_events_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 66 | `title: 'Events',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 136 | `title: 'Events',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 137 | `subtitle: 'Manage church events',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 138 | `screen: AdminEventsScreen(churchId: churchId),` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 258 | `subtitle: 'View church events by month',` |
| `lib/screens/admin/admin_events_screen.dart` | 6 | `import '../../features/events/repositories/event_repository.dart';` |
| `lib/screens/admin/admin_events_screen.dart` | 11 | `class AdminEventsScreen extends ConsumerWidget {` |
| `lib/screens/admin/admin_events_screen.dart` | 12 | `const AdminEventsScreen({super.key, required this.churchId});` |
| `lib/screens/admin/admin_events_screen.dart` | 22 | `title: 'Events',` |
| `lib/screens/admin/admin_events_screen.dart` | 23 | `subtitle: 'Create and manage church events.',` |
| `lib/screens/admin/admin_events_screen.dart` | 32 | `stream: repository.watchAllEvents(),` |
| `lib/screens/admin/admin_events_screen.dart` | 34 | `final events = snapshot.data ?? <ChurchEvent>[];` |
| `lib/screens/admin/admin_events_screen.dart` | 42 | `if (events.isEmpty) {` |
| `lib/screens/admin/admin_events_screen.dart` | 43 | `return const AppCard(child: Text('No events yet.'));` |
| `lib/screens/admin/admin_events_screen.dart` | 47 | `children: events.map((event) {` |
| `lib/screens/admin/admin_events_screen.dart` | 66 | `adminEventServiceByChurchProvider(churchId),` |
| `lib/screens/admin/admin_events_screen.dart` | 368 | `adminEventServiceByChurchProvider(widget.churchId),` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 6 | `import '../../features/events/repositories/event_repository.dart';` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 54 | `stream: _eventRepository.watchPublishedEvents(),` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 66 | `title: const Text('Unable to load events'),` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 72 | `final events = snapshot.data ?? <ChurchEvent>[];` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 74 | `if (events.isEmpty) {` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 77 | `'No published events are available. '` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 90 | `items: events.map((event) {` |
| `lib/screens/events/events_screen.dart` | 8 | `import '../../features/events/providers/event_providers.dart';` |
| `lib/screens/events/events_screen.dart` | 13 | `class EventsScreen extends ConsumerWidget {` |
| `lib/screens/events/events_screen.dart` | 14 | `const EventsScreen({super.key, this.authController});` |
| `lib/screens/events/events_screen.dart` | 28 | `final eventsAsync = ref.watch(publishedEventsByChurchProvider(churchId));` |
| `lib/screens/events/events_screen.dart` | 32 | `title: 'Events',` |
| `lib/screens/events/events_screen.dart` | 34 | `? 'Browse upcoming church events. Member access is required to RSVP or check in.'` |
| `lib/screens/events/events_screen.dart` | 38 | `eventsAsync.when(` |
| `lib/screens/events/events_screen.dart` | 45 | `title: const Text('Unable to load events'),` |
| `lib/screens/events/events_screen.dart` | 49 | `data: (events) {` |
| `lib/screens/events/events_screen.dart` | 50 | `if (events.isEmpty) {` |
| `lib/screens/events/events_screen.dart` | 54 | `title: Text('No upcoming events'),` |
| `lib/screens/events/events_screen.dart` | 55 | `subtitle: Text('New church events will appear here.'),` |
| `lib/screens/events/events_screen.dart` | 61 | `children: events.map((event) {` |
| `lib/screens/events/events_screen.dart` | 109 | `final service = ref.read(eventServiceByChurchProvider(churchId));` |
| `lib/screens/home/churchsnap_shell.dart` | 10 | `import '../events/events_screen.dart';` |
| `lib/screens/home/churchsnap_shell.dart` | 85 | `EventsScreen(authController: widget.authController),` |
| `lib/screens/home/churchsnap_shell.dart` | 125 | `label: 'Events',` |
| `lib/screens/home/churchsnap_shell.dart` | 126 | `assetName: 'events',` |
| `lib/screens/home/home_screen.dart` | 9 | `import '../../features/events/providers/event_providers.dart';` |
| `lib/screens/home/home_screen.dart` | 98 | `onEvents: () => onSelectTab(3),` |
| `lib/screens/home/home_screen.dart` | 112 | `_UpcomingEventsSection(` |
| `lib/screens/home/home_screen.dart` | 588 | `required this.onEvents,` |
| `lib/screens/home/home_screen.dart` | 594 | `final VoidCallback onEvents;` |
| `lib/screens/home/home_screen.dart` | 602 | `_HomeAction(label: 'Events', assetName: 'events', onTap: onEvents),` |
| `lib/screens/home/home_screen.dart` | 842 | `class _UpcomingEventsSection extends ConsumerWidget {` |
| `lib/screens/home/home_screen.dart` | 843 | `const _UpcomingEventsSection({` |
| `lib/screens/home/home_screen.dart` | 853 | `final eventsAsync = ref.watch(publishedEventsByChurchProvider(churchId));` |
| `lib/screens/home/home_screen.dart` | 859 | `title: 'Upcoming Events',` |
| `lib/screens/home/home_screen.dart` | 864 | `eventsAsync.when(` |
| `lib/screens/home/home_screen.dart` | 868 | `title: 'Unable to load events',` |
| `lib/screens/home/home_screen.dart` | 871 | `data: (events) {` |
| `lib/screens/home/home_screen.dart` | 878 | `final upcoming = events` |
| `lib/screens/home/home_screen.dart` | 891 | `title: 'No upcoming events',` |
| `lib/screens/home/home_screen.dart` | 892 | `subtitle: 'New church events will appear here.',` |
| `lib/screens/profile/attendance_history_screen.dart` | 54 | `'after attending events.',` |
| `lib/screens/profile/profile_screen.dart` | 320 | `'You can view published sermons, media, events, prayer updates, '` |
| `firestore.rules` | 389 | `match /events/{eventId} {` |

## churches

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 15 | `.collection('churches')` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 20 | `_firestore.collection('churches').doc(churchId).collection('events');` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 25 | `_firestore.collection('churches').doc(churchId);` |
| `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart` | 416 | `.collection('churches')` |
| `lib/features/auth/screens/live_member_session.dart` | 72 | `.collection('churches')` |
| `lib/features/auth/services/required_name_service.dart` | 38 | `.collection('churches')` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 17 | `.collection('churches')` |
| `lib/features/church_directory/repositories/church_directory_repository.dart` | 11 | `CollectionReference<Map<String, dynamic>> get _churches =>` |
| `lib/features/church_directory/repositories/church_directory_repository.dart` | 12 | `_firestore.collection('churches');` |
| `lib/features/church_directory/repositories/church_directory_repository.dart` | 14 | `Stream<List<ChurchDirectoryEntry>> watchPublicChurches() {` |
| `lib/features/church_directory/repositories/church_directory_repository.dart` | 15 | `return _churches.snapshots().map((snapshot) {` |
| `lib/features/church_directory/repositories/church_directory_repository.dart` | 16 | `final churches = snapshot.docs` |
| `lib/features/church_directory/repositories/church_directory_repository.dart` | 26 | `churches.sort(` |
| `lib/features/church_directory/repositories/church_directory_repository.dart` | 31 | `return churches;` |
| `lib/features/church_directory/repositories/church_directory_repository.dart` | 42 | `final snapshot = await _churches.get();` |
| `lib/features/church_directory/screens/church_selection_screen.dart` | 125 | `stream: _repository.watchPublicChurches(),` |
| `lib/features/church_directory/screens/church_selection_screen.dart` | 130 | `title: 'Unable to load churches',` |
| `lib/features/church_directory/screens/church_selection_screen.dart` | 141 | `final churches = snapshot.data!` |
| `lib/features/church_directory/screens/church_selection_screen.dart` | 149 | `if (churches.isEmpty) {` |
| `lib/features/church_directory/screens/church_selection_screen.dart` | 152 | `title: 'No matching churches',` |
| `lib/features/church_directory/screens/church_selection_screen.dart` | 161 | `itemCount: churches.length,` |
| `lib/features/church_directory/screens/church_selection_screen.dart` | 164 | `final church = churches[index];` |
| `lib/features/dashboard/repositories/dashboard_repository.dart` | 15 | `_firestore.collection('churches').doc(churchId);` |
| `lib/features/giving/repositories/giving_currency_repository.dart` | 16 | `.collection('churches')` |
| `lib/features/giving/repositories/giving_submission_repository.dart` | 21 | `.collection('churches')` |
| `lib/features/home/providers/home_appearance_provider.dart` | 36 | `.collection('churches')` |
| `lib/features/home/providers/pastor_appearance_provider.dart` | 36 | `.collection('churches')` |
| `lib/features/media/repositories/media_repository.dart` | 13 | `_firestore.collection('churches').doc(churchId).collection('media');` |
| `lib/features/media/services/media_storage_service.dart` | 15 | `'churches/$churchId/media/$mediaType/${DateTime.now().millisecondsSinceEpoch}_$fileName';` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 17 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 20 | `.collection('churches')` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 17 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 20 | `.collection('churches')` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 15 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 17 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 20 | `.collection('churches')` |
| `lib/features/members/repositories/member_directory_repository.dart` | 19 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_repository.dart` | 16 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_repository.dart` | 19 | `.collection('churches')` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 29 | `.collection('churches')` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 35 | `.collection('churches')` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 146 | `.child('churches')` |
| `lib/features/ministries/repositories/ministry_repository.dart` | 15 | `_firestore.collection('churches').doc(churchId).collection('ministries');` |
| `lib/features/notifications/repositories/notification_repository.dart` | 13 | `.collection('churches')` |
| `lib/features/notifications/services/notification_service.dart` | 140 | `.collection('churches')` |
| `lib/features/resources/repositories/church_resource_repository.dart` | 28 | `_firestore.collection('churches').doc(churchId).collection('resources');` |
| `lib/features/resources/repositories/church_resource_repository.dart` | 102 | `'churches/$churchId/resources/${document.id}/$safeFileName';` |
| `lib/features/sermons/repositories/sermon_bookmark_repository.dart` | 26 | `.collection('churches')` |
| `lib/features/small_group/repositories/small_group_repository.dart` | 15 | `.collection('churches')` |
| `lib/features/volunteers/repositories/volunteer_repository.dart` | 15 | `.collection('churches')` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 314 | `.collection('churches')` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 519 | `.collection('churches')` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 569 | `.collection('churches')` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 626 | `.collection('churches')` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 54 | `.collection('churches')` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 44 | `.collection('churches')` |
| `lib/features/web_admin/services/web_admin_audit_log_service.dart` | 20 | `.collection('churches')` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 19 | `.collection('churches')` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 26 | `.collection('churches')` |
| `lib/features/worship/repositories/worship_settings_repository.dart` | 17 | `.collection('churches')` |
| `lib/firebase/firebase_collection_names.dart` | 2 | `static const churches = 'churches';` |
| `lib/firebase/firebase_paths.dart` | 5 | `'${FirebaseCollectionNames.churches}/$churchId';` |
| `lib/screens/admin/admin_church_connection_screen.dart` | 35 | `FirebaseFirestore.instance.collection('churches').doc(widget.churchId);` |
| `lib/screens/admin/admin_home_appearance_screen.dart` | 36 | `.collection('churches')` |
| `lib/screens/admin/admin_home_appearance_screen.dart` | 127 | `'churches/${widget.churchId}/home/'` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 260 | `.child('churches')` |
| `lib/screens/admin/admin_pastor_picture_screen.dart` | 36 | `.collection('churches')` |
| `lib/screens/admin/admin_pastor_picture_screen.dart` | 123 | `'churches/${widget.churchId}/home/'` |
| `firestore.rules` | 15 | `return /databases/$(database)/documents/churches/$(churchId)/members/$(memberId);` |
| `firestore.rules` | 74 | `/databases/$(database)/documents/churches/$(churchId)/members/$(request.auth.uid)` |
| `firestore.rules` | 98 | `/databases/$(database)/documents/churches/$(churchId)/ministries/$(ministryId)` |
| `firestore.rules` | 106 | `/databases/$(database)/documents/churches/$(churchId)/ministries/$(ministryId)` |
| `firestore.rules` | 129 | `return /databases/$(database)/documents/churches/$(churchId);` |
| `firestore.rules` | 168 | `match /churches/{churchId} {` |

