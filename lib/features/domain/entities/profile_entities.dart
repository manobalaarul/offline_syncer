// To parse this JSON data, do
//
//     final profileEntities = profileEntitiesFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'profile_entities.g.dart';

List<ProfileEntities> profileEntitiesFromJson(String str) =>
    List<ProfileEntities>.from(
      json.decode(str).map((x) => ProfileEntities.fromJson(x)),
    );

String profileEntitiesToJson(List<ProfileEntities> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class ProfileEntities {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "first_name")
  String firstName;
  @JsonKey(name: "last_name")
  String lastName;
  @JsonKey(name: "email")
  String email;
  @JsonKey(name: "phone")
  String phone;
  @JsonKey(name: "address")
  String address;
  @JsonKey(name: "profile_image")
  String? profileImage;
  @JsonKey(name: "created_at")
  DateTime? createdAt;
  @JsonKey(name: "updated_at")
  DateTime? updatedAt;

  ProfileEntities({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileEntities.fromJson(Map<String, dynamic> json) =>
      _$ProfileEntitiesFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileEntitiesToJson(this);
}
