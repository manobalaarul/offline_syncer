// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileEntities _$ProfileEntitiesFromJson(Map<String, dynamic> json) =>
    ProfileEntities(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProfileEntitiesToJson(ProfileEntities instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'created_at': instance.createdAt!.toIso8601String(),
      'updated_at': instance.updatedAt!.toIso8601String(),
    };
