// To parse this JSON data, do
//
//     final profileResponseEntities = profileResponseEntitiesFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../../data/remote/model/profile_model.dart';

part 'profile_response_entities.g.dart';

ProfileResponseEntities profileResponseEntitiesFromJson(String str) =>
    ProfileResponseEntities.fromJson(json.decode(str));

String profileResponseEntitiesToJson(ProfileResponseEntities data) =>
    json.encode(data.toJson());

@JsonSerializable()
class ProfileResponseEntities {
  @JsonKey(name: "status")
  String? status;
  @JsonKey(name: "message")
  String? message;
  @JsonKey(name: "data")
  Profile? profile;

  ProfileResponseEntities({
    required this.status,
    required this.message,
    this.profile,
  });

  factory ProfileResponseEntities.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseEntitiesFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseEntitiesToJson(this);
}
