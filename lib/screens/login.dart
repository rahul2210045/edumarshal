import 'package:edumarshals/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:edumarshals/utilities.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool isChecked = false;
  bool _isLoading = false;
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2025),
      // barrierColor: Color.fromARGB(60, 0, 74, 184),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF004BB8), // Background color
              onPrimary: Colors.white, // Selected date text color
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

  // TimeOfDay? selectedTime;

  // Future<void> _selectTime(BuildContext context) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: selectedTime ?? TimeOfDay.now(),
  //   );

  //   if (picked != null && picked != selectedTime) {
  //     setState(() {
  //       selectedTime = picked;
  //     });
  //   }
  // }

  Future<void> _saveItem() async {
    setState(() {
      _isLoading = true;
    });
    String formattedDate = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : '';
    final url = Uri.https('akgec-edu.onrender.com', '/v1/student/login');
    // http.post(url,headers:{}, body: json.encode({
    // https: //akgec-edu.onrender.com/v1/student/login

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

      //
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final message = responseData['message'];
        final name = responseData['name'];

        print('Message from API: $message');
        print('Message from API: $name');
        print('dob :$formattedDate');
        // Update UI to show success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
        // prefs.setString('email', _emailController.text);
        // prefs.setString('name', _nameController.text);

        //uncomment for using prefernce manager
        // PreferencesManager().email = _emailController.text;
        // PreferencesManager().name = _nameController.text;

        // if (.isNotEmpty) {
        //   prefs.setString('token', );
        //   print('Token stored in prefs: $actualAccessToken');
        // } else {
        //   // Handle the case where the token is empty
        //   print('Token is empty');
        // }

        setState(() {
          _isLoading = false;
        });
        // for navigaation to next page
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) =>
        //           otpVerification(email: _emailController.text),
        //     ));
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final message = responseData['message'];
        print('Failed: $message');
        print('dob :$formattedDate');
        // Update UI to show success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        // print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('dob :$formattedDate');
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          bottom: 100.0,
          right: 20.0,
          child: Image.asset('assets/Frame 100.png'),
          // child: button3('Login', 0.6, 0.5, context, () => Login())
        ),
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Android Large - 18.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Positioned(
        //   bottom: 200.0,
        //   right: 40.0,
        //   child: Image.asset('assets/user-square.png'),
        //   // child: button3('Login', 0.6, 0.5, context, () => Login())
        // ),
        Scaffold(
            backgroundColor: const Color.fromARGB(0, 151, 147, 147),
            body: ListView(
              children: [buildheading(context)],
            )),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4E82EA)),
                strokeWidth: 5.0,
              ),
            ),
          ),
        Positioned(
            bottom: 500,
            right: 100.0,
            child: button3('Login', 0.6, 0.5, context, () => Login())),
        Positioned(
          bottom: 550.0,
          right: 120.0,
          child: Image.asset(
            'assets/Frame 100.png',
            scale: 4.5,
          ),

          // child: button3('Login', 0.6, 0.5, context, () => Login())
        ),
      ],
    );
  }

  Widget buildheading(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.02),
        const CustomText(
          text: "Login",
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 44,
          fontStyle: null,
          fontfamily: '',
        ),
        SizedBox(height: screenHeight * 0.07),
        Stack(children: [
          Container(
              width: screenWidth * 0.85,
              height: screenHeight * 0.44,
              decoration: ShapeDecoration(
                color: Color(0xFFFBFBFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadows: [
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
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  buildtextfiled(
                    'assets/User.png',
                    "User ID",
                    context,
                    "Enter User ID",
                    false,
                    _usernameController,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  buildtextfiled(
                    'assets/shield-security.png',
                    "Password",
                    context,
                    "Enter Password",
                    false,
                    _passController,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: const EdgeInsets.only(left: 50.0),
                        child: CustomText(
                          text: "Date of Birth",
                          color: Color(0xFF3386FF),
                          fontSize: 12,
                          fontStyle: null,
                          fontfamily: 'Poppins',
                          // fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              // height: screenHeight * .05,
                              width: screenWidth * 0.7,
                              decoration: const BoxDecoration(
                                // borderRadius: BorderRadius.circular(10),
                                // border: Border.(
                                //   color: Color(0xff00194A),
                                // ),
                                border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xFFA0A0A0)),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 0, right: 0),
                                child: Center(
                                    child: selectedDate == null
                                        ? Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                // child: Icon(
                                                //   Icons.calendar_month,
                                                //   size: 20,
                                                //   color: Color(0xff617193),
                                                // ),
                                                child: Image.asset(
                                                  'assets/calendar.png',
                                                  scale: 4.5,
                                                  // height: screenHeight * 0.032,
                                                ),
                                              ),
                                              Text(
                                                // '  Enter D.O.B',
                                                selectedDate != null
                                                    ? DateFormat('dd/MM/yyyy')
                                                        .format(selectedDate!)
                                                    : 'Enter D.O.B',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF565656),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 15),
                                                child: Image.asset(
                                                  'assets/calendar.png',
                                                  scale: 4.5,
                                                  // height: screenHeight * 0.032,
                                                ),
                                              ),
                                              Text(
                                                '${selectedDate!.toLocal()}'
                                                    .split(' ')[0],
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                            value: isChecked,
                            splashRadius: 20,
                            activeColor: Color(0xFF004BB8),
                            onChanged: (bool? value) {
                              setState(() {
                                // Color? Color(0xFF004BB8)
                                isChecked = value ?? false;
                              });
                            }),
                        SizedBox(
                          width: screenWidth * 0.001,
                        ),
                        const CustomText(
                          text: "Remember me",
                          color: Color(0xFF828282),
                          fontSize: 12,
                          fontStyle: null,
                          fontfamily: 'Poppins',
                        ),
                      ],
                    ),
                  )
                ]),
              )),
          Positioned(
            bottom: 0,
            left: 80,
            right: 00,
            child: FractionallySizedBox(
              widthFactor:
                  0.7, // Adjust the portion of the button inside the container
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveItem();

                  // Add your onPressed logic here
                },
                child: Text('Login'),
              ),
            ),
          ),
        ]),
        // Positioned(
        //   bottom: 00,
        //   left: 80,
        //   right: 00,
        //   top: 400,
        //   child: FractionallySizedBox(
        //     widthFactor:
        //         0.7, // Adjust the portion of the button inside the container
        //     alignment: Alignment.centerLeft,
        //     child: ElevatedButton(
        //       onPressed: () async {
        //         await _saveItem();

        //         // Add your onPressed logic here
        //       },
        //       child: Text('Login'),
        //     ),
        //   ),
        // ),
        SizedBox(height: screenHeight * 0.154),
        const CustomText(
          text: "Forget your password?",
          color: Colors.white,
          fontSize: 20,
          fontStyle: null,
          fontfamily: '',
        ),
        SizedBox(height: screenHeight * 0.03),
        // const CustomText(
        //   text: "Reset Password",
        //   color: Colors.white,
        //   fontSize: 15,
        //   fontStyle: null,
        //   fontfamily: '',
        // ),
        Container(
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(10),
            // border: Border.(
            //   color: Color(0xff00194A),
            // ),
            border: Border(
              bottom: BorderSide(width: 1, color: Color(0xFFFBFBFB)),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              // Handle the onTap event here
              print('Container tapped!');
              // Add your logic for resetting password here
            },
            child: Text(
              'Reset Password',
              style: TextStyle(
                color: Color(0xFFFBFBFB),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}