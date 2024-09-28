import 'package:flutter/material.dart';
import '/auth/login_repo.dart';

class LoginService {
  static Future<void> sendOTP(
    String countryCode,
    String phoneNumber,
    BuildContext context,
  ) async {
    String completePhoneNumber = countryCode + phoneNumber;
    print("Phone Number: $completePhoneNumber");

    try {
      await LoginRepo.sendOTP(completePhoneNumber, context);
    } catch (e) {
      print("Error during sending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    }
  }

  static Future<void> verifyOTP(String otp, BuildContext context) async {
    try {
      bool success = await LoginRepo.verifyOTP(otp);

      if (success) {
        // Login Success.
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP, please try again.')),
        );
      }
    } catch (e) {
      print("Error during OTP verification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: $e')),
      );
    }
  }
}
