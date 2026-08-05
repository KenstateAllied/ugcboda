import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import 'package:ride_share/controllers/signup_controller.dart';
import 'package:ride_share/utils/constants/colors.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({
    super.key,
    required this.signupController,
  });

  final SignupController signupController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create your account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 20),

            userProfilePic(),

            const SizedBox(height: 20),

            firstNameField(),

            const SizedBox(height: 16),

            lastNameField(),

            const SizedBox(height: 16),

            usernameField(),

            const SizedBox(height: 16),
            phoneField(),

            const SizedBox(height: 16),
            UserTypeField(),

            const SizedBox(height: 16),

            emailField(),

            const SizedBox(height: 16),


            const SizedBox(height: 16),

            passwordField(),

            const SizedBox(height: 16),

            confirmPasswordField(),

            const SizedBox(height: 24),

            signupButton(),
          ],
        ),
      ),
    );
  }

  Widget signupButton() {
    return SizedBox(
      height: 50,
      child: Obx(
        () => ElevatedButton(
          onPressed: signupController.isLoading.value
              ? null
              : signupController.signup,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
          child: signupController.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }

  Widget firstNameField() {
    return TextField(
      controller: signupController.firstNameController,
      decoration: const InputDecoration(
        labelText: "First Name",
        border: OutlineInputBorder(),
        prefixIcon: Icon(LineIcons.user),
      ),
    );
  }

  Widget lastNameField() {
    return TextField(
      controller: signupController.lastNameController,
      decoration: const InputDecoration(
        labelText: "Last Name",
        border: OutlineInputBorder(),
        prefixIcon: Icon(LineIcons.user),
      ),
    );
  }

  Widget usernameField() {
    return TextField(
      controller: signupController.usernameController,
      decoration: const InputDecoration(
        labelText: "Username",
        border: OutlineInputBorder(),
        prefixIcon: Icon(LineIcons.tag),
      ),
    );
  }

  

  Widget phoneField() {
    return TextField(
      controller: signupController.mobileNumberController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: "Phone Number",
        hintText: "+254712345678",
        border: OutlineInputBorder(),
        prefixIcon: Icon(LineIcons.phone),
      ),
    );
  }

  Widget UserTypeField() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: signupController.selectedUserType.value,
        decoration: const InputDecoration(
          labelText: "User Type",
          border: OutlineInputBorder(),
          prefixIcon: Icon(LineIcons.venusMars),
        ),
        items: const [
          DropdownMenuItem(
            value: "Rider",
            child: Text("Rider"),
          ),
          DropdownMenuItem(
            value: "Client",
            child: Text("Client"),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            signupController.selectedUserType.value = value;
          }
        },
      ),
    );
  }
Widget emailField() {
    return TextField(
      controller: signupController.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email",
        border: OutlineInputBorder(),
        prefixIcon: Icon(LineIcons.envelope),
      ),
    );
  }

  Widget passwordField() {
    return TextField(
      controller: signupController.passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(),
        prefixIcon: Icon(LineIcons.lock),
      ),
    );
  }

  Widget confirmPasswordField() {
    return TextField(
      controller: signupController.confirmPasswordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Confirm Password",
        border: OutlineInputBorder(),
        prefixIcon: Icon(LineIcons.lock),
      ),
    );
  }

  Widget userProfilePic() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Obx(
            () => CircleAvatar(
              radius: 45,
              backgroundImage: signupController.selectedImage.value != null
                  ? FileImage(signupController.selectedImage.value!)
                  : const AssetImage(
                          "assets/images/ugclogo.jpeg")
                      as ImageProvider,
            ),
          ),
          Positioned(
            bottom: -5,
            right: -5,
            child: FloatingActionButton.small(
              heroTag: "profilePic",
              backgroundColor: kPrimaryColor,
              onPressed: signupController.pickImage,
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }
}