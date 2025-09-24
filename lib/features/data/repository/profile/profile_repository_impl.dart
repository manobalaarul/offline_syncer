import 'package:dartz/dartz.dart';
import 'package:profile_app/features/data/remote/datasource/profile/profile_remote_datasource.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../domain/entities/profile_entities.dart';
import '../../../domain/repository/profile/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource profileRemoteDatasource;

  ProfileRepositoryImpl({required this.profileRemoteDatasource});
  @override
  Future<Either<Failure, List<ProfileEntities>>> getProfiles(params) async {
    try {
      final getProfiles = await profileRemoteDatasource.getProfiles(params);
      return Right(getProfiles);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Unexpected error'));
    }
  }
}
