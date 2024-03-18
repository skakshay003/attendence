// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, library_private_types_in_public_api, avoid_hack, avoid_hack, use_build_context_synchronously, deprecated_member_use, duplicate_ignore, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers, unused_local_variable, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unused_element, prefer_adjacent_string_concatenation, dead_code, unnecessary_null_comparison, sort_child_properties_last, unused_import, unnecessary_string_interpolations, prefer_final_fields

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:attendence/bottom_navigator.dart';
import 'package:attendence/help.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
import 'config.dart';

class AttendanceLogin extends StatefulWidget {
  const AttendanceLogin({Key? key}) : super(key: key);

  @override
  _AttendanceLoginState createState() => _AttendanceLoginState();
}

class _AttendanceLoginState extends State<AttendanceLogin> {
  var backendIP = ApiConstants.backendIP;
  late ConfettiController _controllerTopCenter;
  String username = '';
  String _username = '';
  String password = '';
  String clk_in = '';
  String clk_out = '';
  String formattedDate = '';
  String formattedTime = '';
  String Login_dttm = '';
  String Birthday_nm = ''; // Initialize an empty string to store names
  String reg_year = '';
  String reg_month = '';
  String status = '123';
  String oldpass = '456';
  String id = '789';
  String depart = '';
  String branch_nm = '';
  String work_frm = '';
  String work_to = '';
  String clckin_clicked = '';
  String clckout_clicked = '';
  String clkin_tm = '';
  String clkout_tm = '';
  String clkInTm = '';
  String clksts = '';
  String late_resn_status = '0';
  bool isUsernameEmpty = false; // Track if the username field is empty
  bool isPasswordEmpty = false; // Track if the password field is empty
  bool isTextFieldFocused = false;
  Map<String, dynamic> data = {};

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  TextEditingController oldpassController = TextEditingController();

  bool isPasswordVisible = false; // Initially, the password is hidden.
  bool isTextFieldNotEmpty = false;
  bool showNewPasswordField = false;

  List birthdayList = [];
  late Future<List<Map<String, dynamic>>> _birthdayData;

  FocusNode _textField1FocusNode = FocusNode();
  FocusNode _textField2FocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _birthdayData = viewBirthdayReport();
    _controllerTopCenter = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _controllerTopCenter.play();
    submitForm();
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      hack('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  Future<List<Map<String, dynamic>>> viewBirthdayReport() async {
    try {
      var apiUrl = Uri.parse('$backendIP/view/vfetchall_branch_birthrep.php');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        hack('came');
        List<Map<String, dynamic>> birthdayList =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        hack(birthdayList);
        await filterAndhackBirthdayList(birthdayList);
        // You can now use birthdayList for further processing if needed
        return birthdayList;
        hack('came');
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }

    // Add a return statement here to satisfy the return type
    return [];
  }

  Future<void> filterAndhackBirthdayList(
      List<Map<String, dynamic>> birthdayList) async {
    hack('hi');
    DateTime today = DateTime.now();
    String formattedToday = DateFormat('MM-dd').format(today);

    List<Map<String, dynamic>> filteredList = birthdayList
        .where((entry) =>
            DateFormat('MM-dd').format(DateTime.parse(entry['dob'])) ==
            formattedToday)
        .toList();

    if (filteredList.isNotEmpty) {
      for (var entry in filteredList) {
        Birthday_nm += '${entry['nm']}, '; // Concatenate names
      }

      // Remove the trailing comma and space
      Birthday_nm = Birthday_nm.substring(0, Birthday_nm.length - 2);

      hack('Names: $Birthday_nm');
      showBirthdayPopup(context, Birthday_nm);
    } else {
      hack('No birthdays found for today: $formattedToday');
    }
  }

