// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_local_variable, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, non_constant_identifier_names, unused_element, camel_case_types, prefer_final_fields, unused_field, sort_child_properties_last, use_build_context_synchronously, unused_import

import 'dart:convert';
import 'package:attendence/Attendance/allstaff_leave_rep.dart';
import 'package:attendence/Staff_report/permission/add_permission_adm.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Attendance/add_leave_adm.dart';
import '../../admin_login.dart';
import '../../config.dart';

class AddPermission_emp extends StatefulWidget {
  const AddPermission_emp({Key? key, required this.id, required this.name})
      : super(key: key);

  final String id;
  final String name;

  @override
  State<AddPermission_emp> createState() => _AddPermission_empState();
}

class _AddPermission_empState extends State<AddPermission_emp> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController TakeFromController = TextEditingController();
  final TextEditingController UpToController = TextEditingController();
  final TextEditingController _reasn = TextEditingController();
  final TextEditingController _search = TextEditingController();

  FocusNode _textField1FocusNode = FocusNode();
  FocusNode _textField2FocusNode = FocusNode();
  FocusNode _textField3FocusNode = FocusNode();
  FocusNode _textField4FocusNode = FocusNode();
  FocusNode _textField5FocusNode = FocusNode();

  List viewstaffreport = [];
  List filteredData = [];
  bool isSearchVisible = false;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String currentDate = '';
  String dep = '';
  String name = '';
  String id = '';
  String selectedLeaveType = 'SELECT';
  String To = '';
  String formattedDate = '';
  String currentMonth = '';
  String currentYear = '';
  String status = '';
  String logindepart = '';
  String per_year = '';
  String per_month = '';
  String formattedfrom12Hour = '';
  String formattedTo12Hour = '';
  String perm_from = 'ad';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('session_user');
    if (session1_user != null) {
      setState(() {
        logindepart = session1_user;
        hack(logindepart);

        final currentDateMap = getCurrentDate();
        name = widget.name.toString();
        id = widget.id.toString().toUpperCase();
        fetchdept();

        final currentDay = currentDateMap['day'];
        currentMonth = currentDateMap['month'].toString(); // Update this line
        currentYear = currentDateMap['year'].toString(); // Update this line
        formattedDate = currentDateMap['formattedDate'];

        hack('Current Date: $currentDay');
        hack('Current Month: $currentMonth');
        hack('Current Year: $currentYear');
        hack('Formatted Date: $formattedDate');

        if (logindepart == 'SAD') {
          status = 'Approved'.toString();
        } else {
          status = 'Pending'.toString();
        }
        hack(status);
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  String permdt = ''; // Assuming permdt is declared as a string

  Future<void> _fromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // Set your desired minimum date
      lastDate: DateTime(2050), // Set your desired maximum date
    );
    if (picked != null) {
      setState(() {
        permdt =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

        // Split the permdt and store in separate variables
        List<String> dateParts = permdt!.split('-');
        per_year = dateParts[0]; // Assign to instance variable
        per_month = dateParts[1]; // Assign to instance variable

        // Now you have year and month as instance variables
        hack('Year: $per_year, Month: $per_month');
      });
    }
  }

  Map<String, dynamic> getCurrentDate() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return {
      'day': now.day,
      'month': now.month,
      'year': now.year,
      'formattedDate': formattedDate,
    };
  }

  Future<void> fetchdept() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Leave_Reports/vfetchempdept.php');
      var response = await http.post(apiUrl, body: {
        'name': name,
      });
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          if (responseData.isNotEmpty) {
            // Check if the response is not empty before accessing elements
            dep = responseData[0]['em_depart'].toString();
            hack(dep);
          } else {
            hack('No department data found');
          }
          isLoading = true;
        });
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
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

  TimeOfDay parseTime(String time) {
    try {
      DateTime dateTime = DateFormat('hh:mm a').parse(time);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      hack('Error parsing time: $e');
      // Handle the error, e.g., return a default time
      return TimeOfDay(hour: 0, minute: 0);
    }
  }

  String _formatTime(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  String _formatTime2(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  String calculateTimeDifference(takeFromTime, upToTime) {
    String takeFromDateTimeString = '$formattedDate $takeFromTime:00';
    String upToDateTimeString = '$formattedDate $upToTime:00';

    // Parse date and time strings with the correct format
    DateTime takeFromDateTime =
        DateFormat('dd-MM-yyyy HH:mm:ss').parse(takeFromDateTimeString);
    DateTime upToDateTime =
        DateFormat('dd-MM-yyyy HH:mm:ss').parse(upToDateTimeString);

    Duration duration = upToDateTime.difference(takeFromDateTime);
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    String timeGap = '$hours hours $minutes minutes';

    return timeGap;
  }

  Future<void> submit() async {
    String takeFromTime = TakeFromController.text;
    String upToTime = UpToController.text;
    if (takeFromTime.isNotEmpty) {
      TimeOfDay parsedTime = parseTime(takeFromTime);
      String formattedTime = _formatTime(parsedTime);
      TakeFromController.text = formattedTime + ':00'.toString();
    }

    if (upToTime.isNotEmpty) {
      TimeOfDay parsedTime = parseTime(upToTime);
      String formattedTime = _formatTime2(parsedTime);
      UpToController.text = formattedTime + ':00'.toString();
    }

    String timeGap =
        calculateTimeDifference(TakeFromController.text, UpToController.text);
    hack('Time Gap: $timeGap');
    hack('FROM: $TakeFromController');
    hack('UPTO: $UpToController');
    hack('takeFromTime: $takeFromTime');
    hack('upToTime: $upToTime');

    // Convert times to 12-hour format
    // String formattedFrom12Hour = convertTo12HourFormat(takeFromTime);
    // String formattedTo12Hour = convertTo12HourFormat(upToTime);

    try {
      hack(formattedDate);
      var apiUrl = Uri.parse('$backendIP/Permission/add_permission.php');

      var response = await http.post(apiUrl, body: {
        'sub_dt': formattedDate,
        'emp_name': name,
        'emp_id': id,
        'resn': _reasn.text,
        'per_st': TakeFromController.text,
        'per_end': UpToController.text,
        'per_st_12': takeFromTime,
        'per_end_12': upToTime,
        'permdt': permdt,
        'perm_mnt': per_month,
        'perm_yr': per_year,
        'month': currentMonth,
        'year': currentYear,
        'status': status,
        'time_gap': timeGap,
        'perm_from': perm_from,
      });

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          if (responseData is Map<String, dynamic> && responseData.isNotEmpty) {
            viewstaffreport = [responseData]; // Wrap responseData in a list
            hack(viewstaffreport);
          } else {
            hack('No data received from the server');
          }
        });

        // Show a SnackBar when data insertion is successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Center(
                    child: Text('Permission added successfully',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)))),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        TakeFromController.clear();
        UpToController.clear();
        _reasn.clear();
        permdt = '';
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text('! Failed to insert Data',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      hack('Insert error: $e');
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

// Function to convert time to 12-hour format
  String convertTo12HourFormat(String time24Hour) {
    DateTime dateTime = DateFormat('HH:mm').parse(time24Hour);
    return DateFormat('h:mm a').format(dateTime);
  }

  Future<void> onClick() async {
    setState(() {
      isSearchVisible = !isSearchVisible;
      _search.clear();
      filteredData.clear();
    });
  }

  void onSearchTextChanged(String text) {
    setState(() {
      filteredData = viewstaffreport
          .where((data) =>
              data['from_dt']
                  .toString()
                  .toLowerCase()
                  .contains(text.toLowerCase()) ||
              data['status']
                  .toString()
                  .toLowerCase()
                  .contains(text.toLowerCase()))
          .toList();
    });
  }

  TimeOfDay selectedTime = TimeOfDay.now();

  String _formatTime4(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    // Determine if it's AM or PM
    String period = (hour < 12) ? 'AM' : 'PM';

    // Convert to 12-hour format
    hour = hour % 12;
    hour = (hour == 0) ? 12 : hour;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return formattedTime;
  }

  String _formatTime3(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    // Determine if it's AM or PM
    String period = (hour < 12) ? 'AM' : 'PM';

    // Convert to 12-hour format
    hour = hour % 12;
    hour = (hour == 0) ? 12 : hour;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 10,
          toolbarHeight: 50,
          backgroundColor: Color.fromARGB(255, 133, 251, 247),
          shadowColor: Colors.black,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
          ),
          title: Row(
            children: [
              Text(
                'Add Permission',
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
              Spacer(),
              // IconButton(
              //   onPressed: () {
              //     onClick();
              //   },
              //   icon: const Icon(Icons.search),
              // )
            ],
          ),
        ),
        body: isLoading
            ? SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/leave2.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (isSearchVisible)
                        SizedBox(
                          height: 15,
                        ),
                      if (isSearchVisible)
                        Container(
                          height: 50.0,
                          width: 250.0,
                          child: TextField(
                            controller: _search,
                            onChanged: (text) {
                              onSearchTextChanged(text);
                              setState(() {}); // Update the UI
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Search...',
                            ),
                          ),
                        ),
                      if (isSearchVisible) SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.amber),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.name,
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ' : ',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    widget.id.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.1, color: Colors.black)),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    '  Date',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Text(
                                    permdt,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _fromDate(context),
                                    child: Text(
                                      'Select date',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(172, 120, 255, 244),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text('Take From',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            InkWell(
                              onTap: () async {
                                // Set initial time to 9:20
                                TimeOfDay initialTime =
                                    TimeOfDay(hour: 9, minute: 20);

                                // Show time picker and wait for user input
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: initialTime,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child!,
                                    );
                                  },
                                );

                                // Update the controller with the selected time
                                if (pickedTime != null) {
                                  String formattedTime =
                                      _formatTime3(pickedTime);
                                  TakeFromController.text = formattedTime;
                                }
                              },
                              child: TextFormField(
                                style: TextStyle(color: Colors.black),
                                controller: TakeFromController,
                                enabled: false,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.timer,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {},
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Text('UpTo',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            InkWell(
                              onTap: () async {
                                // Set initial time to 5:20
                                TimeOfDay initialTime =
                                    TimeOfDay(hour: 17, minute: 20);

                                // Show time picker and wait for user input
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: initialTime,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child!,
                                    );
                                  },
                                );

                                // Update the controller with the selected time
                                if (pickedTime != null) {
                                  String formattedTime =
                                      _formatTime4(pickedTime);
                                  UpToController.text = formattedTime;
                                }
                              },
                              child: TextFormField(
                                style: TextStyle(color: Colors.black),
                                controller: UpToController,
                                enabled: false,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.timer, color: Colors.blue),
                                    onPressed: () async {
                                      // Your onPressed logic here
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Reason',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.1, color: Colors.black),
                              ),
                              child: TextFormField(
                                controller: _reasn,
                                style: TextStyle(fontSize: 20),
                                maxLines:
                                    5, // Set maxLines to null for a textarea-like input
                                focusNode: _textField4FocusNode,
                                onFieldSubmitted: (value) {
                                  // Move focus to the next text field when submitted
                                  _textField1FocusNode.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_textField5FocusNode);
                                },
                                enabled: true,
                                decoration: InputDecoration(
                                  // Customize the border color and width
                                  border: InputBorder.none, // Remove the border
                                  contentPadding: EdgeInsets.all(
                                      8), // Adjust content padding
                                ),
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                            SizedBox(height: 15),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (permdt != '') {
                                    if (_reasn.text != '') {
                                      submit();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Center(
                                              child: Text('Enter Reason !',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black))),
                                          backgroundColor: Colors.amber,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Center(
                                            child: Text('Select date !',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black))),
                                        backgroundColor: Colors.amber,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
