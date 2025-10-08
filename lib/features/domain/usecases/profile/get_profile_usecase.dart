import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecases.dart';
import '../../entities/profile_entities.dart';
import '../../repository/profile/profile_repository.dart';

class GetProfileUsecase implements UseCase<List<ProfileEntities>, dynamic> {
  final ProfileRepository repository;

  GetProfileUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProfileEntities>>> call(params) async {
    // TODO: implement call
    return await repository.getProfiles(params);
  }
}
