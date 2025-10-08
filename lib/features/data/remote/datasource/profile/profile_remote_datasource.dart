import 'package:dio/dio.dart';
import 'package:offline_syncer/offline_syncer.dart';

import '../../../../../core/constants/api_routes.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../domain/entities/profile_response_entities.dart';
import '../../model/profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<List<Profile>> getProfiles(dynamic params);
  Future<ProfileResponseEntities> createProfile(Profile params);
  Future<ProfileResponseEntities> deleteProfile(int id);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final DioClient dioClient;
  final OfflineSyncManager _offlineSync;

  ProfileRemoteDatasourceImpl({
    required this.dioClient,
    required OfflineSyncManager offlineSyncer,
  }) : _offlineSync = offlineSyncer;

  @override
  Future<List<Profile>> getProfiles(params) async {
    try {
      final response = await dioClient.get(path: ApiRoutes.getProfiles);
      print(response);
      final profiles = (response.data['data'] as List)
          .map((json) => Profile.fromJson(json))
          .toList();
      return profiles;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Something went wrong',
      );
    } catch (e) {
      throw ServerException(message: 'Something went wrong');
    }
  }

  @override
  Future<ProfileResponseEntities> createProfile(Profile profile) async {
    try {
      print(profile);
      final profileMap = profile.toJson();

      final result = await _offlineSync.submitForm(
        formId: 'Profile Form',
        formData: profileMap,
        path: ApiRoutes.createProfile,
      );

      if (result['success'] == true) {
        final profileJson = result['data']?['data'] ?? profileMap;
        print("Response : ${result['data']}");
        return ProfileResponseEntities.fromJson({
          "status": "success",
          "message": "Profile created successfully",
          "data": profileJson,
        });
      } else {
        // Handle different error response structures
        String errorMessage;

        if (result.containsKey('stored_offline') &&
            result['stored_offline'] == true) {
          errorMessage = result['message'] ?? "Stored offline for later sync";
        } else {
          final errorData = result['data'];
          errorMessage =
              errorData?['message'] ?? result['message'] ?? "Unknown error";
        }

        throw ServerException(message: errorMessage);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Something went wrong');
    }
  }

  @override
  Future<ProfileResponseEntities> deleteProfile(int id) async {
    try {
      print("Id $id");
      final response = await dioClient.delete(
        path: ApiRoutes.deleteProfile,
        queryParameters: {"id": id},
      );
      if (response.data['status'] == "success") {
        print(response.data);

        return ProfileResponseEntities.fromJson({
          "status": response.data['status'],
          "message": response.data['message'],
          "data": null,
        });
      } else {
        throw ServerException(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Something went wrong 2',
      );
    } catch (e) {
      throw ServerException(message: 'Something went wrong 1');
    }
  }
}
