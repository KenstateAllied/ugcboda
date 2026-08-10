import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  /// Android Emulator:
  /// http://10.0.2.2:8000
  ///
  /// Physical phone:
  /// http://192.168.8.153:8000

  static final String baseURL =
      dotenv.env['API_URL'] ?? "http://172.16.1.8:8000";

  static final String mediaURL = "$baseURL/uploads";

  // ======================
  // Authentication
  // ======================

  static final String login =
      "$baseURL/api/v1/auth/login";

  static final String signup =
      "$baseURL/api/v1/auth/signup";

  static final String logout =
      "$baseURL/api/v1/auth/logout";

  // ======================
  // User
  // ======================

  static final String userProfile =
      "$baseURL/api/v1/users/profile";

  static final String editUserProfile =
      "$baseURL/api/v1/users/profile/edit";

  // ======================
  // Rides
  // ======================

  static final String getRides =
      "$baseURL/api/v1/rides";

  static final String bookedRides =
      "$baseURL/api/v1/rides/booked";

  static final String shareRide =
      "$baseURL/api/v1/rides/new-ride";

  static final String bookRide =
      "$baseURL/api/v1/rides";

  // ======================
  // Messages
  // ======================

  static final String getUserMessages =
      "$baseURL/api/v1/message";

  static final String getGroupChats =
      "$baseURL/api/v1/message";

  static final String sendMessage =
      "$baseURL/api/v1/message/send";
}