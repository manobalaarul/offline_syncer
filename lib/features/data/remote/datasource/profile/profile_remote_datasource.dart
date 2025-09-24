import 'package:dio/dio.dart';
import 'package:profile_app/core/constants/api_routes.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../model/profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<List<Profile>> getProfiles(dynamic params);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final DioClient dioClient;

  ProfileRemoteDatasourceImpl({required this.dioClient});
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
}
