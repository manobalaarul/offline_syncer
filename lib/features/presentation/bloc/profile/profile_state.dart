part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final bool isLoading;
  final ProfileStatus status;
  final String? errorMsg;
  final String? successMsg;
  final List<ProfileEntities>? profiles;

  ProfileState({
    this.isLoading = true,
    this.status = ProfileStatus.initial,
    this.errorMsg,
    this.successMsg,
    this.profiles,
  });

  ProfileState copyWith({
    bool? isLoading,
    ProfileStatus? status,
    String? errorMsg,
    String? successMsg,
    final List<ProfileEntities>? profiles,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      errorMsg: errorMsg ?? this.errorMsg,
      successMsg: successMsg ?? this.successMsg,
      profiles: profiles ?? profiles,
    );
  }
}
