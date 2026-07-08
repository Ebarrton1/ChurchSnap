import '../models/check_in_record.dart';
import '../repositories/check_in_repository.dart';

class CheckInService {
  CheckInService(this._repository);

  final CheckInRepository _repository;

  Future<void> checkIn(CheckInRecord record) {
    return _repository.checkIn(record);
  }
}
