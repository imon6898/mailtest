import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:qtech/pages/auth_page/login_page.dart';
import 'package:qtech/pages/dashboard/dashboard_page.dart';
import 'models/login_model.dart';


class SplashScreen extends StatefulWidget {
  final storage = FlutterSecureStorage();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Lottie Animation as Background
          Lottie.asset(
            'lib/assets/Images/screen.lottie.json', // Replace with your Lottie animation file
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Positioned widget placed directly inside Stack
          Positioned(
            top: MediaQuery.of(context).size.height / 3, // Adjust the top position as needed
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Your Image
                  Image.asset(
                    'lib/assets/Images/qtech_logo.png', // Replace with your image file
                    width: 400, // Adjust the width as needed
                    height: 400, // Adjust the height as needed
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkConnectivityThenNavigate(); // Check connectivity before navigating
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // Initialize Scale Animation
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  void checkConnectivityThenNavigate() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // If there is no internet connection, show a message box
      showNoInternetDialog();
    } else {
      // If there is internet connection, proceed with navigation
      navigateToNextScreen();
    }
  }

  void showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please connect to the internet to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Exit the app if the user dismisses the dialog
                exit(0);
              },
              child: Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2));

    // Check if the user is logged in using Hive
    bool isLoggedIn = await checkIfUserIsLoggedIn();

    if (isLoggedIn) {
      // Retrieve user data from Hive
      var box = Hive.box('loginData');
      var userDataJson = box.get('userData');

      print('userDataJson: $userDataJson'); // Add this line for debugging

      if (userDataJson != null) {
        try {
          // Explicitly convert userDataJson to a string and trim whitespaces
          String jsonString = userDataJson.toString().trim();

          // Check if jsonString is not empty
          if (jsonString.isNotEmpty) {
            // Decode the JSON string more gracefully
            var decodedUserData = json.decode(jsonString);
            if (decodedUserData is Map<String, dynamic>) {
              var loginModel = LoginModel.fromJson(decodedUserData);

              print('Decoded userData: $loginModel'); // Add this line for debugging

              // Pass the actual data to IndexingPage
              Get.off(DashBoard(loginModel: loginModel));
              return; // Exit the method after navigation
            } else {
              print('Decoded userData is not a Map');
            }
          } else {
            print('JSON string is empty');
          }
        } catch (e) {
          // Log the error and take appropriate action
          print('Error decoding userData: $e');
        }
      } else {
        // Handle the case where userDataJson is null
        print('userDataJson is null');
      }
    }

    // If no saved credentials are found or encountered any error, navigate to the login screen
    Get.off(LoginPage());
  }


  Future<bool> checkIfUserIsLoggedIn() async {
    // Check if the authentication token is present in Hive
    var box = Hive.box('loginData');
    return box.get('userData') != null;
  }

  void handleDecodingError() {
    // Handle the error, e.g., show an error message
    Get.snackbar(
      'Error',
      'An error occurred while decoding user data. Please log in again.',
      snackPosition: SnackPosition.BOTTOM,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred while decoding user data. Please log in again.'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate to the login screen
    Get.off(LoginPage());
  }
}

class BaseUrl {
  static const String baseUrl = 'https://api.mail.tm';
  static const String authorization = 'Basic YWRtaW5pc3RyYXRvcjpBQyFAIyQxMjQzdXNlcg==';
  static const String TOKEN = 'Token';
}
