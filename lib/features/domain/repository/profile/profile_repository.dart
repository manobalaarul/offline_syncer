import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../entities/profile_entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<ProfileEntities>>> getProfiles(dynamic params);
}