  void showBirthdayPopup(BuildContext context, String birthdayNames) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _controllerTopCenter,
            builder: (context, child) {
              return IntrinsicHeight(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfettiWidget(
                          confettiController: _controllerTopCenter,
                          blastDirectionality: BlastDirectionality.directional,
                          blastDirection: -pi / 2,
                          emissionFrequency: 0.05,
                          numberOfParticles: 15,
                          gravity: 0.05,
                          colors: const [
                            Colors.yellow,
                            Colors.lightBlue,
                            Colors.green,
                            Color.fromARGB(255, 23, 74, 241),
                            Colors.pink,
                            Colors.orange,
                            Colors.purple,
                          ],
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cake,
                              color: Colors.blue,
                              size: 48.0,
                            ),
                            SizedBox(height: 16.0),
                            Center(
                              child: Text(
                                'Happy Birthday',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '$birthdayNames!',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // SizedBox(height: 8.0),
                            Center(
                              child: Text(
                                'Wishing $birthdayNames a fantastic day!',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('OK'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void userLogin() async {
    try {
      var url = "$backendIP/login.php";
      var response = await http.post(Uri.parse(url), body: {
        "username": username,
        "userpassword": password,
      });

      var data = jsonDecode(response.body);
      print('data:$data');
      hack(username);
      hack(password);
      if (data == "successfully") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Center(
              child: Text(
                'Login successfully',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
        setState(() {
          logdetails();
        });
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return HomeNavigator();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('session_user', username);
        sharedPreferences.setString('depart', depart);
        sharedPreferences.setString('name', _username);
        if (depart != 'SAD') {
          sharedPreferences.setString('brnnm', branch_nm);
        }
      } else if (data == "trainee") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.amber,
            content: Center(
              child: Text(
                'You are a trainee , Cant Login !',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
        );
      } else if (data == "hack") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 255, 230, 7),
            content: Center(
              child: Text(
                'Better luck Nxt tym hacker . . . 😜',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Center(
              child: Text(
                'Invalid username or password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      hack('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black87,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                color: Colors.yellow,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please check your network connection and try again.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            textColor: Colors.yellow,
          ),
        ),
      );
    }
  }

  Future<void> fetchEmployeeName() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Department_Head/fetchname_usingid.php');

      var response = await http.post(apiUrl, body: {
        'employee_id': _user.text,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes

        setState(() {
          _username = data['nm'];
        });
      } else {
        hack('Error occurred while fetching employee name: ${response.body}');
        setState(() {
          clk_InTIME = '';
        });
      }
    } catch (e) {
      hack('Fetch error: $e');
      setState(() {
        clk_InTIME = '';
      });
    }
  }

  Future<void> int_changepassword() async {
    try {
      var apiUrl = Uri.parse('$backendIP/changepass.php');

      var response = await http.post(apiUrl, body: {
        'id': _user.text,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes

        if (data.isNotEmpty) {
          setState(() {
            status = data[0]['pass_chg'].toString();
            oldpass = data[0]['pwd'];
            id = data[0]['id'].toString();
            depart = data[0]['depart'];
            branch_nm = data[0]['branch_name'];
            work_frm = data[0]['work_frm'];
            work_to = data[0]['work_to'];
            hack(status);
            hack(oldpass);
            hack(id);
            hack(depart);
            hack(branch_nm);
            hack(work_to);
          });
        } else {
          hack('Error occurred while fetching pass status: ${response.body}');
        }
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  Future<void> changepassword() async {
    hack('data');
    try {
      var apiUrl = Uri.parse('$backendIP/changepass.php');

      var response = await http.post(apiUrl, body: {
        'id': _user.text,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes

        if (data.isNotEmpty) {
          setState(() {
            status = data[0]['pass_chg'].toString();
            oldpass = data[0]['pwd'];
            id = data[0]['id'].toString();
            depart = data[0]['depart'];
            branch_nm = data[0]['branch_name'];
            hack(status);
            hack(oldpass);
            hack(id);
            hack(depart);
            hack(branch_nm);
            hack('ok');
            setState(() {
              showPasswordChangePopup();
            });
          });
        } else {
          hack('Error occurred while fetching pass status: ${response.body}');
        }
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  String passwordMismatchMessage = '';
  String Newpassword = '';

  void showPasswordChangePopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TextEditingController newPasswordController = TextEditingController();
        Newpassword = newPasswordController.text;

        FocusNode _textField1FocusNode = FocusNode();
        FocusNode _textField2FocusNode = FocusNode();
        Timer? _debounce;

        return AlertDialog(
          title: Text('Change Password'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                // Set the desired height
                height: 133,
                child: Column(
                  children: [
                    TextField(
                      controller: oldpassController,
                      focusNode: _textField1FocusNode,
                      onChanged: (value) {
                        // Clear existing debounce timer
                        if (_debounce != null && _debounce!.isActive) {
                          _debounce!.cancel();
                        }

                        // Set a new debounce timer
                        _debounce = Timer(Duration(milliseconds: 500), () {
                          // Validation logic after a delay of 500 milliseconds
                          if (oldpassController.text == oldpass) {
                            // If old password matches, show the new password field
                            setState(() {
                              showNewPasswordField = true;
                              passwordMismatchMessage = '';
                            });
                            FocusScope.of(context)
                                .requestFocus(_textField2FocusNode);
                          } else {
                            // If old password doesn't match, hide the new password field
                            setState(() {
                              showNewPasswordField = false;
                              passwordMismatchMessage =
                                  'Old password does not match. Please try again.';
                            });
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Old Password',
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      passwordMismatchMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Visibility(
                      visible: showNewPasswordField,
                      child: TextField(
                        controller: newPasswordController,
                        focusNode: _textField2FocusNode,
                        decoration: InputDecoration(
                          hintText: 'New Password',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog
                oldpassController.clear();
                newPasswordController.clear();
                showNewPasswordField = false;
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Clear existing debounce timer before closing the dialog
                if (_debounce != null && _debounce!.isActive) {
                  _debounce!.cancel();
                }

                // Perform the update logic with newPasswordController.text
                if (showNewPasswordField) {
                  // Assuming you have the necessary information
                  String newpass = newPasswordController.text;
                  String stus = '1'; // Replace with the actual status

                  // Only update the password if the new password field is visible

                  setState(() {
                    updtpass(id, newpass, stus);
                    oldpassController.clear();
                    newPasswordController.clear();
                    showNewPasswordField = false;
                  });
                }

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updtpass(String id, String newpass, String stus) async {
    if (newpass.isNotEmpty) {
      try {
        var apiUrl = Uri.parse(
            '$backendIP/updatepass.php'); // Replace with your API endpoint

        var response = await http.post(apiUrl, body: {
          'id': id,
          'updtpass': newpass,
          'status': stus,
        });

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['message'] == 'Data updated successfully') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text('Password changed successfully!',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                backgroundColor: Colors.green,
              ),
            );
            // You may want to handle success actions here
            await int_changepassword();
          } else {
            hack('Error updating data: ${data['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text('Error updating data!')),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          hack('Error occurred during HTTP request: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Failed to make HTTP request!')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        hack('HTTP request error: $e');
      }
    }
  }

  Future<void> _refresh() async {
    // Implement your refresh logic here
    // For example, you can reload data, reset states, etc.
    // In this example, I'm just delaying for 2 seconds to simulate a refresh.
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Reset variables or states
      _username = ''; // Reset the username
      // You can add more reset logic as needed
      _pass.text = '';
      _user.text = '';
    });
  }

  Future<void> _handleRefresh() async {
    // Implement your refresh logic here
    // For example, you can reload data, reset states, etc.
    // In this example, I'm just delaying for 2 seconds to simulate a refresh.
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Reset variables or states
      _username = ''; // Reset the username
      // You can add more reset logic as needed
      _pass.text = '';
      _user.text = '';
    });
  }

  void submitForm() {
    // Get the current date and time
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    // Create a formatted time string (e.g., "12:34:56")
    formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Get the current date
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    Login_dttm =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}' +
            ' ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Split the formatted date string
    List<String> dateParts = formattedDate.split('-');
    int extractedYear = int.parse(dateParts[0]);
    int extractedMonth = int.parse(dateParts[1]);

    reg_month = extractedMonth.toString();
    reg_year = extractedYear.toString();
    hack(formattedDate);
  }

  void currentdt() {
    hack('bbbb');
    // Get the current date and time
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    // Create a formatted time string (e.g., "12:34:56")
    formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Get the current date
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    Login_dttm =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}' +
            ' ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Split the formatted date string
    // List<String> dateParts = formattedDate.split('-');
    // int extractedYear = int.parse(dateParts[0]);
    // int extractedMonth = int.parse(dateParts[1]);

    // reg_month = extractedMonth.toString();
    // reg_year = extractedYear.toString();
    // hack(formattedDate);
    setState(() {
      fetchatt_tdy();
      //fetch_last_clckin();
    });
  }

  String conv_clkin_tm = '';

  Future<void> fetch_last_clckin() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Attendance_Reports/vfetch_last_clkin.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'user_id': _user.text,
      });

      if (response.statusCode == 200) {
        hack('ata');
        data = jsonDecode(response.body);
        // Extract and store 'clk_in_tm' as a string
        clkInTm = data['clk_in_tm'];

        // Use clkInTm as needed
        hack('clkInTm:$clkInTm');
      } else {
        hack('Error occurred during HTTP request: ${response.body}');
      }
    } catch (e) {
      hack('HTTP request error: $e');
    }
  }

  String tm_convert2(String clkInTm) {
    try {
      // Parsing the input time string
      DateTime dateTime = DateFormat('HH:mm:ss').parse(clkInTm);

      // Formatting the time in 12-hour format
      String convClkInTm = DateFormat('h:mm a').format(dateTime);

      hack('Original time: $clkInTm');
      hack('12-hour format: $convClkInTm');

      return convClkInTm;
    } catch (e) {
      hack('Error converting time: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  String clk_in_sts = '';
  String clk_out_sts = '';
  String clk_InTIME = '';

  Map<String, dynamic> tdy_attend = {};

  Future<void> fetchatt_tdy() async {
    hack('formattedDate');
    hack(formattedDate);
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Attendance_Reports/fetch_attnd_tdy.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'user_id': _user.text,
        'date': formattedDate,
      });

      if (response.statusCode == 200) {
        hack('1');
        tdy_attend = jsonDecode(response.body);
        hack(tdy_attend);
        setState(() {
          clk_in_sts = tdy_attend['clk_in'].toString();
          clk_out_sts = tdy_attend['clk_out'].toString();
          clk_InTIME = tdy_attend['clk_in_tm'].toString();
          hack(clk_in_sts);
          hack(clk_out_sts);
        });
      } else {
        hack('Error occurred during HTTP request: ${response.body}');
      }
    } catch (e) {
      hack('HTTP request error: $e');
    }
  }

  Future<void> clock_in() async {
    // Get the current date and time
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    // Create a formatted time string (e.g., "12:34:56")
    formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Get the current date
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    Login_dttm =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}' +
            ' ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    clkin_tm =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Split the formatted date string
    List<String> dateParts = formattedDate.split('-');
    int extractedYear = int.parse(dateParts[0]);
    int extractedMonth = int.parse(dateParts[1]);

    reg_month = extractedMonth.toString();
    reg_year = extractedYear.toString();
    hack(formattedDate);
    hack(clkin_tm);
    hack(Login_dttm);
    hack(reg_month);
    hack(reg_year);
    hack(_user.text);
    hack(depart);
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Attendance_Reports/log_clkin.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'userid': _user.text.toUpperCase(),
        'dept': depart,
        'work_frm': work_frm,
        'work_to': work_to,
        'clk_in': clckin_clicked,
        'clk_out': '0',
        'clk_in_tm': clkin_tm,
        'clk_out_tm': '00:00:00',
        'clk_in_dt_tm': Login_dttm,
        'clk_out_dt_tm': '0000-00-00 00:00:00',
        'tot_hr': '00:00:00',
        'date': formattedDate,
        'mnth': reg_month,
        'yr': reg_year,
        'late_resn_status': late_resn_status,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data);
        await fetchatt_tdy();
        // await int_changepassword();
      } else {
        hack('Error occurred during HTTP request: ${response.body}');
      }
    } catch (e) {
      hack('HTTP request error: $e');
    }
  }

  String calculateTotalHoursAndMinutes(String startTime, String endTime) {
    // Assuming the format is "HH:mm:ss.SSSSSS"
    hack('startTime:$startTime');
    hack('startTime:$endTime');
    DateTime startDateTime = DateTime.parse("2024-01-01 $startTime");
    DateTime endDateTime = DateTime.parse("2024-01-01 $endTime");

    // Calculate the difference in minutes
    int differenceInMinutes = endDateTime.difference(startDateTime).inMinutes;

    // Create a Duration object
    Duration duration = Duration(minutes: differenceInMinutes);

    // Format the duration using intl package
    String formattedDuration = DateFormat('HH:mm:ss')
        .format(DateTime.utc(0, 0, 0, 0, 0, 0).add(duration));

    return formattedDuration;
  }

  Future<void> clock_out() async {
    // Get the current date and time
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    // Create a formatted time string (e.g., "12:34:56")
    formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Get the current date
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    Login_dttm =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}' +
            ' ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    clkout_tm =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    hack(formattedDate);
    hack(clkout_tm);
    hack(Login_dttm);
    hack(_user.text);
    String totalHoursAndMinutes =
        calculateTotalHoursAndMinutes(clk_InTIME!, clkout_tm!).toString();
    hack('totalHoursAndMinutes');
    hack(totalHoursAndMinutes);
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Attendance_Reports/log_clkout.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'userid': _user.text.toUpperCase(),
        'clk_out': clckout_clicked,
        'clk_out_tm': clkout_tm,
        'clk_out_dt_tm': Login_dttm,
        'tot_hr': totalHoursAndMinutes,
        'date': formattedDate,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data);
        await fetchatt_tdy();
        // await int_changepassword();
      } else {
        hack('Error occurred during HTTP request: ${response.body}');
      }
    } catch (e) {
      hack('HTTP request error: $e');
    }
  }

  Future<void> logdetails() async {
    hack('vangga na');
    hack(formattedTime);
    hack(Login_dttm);
    hack(formattedDate);
    hack(reg_month);
    hack(reg_year);
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Visitors/visitors.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'userid': _user.text,
        'log_in_tm': formattedTime,
        'log_in_dt_tm': Login_dttm,
        'log_dt': formattedDate,
        'log_mnth': reg_month,
        'log_yr': reg_year,
      });

      if (response.statusCode == 200) {
        hack(response.body);
        var data = jsonDecode(response.body);
      } else {
        hack('Error occurred during HTTP request: ${response.body}');
      }
    } catch (e) {
      hack('HTTP request error: $e');
    }
  }

  // void tm_convert() {
  //   // Parsing the input time string
  //   DateTime dateTime = DateFormat('HH:mm:ss').parse(clkin_tm);

  //   // Formatting the time in 12-hour format
  //   conv_clkin_tm = DateFormat('h:mm a').format(dateTime);

  //   hack('Original time: $clkin_tm ');
  //   hack('12-hour format: $conv_clkin_tm');
  // }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      color: Color.fromARGB(69, 144, 185, 231),
      onRefresh: _handleRefresh,
      showChildOpacityTransition: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            // Clear focus when tapping outside of the text field
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                // height: MediaQuery.of(context).size.height - 150,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 205, 228, 236),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                  image: DecorationImage(
                    image: AssetImage('images/bg2.jfif'),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                child: Center(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/staffinlogo.png',
                              width: 250,
                              height: 200,
                            ),
                            Container(
                              height: 40,
                              width: 250,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Username',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 119, 118, 118),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 250,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.person,
                                      color: Color.fromARGB(255, 119, 119, 119),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Container(
                                        child: TextFormField(
                                          focusNode: _textField1FocusNode,
                                          onFieldSubmitted: (value) {
                                            // Move focus to the next text field when submitted
                                            _textField1FocusNode.unfocus();
                                            FocusScope.of(context).requestFocus(
                                                _textField2FocusNode);
                                          },
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                169, 0, 0, 0),
                                            fontSize: 18,
                                          ),
                                          controller: _user,
                                          onChanged: (value) {
                                            setState(() {
                                              username = value;
                                              isUsernameEmpty = value.isEmpty;
                                              _username = '';
                                              fetchEmployeeName();
                                              int_changepassword();
                                              currentdt();
                                            });
                                          },
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 7,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: isUsernameEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'Please enter a username',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 40,
                              width: 250,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Password',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 119, 118, 118),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 250,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Icon(
                                      Icons.lock,
                                      color: Color.fromARGB(255, 119, 119, 119),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: TextFormField(
                                        focusNode: _textField2FocusNode,
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                              169, 0, 0, 0),
                                          fontSize: 18,
                                        ),
                                        controller: _pass,
                                        onChanged: (value) {
                                          setState(() {
                                            password = value;
                                            isPasswordEmpty = value.isEmpty;
                                            isTextFieldNotEmpty =
                                                value.isNotEmpty;
                                          });
                                        },
                                        onFieldSubmitted: (value) {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            userLogin();
                                            submitForm();
                                          }
                                        },
                                        obscureText: !isPasswordVisible,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          suffixIcon: isTextFieldNotEmpty
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isPasswordVisible =
                                                          !isPasswordVisible;
                                                    });
                                                  },
                                                  child: Icon(
                                                    isPasswordVisible
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                    color: Color.fromARGB(
                                                        255, 119, 119, 119),
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: isPasswordEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'Please enter a password',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            if (_username.isNotEmpty)
                              Container(
                                height: 45,
                                width: 250,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '🌀',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 8, 42, 136),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '$_username',
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 8, 42, 136),
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '🌀',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 8, 42, 136),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                height: 40,
                                width: 250,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      userLogin();
                                      submitForm();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Color.fromARGB(255, 8, 42, 136),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_username.isNotEmpty) SizedBox(height: 15),
                            if (_username.isNotEmpty && depart != 'SAD')
                              (clk_in_sts == '0' || tdy_attend.isEmpty) ||
                                      (clk_in_sts == '1' && clk_out_sts == '1')
                                  ? InkWell(
                                      onTap: () {
                                        hack(_pass);
                                        if (_pass.text != '') {
                                          if (oldpass == _pass.text) {
                                            setState(() {
                                              clckin_clicked = '1';
                                              clock_in();
                                            });
                                            hack(clckin_clicked);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Center(
                                                  child: Text(
                                                    'Wrong Password !',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Center(
                                                child: Text(
                                                  'Please enter password !',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 80,
                                        color: Colors.green,
                                        child: Center(
                                          child: Text(
                                            'Clock In',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : clk_in_sts == '1' && clk_out_sts == '0'
                                      ? InkWell(
                                          onTap: () {
                                            hack(_pass);
                                            if (_pass.text != '') {
                                              if (oldpass == _pass.text) {
                                                setState(() {
                                                  clckout_clicked = '1';
                                                  clock_out();
                                                });
                                                hack(clckout_clicked);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Center(
                                                      child: Text(
                                                        'Wrong Password !',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Center(
                                                    child: Text(
                                                      'Please enter password !',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 80,
                                            color: Colors.red,
                                            child: Center(
                                              child: Text(
                                                'Clock Out',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text('Punched'),
                            SizedBox(height: 9),
                            // Text(
                            //   formatDate(formattedDate),
                            //   style: TextStyle(fontSize: 12.5),usre
                            // ),
                            SizedBox(height: 5),
                            if (clk_InTIME.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Last Clock In : ',
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    tm_convert2(clk_InTIME),
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),

                            SizedBox(height: 30),
                            // TextButton(
                            //   onPressed: () {
                            //     changepassword();
                            //   },
                            //   child: Text(
                            //     'Forgot your Password?',
                            //     style: TextStyle(
                            //       fontSize: 13,
                            //       color: Color.fromARGB(255, 255, 255, 255),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HelpPage(),
                      ));
                },
                child: Text(
                  'Need help? Check our FAQ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllerTopCenter.dispose();
    super.dispose();
  }
}

// Widget SplashScreen() {
//   return Container(
//     constraints: BoxConstraints.expand(), // or any other constraints
//     child: Scaffold(
//       backgroundColor: Colors.blue,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             SvgPicture.asset(
//               'images/svg.svg',
//               height: 150,
//               width: 150,
//               color: Colors.white,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Attendance App',
//               style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Your Tagline Goes Here',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(height: 30),
//             SpinKitWave(
//               color: Colors.white,
//               size: 50.0,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add any splash screen content/widgets here
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

class _TransitionListTile extends StatelessWidget {
  const _TransitionListTile({
    this.onTap,
    required this.title,
    required this.subtitle,
    required ElevatedButton child,
  });

  final GestureTapCallback? onTap;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0,
      ),
      leading: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.black54,
          ),
        ),
        child: const Icon(
          Icons.play_arrow,
          size: 35,
        ),
      ),
      onTap: onTap,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
