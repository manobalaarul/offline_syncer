import '../../model/profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<Profile> getProfiles(dynamic params);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  @override
  Future<Profile> getProfiles(params) {
    try {
      final response = 
    } catch (e) {}
  }
}
