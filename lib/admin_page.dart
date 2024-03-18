// ignore_for_file: depend_on_referenced_packages, use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, unused_local_variable, prefer_const_literals_to_create_immutables, deprecated_member_use, use_build_context_synchronously, avoid_hack, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, prefer_adjacent_string_concatenation, unnecessary_string_interpolations, avoid_unnecessary_containers, sort_child_properties_last, unrelated_type_equality_checks, prefer_interpolation_to_compose_strings, unnecessary_cast, prefer_final_fields

import 'dart:async';
import 'package:attendence/Attendance/Morning_late.dart';
import 'package:attendence/Attendance/Evening_late.dart';
import 'package:attendence/WFH_Rep.dart/add_wfh.dart';
import 'package:attendence/bottom_navigator.dart';
import 'package:attendence/print_id/print_id_adm.dart';
import 'package:intl/intl.dart';
import 'package:attendence/Company_Section/add_branch/add_branch.dart';
import 'package:attendence/Staff_report/Attendance_Reports/add_attendance.dart';
import 'package:attendence/Staff_report/permission/add_permission_adm.dart';
import 'package:attendence/Staff_report/registration.dart';
import 'package:attendence/Staff_report/view/anniverasry.dart';
import 'package:attendence/Staff_report/view/birthdayrep.dart';
import 'package:attendence/Staff_report/view/viewadmin.dart';
import 'package:attendence/Staff_report/view/viewemployee.dart';
import 'package:attendence/admin_login.dart';
import 'package:attendence/print_id/print_id_emp.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Attendance/add_leave_adm.dart';
import 'Attendance/add_leave_emp.dart';
import 'Attendance/allstaff_leave_rep.dart';
import 'Attendance/excel_database.dart';
import 'Attendance/set_holiday.dart';
import 'Attendance/today_present.dart';
import 'Pay_Roll/Salary_calc_adm.dart';
import 'Pay_Roll/Salary_calc_emp.dart';
import 'Pay_Roll/Salary_inc_adm.dart';
import 'Pay_Roll/salary_rep2.dart';
import 'Staff_report/Attendance_Reports/Empwise_attend_rep_adm.dart';
import 'Staff_report/Attendance_Reports/Empwise_attend_rep_emp.dart';
import 'Staff_report/Leave status/leave_status.dart';
import 'Company_Section/add_dept/add_department.dart';
import 'Company_Section/add_dept_head/headtl.dart';
import 'Pay_Roll/Salary_Rep.dart';
import 'Pay_Roll/Salary_appr.dart';
import 'Staff_report/Leave status/leave_status_adm.dart';
import 'Staff_report/permission/add_permission_emp.dart';
import 'Staff_report/permission/permission_rep_adm.dart';
import 'Staff_report/permission/permission_rep_emp.dart';
import 'Staff_report/view/viewtrainee.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Visitors/visitors.dart';
import 'WFH_Rep.dart/wfh_rep.dart';
import 'config.dart';
import 'help.dart';
import 'print_id/print_id_adm.dart';
import 'profile.dart';
import 'theme_pro.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  var backendIP = ApiConstants.backendIP;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String loginuser = '';
  String logindepart = '';
  List<Map<String, dynamic>> userData = [];
  String username1 = 'ad';
  String username2 = 'emp';
  String username3 = 'trainee';

  String formattedDate = '';
  String formattedTime = '';
  String Logout_dttm = '';

  String reg_year = '';
  String reg_month = '';
  String brnch_nm = '';
  String branch = '. . .';
  String clicked = '0';
  String sub_sts = '';
  String branch_staffcount = '';
  String app_sts = '0';

  List branchname = [];
  List staffids = [];
  Map<String, dynamic> data = {};
  Map<String, dynamic> companyData = {};
  bool isLoading = false;
  String name = '';
  String pic = '';
  String greeting = '';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('session_user');
    var session2_user = sharedPreferences.getString('depart');
    if (session1_user != null && session2_user != null) {
      setState(() {
        loginuser = session1_user;
        logindepart = session2_user;
        hack(loginuser);
        hack(logindepart);
        if (logindepart != 'SAD') {
          var session3_user = sharedPreferences.getString('brnnm');
          if (session3_user != null) {
            setState(() {
              brnch_nm = session3_user;
              hack(brnch_nm);
            });
          }
        }
        DateTime now = DateTime.now();
        greeting = getGreeting(now);

        print('Current time: $now');
        print('Greeting: $greeting');
        fetchData();
        // Moved getUserdata call here, so it only happens when loginuser is available
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  String getGreeting(DateTime currentTime) {
    int hour = currentTime.hour;
    int minute = currentTime.minute;

    if (hour < 12 || (hour == 12 && minute == 0)) {
      return 'Good Morning 🌅';
    } else if (hour < 15 || (hour == 15 && minute <= 30)) {
      return 'Good AfterNoon 🌤️';
    } else {
      return 'Good Evening 🌆';
    }
  }

  Future<void> viewbranch() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Registration/vfetch_branch.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          branchname = jsonDecode(response.body);
          hack(branchname);
          if (logindepart != 'SAD') {
            branch = brnch_nm.toString();
            hack(branch);
          } else {
            branch = branchname[0]['branch_name'].toString();
            hack(branch);
          }
          hack('count');

          viewBranchStaffCount();
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  Future<void> viewBranchStaffCount() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/branch/branch_stf_cnt.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack('Data type: ${data.runtimeType}');

        setState(() {
          // Assuming the data is a Map<String, int>
          companyData = Map<String, dynamic>.from(data);
          hack(companyData);
          isLoading = true;
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  void showBranch(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: buildDialogContent(),
        );
      },
    );
  }

  String initialbranch = '';
  Widget buildDialogContent() {
    initialbranch =
        branchname.isNotEmpty ? branchname[0]['branch_name'] : 'Select Branch';

    return Container(
      height: 200,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Center(
              child: Text(
                'Select branch',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey,width: 0.5)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: branch ?? initialbranch,
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      setState(() {
                        branch = newValue;
                        viewBranchStaffCount();
                        Navigator.pop(context);
                      });
                    }
                  },
                  items: [
                    for (int index = 0; index < branchname.length; index++)
                      DropdownMenuItem<String>(
                        value: branchname[index]['branch_name'],
                        child: Container(
                          width: 150,
                          child: Text(
                            branchname[index]['branch_name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    DropdownMenuItem<String>(
                      value: 'All-Branch',
                      child: Container(
                        width: 150,
                        child: Text(
                          'All Branch',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  underline: Container(),
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.help,color: Colors.grey,size: 15,),
                SizedBox(width: 5,),
                Text('Select the branch to apply',style: TextStyle(color: Colors.grey),)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout() async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.remove('session_user');

      // Navigate to LoginPage after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );

      // Show SnackBar using the Scaffold of the current context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
              child: Text(
            "Your Account Logout Successfully",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      hack('the error is $e');
    }
  }

  Future<dynamic> logoutdialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
            content: Container(
              height: 150,
              // decoration: BoxDecoration(
              //   color: Colors.red
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Are you sure you want to Logout\nthis account?",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 255, 255,
                              255), // Change the background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                0), // Set the border radius to 0
                          ),
                        ),
                        child: Text("Yes"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            logout();
                            submitForm();
                          });
                          await logoutdetails();
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 255, 252,
                              251), // Change the background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                0), // Set the border radius to 0
                          ),
                        ),
                        child: Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  TextEditingController oldpassController = TextEditingController();
  bool showNewPasswordField = false;
  FocusNode _textField2FocusNode = FocusNode();
  bool isPasswordVisible = false;

  void showPasswordChangePopup1() async {
    hack('hi');
    if (status == '0') {
      hack(status);
      setState(() {
        oldpassController.text = oldpass.toString();
        hack(oldpassController);
        if (oldpassController.text == oldpass) {
          // If old password matches, show the new password field
          setState(() {
            hack('equal');
            showNewPasswordField = true;
            passwordMismatchMessage = '';
          });
          FocusScope.of(context).requestFocus(_textField2FocusNode);
        } else {
          // If old password doesn't match, hide the new password field
          setState(() {
            showNewPasswordField = false;
            passwordMismatchMessage =
                'Old password does not match. Please try again.';
          });
        }
      });
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TextEditingController newPasswordController = TextEditingController();
        Newpassword = newPasswordController.text;

        FocusNode _textField1FocusNode = FocusNode();
        FocusNode _textField2FocusNode = FocusNode();

        // bool showNewPasswordField = false;
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
                    TextFormField(
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
                      obscureText:
                          !isPasswordVisible, // Add this line for password visibility
                      decoration: InputDecoration(
                        hintText: 'Old Password',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          child: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color.fromARGB(255, 119, 119, 119),
                          ),
                        ),
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
                      child: TextFormField(
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

  String status = '123';
  String oldpass = '456';
  String id = '789';

  Future<void> changepassword1() async {
    try {
      var apiUrl = Uri.parse('$backendIP/changepass.php');

      var response = await http.post(apiUrl, body: {
        'id': loginuser,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes

        if (data.isNotEmpty) {
          setState(() {
            status = data[0]['pass_chg'].toString();
            oldpass = data[0]['pwd'];
            id = data[0]['id'].toString();
            hack(status);
            hack(oldpass);
            hack(id);
            if (status == '0') {
              showPasswordChangePopup1();
            }
          });
        } else {
          hack('Error occurred while fetching pass status: ${response.body}');
        }
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  String log_in_tm = '';
  String log_out_tm = '';

  String formatDateTime(String dateTimeString) {
    try {
      // Concatenate date and time strings
      String combinedDateTimeString =
          '${dateTimeString.substring(0, 10)} ${dateTimeString.substring(10)}';

      // Parse the input string to a DateTime object with a custom format
      DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS')
          .parse(combinedDateTimeString);

      // Format the DateTime object as desired (12-hour format for time and dd-mm-yyyy for date)
      String formattedDateTime =
          "${DateFormat('dd-MM-yyyy').format(dateTime)}  ${DateFormat('hh:mm:ss a').format(dateTime)}";
      hack(formattedDateTime);
      return formattedDateTime;
    } catch (e) {
      hack('Error formatting date-time: $e');
      return 'Invalid Date';
    }
  }

  Future<void> vfetchvisitors() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Visitors/lastvisit.php');

      var response = await http.post(apiUrl, body: {
        'id': loginuser,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes
        if (data.isNotEmpty) {
          setState(() {
            log_in_tm = formatDateTime(
                (data[0]['log_dt'] + '' + data[0]['log_in_tm']).toString());
            hack(data[0]['log_out_tm']);
            hack(data[0]['log_out_dt']);
            log_out_tm = formatDateTime(
                (data[0]['log_out_dt'] + '' + data[0]['log_out_tm'])
                    .toString());
          });
        } else {
          hack('Error occurred while fetching pass status: ${response.body}');
        }
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  Future<void> changepassword2() async {
    try {
      var apiUrl = Uri.parse('$backendIP/changepass.php');

      var response = await http.post(apiUrl, body: {
        'id': loginuser,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes

        if (data.isNotEmpty) {
          setState(() {
            var status = data[0]['pass_chg'];
            oldpass = data[0]['pwd'];
            id = data[0]['id'].toString();
            hack(status);
            hack(oldpass);
            hack(id);
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
    await changepassword2();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TextEditingController newPasswordController = TextEditingController();
        TextEditingController oldpassController = TextEditingController();
        Newpassword = newPasswordController.text;

        FocusNode _textField1FocusNode = FocusNode();
        FocusNode _textField2FocusNode = FocusNode();

        bool showNewPasswordField = false;
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
                      obscureText:
                          !isPasswordVisible, // Add this line for password visibility
                      decoration: InputDecoration(
                        hintText: 'Old Password',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          child: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color.fromARGB(255, 119, 119, 119),
                          ),
                        ),
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
            await changepassword2();
          } else {
            hack('Error updating data: ${data['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text('Error updating data!',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          hack('Error occurred during HTTP request: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Failed to make HTTP request!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        hack('HTTP request error: $e');
      }
    }
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
    Logout_dttm =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}' +
            ' ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Split the formatted date string
    List<String> dateParts = formattedDate.split('-');
    int extractedYear = int.parse(dateParts[0]);
    int extractedMonth = int.parse(dateParts[1]);

    reg_month = extractedMonth.toString();
    reg_year = extractedYear.toString();
  }

  Future<void> logoutdetails() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Visitors/logout_userdet.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'userid': loginuser,
        'log_out_tm': formattedTime,
        'log_out_dt_tm': Logout_dttm,
        'log_out_dt': formattedDate,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
      } else {
        hack('Error occurred during HTTP request: ${response.body}');
      }
    } catch (e) {
      hack('HTTP request error: $e');
    }
  }

  String pic_sts = '';

  Future<void> fetchData() async {
    try {
      // Make an HTTP request to fetch data based on the profile email
      var apiUrl = Uri.parse('$backendIP/vfetchdata.php');
      var response = await http.post(apiUrl, body: {'user_id': loginuser});
      if (response.statusCode == 200) {
        hack(response.body);
        // Parse the JSON response
        // Update the labelTexts based on the fetched data
        setState(() {
          List<Map<String, dynamic>> dataList =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          if (dataList.isNotEmpty) {
            data = dataList[0];
            name = data['nm'].toString();
            pic = data['pic'].toString();
            pic_sts = data['team_ld'].toString();
            hack(name);
            hack(pic);
          } else {
            hack('No data');
          }
          isLoading = true;
          viewbranch();
          vfetchvisitors();
          changepassword1();
        });
      } else {
        setState(() {
          isLoading = true;
          viewbranch();
          vfetchvisitors();
          changepassword1();
        });
        // Handle API error here
        hack('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      hack('Error: $e');
    }
  }

  void page_navigation(String usnm) async {
    hack(usnm);
    hack(branch);
    Navigator.pop(context);
    String? refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationForm(usnm: usnm, branch: branch),
      ),
    );

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    // sharedPreferences.setString('user123', usnm);
    sharedPreferences.setString('branch123', branch);

    if (refresh == '1') {
      setState(() {
        checkLoginStatus();
      });
    } else {
      hack('refresh is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    int serialNumber = 1;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 10,
        toolbarHeight: 70,
        backgroundColor: Color.fromARGB(255, 133, 251, 247),
        shadowColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: Colors.black,
            size: 30,
          ),
          iconSize: 25,
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Row(
            children: [
              InkWell(
                onTap: () async {
                  String? refresh = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditProfile()));
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString('session_user', loginuser);
                  sharedPreferences.setString('session2_user', logindepart);
                  if (refresh == '1') {
                    setState(() {
                      checkLoginStatus();
                    });
                  } else {
                    hack('refresh is null');
                  }
                },
                child: CircleAvatar(
                  backgroundImage: data['pic'] == null ||
                          data['pic'].toString().isEmpty
                      ? NetworkImage(
                              '$backendIP/Registration/uploads/images.png')
                          as ImageProvider<Object>?
                      : (pic_sts == '1')
                          ? NetworkImage('$backendIP/Registration/uploads/' +
                              data['pic'].toString()) as ImageProvider<Object>?
                          : NetworkImage('https://staffin.cloud/static/upload' +
                              data['pic'].toString()) as ImageProvider<Object>,
                  radius: 25,
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 115,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      '$branch',
                      style: (branch == '.     .     .')
                          ? TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            )
                          : TextStyle(
                              color: Color.fromARGB(255, 83, 76, 76),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.lightbulb),
          //   onPressed: () {
          //     // Provider.of<ThemeProvider>(context, listen: false)
          //     //     .toggleDarkMode();
          //   },
          // ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  height: (logindepart == 'SAD') ? 260 : 205,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HelpPage(),
                                ));
                          },
                          child: Card(
                            color: Color.fromARGB(255, 133, 251, 247),
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(Icons.arrow_right),
                              title: Text('Help'),
                              trailing: Icon(Icons.help),
                            ),
                          ),
                        ),
                        if (logindepart == 'SAD')
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              showBranch(context);
                            },
                            child: Card(
                              color: Color.fromARGB(255, 133, 251, 247),
                              elevation: 2,
                              child: ListTile(
                                leading: Icon(Icons.arrow_right),
                                title: Text('Branch'),
                                trailing: Icon(Icons.home_work),
                              ),
                            ),
                          ),
                        InkWell(
                          onTap: () {
                            showPasswordChangePopup();
                            Navigator.pop(context);
                          },
                          child: Card(
                            color: Color.fromARGB(172, 120, 255, 244),
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(Icons.arrow_right),
                              title: Text('Change password'),
                              trailing: Icon(Icons.key),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            logoutdialog(context);
                          },
                          child: Card(
                            color: Color.fromARGB(172, 120, 255, 244),
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(Icons.arrow_right),
                              title: Text('Logout'),
                              trailing: Icon(Icons.logout),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: (logindepart == 'SAD') ? 180 : 200,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 133, 251, 247),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 100,
                      width: 200,
                      child: Image.asset('images/staffinlogo.png'),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_outlined, color: Colors.black54),
              title: Text('HOME',
                  style: TextStyle(
                      fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeNavigator(),
                    ));
              },
            ),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),
            ListTile(
              leading: Icon(Icons.person_2_outlined, color: Colors.black54),
              title: Text('PROFILE',
                  style: TextStyle(
                      fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
              onTap: () async {
                String? refresh = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditProfile()));
                // final SharedPreferences sharedPreferences =
                //     await SharedPreferences.getInstance();
                // sharedPreferences.setString('session_user', loginuser);
                // sharedPreferences.setString('session2_user', logindepart);
                if (refresh == '1') {
                  setState(() {
                    checkLoginStatus();
                  });
                } else {
                  hack('refresh is null');
                }
              },
            ),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),
            if (logindepart == 'SAD')
              ExpansionTile(
                leading: Icon(Icons.villa_outlined, color: Colors.black54),
                title: Text(
                  'COMPANY SETTINGS',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(164, 0, 0, 0),
                  ),
                ),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () async {
                          String? refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Add_branch(loginuser: loginuser),
                            ),
                          );
                          if (refresh == '1') {
                            setState(() {
                              checkLoginStatus();
                            });
                          } else {
                            hack('refresh is null');
                          }
                        },
                        child: Text(
                          'ADD BRANCH',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddDepartment(),
                            ),
                          );
                        },
                        child: Text(
                          'ADD DEPARTMENT',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddDepartmenthead(branch: branch),
                            ),
                          );
                        },
                        child: Text(
                          'ADD DEPARTMENT HEAD/TL',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (logindepart == 'SAD') SizedBox(height: 5),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),
            if (logindepart == 'SAD')
              ExpansionTile(
                leading: Icon(
                  Icons.report_gmailerrorred,
                  color: Colors.black54,
                ),
                title: Text('EMPLOYEE PORTAL',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                children: [
                  if (logindepart == 'SAD')
                    Container(
                        height: 30,
                        width: double.infinity,
                        color: Color.fromARGB(132, 214, 214, 214),
                        child: Center(
                            child: Text(
                          'REGISTRATION',
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 133, 132, 132)),
                        ))),
                  if (logindepart == 'SAD')
                    SizedBox(
                      height: 10,
                    ),
                  if (logindepart == 'SAD')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () async {
                            page_navigation(username1.toString());
                          },
                          child: Text(
                            'ADMINISTRATION',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            page_navigation(username2.toString());
                          },
                          child: Text(
                            'EMPLOYEE                          ',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            page_navigation(username3.toString());
                          },
                          child: Text(
                            'TRAINEE',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  if (logindepart == 'SAD')
                    Container(
                        height: 30,
                        width: double.infinity,
                        color: Color.fromARGB(132, 214, 214, 214),
                        child: Center(
                            child: Text(
                          'VIEW',
                          style: TextStyle(
                              color: Color.fromARGB(255, 133, 132, 132)),
                        ))),
                  if (logindepart == 'SAD')
                    SizedBox(
                      height: 10,
                    ),
                  if (logindepart == 'SAD')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => View_Admin(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'VIEW ADMINISTRATION',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => View_Employee(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'VIEW EMPLOYEE',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => View_Trainee(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'VIEW TRAINEE',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BirthdayReport(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'BIRTHDAY REPORTS',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnniversaryReport(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'ANNIVERSARY REPORTS',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  if (logindepart == 'SAD')
                    Container(
                        height: 30,
                        width: double.infinity,
                        color: Color.fromARGB(132, 214, 214, 214),
                        child: Center(
                            child: Text(
                          'LOAN',
                          style: TextStyle(
                              color: Color.fromARGB(255, 133, 132, 132)),
                        ))),
                  if (logindepart == 'SAD')
                    SizedBox(
                      height: 10,
                    ),
                  if (logindepart == 'SAD')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'ADD LOAN                   ',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'LIST OF MEMBER',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'LOAN DEPOSIT',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'DEPOSIT MEMBER',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                ],
              ),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),
            if (logindepart == 'SAD')
              ExpansionTile(
                leading: Icon(Icons.calendar_month, color: Colors.black54),
                title: Text('ATTENDANCE',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                children: [
                  Container(
                      height: 30,
                      width: double.infinity,
                      color: Color.fromARGB(132, 214, 214, 214),
                      child: Center(
                          child: Text(
                        'ATTENDANCE REPORTS',
                        style: TextStyle(
                            color: Color.fromARGB(255, 133, 132, 132)),
                      ))),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (logindepart == 'SAD')
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => today_present(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'TODAY REPORT/           \nABSENT REPORT',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      if (logindepart == 'SAD')
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddAttendance(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'ADD PUNCHED RECORD',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      TextButton(
                        onPressed: () async {
                          if (logindepart == 'SAD') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Empwise_rep_1(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                            sharedPreferences.setString('dept', logindepart);
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Empwise_rep_2(
                                    id: loginuser,
                                    name: name,
                                    userdpt: logindepart,
                                    app: app_sts,
                                  ),
                                ));
                            // final SharedPreferences sharedPreferences =
                            //     await SharedPreferences.getInstance();
                            // sharedPreferences.setString('branch', branch);
                          }
                        },
                        child: Text(
                          'EMPLOYEE WISE\nATTENDANCE REPORT',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                      if (logindepart == 'SAD')
                        SizedBox(
                          height: 10,
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 30,
                      width: double.infinity,
                      color: Color.fromARGB(132, 214, 214, 214),
                      child: Center(
                          child: Text(
                        'LEAVE REPORTS',
                        style: TextStyle(
                            color: Color.fromARGB(255, 133, 132, 132)),
                      ))),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => leave_status_adm(),
                            ),
                          );
                          final SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.setString(
                              'session_user', logindepart);
                          sharedPreferences.setString('branch', branch);
                          sharedPreferences.setString('userdpt', logindepart);
                        },
                        child: Text(
                          'LEAVE STATUS',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                      if (logindepart == 'SAD')
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllStaff_Leave_Report(),
                              ),
                            );
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'EMPLOYEE LEAVE \nREPORT',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                  if (logindepart == 'SAD')
                    Container(
                        height: 30,
                        width: double.infinity,
                        color: Color.fromARGB(132, 214, 214, 214),
                        child: Center(
                            child: Text(
                          'LATE REPORT',
                          style: TextStyle(
                              color: Color.fromARGB(255, 133, 132, 132)),
                        ))),
                  if (logindepart == 'SAD')
                    SizedBox(
                      height: 10,
                    ),
                  if (logindepart == 'SAD')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Evening_Late_Page(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'EARLY BY REPORT     ',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Morning_Late_Page(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'MORNING LATE \nREPORT',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  Container(
                      height: 30,
                      width: double.infinity,
                      color: Color.fromARGB(132, 214, 214, 214),
                      child: Center(
                          child: Text(
                        'OTHERS',
                        style: TextStyle(
                            color: Color.fromARGB(255, 133, 132, 132)),
                      ))),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (logindepart == 'SAD')
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Set_Holiday(),
                                ));
                          },
                          child: Text(
                            'SET HOLIDAY',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      if (logindepart == 'SAD')
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExcelDatabase(),
                              ),
                            );
                          },
                          child: Text(
                            'EXCEL TO DATABASE',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      TextButton(
                        onPressed: () async {
                          if (logindepart == 'SAD') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddLeave_adm(),
                              ),
                            );
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString(
                                'session_user', logindepart);
                            sharedPreferences.setString('branch', branch);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddLeave_emp(id: loginuser, name: name),
                              ),
                            );
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString(
                                'session_user', logindepart);
                            sharedPreferences.setString('branch', branch);
                          }
                        },
                        child: Text(
                          'ADD LEAVE',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      height: 30,
                      width: double.infinity,
                      color: Color.fromARGB(132, 214, 214, 214),
                      child: Center(
                          child: Text(
                        'PERMISSION',
                        style: TextStyle(
                            color: Color.fromARGB(255, 133, 132, 132)),
                      ))),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (logindepart == 'SAD') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Add_Permission(),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPermission_emp(
                                    id: loginuser,
                                    name: name,
                                  ),
                                ));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          }
                        },
                        child: Text(
                          'ADD PERMISSION',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (logindepart == 'SAD') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AllStaff_Permission_Report(),
                              ),
                            );
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString(
                                'session_user', logindepart);
                            sharedPreferences.setString('branch', branch);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => View_Permission_Report(
                                  id: loginuser,
                                  name: name,
                                ),
                              ),
                            );
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('userdpt', logindepart);
                          }
                        },
                        child: Text(
                          'PERMISSION REPORT',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),
            if (logindepart == 'SAD')
              ExpansionTile(
                leading: Icon(Icons.payment_outlined, color: Colors.black54),
                title: Text('PAYROLL',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                children: [
                  Container(
                      height: 30,
                      width: double.infinity,
                      color: Color.fromARGB(132, 214, 214, 214),
                      child: Center(
                          child: Text(
                        'SALARY PAYROLL',
                        style: TextStyle(
                            color: Color.fromARGB(255, 133, 132, 132)),
                      ))),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (logindepart == 'SAD')
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Salary_Calc_1()));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'SALARY CALCULATION',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      if (logindepart == 'SAD')
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Salary_Inc_adm(),
                              ),
                            );
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('user', username3);
                            sharedPreferences.setString('branch', branch);
                          },
                          child: Text(
                            'SALARY INCREMENT',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      TextButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SalaryApproval(),
                            ),
                          );
                        },
                        child: Text(
                          'SALARY APPROVAL',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (logindepart == 'SAD') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SalaryReport(),
                              ),
                            );
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('user', username3);
                            sharedPreferences.setString('branch', branch);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SalaryReport2(
                                  id: loginuser,
                                  name: name,
                                  clicked: clicked,
                                  app: app_sts,
                                ),
                              ),
                            );
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('user', username3);
                            sharedPreferences.setString('branch', branch);
                          }
                        },
                        child: Text(
                          'SALARY REPORT',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      height: 30,
                      width: double.infinity,
                      color: Color.fromARGB(132, 214, 214, 214),
                      child: Center(
                          child: Text(
                        'OTHERS',
                        style: TextStyle(
                            color: Color.fromARGB(255, 133, 132, 132)),
                      ))),
                ],
              ),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),
            if (logindepart == 'SAD')
              ListTile(
                leading:
                    Icon(Icons.assignment_ind_rounded, color: Colors.black54),
                title: Text('PRINT ID',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                onTap: () async {
                  final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString('branch', branch);
                  // Handle the tap
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => printadm(),
                      ));
                },
              ),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),
            if (logindepart == 'SAD')
              ListTile(
                leading: Icon(Icons.home_work, color: Colors.black54),
                title: Text('WORK FROM HOME',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                onTap: () async {
                  // Handle the tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WFH_Report(),
                    ),
                  );
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString('branch', branch);
                  sharedPreferences.setString('dpt', logindepart);
                },
              ),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),
            if (logindepart == 'SAD')
              ListTile(
                leading: Icon(Icons.visibility_sharp, color: Colors.black54),
                title: Text('VISITORS',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                onTap: () async {
                  // Handle the tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewVisitors(),
                    ),
                  );
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString('user', username3);
                },
              ),
            if (logindepart == 'SAD')
              SizedBox(
                height: 5,
              ),

            // EMPLOYEE LOGIN VIEW

            if (logindepart == 'ad' || logindepart == 'emp')
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.black54),
                title: Text('ATTENDANCE',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                onTap: () async {
                  // Handle the tap
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Empwise_rep_2(
                            id: loginuser, name: name, userdpt: logindepart,app: app_sts,),
                      ));
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString('branch', branch);
                },
              ),
            if (logindepart == 'ad' || logindepart == 'emp')
              ExpansionTile(
                leading: Icon(Icons.exit_to_app, color: Colors.black54),
                title: Text('Leave',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                children: [
                  TextButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddLeave_emp(id: loginuser, name: name),
                          ),
                        );
                        final SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString(
                            'session_user', logindepart);
                        sharedPreferences.setString('branch', branch);
                      },
                      child: Text('APPLY LEAVE',
                          style: TextStyle(fontSize: 12.5))),
                  TextButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveStatus(
                              id: loginuser,
                              name: name,
                              userdpt: logindepart,
                              app: app_sts,
                            ),
                          ),
                        );
                      },
                      child: Text('LEAVE STATUS',
                          style: TextStyle(fontSize: 12.5)))
                ],
              ),
            if (logindepart == 'ad' || logindepart == 'emp')
              ListTile(
                leading: Icon(Icons.payments_outlined, color: Colors.black54),
                title: Text('SALARY',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalaryReport2(
                        id: loginuser,
                        name: name,
                        clicked: clicked,
                        app: app_sts,
                      ),
                    ),
                  );
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString('user', username3);
                  sharedPreferences.setString('branch', branch);
                },
              ),
            if (logindepart == 'ad' || logindepart == 'emp')
              ExpansionTile(
                leading: Icon(Icons.home_work, color: Colors.black54),
                title: Text('WORK FROM HOME',
                    style: TextStyle(
                        fontSize: 17, color: Color.fromARGB(164, 0, 0, 0))),
                children: [
                  TextButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddWFH(),
                            ));
                        final SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString(
                            'session_user', logindepart);
                        sharedPreferences.setString('uid', loginuser);
                        sharedPreferences.setString('branch', branch);
                      },
                      child: Text('ADD WFH', style: TextStyle(fontSize: 12.5))),
                  TextButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WFH_Report(),
                          ),
                        );
                        final SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString('branch', branch);
                        sharedPreferences.setString('dpt', logindepart);
                      },
                      child:
                          Text('WFH REPORT', style: TextStyle(fontSize: 12.5)))
                ],
              ),
            ListTile(
              leading: Icon(Icons.logout_outlined, color: Colors.black54),
              title: Text(
                'LOGOUT',
                style: TextStyle(
                    fontSize: 17, color: Color.fromARGB(164, 0, 0, 0)),
              ),
              onTap: () {
                Navigator.pop(context);
                logoutdialog(context);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement your refresh logic here
          // For example, you can fetch data from the server again
          setState(() {
            isLoading = true;
          });
          await checkLoginStatus(); // Replace fetchData() with your actual function to fetch data
          setState(() {
            isLoading = false;
          });
        },
        child: isLoading
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/back23.jpg'),
                    fit: BoxFit.cover, // You can adjust the fit as needed
                    colorFilter: ColorFilter.mode(
                      logindepart == 'SAD'
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      BlendMode.srcOver,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: logindepart == 'SAD' ? 20 : 70),
                      if (logindepart == 'SAD')
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text('WELCOME,',
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold)),
                        ),
                      if (logindepart == 'SAD')
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: data.isNotEmpty
                              ? Text(
                                  name,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  'No data available',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                        ),
                      if (logindepart == 'SAD')
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text('$greeting',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      if (logindepart == 'SAD')
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Row(
                            children: [
                              Text('Last Log In    ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Card(
                                  elevation: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text((log_in_tm == null)
                                        ? 'No data'
                                        : log_in_tm),
                                  )),
                            ],
                          ),
                        ),
                      if (logindepart == 'SAD')
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Row(
                            children: [
                              Text(
                                'Last Log Out ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Card(
                                  elevation: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text((log_out_tm == null)
                                        ? 'No data'
                                        : log_out_tm),
                                  )),
                            ],
                          ),
                        ),
                      if (logindepart != 'SAD')
                        Center(
                          child: Container(
                            height: 230,
                            width: 310,
                            child: Card(
                              elevation: 10,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('WELCOME,',
                                      style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold)),
                                  data.isNotEmpty
                                      ? Text(
                                          name.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Text(
                                          'No data available',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w200),
                                        ),
                                  Text('$greeting',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 34),
                                    child: Row(
                                      children: [
                                        Text('Last Log In    ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Card(
                                            elevation: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text((log_in_tm == null)
                                                  ? 'No data'
                                                  : log_in_tm),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 34),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Last Log Out ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Card(
                                            elevation: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text((log_out_tm == null)
                                                  ? 'No data'
                                                  : log_out_tm),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (logindepart == 'SAD')
                        Stack(
                          children: [
                            Container(
                              height:
                                  MediaQuery.of(context).size.height / 8 + 100,
                              width: MediaQuery.of(context).size.width / 2 + 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(100),
                                    bottomRight: Radius.circular(100)),
                                image: DecorationImage(
                                  image: AssetImage('images/label.jpg'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).size.height /
                                  50, // Adjust the top position as needed
                              left: MediaQuery.of(context).size.width /
                                  10, // Adjust the left position as needed
                              child: Text(
                                'Now you are in',
                                style: TextStyle(
                                  color: Colors.black, // Set the text color
                                  fontSize: 20, // Set the font size
                                  fontWeight:
                                      FontWeight.bold, // Set the font weight
                                ),
                              ),
                            ),
                            Positioned(
                                top: MediaQuery.of(context).size.height / 11,
                                left: MediaQuery.of(context).size.width / 10,
                                child: Container(
                                  height: 70,
                                  width: 150,
                                  // color: Colors.amber,
                                  child: Text(
                                    '$branch',
                                    style: TextStyle(
                                        fontSize: 25,
                                        color:
                                            Color.fromARGB(255, 240, 237, 237),
                                        fontWeight: FontWeight.bold),
                                    maxLines:
                                        2, // Set the maximum number of lines
                                    overflow: TextOverflow
                                        .ellipsis, // Overflow handling
                                  ),
                                )),
                            Positioned(
                                top:
                                    MediaQuery.of(context).size.height / 8 + 65,
                                left: MediaQuery.of(context).size.width / 10,
                                child: Text(
                                  'Portal',
                                  style: TextStyle(
                                    color: Colors.black, // Set the text color
                                    fontSize: 20, // Set the font size
                                    fontWeight:
                                        FontWeight.bold, // Set the font weight
                                  ),
                                ))
                          ],
                        ),
                      if (logindepart == 'SAD')
                        SizedBox(
                          height: 30,
                        ),
                      if (logindepart == 'SAD')
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.blueAccent,
                              ),
                              border: TableBorder.all(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black,
                                width: 0.4,
                              ),
                              columns: [
                                DataColumn(
                                    label: Text('S.No',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white))),
                                DataColumn(
                                    label: Text('Branch Name',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white))),
                                DataColumn(
                                    label: Text('Staff Count',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white))),
                              ],
                              rows: companyData.entries.map((entry) {
                                return DataRow(
                                    color: MaterialStateColor.resolveWith(
                                        (states) => Colors.white),
                                    cells: [
                                      DataCell(Center(
                                        child: Text((serialNumber++).toString(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                      DataCell(Center(
                                        child: Text(entry.key,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                      DataCell(Center(
                                        child: InkWell(
                                          onTap: () async {
                                            setState(() {
                                              branch = entry.key;
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      View_Employee(),
                                                ));
                                            final SharedPreferences
                                                sharedPreferences =
                                                await SharedPreferences
                                                    .getInstance();
                                            sharedPreferences.setString(
                                                'branch', entry.key);
                                          },
                                          child: Container(
                                            height: 25,
                                            width: 25,
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                  entry.value.toString(),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      companyData.isNotEmpty
                          ? Text('')
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Container(
                                color: const Color.fromARGB(166, 255, 255, 255),
                                child: Column(
                                  children: [
                                    Image(
                                        image: AssetImage('images/Search.png')),
                                    Text(
                                      'No data found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
