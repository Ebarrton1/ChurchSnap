import '../models/small_group.dart';
import '../repositories/small_group_repository.dart';

class SmallGroupService {
  final SmallGroupRepository _repository;

  SmallGroupService(this._repository);

  Stream<List<SmallGroup>> watchGroups() {
    return _repository.watchGroups();
  }

  Future<void> addGroup(SmallGroup group) {
    return _repository.addGroup(group);
  }

  Future<void> updateGroup(SmallGroup group) {
    return _repository.updateGroup(group);
  }

  Future<void> deleteGroup(String id) {
    return _repository.deleteGroup(id);
  }
}
