import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

import 'package:ride_share/common/widgets/custom_snackbar.dart';
import 'package:ride_share/controllers/auth_controller.dart';

final logger = Logger('SignupController');

class SignupController extends GetxController {
  // Text Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable Variables
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString selectedUserType = 'Rider'.obs;
  final RxBool isLoading = false.obs;

  /// Pick profile image
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e, stackTrace) {
      logger.severe("Image Picker Error", e, stackTrace);

      SnackbarUtils.showSnackbar(
        title: "Image Error",
        message: e.toString(),
        contentType: ContentType.failure,
      );
    }
  }

  /// Signup
  Future<void> signup() async {
    if (isLoading.value) return;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final username = usernameController.text.trim();
    final mobileNumber = mobileNumberController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validation
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        mobileNumber.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      SnackbarUtils.showSnackbar(
        title: "Missing Information",
        message: "Please fill in all fields.",
        contentType: ContentType.warning,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      SnackbarUtils.showSnackbar(
        title: "Invalid Email",
        message: "Please enter a valid email address.",
        contentType: ContentType.warning,
      );
      return;
    }

    if (!mobileNumber.startsWith('+')) {
      SnackbarUtils.showSnackbar(
        title: "Invalid Phone Number",
        message: "Use international format e.g. +254712345678",
        contentType: ContentType.warning,
      );
      return;
    }

    if (password.length < 8) {
      SnackbarUtils.showSnackbar(
        title: "Weak Password",
        message: "Password must be at least 8 characters.",
        contentType: ContentType.warning,
      );
      return;
    }

    if (password != confirmPassword) {
      SnackbarUtils.showSnackbar(
        title: "Password Mismatch",
        message: "Passwords do not match.",
        contentType: ContentType.warning,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthController.signup(
        firstName,
        lastName,
        username,
        mobileNumber,
        selectedUserType.value,
        email,
        password,
        selectedImage.value,
      );

      if (response != null) {
        SnackbarUtils.showSnackbar(
          title: "Success",
          message: "Account created successfully.",
          contentType: ContentType.success,
        );

        Get.offAllNamed('/login');
      } else {
        SnackbarUtils.showSnackbar(
          title: "Registration Failed",
          message: "Unable to create account.",
          contentType: ContentType.failure,
        );
      }
    } catch (e, stackTrace) {
      logger.severe("Signup Error", e, stackTrace);

      SnackbarUtils.showSnackbar(
        title: "Error",
        message: e.toString(),
        contentType: ContentType.failure,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
}
