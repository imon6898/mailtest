import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qtech/pages/auth_page/regiser_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Custom_widget/custom_text_field.dart';
import '../../methods/common_methods.dart';
import '../../models/login_model.dart';
import '../../splash_screen.dart';
import '../dashboard/dashboard_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  SharedPreferences? sharedPreferences;

  String? save;
  Map<String, dynamic>? jsonResponse;
  CommonMethods cMethods = CommonMethods();

  bool rememberMe = false;
  bool passwordVisible = false;
  bool _isLoading = false;

  List<Map<String, String>> userCredentialsList = [];




  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userNameController.text = prefs.getString('userName') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  void saveCredentials(String userName, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
    prefs.setBool('rememberMe', rememberMe);

    var status = await Permission.storage.request();
    if (status.isGranted) {
      prefs.setString('password', password);
      Map<String, String> credentials = {'userName': userName, 'password': password};
      userCredentialsList.add(credentials);
      prefs.setString('userCredentialsList', json.encode(userCredentialsList));
    } else {
      print('Permission not granted to save password.');
    }
  }

  void signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var url = Uri.parse('${BaseUrl.baseUrl}/token');
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      var body = json.encode({
        "address": userNameController.text,
        "password": passwordController.text,
      });

      var response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var loginModel = LoginModel.fromJson(jsonResponse);
        saveLoginData(loginModel);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashBoard(loginModel: loginModel)),
        );
        if (rememberMe) {
          saveCredentials(userNameController.text, passwordController.text);
        }
        cMethods.displaySnackBarGreen("Login successful", context);
      } else {
        print('Login failed: ${response.reasonPhrase}');
        cMethods.displaySnackBarRed("Login Failed", context);
      }
    } catch (error) {
      print('Error during login: $error');
    }
    setState(() {
      _isLoading = false;
    });
  }

  void saveLoginData(LoginModel loginData) async {
    var box = await Hive.openBox('loginData');
    String jsonData = json.encode(loginData.toJson());
    box.put('userData', jsonData);
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
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        elevation: 0,
                      ),
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
                          Text("Login", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),)
                        ],
                      ),
                      SizedBox(height: 20),
                      CustomTextFields(
                        controller: userNameController,
                        labelText: 'User Name',
                        hintText: 'User Name',
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
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          icon: Icon(
                            passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                        obscureText: !passwordVisible,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              rememberMe = !rememberMe;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetSandOtpPage()));
                                },
                                child: Text(
                                  "Forget password",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),


                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  signIn();
                                },
                                child: Text(
                                  "Sign In",
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
                            "I have no account...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage(),));
                            },
                            child: Text(
                              "Register",
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

