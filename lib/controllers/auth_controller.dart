import 'dart:async';
import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:ride_share/common/widgets/custom_snackbar.dart';
import 'package:ride_share/services/storage_service.dart';
import 'package:ride_share/utils/constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';import 'dart:io';
import 'package:http_parser/http_parser.dart';


final logger = Logger("AuthController");

class AuthController {
  /// ==========================
  /// LOGIN
  /// ==========================
  
static Future<Map<String, dynamic>?> login(
  String username,
  String password,
) async {
  try {
    print("POST => ${ApiConstants.login}");
    print("Username => $username");

    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "username": username.trim(),
        "password": password,
      },
    );

    print("STATUS => ${response.statusCode}");
    print("BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  } catch (e) {
    print(e);
    return null;
  }
}
    
  /// ==========================
  /// SIGNUP
  /// ==========================
  
  /// ==========================
  
static Future<Map<String, dynamic>?> signup(
  String firstName,
  String lastName,
  String username,
  String mobileNumber,
  String gender,
  String email,
  String password,
  File? profileImage,
) async {

  try {

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(ApiConstants.signup),
    );

    request.fields["first_name"] = firstName;
    request.fields["last_name"] = lastName;
    request.fields["username"] = username;
    request.fields["mobile_number"] = mobileNumber;
    request.fields["gender"] = gender;
    request.fields["email"] = email;
    request.fields["password"] = password;

    if (profileImage != null) {

      final ext = profileImage.path.split(".").last.toLowerCase();

      request.files.add(
        await http.MultipartFile.fromPath(
          "profile_image",
          profileImage.path,
          contentType: MediaType(
            "image",
            ext == "png" ? "png" : "jpeg",
          ),
        ),
      );
    }

    print("POST => ${ApiConstants.signup}");
    print(request.fields);

    final streamed = await request.send();

    final response = await http.Response.fromStream(streamed);

    logger.info(response.body);

    if (response.statusCode == 201) {

      SnackbarUtils.showSnackbar(
        title: "Success",
        message: "Account created successfully.",
        contentType: ContentType.success,
      );

      return jsonDecode(response.body);
    }

    print(response.body);

    SnackbarUtils.showSnackbar(
      title: "Signup Failed",
      message: response.body,
      contentType: ContentType.failure,
    );

    return null;

  } catch (e) {

    logger.severe(e);

    SnackbarUtils.showSnackbar(
      title: "Error",
      message: e.toString(),
      contentType: ContentType.failure,
    );

    return null;
  }
}
  /// ==========================
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("access_token");

      if (token == null) {
        Get.offAllNamed("/login");
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.logout),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        await StorageService.clearUserInfo();
        Get.offAllNamed("/login");
      } else {
        SnackbarUtils.showSnackbar(
          title: "Logout Failed",
          message: "Unable to logout.",
          contentType: ContentType.failure,
        );
      }
    } catch (e) {
      SnackbarUtils.showSnackbar(
        title: "Error",
        message: e.toString(),
        contentType: ContentType.failure,
      );
    }
  }
}