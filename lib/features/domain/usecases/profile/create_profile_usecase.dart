import 'package:dartz/dartz.dart';
import 'package:profile_app/core/error/failures.dart';
import 'package:profile_app/core/usecases/usecases.dart';
import 'package:profile_app/features/domain/repository/profile/profile_repository.dart';

import '../../entities/profile_response_entities.dart';

class CreateProfileUsecase
    implements UseCase<ProfileResponseEntities, dynamic> {
  final ProfileRepository repository;

  CreateProfileUsecase(this.repository);

  @override
  Future<Either<Failure, ProfileResponseEntities>> call(params) async {
    // TODO: implement call
    return await repository.createProfile(params);
  }
}
