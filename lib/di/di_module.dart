import 'package:get_it/get_it.dart';
import 'package:profile_app/features/presentation/bloc/profile/profile_bloc.dart';

import '../core/network/dio_client.dart';
import '../features/data/remote/datasource/profile/profile_remote_datasource.dart';
import '../features/data/repository/profile/profile_repository_impl.dart';
import '../features/domain/repository/profile/profile_repository.dart';
import '../features/domain/usecases/profile/get_profile_usecase.dart';

final sl = GetIt.instance;

class DiModule {
  Future<void> init() async {
    //Bloc
    sl.registerFactory(() => ProfileBloc(sl()));

    //Usecase
    sl.registerLazySingleton(() => GetProfileUsecase(sl()));

    //Repository
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(profileRemoteDatasource: sl()),
    );

    //DataSource
    sl.registerLazySingleton<ProfileRemoteDatasource>(
      () => ProfileRemoteDatasourceImpl(dioClient: sl()),
    );

    //Core
    sl.registerLazySingleton(() => DioClient());
  }
}
