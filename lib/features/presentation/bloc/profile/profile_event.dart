part of 'profile_bloc.dart';

class ProfileEvent {
  const ProfileEvent();
}

class GetProfileEvent extends ProfileEvent {}

class CreateProfileEvent extends ProfileEvent {
  final Profile profile;

  CreateProfileEvent({required this.profile});
}
