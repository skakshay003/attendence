// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, deprecated_member_use, use_key_in_widget_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, use_build_context_synchronously, non_constant_identifier_names, sort_child_properties_last, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../admin_login.dart';
import '../config.dart';
import 'package:intl/intl.dart';

class AddWFH extends StatefulWidget {
  @override
  State<AddWFH> createState() => _AddWFHState();
}

class _AddWFHState extends State<AddWFH> {
  final TextEditingController _supnm = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String monst = '';
  String monend = '';
  String tuest = '';
  String tueend = '';
  String wedst = '';
  String wedend = '';
  String thust = '';
  String thuend = '';
  String frist = '';
  String friend = '';
  String satst = '';
  String satend = '';
  String sunst = '';
  String sunend = '';

  var backendIP = ApiConstants.backendIP;
  bool tick = false;

  String user_id = '';
  String branch = '';
  String formattedDate = '';
  String name = '';
  String dept = '';
  String desig = '';
  String app_sts = '0';
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    submitForm();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('uid');
    var session2_user = sharedPreferences.getString('branch');
    if (session1_user != null && session2_user != null) {
      setState(() {
        user_id = session1_user;
        branch = session2_user;
        hack(user_id);
        hack(branch);
        fetchData();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  Future<void> fetchData() async {
    try {
      // Make an HTTP request to fetch data based on the profile email
      var apiUrl = Uri.parse('$backendIP/vfetchdata.php');
      var response = await http.post(apiUrl, body: {'user_id': user_id});
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
            dept = (data['em_depart'] == '')
                ? 'No Data'
                : data['em_depart'].toString();
            desig = (data['dsig'] == '') ? 'No Data' : data['dsig'].toString();
            hack(name);
          } else {
            hack('No data');
          }
        });
      } else {
        // Handle API error here
        hack('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      hack('Error: $e');
    }
  }

  Future<void> add_wfh() async {
    try {
      // Make an HTTP request to fetch data based on the profile email
      var apiUrl = Uri.parse('$backendIP/WFH_Status/add_wfh.php');
      var response = await http.post(apiUrl, body: {
        'req_dt': formattedDate,
        'nm': name,
        'user_id': user_id,
        'dept': dept,
        'desig': desig,
        'wfhst': selectedDate1,
        'wfhend': selectedDate2,
        'monst': monst,
        'monend': monend,
        'tuest': tuest,
        'tueend': tueend,
        'wedst': wedst,
        'wedend': wedend,
        'thust': thust,
        'thuend': thuend,
        'frist': frist,
        'friend': friend,
        'satst': satst,
        'satend': satend,
        'sunst': sunst,
        'sunend': sunend,
        'rsn': _reason.text,
        'supnm': _supnm.text,
        'sts': app_sts,
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        setState(() {
          // Clear text fields
          _reason.clear();
          _supnm.clear();
          // Clear all string variables
          name = '';
          user_id = '';
          dept = '';
          desig = '';
          selectedDate1 = '';
          selectedDate2 = '';
          monst = '';
          monend = '';
          tuest = '';
          tueend = '';
          wedst = '';
          wedend = '';
          thust = '';
          thuend = '';
          frist = '';
          friend = '';
          satst = '';
          satend = '';
          sunst = '';
          sunend = '';
          app_sts = '';
        });
      } else {
        // Handle API error here
        hack('Failed to insert data. Status code: ${response.statusCode}');
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

  void submitForm() {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Get the current date
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    hack(formattedDate);
  }

  String selectedDate1 = '';
  String selectedDate3 = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // Set your desired minimum date
      lastDate: DateTime(2100), // Set your desired maximum date
    );
    if (picked != null)
      setState(() {
        selectedDate1 = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        selectedDate3 = DateFormat('dd-MM-yyyy').format(picked);
      });
  }

  String selectedDate2 = '';
  String selectedDate4 = '';

  Future<void> _selectDate2(BuildContext context) async {
    DateTime fromDate = DateTime.parse(selectedDate1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: fromDate, // Set your desired minimum date
      lastDate: DateTime(2100), // Set your desired maximum date
    );
    if (picked != null)
      setState(() {
        selectedDate2 = "${picked.year}-${picked.month}-${picked.day}";
        selectedDate4 = DateFormat('dd-MM-yyyy').format(picked);
      });
  }

  String _formatTime(TimeOfDay timeOfDay) {
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

  String _formatTime2(TimeOfDay timeOfDay) {
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

  String _formatTime5(TimeOfDay timeOfDay) {
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

  String _formatTime6(TimeOfDay timeOfDay) {
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

  String _formatTime7(TimeOfDay timeOfDay) {
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

  String _formatTime8(TimeOfDay timeOfDay) {
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

  String _formatTime9(TimeOfDay timeOfDay) {
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

  String _formatTime10(TimeOfDay timeOfDay) {
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

  String _formatTime11(TimeOfDay timeOfDay) {
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

  String _formatTime12(TimeOfDay timeOfDay) {
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

  String _formatTime13(TimeOfDay timeOfDay) {
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

  String _formatTime14(TimeOfDay timeOfDay) {
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
          icon: Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: Text(
          'Work From Home Report',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'REQUEST FORM',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Request Date : ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: const Color.fromARGB(255, 33, 89, 243)),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Department : ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: const Color.fromARGB(255, 33, 89, 243)),
                          ),
                          Text(
                            dept,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Emp ID : ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: const Color.fromARGB(255, 33, 89, 243)),
                          ),
                          Text(
                            user_id,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Employee Name : ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: const Color.fromARGB(255, 33, 89, 243)),
                          ),
                          Text(
                            name,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'WFH Start',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: const Color.fromARGB(255, 33, 89, 243)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(selectedDate3),
                              InkWell(
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'WFH End',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: const Color.fromARGB(255, 33, 89, 243)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(selectedDate4),
                              InkWell(
                                  onTap: () {
                                    (selectedDate1 != '')?_selectDate2(context)
                                    : ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Center(child: Text('Select WFH Start Date !',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)),
                                      backgroundColor: Colors.amber,
                                      )
                                    );
                                  },
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'PROPOSED SCHEDULE DETAILS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'DAY',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Text(
                          'START TIME',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Text(
                          'END TIME',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'Monday',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              monst,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime(pickedTime);
                                      monst = formattedTime;
                                      print(monst);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              monend,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime2(pickedTime);
                                      monend = formattedTime;
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'Tuesday',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tuest,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime3(pickedTime);
                                      tuest = formattedTime;
                                      print(tuest);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tueend,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime4(pickedTime);
                                      tueend = formattedTime;
                                      print(tueend);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'Wednesday',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              wedst,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime5(pickedTime);
                                      wedst = formattedTime;
                                      print(wedst);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              wedend,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime6(pickedTime);
                                      wedend = formattedTime;
                                      print(wedend);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'Thursday',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              thust,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime7(pickedTime);
                                      thust = formattedTime;
                                      print(thust);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              thuend,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime8(pickedTime);
                                      thuend = formattedTime;
                                      print(thuend);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'Friday',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              frist,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime9(pickedTime);
                                      frist = formattedTime;
                                      print(frist);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              friend,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime10(pickedTime);
                                      friend = formattedTime;
                                      print(friend);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'Saturday',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              satst,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime11(pickedTime);
                                      satst = formattedTime;
                                      print(satst);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              satend,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime12(pickedTime);
                                      satend = formattedTime;
                                      print(satend);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                          child: Text(
                        'Sunday',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sunst,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime13(pickedTime);
                                      sunst = formattedTime;
                                      print(sunst);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 138, 138,
                              138), // You can set the color of the border
                        ),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sunend,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () async {
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
                                    setState(() {
                                      String formattedTime =
                                          _formatTime14(pickedTime);
                                      sunend = formattedTime;
                                      print(sunend);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.access_time_filled_sharp,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        child: TextFormField(
                          controller: _reason,
                          maxLines: null, // Allow unlimited lines
                          decoration: InputDecoration(
                            labelText: 'Reason for Working at Home',
                            hintText: 'Type here...',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a reason';
                            }
                            if (value.length < 3) {
                              return 'Reason must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                        child: TextFormField(
                          controller: _supnm,
                          maxLines: null, // Allow unlimited lines
                          decoration: InputDecoration(
                            labelText: 'Supervisor Name',
                            hintText: 'Type here...',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter supervisor name';
                            }
                            if (value.length < 3) {
                              return 'Reason must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Checkbox(
                    value: tick,
                    onChanged: (value) {
                      setState(() {
                        tick = value!;
                      });
                    },
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 70,
                      child: Text(
                          'I VIJAY hereby accept the terms & condiiton of work from home policy.'))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('1. CL Cannot Availed During WFH .'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('2. IP Portal & Slack should be online .'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width - 20,
                      child: Text(
                          '3. Respond to Calls / Emails / Messages.If Not Respond Within 10 Minutes the Management Cancel the WFH Without Prior Notice .')),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    (tick)
                        ? add_wfh()
                        : ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text(
                                  'Please check the terms & conditions !',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              backgroundColor:
                                  Colors.amber, // Set the background color
                            ),
                          );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text(
                            'Please fill the required fields !',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        backgroundColor: Color.fromARGB(255, 253, 215, 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text(
                  'Accept & Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
