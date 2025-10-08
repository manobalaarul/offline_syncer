// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponseEntities _$ProfileResponseEntitiesFromJson(
  Map<String, dynamic> json,
) => ProfileResponseEntities(
  status: json['status'] as String?,
  message: json['message'] as String?,
  profile: json['data'] == null
      ? null
      : Profile.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileResponseEntitiesToJson(
  ProfileResponseEntities instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'data': instance.profile,
};
