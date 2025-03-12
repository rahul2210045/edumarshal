import 'dart:convert';
import 'dart:io';

import 'package:edumarshals/Screens/HomePage/Homepage.dart';
import 'package:edumarshals/Screens/Password/forget_password.dart';
import 'package:edumarshals/Utils/Utilities/utilities2.dart';
import 'package:edumarshals/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool isChecked = false;
  bool _isLoading = false;
  DateTime? selectedDate;

  /// Function to handle date selection
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2025),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF004BB8),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  /// Function to save login details and handle API call
  Future<void> _saveItem() async {
    setState(() {
      _isLoading = true;
    });
    String formattedDate = selectedDate != null
        ? DateFormat('dd-MM-yyyy').format(selectedDate!)
        : '';
    PreferencesManager().dob = formattedDate;
    final url = Uri.https('akgec-edu.onrender.com', '/v1/student/login');

    final Map<String, String> requestBody = {
      'password': _passController.text,
      'username': _usernameController.text,
      'dob': formattedDate,
    };

    try {
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _handleSuccessfulLogin(response);
      } else {
        _handleFailedLogin(response);
      }
    } catch (e) {
      _handleError(e, formattedDate);
    }
  }

  /// Function to handle successful login
  void _handleSuccessfulLogin(http.Response response) async {
    dynamic setCookieHeader = response.headers['set-cookie'];
    List<String>? cookies;

    if (setCookieHeader is String) {
      cookies = [setCookieHeader];
    } else if (setCookieHeader is List<String>) {
      cookies = setCookieHeader;
    } else {
      cookies = [];
    }

    String accessToken = cookies
        .map((cookie) => cookie.split(';').first)
        .firstWhere((value) => value.startsWith('accessToken='), orElse: () => '');
    String actualAccessToken = accessToken.substring("accesstoken=".length);

    PreferencesManager().token = actualAccessToken;

    final Map<String, dynamic> responseData = json.decode(response.body);
    final message = responseData['message'];
    final name = responseData['name'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );

    setState(() {
      _isLoading = false;
    });

    if (isChecked) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', _usernameController.text);
      prefs.setString('password', _passController.text);
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Homepage()));
  }

  /// Function to handle failed login
  void _handleFailedLogin(http.Response response) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final message = responseData['message'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
    setState(() {
      _isLoading = false;
    });
  }

  /// Function to handle errors during login
  void _handleError(dynamic error, String formattedDate) {
    print('Error: $error');
    print('dob :$formattedDate');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    _loadSavedCredentials();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(0, 75, 184, 1),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              _buildBackgroundContainers(screenHeight, screenWidth),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        textAlign: TextAlign.center,
                        text: "Login",
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 42,
                        fontStyle: null,
                        fontfamily: '',
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  _buildLoginForm(screenHeight, screenWidth),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.089),
                  Image.asset(
                    'assets/Frame 100.png',
                    scale: 4.5,
                  ),
                  SizedBox(height: screenHeight * 0.345),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveItem();
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromRGBO(0, 75, 184, 1))),
                    child: const Text(
                      '       Log in       ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.15),
                  const CustomText(
                    text: "Forget your password?",
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: null,
                    fontfamily: '',
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()));
                    },
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: Color(0xFFFBFBFB),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF4E82EA)),
                      strokeWidth: 5.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Function to load saved credentials from SharedPreferences
  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');
    final savedDob = PreferencesManager().dob;

    if (savedUsername != null) {
      _usernameController.text = savedUsername;
      setState(() {
        isChecked = true;
      });
    }

    if (savedPassword != null) {
      _passController.text = savedPassword;
    }

    if (savedDob != null) {
      final savedDate = DateFormat('dd-MM-yyyy').parse(PreferencesManager().dob);
      setState(() {
        selectedDate = savedDate;
      });
    }
  }

  /// Function to build the background containers
  Widget _buildBackgroundContainers(double screenHeight, double screenWidth) {
    return Column(
      children: [
        _buildContainer(screenHeight * 0.79, screenWidth * 1, 440, 550),
        _buildContainer(screenHeight * 0.786, screenWidth * 1, 440, 350),
        _buildContainer(screenHeight * 0.78, screenWidth * 1, 210, 130),
        _buildContainer(screenHeight * 0.77, screenWidth * 1, 310, 130),
        _buildContainer(screenHeight * 0.75, screenWidth * 1, 400, 95),
      ],
    );
  }

  /// Function to build a single background container
  Widget _buildContainer(double height, double width, double radiusX, double radiusY) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 197, 212, 220),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(radiusX, radiusY),
          bottomRight: Radius.elliptical(radiusX, radiusY),
        ),
      ),
    );
  }

  /// Function to build the login form
  Widget _buildLoginForm(double screenHeight, double screenWidth) {
    return Container(
      width: screenWidth * 0.85,
      height: screenHeight * 0.47,
      decoration: ShapeDecoration(
        color: const Color(0xFFFBFBFB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x26E0E0E0),
            blurRadius: 30,
            offset: Offset(0, 3),
            spreadRadius: 3,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [
          SizedBox(height: screenHeight * 0.05),
          buildtextfiled(
            'asset/images/user.png',
            "User ID",
            context,
            "Enter User ID",
            false,
            _usernameController,
          ),
          SizedBox(height: screenHeight * 0.02),
          buildtextfiled(
            'asset/images/user.png',
            "Password",
            context,
            "Enter Password",
            false,
            _passController,
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildDateOfBirthField(screenWidth),
          _buildRememberMeCheckbox(screenWidth), // Pass screenWidth here
        ]),
      ),
    );
  }

  /// Function to build the date of birth field
  Widget _buildDateOfBirthField(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 50.0),
          child: CustomText(
            text: "Date of Birth",
            color: Color(0xFF3386FF),
            fontSize: 12,
            fontStyle: null,
            fontfamily: 'Poppins',
          ),
        ),
        Padding(padding: EdgeInsets.all(4)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: screenWidth * 0.7,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0),
                  child: Center(
                    child: selectedDate == null
                        ? Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  'assets/calendar.png',
                                  scale: 4.5,
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.58,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1,
                                        color: Color.fromARGB(224, 16, 15, 15)),
                                  ),
                                ),
                                child: Text(
                                  selectedDate != null
                                      ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                                      : '  Enter D.O.B',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF565656),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Image.asset(
                                  'assets/calendar.png',
                                  scale: 4.5,
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.58,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1,
                                        color: Color.fromARGB(224, 16, 15, 15)),
                                  ),
                                ),
                                child: Text(
                                  '${selectedDate!.toLocal()}'.split(' ')[0],
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Function to build the remember me checkbox
  Widget _buildRememberMeCheckbox(double screenWidth) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
              value: isChecked,
              splashRadius: 20,
              activeColor: const Color(0xFF004BB8),
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value ?? false;
                });
              }),
          SizedBox(width: screenWidth * 0.001),
          const CustomText(
            text: "Remember me",
            color: Color(0xFF828282),
            fontSize: 12,
            fontStyle: null,
            fontfamily: 'Poppins',
          ),
        ],
      ),
    );
  }
}