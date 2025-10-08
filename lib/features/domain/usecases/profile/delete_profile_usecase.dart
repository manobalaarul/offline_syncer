import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecases.dart';
import '../../entities/profile_response_entities.dart';
import '../../repository/profile/profile_repository.dart';

class DeleteProfileUsecase
    implements UseCase<ProfileResponseEntities, dynamic> {
  final ProfileRepository repository;

  DeleteProfileUsecase(this.repository);

  @override
  Future<Either<Failure, ProfileResponseEntities>> call(id) async {
    // TODO: implement call
    return await repository.deleteProfile(id);
  }
}
