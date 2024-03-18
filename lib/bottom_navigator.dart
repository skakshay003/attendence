// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print, dead_code, unused_local_variable, avoid_unnecessary_containers, non_constant_identifier_names, unused_import, duplicate_import, depend_on_referenced_packages, use_super_parameters, unnecessary_new, prefer_final_fields, unused_field, deprecated_member_use

import 'package:attendence/Staff_report/view/birthdayrep.dart';
import 'package:attendence/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'admin_login.dart';
import 'config.dart';
import 'dart:convert';
import 'package:attendence/Pay_Roll/salary_rep2.dart';
import 'package:attendence/Staff_report/Attendance_Reports/Empwise_attend_rep_emp.dart';
import 'package:attendence/Staff_report/Leave%20status/leave_status.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});
  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  AppUpdateInfo? _updateInfo;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool _flexibleUpdateAvailable = false;

  int _currentIndex = 0;
  var backendIP = ApiConstants.backendIP;
@override
void initState() {
  super.initState();
  if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
    InAppUpdate.performImmediateUpdate().catchError((e) {
      showSnack(e.toString());
      return AppUpdateResult.inAppUpdateFailed;
    });
    hack('update');
  } else {
    hack('no update');
  }
  checkLoginStatus();
  isloading = true;
}


  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  String depart = '';

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('depart');

    if (session1_user != null) {
      setState(() {
        depart = session1_user;
      });

      if (depart == 'SAD') {
        // Do nothing or navigate to a different screen if needed
        setState(() {
          submitForm();
        });
      } else if (depart == 'ad' || depart == 'emp') {
        // Navigate to HomeNavigator2 if the department is 'ad' or 'emp'
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeNavigator2()),
        );
      } else {
        // Navigate to the login screen if the department is neither 'SAD', 'ad', nor 'emp'
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AttendanceLogin()),
        );
      }
    } else {
      // Navigate to the login screen if user is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  bool isloading = false;
  String user_id = '';

  final List<Widget> _screens = [
    AdminPage(),
    AdminPage(),
    AdminPage(),
    AdminPage(),
  ];

  String Birthday_nm = ''; // Initialize an empty string to store names
  String formattedDate = '';
  String reg_day = '';
  int reg_month = 0;
  int reg_yr = 0;
  int daysTillToday = 0;

  void submitForm() {
  // Get the current date
  DateTime now = DateTime.now();
  int year = now.year;
  int month = now.month;
  int day = now.day;

  // Create a formatted date string (e.g., "2023-11-08")
  formattedDate = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  // Split the formatted date string
  List<String> dateParts = formattedDate.split('-');

  // Extract the day part and store it in reg_day
  reg_day = dateParts[2];

  // Store the extracted month in reg_month
  int extractedMonth = int.parse(dateParts[1]);
  int extractedYear = int.parse(dateParts[0]);
  reg_month = extractedMonth;
  reg_yr = extractedYear;

  // Calculate the count of days till today in the current month
  daysTillToday = day;

  // Use reg_day wherever you need it in your code
  hack(reg_day);
  hack(reg_month);
  hack(reg_yr);
  hack(daysTillToday); // Use this value as needed

  setState(() {
    viewBirthdayReport();
  });
}


  List birthdaydata = [];

  Future<void> viewBirthdayReport() async {
    print(reg_day);
    print(reg_month);
    try {
      var apiUrl = Uri.parse('$backendIP/dash_birthday.php');
      var response = await http.post(apiUrl, body: {
        'day': reg_day,
        'month': reg_month.toString(),
      });
      if (response.statusCode == 200) {
        birthdaydata = jsonDecode(response.body);
        print('birth');
        setState(() {
          ViewAnniversaryReport();
        });
        print(birthdaydata);
      } else {
        setState(() {
          ViewAnniversaryReport();
        });
        print('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  List anniversary = [];

  Future<void> ViewAnniversaryReport() async {
    print(reg_day);
    print(reg_month);
    try {
      var apiUrl = Uri.parse('$backendIP/dash_anniversary.php');
      var response = await http.post(apiUrl, body: {
        'day': reg_day,
        'month': reg_month.toString(),
      });
      if (response.statusCode == 200) {
        anniversary = jsonDecode(response.body);
        print('anniversary');
        setState(() {
          ViewAttendanceReport();
          ViewLeaveReport();
        });
        print(anniversary);
      } else {
        setState(() {
          ViewAttendanceReport();
          ViewLeaveReport();
        });
        print('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  List attendance = [];
  Map<String, int> userCounts = {};

  Future<void> ViewAttendanceReport() async {
    print(reg_day);
    print(reg_month);
    try {
      var apiUrl = Uri.parse('$backendIP/dash_attendance.php');
      var response = await http.post(apiUrl, body: {
        'yr': reg_yr.toString(),
        'month': reg_month.toString(),
      });
      if (response.statusCode == 200) {
        attendance = jsonDecode(response.body);
        print('attendance');
        print(attendance);

        for (Map<String, dynamic> entry in attendance) {
          String userId = entry['user_id'];
          userCounts[userId] = (userCounts[userId] ?? 0) + 1;
        }

        List<Map<String, dynamic>> result = userCounts.entries
            .map((entry) => {entry.key: entry.value})
            .toList();

        print(result); // Output: [{SS1001: 2}]
      } else {
        print('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  List Leave = [];
  Map<String, int> userLeaveCounts = {};

  Future<void> ViewLeaveReport() async {
    print(reg_day);
    print(reg_month);
    try {
      var apiUrl = Uri.parse('$backendIP/dash_leave.php');
      var response = await http.post(apiUrl, body: {
        'yr': reg_yr.toString(),
        'month': reg_month.toString(),
      });
      if (response.statusCode == 200) {
        Leave = jsonDecode(response.body);
        print('Leave');
        print(Leave);

        for (Map<String, dynamic> entry in Leave) {
          String userId = entry['user_id'];
          DateTime fromDate = DateTime.parse(entry['from_dt']);
          DateTime toDate = DateTime.parse(entry['to_dt']);

          // Calculate in-between dates
          List<DateTime> inBetweenDates = [];
          for (int i = 0; i <= toDate.difference(fromDate).inDays; i++) {
            inBetweenDates.add(fromDate.add(Duration(days: i)));
          }

          // Count in-between dates for each user
          userLeaveCounts[userId] =
              (userLeaveCounts[userId] ?? 0) + inBetweenDates.length;
        }

        List<Map<String, dynamic>> result = userLeaveCounts.entries
            .map((entry) => {entry.key: entry.value})
            .toList();

        print(result); // Output: [{SS1002: 5}]
        setState(() {
          viewholidayattend();
        });
      } else {
        setState(() {
          viewholidayattend();
        });
        print('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  List<Map<String, dynamic>> full_attendMapped = [];

Future<void> displayRemainingUsers(int totalAttendanceDays) async {
  // Remove users who have leave entries
  userCounts.removeWhere((userId, count) =>
      userLeaveCounts.containsKey(userId) || count != totalAttendanceDays);

  // Map userCounts to the desired format
  full_attendMapped = userCounts.entries.map((entry) {
    return {
      'user_id': entry.key,
      'count': entry.value,
    };
  }).toList();

  print('full_attend : $full_attendMapped');
}



  List viewholiday = [];
  int holidayLength = 0;
  int total_attendance_days = 0;

  Future<void> viewholidayattend() async {
    print('date : $formattedDate');
    try {
      var apiUrl =
          Uri.parse('$backendIP/dash_holiday.php');
      var response = await http.post(apiUrl, body: {
        'month': reg_month.toString(),
        'day': formattedDate.toString(),
      });
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          viewholiday = List<Map<String, dynamic>>.from(responseData);
          print(viewholiday);
          holidayLength = viewholiday.length;
          hack('holidayLength:$holidayLength');
          total_attendance_days = daysTillToday - holidayLength ;
          hack(total_attendance_days);
          isloading = true;
        });
        await displayRemainingUsers(total_attendance_days);
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error1: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int serialNumber = 1;
    return Scaffold(
      body: isloading
          ? _screens[_currentIndex]
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white60,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomNavigationBar(
              elevation: 10,
              selectedItemColor: isloading ? Colors.black : Colors.white,
              unselectedItemColor: isloading ? Colors.black : Colors.white,
              currentIndex: _currentIndex,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });

                // Show the bottom sheet when the 'Birthday' tab is selected
                if (index == 1) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Container(
                              // Customize the bottom sheet as per your requirement
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cake,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'BirthdayReport',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowColor:
                                        MaterialStateColor.resolveWith(
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
                                          label: Text('Names',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white))),
                                      DataColumn(
                                          label: Text('Date',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white))),
                                    ],
                                    rows: birthdaydata.map((entry) {
                                      return DataRow(cells: [
                                        DataCell(Center(
                                          child: Text(
                                            (birthdaydata.indexOf(entry) + 1)
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                        DataCell(Center(
                                          child: Text(
                                            entry['nm']
                                                .toString(), // Replace 'name' with the actual property name in your data
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                        DataCell(Center(
                                          child: InkWell(
                                            onTap: () {
                                              // Handle onTap action if needed
                                            },
                                            child: Center(
                                              child: Text(
                                                // Format the date as needed
                                                entry['dob'] != null
                                                    ? DateFormat('dd/MM/yyyy')
                                                        .format(DateTime.parse(
                                                            entry['dob']))
                                                        .toString()
                                                    : 'Invalid Date', // Handle the case if entry['dob'] is null or not in the expected format
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                              birthdaydata.isNotEmpty || birthdaydata.isNotEmpty
                                  ? Text('')
                                  : Column(
                                      children: [
                                        Image(
                                            image: AssetImage(
                                                'images/Search.png')),
                                        Text(
                                          'No data found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                            ],
                          )),
                        ),
                      );
                    },
                  );
                }
                if (index == 2) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Container(
                              // Customize the bottom sheet as per your requirement
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cake,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Anniversary Report',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowColor:
                                        MaterialStateColor.resolveWith(
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
                                                  fontWeight:
                                                      FontWeight.bold,color: Colors.white))),
                                      DataColumn(
                                          label: Text('Names',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold,color: Colors.white))),
                                      DataColumn(
                                          label: Text('Date',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold,color: Colors.white))),
                                    ],
                                    rows: anniversary.map((entry) {
                                      return DataRow(cells: [
                                        DataCell(Center(
                                          child: Text(
                                            serialNumber.toString(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                        DataCell(Center(
                                          child: Text(
                                            entry['nm']
                                                .toString(), // Replace 'name' with the actual property name in your data
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                        DataCell(Center(
                                          child: InkWell(
                                            onTap: () {
                                              // Handle onTap action if needed
                                            },
                                            child: Center(
                                              child: Text(
                                                // Format the date as needed
                                                // Format the date as needed
                                                entry['doj'] != null
                                                    ? DateFormat('dd/MM/yyyy')
                                                        .format(DateTime.parse(
                                                            entry['doj']))
                                                        .toString()
                                                    : 'Invalid Date', // Handle the case if entry['dob'] is null or not in the expected format
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                              anniversary.isNotEmpty || anniversary.isNotEmpty
                                  ? Text('')
                                  : Column(
                                      children: [
                                        Image(
                                            image: AssetImage(
                                                'images/Search.png')),
                                        Text(
                                          'No data found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                            ],
                          )),
                        ),
                      );
                    },
                  );
                }
                if (index == 3) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Container(
                              // Customize the bottom sheet as per your requirement
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Attendance Report',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Center(
                                child: DataTable(
                                  // columnSpacing: 20,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
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
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.bold,color: Colors.white))),
                                    DataColumn(
                                        label: Text('Emp Id',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.bold,color: Colors.white))),
                                    DataColumn(
                                        label: Text('Sts',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.bold,color: Colors.white))),
                                  ],
                                  rows: full_attendMapped.map((entry) {
                                    return DataRow(cells: [
                                      DataCell(Center(
                                        child: Text(
                                          serialNumber.toString(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                      DataCell(Center(
                                        child: Text(
                                          entry['user_id']
                                              .toString(), // Replace 'name' with the actual property name in your data
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                      DataCell(Center(
                                        child: Text('💯',style: TextStyle(fontSize: 21),)
                                      )),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                              full_attendMapped.isNotEmpty || full_attendMapped.isNotEmpty
                                  ? Text('')
                                  : Column(
                                      children: [
                                        Image(
                                            image: AssetImage(
                                                'images/Search.png')),
                                        Text(
                                          'No data found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                            ],
                          )),
                        ),
                      );
                    },
                  );
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cake),
                  label: 'Birthday',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.festival),
                  label: 'Anniversary',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Attendance',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeNavigator2 extends StatefulWidget {
  const HomeNavigator2({Key? key}) : super(key: key);

  @override
  State<HomeNavigator2> createState() => _HomeNavigator2State();
}

class _HomeNavigator2State extends State<HomeNavigator2> {
  int _currentIndex = 0;
  var backendIP = ApiConstants.backendIP;

  bool isloading = false;
  String user_id = '';
  String id = '';
  String depart = '';
  String name = '';
  String clicked = '0';
  String app_sts = '1';

  // Updated the type of _screens to List<Widget>
  final List<Widget> _screens = [
    AdminPage(),
    LeaveStatus(id: '', name: '', userdpt: '', app: ''),
    SalaryReport2(id: '', name: '', clicked: '', app: '',),
    Empwise_rep_2(id: '', name: '', userdpt: '', app: '',),
  ];

  // Function to update LeaveStatusPage arguments
  void updateLeaveStatusArguments(
      String newId, String newName, String newDepart, String apps) {
    setState(() {
      id = newId;
      name = newName;
      depart = newDepart;
      apps = apps;
      // If the widget is mounted, update the arguments
      if (_screens[_currentIndex] is LeaveStatus) {
        (_screens[_currentIndex] as LeaveStatus)
            .updateArguments(id, name, depart, apps);
      }
    });
  }

  // Function to update SalaryPage arguments
  void updateSalaryArguments(String newId, String newName, String newClicked, String apps) {
    setState(() {
      id = newId;
      name = newName;
      clicked = newClicked;
      apps = apps;

      if (_screens[_currentIndex] is SalaryReport2) {
        (_screens[_currentIndex] as SalaryReport2)
            .updateArguments(id, name, clicked, apps);
      }
    });
  }

  // Function to update attendancePage arguments
  void updateAttendanceArguments(
      String newId, String newName, String newDepart, String apps) {
    setState(() {
      id = newId;
      name = newName;
      depart = newDepart;
      apps = apps;

      if (_screens[_currentIndex] is Empwise_rep_2) {
        (_screens[_currentIndex] as Empwise_rep_2)
            .updateArguments(id, name, depart, apps);
      }
    });
  }

  String Birthday_nm = '';
  String formattedDate = '';
  String reg_day = '';
  int reg_month = 0;
  int reg_yr = 0;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    submitForm();
    isloading = true;
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('session_user');
    var session2_user = sharedPreferences.getString('depart');
    var session3_user = sharedPreferences.getString('name');
    if (session1_user != null &&
        session2_user != null &&
        session3_user != null) {
      setState(() {
        id = session1_user;
        depart = session2_user;
        name = session3_user;
        print('id:$id');
        print('id:$depart');
        print('id:$name');
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  void submitForm() {
    // Get the current date
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    String formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    // Split the formatted date string
    List<String> dateParts = formattedDate.split('-');

    // Extract the day part and store it in reg_day
    reg_day = dateParts[2];

    // Store the extracted month in reg_month
    int extractedMonth = int.parse(dateParts[1]);
    int extractedYear = int.parse(dateParts[0]);
    reg_month = extractedMonth;
    reg_yr = extractedYear;

    // Use reg_day wherever you need it in your code
    hack(reg_day);
    hack(reg_month);
    hack(reg_yr);
    setState(() {
      isloading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    int serialNumber = 1;
    return Scaffold(
      appBar:(_currentIndex != 0)?AppBar(
          elevation: 10,
          toolbarHeight: 50,
          backgroundColor: Color.fromARGB(255, 133, 251, 247),
          shadowColor: Colors.black,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              setState(() {
              _currentIndex = 0;
            });
            },
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
          ),
          title: Row(
            children: [
              (_currentIndex == 1)?Text(
                'Leave Status',
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              )
              : (_currentIndex == 2)?Text(
                'Salary Report',
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              )
              :(_currentIndex == 3)?Text(
                'Attendance Report',
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              )
              : Text(''),
              Spacer(),
              // IconButton(
              //   onPressed: () {
              //     onClick();
              //   },
              //   icon: const Icon(Icons.search),
              // )
            ],
          ),
        ): null,
      body: isloading
          ? _screens[_currentIndex]
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white60,
        ),
        child: WillPopScope(
          // Intercepts back button press
          onWillPop: () async {
        // Navigate to the home page (index 0)
        setState(() {
          _currentIndex = 0;
        });
        // Return false to allow the back navigation
        return false;
      },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomNavigationBar(
                elevation: 10,
                selectedItemColor: isloading ? Colors.black : Colors.white,
                unselectedItemColor: isloading ? Colors.black : Colors.white,
                currentIndex: _currentIndex,
                onTap: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
          
                  // Show the bottom sheet when the 'Birthday' tab is selected
                  if (index == 1) {
                    updateLeaveStatusArguments(id, name, depart, app_sts);
                  }
                  if (index == 2) {
                    updateSalaryArguments(id, name, clicked, app_sts);
                  }
                  if (index == 3) {
                    updateAttendanceArguments(id, name, depart, app_sts);
                  }
                  // Add similar conditions for other tabs if needed
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.time_to_leave_sharp),
                    label: 'Leave',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.payments_sharp),
                    label: 'Salary',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month),
                    label: 'Attendance',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
