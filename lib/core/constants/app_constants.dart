class ApiConstants {
  static const String baseUrl = "http://192.168.137.1/profile_app_api/";
  // static const String baseUrl =
  //     "https://876959c207cd.ngrok-free.app/profile_app_api/";
  static const int connectionTimeout = 2; // 2 minutes
  static const int receiveTimeout = 3; // 3 minutes

  // Error Messages
  static const String serverError = 'Server Error';
  static const String connectionError = 'Connection Error';
  static const String invalidResponse = 'Invalid Response';
}
