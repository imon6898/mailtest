import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import '../../custom_widget/custom_text_field.dart';
import '../../methods/common_methods.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
   SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();
  FocusNode focusNode = FocusNode();
  bool passwordVisible = false;
  CommonMethods cMethods = CommonMethods();

  void registrationIn() async {
    try {
      var headers = {
        'Accept': 'application/ld+json',
        'Content-Type': 'application/ld+json',
      };
      var body = json.encode({
        "address": userNameController.text,
        "password": passwordController.text,
      });

      var response = await http.post(
        Uri.parse('https://api.mail.tm/accounts'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        print('Registration successful');
        // Show a snackbar message indicating successful registration
        cMethods.displaySnackBarGreen("Registration successful", context);
        // Navigate to the login page after successful registration
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        print('Registration failed: ${response.reasonPhrase}');
        // Display an error message to the user
        cMethods.displaySnackBarRed("Registration failed: ${response.reasonPhrase}", context);
      }
    } catch (error) {
      print('Error during registration: $error');
      // Display an error message to the user
      cMethods.displaySnackBarRed("Error during registration: $error", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Lottie.asset(
            'lib/assets/Images/login_page_animation.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Container(
              height: screenHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                          },
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
                        ),
                        elevation: 0,
                      ),
                      Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 180,
                                width: 180,
                                child: Lottie.asset(
                                  'lib/assets/Images/animation_login.json',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                "Registration",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                              )
                            ],
                          ),
                          SizedBox(height: 20,),
                          CustomTextFields(
                            controller: userNameController,
                            labelText: 'Email',
                            hintText: 'user@mitico.org',
                            disableOrEnable: true,
                            borderColor: 0xFFBCC2C2,
                            filled: false,
                            prefixIcon: Icons.account_circle,
                          ),
                          CustomTextFields(
                            controller: passwordController,
                            labelText: 'Password',
                            hintText: 'Password',
                            disableOrEnable: true,
                            borderColor: 0xFFBCC2C2,
                            filled: false,
                            prefixIcon: Icons.password_rounded,
                            obscureText: !passwordVisible, // Toggle password visibility
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (){
                                  registrationIn();
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      side: BorderSide(
                                        color: Colors.white,
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "I have an account...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
