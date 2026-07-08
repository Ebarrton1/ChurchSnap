import '../models/volunteer_assignment.dart';
import '../repositories/volunteer_repository.dart';

class VolunteerService {
  final VolunteerRepository _repository;

  VolunteerService(this._repository);

  Stream<List<VolunteerAssignment>> watchAssignments() {
    return _repository.watchAssignments();
  }

  Stream<List<VolunteerAssignment>> watchAssignmentsForMember(String memberId) {
    return _repository.watchAssignmentsForMember(memberId);
  }

  Future<void> addAssignment(VolunteerAssignment assignment) {
    return _repository.addAssignment(assignment);
  }

  Future<void> updateAssignment(VolunteerAssignment assignment) {
    return _repository.updateAssignment(assignment);
  }

  Future<void> deleteAssignment(String id) {
    return _repository.deleteAssignment(id);
  }
}
