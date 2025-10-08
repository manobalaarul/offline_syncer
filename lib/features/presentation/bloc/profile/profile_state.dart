part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, error }

enum CreateProfileStatus { initial, loading, loaded, error }

enum DeleteProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final bool isLoading;
  final ProfileStatus status;
  final CreateProfileStatus createProfileStatus;
  final DeleteProfileStatus deleteProfileStatus;
  final String? errorMsg;
  final String? createErrorMsg;
  final String? deleteErrorMsg;
  final String? successMsg;
  final List<ProfileEntities>? profiles;

  ProfileState({
    this.isLoading = true,
    this.status = ProfileStatus.initial,
    this.createProfileStatus = CreateProfileStatus.initial,
    this.deleteProfileStatus = DeleteProfileStatus.initial,
    this.errorMsg,
    this.createErrorMsg,
    this.deleteErrorMsg,
    this.successMsg,
    this.profiles,
  });

  ProfileState copyWith({
    bool? isLoading,
    ProfileStatus? status,
    CreateProfileStatus? createProfileStatus,
    DeleteProfileStatus? deleteProfileStatus,
    String? errorMsg,
    String? createErrorMsg,
    String? deleteErrorMsg,
    String? successMsg,
    final List<ProfileEntities>? profiles,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      createProfileStatus: createProfileStatus ?? this.createProfileStatus,
      deleteProfileStatus: deleteProfileStatus ?? this.deleteProfileStatus,
      errorMsg: errorMsg ?? this.errorMsg,
      createErrorMsg: createErrorMsg ?? this.createErrorMsg,
      deleteErrorMsg: deleteErrorMsg ?? this.deleteErrorMsg,
      successMsg: successMsg ?? this.successMsg,
      profiles: profiles ?? this.profiles,
    );
  }
}
