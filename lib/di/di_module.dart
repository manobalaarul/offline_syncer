import 'package:get_it/get_it.dart';
import 'package:offline_syncer/offline_syncer.dart';
import 'package:profile_app/features/domain/usecases/profile/delete_profile_usecase.dart';

import '../core/network/dio_client.dart';
import '../features/data/remote/datasource/profile/profile_remote_datasource.dart';
import '../features/data/repository/profile/profile_repository_impl.dart';
import '../features/domain/repository/profile/profile_repository.dart';
import '../features/domain/usecases/profile/create_profile_usecase.dart';
import '../features/domain/usecases/profile/get_profile_usecase.dart';
import '../features/presentation/bloc/profile/profile_bloc.dart';

final sl = GetIt.instance;

class DiModule {
  Future<void> init() async {
    //Bloc
    sl.registerFactory(() => ProfileBloc(sl(), sl(), sl()));

    //Usecase
    sl.registerLazySingleton(() => GetProfileUsecase(sl()));
    sl.registerLazySingleton(() => CreateProfileUsecase(sl()));
    sl.registerLazySingleton(() => DeleteProfileUsecase(sl()));

    //Repository
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(profileRemoteDatasource: sl()),
    );

    //DataSource
    sl.registerLazySingleton<ProfileRemoteDatasource>(
      () => ProfileRemoteDatasourceImpl(dioClient: sl(), offlineSyncer: sl()),
    );

    //Core
    sl.registerLazySingleton(() => DioClient());
    sl.registerLazySingleton(() => OfflineSyncManager()); // ✅ Add this
  }
}
