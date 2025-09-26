import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:profile_app/features/data/remote/model/profile_model.dart';

import '../../../domain/entities/profile_entities.dart';
import '../../../domain/usecases/profile/create_profile_usecase.dart';
import '../../../domain/usecases/profile/get_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase getProfileUsecase;
  final CreateProfileUsecase createProfileUsecase;

  ProfileBloc(this.getProfileUsecase, this.createProfileUsecase)
    : super(ProfileState()) {
    on<GetProfileEvent>(_getProfiles);
    on<CreateProfileEvent>(_createProfile);
  }

  FutureOr<void> _getProfiles(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profiles == null || state.profiles!.isEmpty) {
      emit(state.copyWith(status: ProfileStatus.loading));
    } else {
      emit(state.copyWith(status: ProfileStatus.loaded));
    }

    final result = await getProfileUsecase.call({});
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMsg: failure.message,
            isLoading: false,
          ),
        );
      },
      (loadedProfiles) {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            profiles: loadedProfiles,
            isLoading: false,
          ),
        );
      },
    );
  }

  FutureOr<void> _createProfile(
    CreateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(createProfileStatus: CreateProfileStatus.loading));

    final result = await createProfileUsecase.call(event.profile.toJson());
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            createProfileStatus: CreateProfileStatus.error,
            errorMsg: failure.message,
            isLoading: false,
          ),
        );
      },
      (loadedProfiles) {
        emit(
          state.copyWith(
            createProfileStatus: CreateProfileStatus.loaded,
            isLoading: false,
          ),
        );
      },
    );
  }
}
