part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, error }

enum CreateProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final bool isLoading;
  final ProfileStatus status;
  final CreateProfileStatus createProfileStatus;
  final String? errorMsg;
  final String? successMsg;
  final List<ProfileEntities>? profiles;

  ProfileState({
    this.isLoading = true,
    this.status = ProfileStatus.initial,
    this.createProfileStatus = CreateProfileStatus.initial,
    this.errorMsg,
    this.successMsg,
    this.profiles,
  });

  ProfileState copyWith({
    bool? isLoading,
    ProfileStatus? status,
    CreateProfileStatus? createProfileStatus,
    String? errorMsg,
    String? successMsg,
    final List<ProfileEntities>? profiles,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      createProfileStatus: createProfileStatus ?? this.createProfileStatus,
      errorMsg: errorMsg ?? this.errorMsg,
      successMsg: successMsg ?? this.successMsg,
      profiles: profiles ?? this.profiles,
    );
  }
}
