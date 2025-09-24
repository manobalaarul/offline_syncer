import 'package:dartz/dartz.dart';
import 'package:profile_app/core/error/failures.dart';
import 'package:profile_app/core/usecases/usecases.dart';
import 'package:profile_app/features/domain/entities/profile_entities.dart';
import 'package:profile_app/features/domain/repository/profile/profile_repository.dart';

class GetProfileUsecase implements UseCase<List<ProfileEntities>, dynamic> {
  final ProfileRepository repository;

  GetProfileUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProfileEntities>>> call(params) async {
    // TODO: implement call
    return await repository.getProfiles(params);
  }
}
