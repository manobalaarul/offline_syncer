import 'package:dartz/dartz.dart';
import 'package:profile_app/core/error/failures.dart';
import 'package:profile_app/core/usecases/usecases.dart';
import 'package:profile_app/features/domain/entities/profile_entities.dart';
import 'package:profile_app/features/domain/repository/profile/profile_repository.dart';

class CreateProfileUsecase implements UseCase<ProfileEntities, dynamic> {
  final ProfileRepository repository;

  CreateProfileUsecase(this.repository);

  @override
  Future<Either<Failure, ProfileEntities>> call(params) async {
    // TODO: implement call
    return await repository.createProfile(params);
  }
}
