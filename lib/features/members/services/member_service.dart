import '../models/church_member.dart';
import '../repositories/member_repository.dart';

class MemberService {
  MemberService(this._repository);

  final MemberRepository _repository;

  Stream<List<ChurchMember>> watchMembers() {
    return _repository.watchMembers();
  }

  Future<void> addMember(ChurchMember member) {
    return _repository.addMember(member);
  }

  Future<void> updateMember(ChurchMember member) {
    return _repository.updateMember(member);
  }

  Future<void> deleteMember(String memberId) {
    return _repository.deleteMember(memberId);
  }
}
