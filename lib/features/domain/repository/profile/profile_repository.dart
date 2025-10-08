import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../entities/profile_entities.dart';
import '../../entities/profile_response_entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<ProfileEntities>>> getProfiles(dynamic params);
  Future<Either<Failure, ProfileResponseEntities>> createProfile(dynamic params);
  Future<Either<Failure, ProfileResponseEntities>> deleteProfile(int id);

}
