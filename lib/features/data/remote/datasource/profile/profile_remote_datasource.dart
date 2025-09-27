import 'package:dio/dio.dart';
import 'package:offline_syncer/offline_syncer.dart';
import 'package:profile_app/core/constants/api_routes.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../model/profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<List<Profile>> getProfiles(dynamic params);
  Future<Profile> createProfile(Profile params);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final DioClient dioClient;
  final OfflineSyncManager _offlineSync;

  ProfileRemoteDatasourceImpl({
    required this.dioClient,
    required OfflineSyncManager offlineSyncer,
  }) : _offlineSync = offlineSyncer; // ✅ Assign here
  @override
  Future<List<Profile>> getProfiles(params) async {
    try {
      final response = await dioClient.get(path: ApiRoutes.getProfiles);
      // Expecting response.data['data'] to be a List<dynamic>
      final profiles = (response.data['data'] as List)
          .map((json) => Profile.fromJson(json))
          .toList();
      print(profiles[0].firstName);
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
  Future<Profile> createProfile(Profile profile) async {
    try {
      print(profile);
      final profileMap = profile.toJson(); // <-- convert to Map
      print("Submitting Profile Map: $profileMap");

      final result = await _offlineSync.submitForm(
        formId: 'profile_form',
        formData: profileMap,
        path: ApiRoutes.createProfile,
      );
      print(result);
      if (result['success'] == true) {
        final profileJson = result['data']?['data'] ?? profileMap;
        return Profile.fromJson(profileJson);
      } else {
        throw ServerException(
          message: result['data']['message'] ?? 'Failed to create profile',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Something went wrong 1',
      );
    } catch (e) {
      throw ServerException(message: 'Something went wrong 2');
    }
  }
}
