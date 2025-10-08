import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../data/remote/model/profile_model.dart';
import '../../../domain/entities/profile_entities.dart';
import '../../../domain/usecases/profile/create_profile_usecase.dart';
import '../../../domain/usecases/profile/delete_profile_usecase.dart';
import '../../../domain/usecases/profile/get_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase getProfileUsecase;
  final CreateProfileUsecase createProfileUsecase;
  final DeleteProfileUsecase deleteProfileUsecase;

  ProfileBloc(
    this.getProfileUsecase,
    this.createProfileUsecase,
    this.deleteProfileUsecase,
  ) : super(ProfileState()) {
    on<GetProfileEvent>(_getProfiles);
    on<CreateProfileEvent>(_createProfile);
    on<DeleteProfileEvent>(_deleteProfile);
  }

  FutureOr<void> _getProfiles(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profiles == null || state.profiles!.isEmpty) {
      emit(state.copyWith(status: ProfileStatus.loading, isLoading: true));
    } else {
      emit(state.copyWith(status: ProfileStatus.loading, isLoading: false));
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
            errorMsg: null, // Clear any previous errors
            deleteProfileStatus:
                DeleteProfileStatus.initial, // Reset delete status
            deleteErrorMsg: null, // Clear delete error
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

    final result = await createProfileUsecase.call(event.profile);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            createProfileStatus: CreateProfileStatus.error,
            createErrorMsg: failure.message,
          ),
        );
      },
      (loadedProfiles) {
        emit(
          state.copyWith(
            createProfileStatus: CreateProfileStatus.loaded,
            createErrorMsg: null,
          ),
        );
        // Refresh the list
        add(GetProfileEvent());

        // Reset create status after short delay
        Future.delayed(Duration(milliseconds: 100), () {
          if (!emit.isDone) {
            emit(
              state.copyWith(createProfileStatus: CreateProfileStatus.initial),
            );
          }
        });
      },
    );
  }

  FutureOr<void> _deleteProfile(
    DeleteProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(deleteProfileStatus: DeleteProfileStatus.loading));

    final result = await deleteProfileUsecase.call(event.id);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            deleteProfileStatus: DeleteProfileStatus.error,
            deleteErrorMsg: failure.message,
          ),
        );
      },
      (success) {
        // Remove from current profiles list optimistically
        print(event.id);
        final updatedProfiles = List<ProfileEntities>.from(state.profiles ?? [])
          ..removeWhere((p) => p.id == event.id);

        emit(
          state.copyWith(
            deleteProfileStatus: DeleteProfileStatus.loaded,
            profiles: updatedProfiles,
            successMsg: success.message,
            errorMsg: "",
          ),
        );

        // Reset delete status after showing success message
        Future.delayed(Duration(seconds: 2), () {
          if (!emit.isDone) {
            emit(
              state.copyWith(deleteProfileStatus: DeleteProfileStatus.initial),
            );
          }
        });
      },
    );
  }
}
