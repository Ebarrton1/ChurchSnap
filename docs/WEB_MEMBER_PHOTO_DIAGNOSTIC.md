# ChurchSnap Web Member Photo Diagnostic

Generated: 2026-07-19 12:24:40

Branch: `churchsnap-testing-stabilization`

## Photo field references

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/church_directory/models/church_directory_entry.dart` | 81 | `logoUrl: readString(['logoUrl', 'photoUrl']),` |
| `lib/features/members/models/church_member.dart` | 6 | `final String photoUrl;` |
| `lib/features/members/models/church_member.dart` | 15 | `this.photoUrl = '',` |
| `lib/features/members/models/church_member.dart` | 26 | `photoUrl: map['photoUrl'] ?? '',` |
| `lib/features/members/models/church_member.dart` | 37 | `'photoUrl': photoUrl,` |
| `lib/features/members/models/member_baptism_record.dart` | 5 | `required this.photoUrl,` |
| `lib/features/members/models/member_baptism_record.dart` | 13 | `final String photoUrl;` |
| `lib/features/members/models/member_baptism_record.dart` | 33 | `photoUrl: (member['photoUrl']?.toString() ?? '').trim(),` |
| `lib/features/members/models/member_directory_entry.dart` | 9 | `required this.photoUrl,` |
| `lib/features/members/models/member_directory_entry.dart` | 26 | `final String photoUrl;` |
| `lib/features/members/models/member_directory_entry.dart` | 56 | `photoUrl: (map['photoUrl']?.toString() ?? '').trim(),` |
| `lib/features/members/models/member_directory_entry.dart` | 76 | `photoUrl: photoUrl,` |
| `lib/features/members/models/member_self_profile.dart` | 8 | `required this.photoUrl,` |
| `lib/features/members/models/member_self_profile.dart` | 18 | `final String photoUrl;` |
| `lib/features/members/models/member_self_profile.dart` | 53 | `photoUrl: (memberData['photoUrl']?.toString() ?? '').trim(),` |
| `lib/features/members/models/member_self_profile.dart` | 170 | `Map<String, dynamic> publicDirectoryMap({required String photoUrl}) {` |
| `lib/features/members/models/member_self_profile.dart` | 177 | `'photoUrl': photoUrl.trim(),` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 61 | `required String existingPhotoUrl,` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 80 | `var photoUrl = existingPhotoUrl.trim();` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 83 | `photoUrl = await _uploadPhoto(` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 89 | `final publicData = draft.publicDirectoryMap(photoUrl: photoUrl);` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 116 | `return photoUrl;` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 148 | `.child('member_profile_photos')` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 217 | `backgroundImage: entry.photoUrl.isEmpty` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 219 | `: NetworkImage(entry.photoUrl),` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 220 | `child: entry.photoUrl.isEmpty` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 61 | `onChangePhoto: _uploadingPhoto ? null : _chooseProfilePhoto,` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 189 | `Future<void> _chooseProfilePhoto() async {` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 203 | `await _uploadProfilePhoto(photo);` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 226 | `await _uploadProfilePhoto(files.first);` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 233 | `Future<void> _uploadProfilePhoto(XFile photo) async {` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 262 | `.child('member_profile_photos')` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 275 | `final photoUrl = await storageReference.getDownloadURL();` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 282 | `photoUrl: photoUrl,` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 333 | `final photoUrl = member.photoUrl.trim();` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 346 | `child: photoUrl.isEmpty` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 366 | `photoUrl,` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 398 | `: photoUrl.isEmpty` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 1039 | `photoUrl: widget.member.photoUrl,` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 225 | `_ProfilePhotoEditor(` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 226 | `existingPhotoUrl: widget.snapshot.photoUrl,` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 656 | `existingPhotoUrl: widget.snapshot.photoUrl,` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 693 | `class _ProfilePhotoEditor extends StatelessWidget {` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 694 | `const _ProfilePhotoEditor({` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 695 | `required this.existingPhotoUrl,` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 700 | `final String existingPhotoUrl;` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 715 | `} else if (existingPhotoUrl.trim().isNotEmpty) {` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 717 | `existingPhotoUrl.trim(),` |
| `lib/screens/profile/edit_my_member_profile_screen.dart` | 747 | `existingPhotoUrl.trim().isEmpty && selectedPhotoBytes == null` |

## Profile and member writes

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/auth/models/live_member_access.dart` | 16 | `factory LiveMemberAccess.fromMap(` |
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
| `lib/features/auth/screens/live_member_session.dart` | 94 | `final access = LiveMemberAccess.fromMap(` |
| `lib/features/auth/screens/live_member_session.dart` | 122 | `'ChurchSnap could not refresh your membership access. '` |
| `lib/features/members/models/church_member.dart` | 20 | `factory ChurchMember.fromMap(String id, Map<String, dynamic> map) {` |
| `lib/features/members/models/church_member.dart` | 32 | `Map<String, dynamic> toMap() {` |
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
| `lib/features/members/models/member_directory_entry.dart` | 50 | `factory MemberDirectoryEntry.fromMap(String id, Map<String, dynamic> map) {` |
| `lib/features/members/models/member_profile_details.dart` | 14 | `this.membershipDate,` |
| `lib/features/members/models/member_profile_details.dart` | 32 | `final DateTime? membershipDate;` |
| `lib/features/members/models/member_profile_details.dart` | 66 | `factory MemberProfileDetails.fromMap(Map<String, dynamic> map) {` |
| `lib/features/members/models/member_profile_details.dart` | 77 | `membershipDate: _dateValue(map['membershipDate']),` |
| `lib/features/members/models/member_profile_details.dart` | 85 | `Map<String, dynamic> toMap() {` |
| `lib/features/members/models/member_profile_details.dart` | 96 | `'membershipDate': _timestampValue(membershipDate),` |
| `lib/features/members/models/member_profile_details.dart` | 114 | `DateTime? membershipDate,` |
| `lib/features/members/models/member_profile_details.dart` | 130 | `membershipDate: membershipDate ?? this.membershipDate,` |
| `lib/features/members/models/member_self_profile.dart` | 4 | `class MemberSelfProfileSnapshot {` |
| `lib/features/members/models/member_self_profile.dart` | 5 | `const MemberSelfProfileSnapshot({` |
| `lib/features/members/models/member_self_profile.dart` | 25 | `factory MemberSelfProfileSnapshot.fromMaps({` |
| `lib/features/members/models/member_self_profile.dart` | 29 | `final privateDetails = MemberProfileDetails.fromMap(privateData);` |
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
| `lib/features/members/repositories/member_baptism_repository.dart` | 22 | `.collection('memberPrivateProfiles');` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 26 | `StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSubscription;` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 30 | `var members = <String, Map<String, dynamic>>{};` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 32 | `var hasMembersSnapshot = false;` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 37 | `!hasMembersSnapshot \|\|` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 42 | `final records = members.entries` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 71 | `memberSubscription = _members.snapshots().listen((snapshot) {` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 72 | `members = <String, Map<String, dynamic>>{` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 75 | `hasMembersSnapshot = true;` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 90 | `await memberSubscription?.cancel();` |
| `lib/features/members/repositories/member_baptism_repository.dart` | 112 | `return _privateProfiles.doc(normalizedMemberId).set(<String, dynamic>{` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 16 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 17 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 22 | `.collection('memberPrivateProfiles');` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 26 | `StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSubscription;` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 30 | `var members = <String, Map<String, dynamic>>{};` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 32 | `var hasMembersSnapshot = false;` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 37 | `!hasMembersSnapshot \|\|` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 42 | `final profiles = members.entries` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 65 | `memberSubscription = _members.snapshots().listen((snapshot) {` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 66 | `members = <String, Map<String, dynamic>>{` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 69 | `hasMembersSnapshot = true;` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 84 | `await memberSubscription?.cancel();` |
| `lib/features/members/repositories/member_celebration_repository.dart` | 103 | `return _privateProfiles.doc(memberId).set(<String, dynamic>{` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 14 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 15 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 18 | `return _members.snapshots().map(MemberCountSummary.fromSnapshot);` |
| `lib/features/members/repositories/member_count_management_repository.dart` | 22 | `final snapshot = await _members.get();` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 16 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 17 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_demographics_repository.dart` | 22 | `.collection('memberPrivateProfiles');` |
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
| `lib/features/members/repositories/member_directory_repository.dart` | 26 | `MemberDirectoryEntry.fromMap(document.id, document.data()),` |
| `lib/features/members/repositories/member_directory_repository.dart` | 94 | `final reference = _members.doc(normalizedMemberId);` |
| `lib/features/members/repositories/member_directory_repository.dart` | 102 | `await reference.update({` |
| `lib/features/members/repositories/member_directory_repository.dart` | 116 | `await reference.update({` |
| `lib/features/members/repositories/member_repository.dart` | 15 | `CollectionReference<Map<String, dynamic>> get _members =>` |
| `lib/features/members/repositories/member_repository.dart` | 16 | `_firestore.collection('churches').doc(churchId).collection('members');` |
| `lib/features/members/repositories/member_repository.dart` | 21 | `.collection('memberPrivateProfiles');` |
| `lib/features/members/repositories/member_repository.dart` | 23 | `Stream<List<ChurchMember>> watchMembers() {` |
| `lib/features/members/repositories/member_repository.dart` | 24 | `return _members.snapshots().map((snapshot) {` |
| `lib/features/members/repositories/member_repository.dart` | 25 | `final members = snapshot.docs` |
| `lib/features/members/repositories/member_repository.dart` | 26 | `.map((document) => ChurchMember.fromMap(document.id, document.data()))` |
| `lib/features/members/repositories/member_repository.dart` | 29 | `members.sort(` |
| `lib/features/members/repositories/member_repository.dart` | 35 | `return members;` |
| `lib/features/members/repositories/member_repository.dart` | 53 | `return MemberProfileDetails.fromMap(data);` |
| `lib/features/members/repositories/member_repository.dart` | 58 | `return _members.doc(member.id).set(member.toMap());` |
| `lib/features/members/repositories/member_repository.dart` | 62 | `return _members.doc(member.id).update(member.toMap());` |
| `lib/features/members/repositories/member_repository.dart` | 75 | `return _privateProfiles.doc(cleanMemberId).set({` |
| `lib/features/members/repositories/member_repository.dart` | 76 | `...details.toMap(),` |
| `lib/features/members/repositories/member_repository.dart` | 93 | `batch.update(_members.doc(cleanMemberId), member.toMap());` |
| `lib/features/members/repositories/member_repository.dart` | 95 | `batch.set(_privateProfiles.doc(cleanMemberId), {` |
| `lib/features/members/repositories/member_repository.dart` | 96 | `...details.toMap(),` |
| `lib/features/members/repositories/member_repository.dart` | 112 | `batch.delete(_members.doc(cleanMemberId));` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 9 | `class MemberSelfProfileRepository {` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 10 | `MemberSelfProfileRepository({` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 31 | `.collection('members')` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 37 | `.collection('memberPrivateProfiles')` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 40 | `Future<MemberSelfProfileSnapshot> load() async {` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 43 | `final memberSnapshot = await _memberReference.get();` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 45 | `if (!memberSnapshot.exists \|\| memberSnapshot.data() == null) {` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 53 | `return MemberSelfProfileSnapshot.fromMaps(` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 54 | `memberData: memberSnapshot.data()!,` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 60 | `required MemberSelfProfileDraft draft,` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 72 | `final memberSnapshot = await _memberReference.get();` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 74 | `if (!memberSnapshot.exists) {` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 94 | `batch.update(_memberReference, <String, dynamic>{` |
| `lib/features/members/repositories/member_self_profile_repository.dart` | 101 | `batch.set(_privateReference, <String, dynamic>{` |
| `lib/features/members/services/member_service.dart` | 5 | `class MemberService {` |
| `lib/features/members/services/member_service.dart` | 6 | `MemberService(this._repository);` |
| `lib/features/members/services/member_service.dart` | 10 | `Stream<List<ChurchMember>> watchMembers() {` |
| `lib/features/members/services/member_service.dart` | 11 | `return _repository.watchMembers();` |
| `lib/features/web_admin/models/web_admin_staff_member.dart` | 12 | `factory WebAdminStaffMember.fromMap({` |
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

## Web dashboard image rendering

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 477 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 547 | `leading: const CircleAvatar(child: Icon(Icons.event_rounded)),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 600 | `leading: CircleAvatar(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 661 | `leading: const CircleAvatar(child: Icon(Icons.payments_rounded)),` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 345 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 405 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 278 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 318 | `const CircleAvatar(child: Icon(Icons.history_rounded)),` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 417 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 599 | `leading: const CircleAvatar(child: Icon(Icons.event_rounded)),` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 402 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 449 | `CircleAvatar(` |
| `lib/features/web_admin/widgets/web_admin_responsive_navigation.dart` | 45 | `CircleAvatar(` |

## Web dashboard member directory rendering

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/web_admin/models/web_admin_audit_entry.dart` | 10 | `required this.targetDisplayName,` |
| `lib/features/web_admin/models/web_admin_audit_entry.dart` | 30 | `targetDisplayName: _text(data, const [` |
| `lib/features/web_admin/models/web_admin_audit_entry.dart` | 31 | `'targetDisplayName',` |
| `lib/features/web_admin/models/web_admin_audit_entry.dart` | 44 | `final String targetDisplayName;` |
| `lib/features/web_admin/models/web_admin_audit_entry.dart` | 69 | `targetDisplayName,` |
| `lib/features/web_admin/models/web_admin_staff_member.dart` | 6 | `required this.displayName,` |
| `lib/features/web_admin/models/web_admin_staff_member.dart` | 17 | `'displayName',` |
| `lib/features/web_admin/models/web_admin_staff_member.dart` | 36 | `displayName: name,` |
| `lib/features/web_admin/models/web_admin_staff_member.dart` | 44 | `final String displayName;` |
| `lib/features/web_admin/models/web_admin_staff_member.dart` | 59 | `displayName: displayName,` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 86 | `user.displayName,` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 260 | `child: Card(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 276 | `'${user?.displayName ?? 'This account'} does not have '` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 328 | `_LiveCountCard(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 334 | `_LiveCountCard(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 340 | `_LiveCountCard(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 346 | `_LiveCountCard(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 374 | `return Card(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 447 | `class _LiveCountCard extends StatelessWidget {` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 448 | `const _LiveCountCard({` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 464 | `child: Card(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 477 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 546 | `return ListTile(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 547 | `leading: const CircleAvatar(child: Icon(Icons.event_rounded)),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 589 | `'memberName',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 590 | `'displayName',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 599 | `return ListTile(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 600 | `leading: CircleAvatar(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 640 | `'memberName',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 642 | `'displayName',` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 660 | `return ListTile(` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 661 | `leading: const CircleAvatar(child: Icon(Icons.payments_rounded)),` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 726 | `return Card(child: itemBuilder(context, documents[index]));` |
| `lib/features/web_admin/screens/churchsnap_web_admin_shell.dart` | 783 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 204 | `_SummaryCard(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 211 | `_SummaryCard(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 219 | `_SummaryCard(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 227 | `_SummaryCard(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 235 | `_SummaryCard(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 261 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 262 | `child: ListTile(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 284 | `return _ActionCard(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 309 | `class _SummaryCard extends StatelessWidget {` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 310 | `const _SummaryCard({` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 330 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 345 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 376 | `class _ActionCard extends StatelessWidget {` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 377 | `const _ActionCard({required this.item, required this.onOpen});` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 397 | `return Card(` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 405 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_action_center.dart` | 538 | `child: const Card(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 103 | `_AuditSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 108 | `_AuditSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 116 | `_AuditSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 123 | `_AuditSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 232 | `return _AuditEntryCard(entry: visibleEntries[index]);` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 250 | `targetDisplayName: '',` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 258 | `class _AuditSummaryCard extends StatelessWidget {` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 259 | `const _AuditSummaryCard({` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 273 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 278 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 303 | `class _AuditEntryCard extends StatelessWidget {` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 304 | `const _AuditEntryCard({required this.entry});` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 312 | `return Card(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 318 | `const CircleAvatar(child: Icon(Icons.history_rounded)),` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 342 | `entry.targetDisplayName,` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 390 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 424 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_audit_log.dart` | 454 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 232 | `Card(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 233 | `child: ListTile(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 248 | `_ReportSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 254 | `_ReportSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 260 | `_ReportSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 266 | `_ReportSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 272 | `_ReportSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 395 | `class _ReportSummaryCard extends StatelessWidget {` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 396 | `const _ReportSummaryCard({` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 412 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 417 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 460 | `return Card(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 597 | `return ListTile(` |
| `lib/features/web_admin/screens/web_admin_operations_reports.dart` | 599 | `leading: const CircleAvatar(child: Icon(Icons.event_rounded)),` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 124 | `_RoleSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 132 | `_RoleSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 140 | `_RoleSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 148 | `_RoleSummaryCard(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 203 | `SwitchListTile(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 223 | `child: SwitchListTile(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 247 | `return _StaffMemberCard(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 272 | `member.displayName.toLowerCase().contains(query) \|\|` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 302 | `member.displayName,` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 361 | `'${member.displayName} is now '` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 382 | `class _RoleSummaryCard extends StatelessWidget {` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 383 | `const _RoleSummaryCard({` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 397 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 402 | `CircleAvatar(child: Icon(icon)),` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 427 | `class _StaffMemberCard extends StatelessWidget {` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 428 | `const _StaffMemberCard({` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 442 | `return Card(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 449 | `CircleAvatar(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 451 | `member.displayName.isEmpty` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 453 | `: member.displayName[0].toUpperCase(),` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 467 | `member.displayName,` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 555 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 586 | `child: Card(` |
| `lib/features/web_admin/screens/web_admin_staff_access.dart` | 617 | `child: Card(` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 61 | `'memberName',` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 62 | `'displayName',` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 172 | `'displayName',` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 208 | `'memberName',` |
| `lib/features/web_admin/services/web_admin_action_center_builder.dart` | 210 | `'displayName',` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 83 | `'targetDisplayName': member.displayName,` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 102 | `return left.displayName.toLowerCase().compareTo(` |
| `lib/features/web_admin/services/web_admin_staff_access_service.dart` | 103 | `right.displayName.toLowerCase(),` |
| `lib/features/web_admin/widgets/web_admin_responsive_navigation.dart` | 45 | `CircleAvatar(` |

## Member photo tests

| File | Line | Source |
| --- | ---: | --- |
| `test/features/home/pastor_appearance_settings_test.dart` | 12 | `expect(settings.imageUrl, isEmpty);` |
| `test/features/home/pastor_appearance_settings_test.dart` | 20 | `'imageUrl': ' https://example.com/pastor.jpg ',` |
| `test/features/home/pastor_appearance_settings_test.dart` | 26 | `expect(settings.imageUrl, 'https://example.com/pastor.jpg');` |
| `test/features/members/member_baptism_record_test.dart` | 12 | `photoUrl: '',` |
| `test/features/members/member_baptism_record_test.dart` | 20 | `photoUrl: '',` |
| `test/features/members/member_baptism_record_test.dart` | 28 | `photoUrl: '',` |
| `test/features/members/member_baptism_record_test.dart` | 49 | `photoUrl: '',` |
| `test/features/members/member_baptism_record_test.dart` | 57 | `photoUrl: '',` |
| `test/features/members/member_baptism_record_test.dart` | 78 | `photoUrl: '',` |
| `test/features/members/member_baptism_record_test.dart` | 86 | `photoUrl: '',` |
| `test/features/members/member_baptism_record_test.dart` | 94 | `photoUrl: '',` |
| `test/features/members/member_baptism_record_test.dart` | 120 | `'photoUrl': 'https://example.com/photo.png',` |
| `test/features/members/member_directory_entry_test.dart` | 46 | `'photoUrl': 'https://example.com/photo.jpg',` |
| `test/features/members/member_self_profile_test.dart` | 51 | `photoUrl: 'https://example.com/member.jpg',` |
| `test/features/members/member_self_profile_test.dart` | 82 | `final publicMap = draft.publicDirectoryMap(photoUrl: '');` |

## Diagnostic summary

- Photo field references: 49
- Profile/member write references: 211
- Web image-rendering references: 13
- Web member-directory references: 116
- Focused member-photo tests: 15

**Likely cause:** the dashboard renders an image, but it may read a different field name than the profile writer uses.


## Stabilization outcome

The Windows Staff Access member model did not read the canonical `photoUrl` field, and each member card always rendered an initial. The stabilization fix carries `photoUrl` from the Firestore member document into `WebAdminStaffMember` and renders an HTTP/HTTPS network photo with an initials fallback for missing, invalid, or failed images.
## Church Member Directory web rendering

The Church Member Directory already read the canonical `photoUrl`, but its `CircleAvatar` used the default Flutter web byte-fetching image provider. The stabilization fix uses `Image.network` with `WebHtmlElementStrategy.fallback`, preserves initials for missing or failed images, and accepts a small set of legacy photo field aliases.