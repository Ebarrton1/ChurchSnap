import '../models/church_member.dart';
import '../models/member_profile_details.dart';
import '../repositories/member_repository.dart';

class MemberService {
  MemberService(this._repository);

  final MemberRepository _repository;

  Stream<List<ChurchMember>> watchMembers() {
    return _repository.watchMembers();
  }

  Stream<MemberProfileDetails> watchPrivateProfile(String memberId) {
    return _repository.watchPrivateProfile(memberId);
  }

  Future<void> addMember(ChurchMember member) {
    return _repository.addMember(member);
  }

  Future<void> updateMember(ChurchMember member) {
    return _repository.updateMember(member);
  }

  Future<void> savePrivateProfile({
    required String memberId,
    required MemberProfileDetails details,
  }) {
    return _repository.savePrivateProfile(memberId: memberId, details: details);
  }

  Future<void> updateMemberWithPrivateProfile({
    required ChurchMember member,
    required MemberProfileDetails details,
  }) {
    return _repository.updateMemberWithPrivateProfile(
      member: member,
      details: details,
    );
  }

  Future<void> deleteMember(String memberId) {
    return _repository.deleteMember(memberId);
  }
}
