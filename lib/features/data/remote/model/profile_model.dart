import 'dart:convert';

import '../../../domain/entities/profile_entities.dart';

List<Profile> profileFromJson(String str) =>
    List<Profile>.from(json.decode(str).map((x) => Profile.fromJson(x)));

String profileToJson(List<Profile> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Profile extends ProfileEntities {
  Profile({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.address,
    super.createdAt,
    super.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "address": address,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
