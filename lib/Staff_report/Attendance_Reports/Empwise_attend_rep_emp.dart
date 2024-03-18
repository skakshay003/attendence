// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_local_variable, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, non_constant_identifier_names, unused_element, camel_case_types, prefer_final_fields, unused_field, sort_child_properties_last, use_build_context_synchronously, unused_import, file_names, dead_code, prefer_interpolation_to_compose_strings, unnecessary_cast, unnecessary_null_comparison, collection_methods_unrelated_type, use_super_parameters

import 'dart:convert';
import 'package:attendence/Staff_report/Attendance_Reports/Empwise_attend_rep_adm.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin_login.dart';
import '../../config.dart';

class Empwise_rep_2 extends StatefulWidget {
  Empwise_rep_2(
      {Key? key, required this.id, required this.name, required this.userdpt, required this.app})
      : super(key: key);

  String id;
  String name;
  String userdpt;
  String app;

  void updateArguments(String newId, String newName, String newDepart, String apps) {
    id = newId;
    name = newName;
    userdpt = newDepart;
  }

  @override
  State<Empwise_rep_2> createState() => _Empwise_rep_2State();
}

class _Empwise_rep_2State extends State<Empwise_rep_2> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController TakeFromController = TextEditingController();
  final TextEditingController UpToController = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _reasn = TextEditingController();
  final TextEditingController _id = TextEditingController();
  final TextEditingController _search = TextEditingController();

  FocusNode _textField1FocusNode = FocusNode();
  FocusNode _textField2FocusNode = FocusNode();
  FocusNode _textField3FocusNode = FocusNode();
  FocusNode _textField4FocusNode = FocusNode();
  FocusNode _textField5FocusNode = FocusNode();

  List viewstaffreport = [];
  List viewholiday = [];
  List viewleavedt = [];
  List departmentData = [];
  List filteredData = [];
  bool isSearchVisible = false;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String selectedMonthYear = '';
  String work_from = '';
  String work_to = '';
  String late = '';
  String early_by = '';
  String permMrng = '';
  bool isLoading = false;
  int staffReportLength = 0;
  int holidayLength = 0;
  String monthName = '';
  String depart = '';
  String user_dept = '';
  int entriesBelowThresholdCount = 0;
  int daysInMonth = 0;
  int mis_clkin = 0;
  Duration totalMrnglateDuration = Duration.zero;
  Duration totalearlybylateDuration = Duration.zero;
  Duration totallate = Duration.zero;

  @override
  void initState() {
    super.initState();
    _name.text = widget.name.toString();
    _id.text = widget.id.toString();
    user_dept = widget.userdpt.toString();
    updateSelectedMonthYear();
    hack(user_dept);
    viewemployee_work_tym();
    hack(selectedMonth);
    summary();
    viewholidayattend();
    viewstaffrep();
  }

  // Future<void> checkLoginStatus() async {
  //   final SharedPreferences sharedPreferences =
  //       await SharedPreferences.getInstance();
  //   var session2_user = sharedPreferences.getString('branch');
  //   if (session2_user != null && session1_user != null) {
  //     setState(() {
  //       logindepart = session2_user;
  //       branch = session2_user;
  //       hack(branch);
  //       viewempreg();
  //     });
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => AttendanceLogin()),
  //     );
  //   }
  // }

  void summary() {
    monthName =
        DateFormat('MMMM').format(DateTime(selectedYear, selectedMonth));

    // Calculate the number of days in the selected month
    daysInMonth = DateTime(2024, selectedMonth + 1, 0).day;
    hack(monthName);
    hack(daysInMonth);
  }

  // Function to compare time strings with the minimum threshold
  bool isTimeBelowThreshold(String timeString, Duration threshold) {
    DateTime entryTime = DateTime.parse("1970-01-01 " + timeString);
    DateTime thresholdTime =
        DateTime(1970, 1, 1, threshold.inHours, threshold.inMinutes % 60);

    return entryTime.isBefore(thresholdTime);
  }

  void calc_clockout() {
    // Set the minimum threshold for tot_hr
    final Duration minimumThreshold = Duration(hours: 03, minutes: 30);

    // Filter the viewstaffreport based on the criteria
    List entriesBelowThreshold = viewstaffreport
        .where((data) =>
            data['tot_hr'] != null &&
            !isTimeBelowThreshold(data['tot_hr'], minimumThreshold))
        .toList();

    // Get the count of entries below the minimum threshold
    int entriesBelowThresholdCount = entriesBelowThreshold.length;

    hack(
        'Number of entries with tot_hr below $minimumThreshold: $entriesBelowThresholdCount');

    // hack details of entries below the threshold
    for (Map<String, dynamic> entry in entriesBelowThreshold) {
      hack('Entry: $entry');
    }
    early_clkout = staffReportLength - entriesBelowThresholdCount;
    hack(early_clkout);
    mis_clkin = daysInMonth - staffReportLength - holidayLength;
    hack(mis_clkin);
    mis_clkin = mis_clkin.abs();
    hack(mis_clkin);
  }

  String formatTime(String timeString) {
    // Split the timeString by ':'
    List<String> parts = timeString.split(':');

    // Take the first two parts (hours and minutes)
    if (parts.length >= 2) {
      String hours = parts[0];
      String minutes = parts[1];

      // Create a TimeOfDay object
      TimeOfDay timeOfDay = TimeOfDay(
        hour: int.parse(hours),
        minute: int.parse(minutes),
      );

      // Format the TimeOfDay to a 12-hour format string
      return _formatTime(timeOfDay);
    }

    // Return an empty string if the format is invalid
    return '';
  }

  String _formatTime(TimeOfDay timeOfDay) {
    // Determine if it's AM or PM
    String period = (timeOfDay.hour < 12) ? 'AM' : 'PM';

    // Convert to 12-hour format
    int hour = timeOfDay.hour % 12;
    hour = (hour == 0) ? 12 : hour;

    // Return the formatted time
    return '$hour:${timeOfDay.minute.toString().padLeft(2, '0')} $period';
  }

  String formatTime1(String timeString) {
    // Split the timeString by ':'
    List<String> parts = timeString.split(':');

    // Take the first two parts (hours and minutes)
    if (parts.length >= 2) {
      String hours = parts[0];
      String minutes = parts[1];
      String seconds = parts[1];

      // Return the formatted time
      return '$hours:$minutes:$seconds';
    }

    // Return an empty string if the format is invalid
    return '';
  }

  List<DateTime> generateDatesForSelectedMonth() {
    int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    return List.generate(daysInMonth,
        (index) => DateTime(selectedYear, selectedMonth, index + 1));
  }

  Future<void> viewemployee_work_tym() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/vfetchemp_work_tym.php');
      var response = await http.post(apiUrl, body: {
        'userid': widget.id,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          departmentData = List<Map<String, dynamic>>.from(data);
          work_from = departmentData.isNotEmpty
              ? departmentData[0]['work_frm'] as String
              : '';
          work_to = departmentData.isNotEmpty
              ? departmentData[0]['work_to'] as String
              : '';
          depart = departmentData.isNotEmpty
              ? departmentData[0]['depart'] as String
              : '';
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  int early_clkout = 0;

  Future<void> viewstaffrep() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/vfetch_empwise_attend.php');
      var response = await http.post(apiUrl, body: {
        'userid': widget.id.toString(),
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          viewstaffreport = List<Map<String, dynamic>>.from(responseData);
          hack(viewstaffreport);
          staffReportLength = viewstaffreport.length;
          isLoading = true;
          calc_clockout();
          totalMrnglateDuration = Duration.zero;
          totalearlybylateDuration = Duration.zero;
          totallate = Duration.zero;
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

  Future<void> viewholidayattend() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/vfetch_holiday_attend.php');
      var response = await http.post(apiUrl, body: {
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          viewholiday = List<Map<String, dynamic>>.from(responseData);
          hack(viewholiday);
          holidayLength = viewholiday.length;
          hack(holidayLength);
          hack(viewholiday[0]['holiday_date']);
          viewleave();
        });
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  List<Map<String, dynamic>> inBetweenDates = [];
  Map<String, int> typeCounts = {};
  Map<String, int> dateCounts = {};

  Future<void> viewleave() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Attendance_Reports/view_emp_lv.php');
      var response = await http.post(apiUrl, body: {
        'userid': widget.id.toString(),
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          viewleavedt = List<Map<String, dynamic>>.from(responseData);
          hack(viewleavedt);
          hack(selectedMonth);

          // Iterate through each row in viewleavedt
          for (var row in viewleavedt) {
            DateTime fromDt = DateTime.parse(row['from_dt']);
            DateTime toDt = DateTime.parse(row['to_dt']);

            // Generate a list of maps for each date between from_dt and to_dt
            List<Map<String, dynamic>> inBetweenDates = List.generate(
              toDt.difference(fromDt).inDays + 1,
              (index) => {
                'date': DateFormat('yyyy-MM-dd')
                    .format(fromDt.add(Duration(days: index))),
                'type': row['lev_typ'],
                'resn': row['reason'],
              },
            );

            // Filter inBetweenDates based on selectedMonth
            int selectedMonthInt = int.parse(selectedMonth.toString());
            inBetweenDates = inBetweenDates
                .where((entry) =>
                    DateTime.parse(entry['date']).month == selectedMonthInt)
                .toList();

            // Count occurrences of each type in the filtered list
            for (var entry in inBetweenDates) {
              String type = entry['type'];
              typeCounts[type] = (typeCounts[type] ?? 0) + 1;
            }

            // hack the filtered in-between dates for each row
            hack('In-between dates for row ${row['id']} in $selectedMonth:');
            hack(inBetweenDates);
            hack('--------------------------');

            // hack the counts of each type in the filtered list
            hack('Type counts in $selectedMonth:');
            hack(typeCounts);
            // Iterate through viewHoliday and inBetweenDates
            for (var holiday in viewholiday) {
              String holidayDate = holiday['holiday_date'];
              dateCounts[holidayDate] = dateCounts[holidayDate] ?? 0;

              for (var entry in inBetweenDates) {
                String entryDate = entry['date'];

                // Compare date strings and update counts
                if (entryDate == holidayDate) {
                  dateCounts[holidayDate] = (dateCounts[holidayDate] ?? 0) + 1;
                }
              }
            }

// hack the counts for each date with count greater than zero
            hack('Date counts:');
            dateCounts.forEach((date, count) {
              if (count > 0) {
                hack({'Matchedt_cnt': count});
              }
            });
          }
        });
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  void updateSelectedMonthYear() {
    setState(() {
      selectedMonthYear =
          DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: selectedMonth,
                items: List.generate(12, (index) => index + 1)
                    .map((int value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            DateFormat('MMMM')
                                .format(DateTime(selectedYear, value)),
                          ),
                        ))
                    .toList(),
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      selectedMonth = value;
                      updateSelectedMonthYear();
                      viewstaffrep();
                      viewholidayattend();
                      summary();
                      Navigator.pop(context);
                    });
                  }
                },
              ),
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(
                        10, (index) => DateTime.now().year - 5 + index)
                    .map((int value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        ))
                    .toList(),
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      selectedYear = value;
                      updateSelectedMonthYear();
                      viewstaffrep();
                      viewholidayattend();
                      summary();
                      Navigator.pop(context);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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

  String calculateTotalHoursMinutes(String workFrom, String clkInTime) {
    try {
      // hack the value of workFrom for debugging
      hack('workFrom: $workFrom');

      // Parse workFrom to DateTime
      DateTime workFromTime = DateFormat('HH:mm:ss').parse(workFrom);

      // Parse clkInTime to DateTime
      DateTime clkInTimeParsed = DateFormat('HH:mm:ss').parse(clkInTime);

      // Calculate the difference
      Duration difference = clkInTimeParsed.difference(workFromTime);

      // Check if the difference is negative
      if (difference.isNegative) {
        // If clk_out_tm exceeds work_to, return '00 hr 00 min'
        return '00:00:00';
      }

      // Format the result
      String late =
          '${difference.inHours.toString().padLeft(2, '0')}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}:00';
      hack(late);
      return late;
    } catch (e) {
      hack('Error parsing date: $e');
      return '';
    }
  }

  String calculateTotalHoursMinutes2(String work_to, String clk_out_tm) {
    try {
      // hack the value of workFrom for debugging
      hack('workTo: $work_to');

      // Parse work_from to DateTime
      DateTime workToTime = DateFormat('h:mm:ss').parse(work_to);

      // Parse clk_in_tm to DateTime
      DateTime clk_out_tmParsed = DateFormat('HH:mm:ss').parse(clk_out_tm);

      // Calculate the difference
      Duration difference = workToTime.difference(clk_out_tmParsed);

      // Check if the difference is negative
      if (difference.isNegative) {
        // If clk_out_tm exceeds work_to, return '00 hr 00 min'
        return '00:00:00';
      }

      // Format the result
      String early_by =
          '${difference.inHours.toString().padLeft(2, '0')}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}:00';
      return early_by;
    } catch (e) {
      hack('Error parsing date: $e');
      return '';
    }
  }

  String calculatePermMrng(String late) {
    late = late.replaceAll(' hr ', ':').replaceAll(' min', '');

    List<String> lateParts = late.split(':');
    if (lateParts.length == 2) {
      int lateHours = int.tryParse(lateParts[0]) ?? 0;
      int lateMinutes = int.tryParse(lateParts[1]) ?? 0;

      if (lateHours == 0 && lateMinutes < 5) {
        return '04 mins';
      } else if (lateHours == 0 && lateMinutes >= 5) {
        return '30 mins';
      } else {
        return '1 hr';
      }
    } else {
      return '- -';
    }
  }

  Future<void> deleteDepartment(String id) async {
    hack(id);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete this Attendance?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                performDelete(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> performDelete(String id) async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/delete_attendance.php');
      var response = await http.post(apiUrl, body: {
        'id': id.toString(),
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Department deleted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Attendance deleted successfully',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            viewstaffrep();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Failed to delete attendance',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        hack('Error occurred during attendance deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text('Failed to delete attendance',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            backgroundColor: Colors.yellow.shade600,
          ),
        );
      }
    } catch (e) {
      hack('Delete error: $e');
    }
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

  String _formatTime8(TimeOfDay timeOfDay) {
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

  int hourOf12HourFormat(int hour) {
    // Convert hour to 12-hour format
    return hour > 12 ? hour - 12 : hour;
  }

  String calculateTotalHoursAndMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    final int startMinutes = startTime.hour * 60 + startTime.minute;
    final int endMinutes = endTime.hour * 60 + endTime.minute;

    final int totalMinutes = endMinutes - startMinutes;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    final int seconds = 0; // Assuming seconds should always be 0

    return '${_formatTimeComponent(hours)}:${_formatTimeComponent(minutes)}:${_formatTimeComponent(seconds)}';
  }

  String _formatTimeComponent(int component) {
    return component.toString().padLeft(2, '0');
  }

  TimeOfDay parseTime2(String time) {
    List<String> components = time.split(':');

    if (components.length >= 2) {
      try {
        int hour = int.parse(components[0]);
        int minute = int.parse(components[1]);

        return TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        hack('Error parsing time: $e');
      }
    }

    // Return a default TimeOfDay if the format is invalid
    return TimeOfDay(hour: 0, minute: 0);
  }

  Future<void> showEditDialog(
      BuildContext context, Map<String, dynamic> data) async {
    TextEditingController intime =
        TextEditingController(text: formatTime(data['clk_in_tm']));
    TextEditingController outtime =
        TextEditingController(text: formatTime(data['clk_out_tm']));

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit InTime / OutTime'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('Work From',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(' *',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red)),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    // Set initial time to 9:20
                    TimeOfDay initialTime = TimeOfDay(hour: 9, minute: 20);

                    // Show time picker and wait for user input
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: initialTime,
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        );
                      },
                    );

                    // Update the controller with the selected time
                    if (pickedTime != null) {
                      String formattedTime = _formatTime3(pickedTime);
                      intime.text = formattedTime;
                    }
                  },
                  child: TextFormField(
                    controller: intime, // Use the existing controller
                    enabled: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {},
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Work To',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(' *',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red)),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    // Set initial time to 9:20
                    TimeOfDay initialTime = TimeOfDay(hour: 17, minute: 20);
                    // Show time picker and wait for user input
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: initialTime,
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        );
                      },
                    );

                    // Update the controller with the selected time
                    if (pickedTime != null) {
                      String formattedTime = _formatTime4(pickedTime);
                      outtime.text = formattedTime;
                    }
                  },
                  child: TextFormField(
                    controller: outtime, // Use the existing controller
                    enabled: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          // Your onPressed logic here
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the data and call the update function
                String workFrom = intime.text;
                String workTo = outtime.text;
                if (workFrom.isNotEmpty) {
                  TimeOfDay parsedTime = parseTime(workFrom);
                  String formattedTime = _formatTime8(parsedTime);
                  intime.text = formattedTime + ':00'.toString();
                }

                if (workTo.isNotEmpty) {
                  TimeOfDay parsedTime = parseTime(workTo);
                  String formattedTime = _formatTime2(parsedTime);
                  outtime.text = formattedTime + ':00'.toString();
                }
                String totalHoursAndMinutes = calculateTotalHoursAndMinutes(
                  parseTime2(intime.text) as TimeOfDay,
                  parseTime2(outtime.text) as TimeOfDay,
                ).toString();
                Map<String, dynamic> updatedData = {
                  'id': data['id'],
                  'intime': intime.text,
                  'outtime': outtime.text,
                  'tot_hr': totalHoursAndMinutes,
                  // 'employee_code': employeeIdController.text,
                  // 'trainee_code': traineeIdController.text,
                  // 'offc_num': offcnumController.text,
                };
                updateBranch(updatedData);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showEditDialog2(BuildContext context, formattedDate) async {
    TextEditingController intime = TextEditingController();
    TextEditingController outtime = TextEditingController();
    String date = formattedDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit InTime / OutTime'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Selected Date   :',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(date.toString()),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text('Work From',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(' *',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red)),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    // Set initial time to 9:20
                    TimeOfDay initialTime = TimeOfDay(hour: 9, minute: 20);

                    // Show time picker and wait for user input
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: initialTime,
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        );
                      },
                    );

                    // Update the controller with the selected time
                    if (pickedTime != null) {
                      String formattedTime = _formatTime3(pickedTime);
                      intime.text = formattedTime;
                    }
                  },
                  child: TextFormField(
                    controller: intime, // Use the existing controller
                    enabled: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {},
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Work To',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(' *',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red)),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    // Set initial time to 9:20
                    TimeOfDay initialTime = TimeOfDay(hour: 17, minute: 20);
                    // Show time picker and wait for user input
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: initialTime,
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        );
                      },
                    );

                    // Update the controller with the selected time
                    if (pickedTime != null) {
                      String formattedTime = _formatTime4(pickedTime);
                      outtime.text = formattedTime;
                    }
                  },
                  child: TextFormField(
                    controller: outtime, // Use the existing controller
                    enabled: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          // Your onPressed logic here
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                addAttendance(date, intime, outtime);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateBranch(Map<String, dynamic> updatedData) async {
    hack(updatedData);
    try {
      hack('ho');
      var apiUrl = Uri.parse(
          '$backendIP/Attendance_Reports/edit_attendance.php'); // Replace with your API endpoint for updating

      var response = await http.post(apiUrl, body: {
        'id': updatedData['id'].toString(),
        'intime': updatedData['intime'],
        'outtime': updatedData['outtime'],
        'tot_hr': updatedData['tot_hr'],
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data);

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          if (data['message'] == 'Data updated successfully') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text('Attendance Updated successfully!',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                backgroundColor: Colors.green,
              ),
            );
            await viewstaffrep(); // Refresh the data after update
          } else if (data['message'] == 'Error updating data') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text('Failed to update attendance details',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                backgroundColor: Colors.red,
              ),
            );
          } else if (data['message'] == 'Error') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text('Error')),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          hack('Error: Unexpected response format');
        }
      } else {
        hack(
            'Error occurred during branch update. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text('Failed to update attendance details',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      hack('Update error: $e');
    }
  }

  TimeOfDay parseTime3(String time) {
    try {
      DateTime dateTime = DateFormat('hh:mm a').parse(time);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      hack('Error parsing time: $e');
      // Handle the error, e.g., return a default time
      return TimeOfDay(hour: 0, minute: 0);
    }
  }

  String _formatTime5(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  String _formatTime6(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  TimeOfDay parseTimeOfDay(String timeString) {
    List<String> parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> addAttendance(String date, inTime, outTime) async {
    String workFrom = inTime.text;
    String workTo = outTime.text;
    if (workFrom.isNotEmpty) {
      TimeOfDay parsedTime = parseTime3(workFrom);
      String formattedTime = _formatTime5(parsedTime);
      inTime.text = formattedTime + ':00'.toString();
    }

    if (workTo.isNotEmpty) {
      TimeOfDay parsedTime = parseTime3(workTo);
      String formattedTime = _formatTime6(parsedTime);
      outTime.text = formattedTime + ':00'.toString();
    }
    hack(inTime.text);
    hack(outTime.text);
    hack(date);

    String In = inTime.text;
    String Out = outTime.text;

    TimeOfDay inTimeOfDay = parseTimeOfDay(In);
    TimeOfDay outTimeOfDay = parseTimeOfDay(Out);

    String totalHoursAndMinutes =
        calculateTotalHoursAndMinutes(inTimeOfDay, outTimeOfDay).toString();

    String combinedInDateTime = '$date $In';
    hack(combinedInDateTime);

    String combinedOutDateTime = '$date $Out';
    hack(combinedOutDateTime);
    hack(totalHoursAndMinutes);
    hack(depart);
    try {
      // Parse the date string into a DateTime object
      DateTime parsedDate = DateTime.parse(date as String);

      // Extract the month and year
      int month = parsedDate.month;
      int year = parsedDate.year;

      // Convert month and year to strings
      String monthString = month.toString().padLeft(2, '0');
      String yearString = year.toString();

      // Now you have separate strings for month and year
      hack("Month: $monthString");
      hack("Year: $yearString");

      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/empwise_add_attend.php');

      var response = await http.post(apiUrl, body: {
        'userId': widget.id,
        'dept': depart,
        'work_frm': work_from,
        'work_to': work_to,
        'inTime': In,
        'outTime': Out,
        'clk_in': '0',
        'clk_out': '0',
        'clk_in_dt_tm': combinedInDateTime,
        'clk_out_dt_tm': combinedOutDateTime,
        'formattedDate': date,
        'reg_month': monthString,
        'reg_year': yearString,
        'late_resn_status': '0',
        'tot_hrs_min': totalHoursAndMinutes,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data);
        // Handle the response data as needed

        // Show a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text('Attendance added successfully',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 36, 195, 41),
          ),
        );
        setState(() {
          viewstaffrep();
        });
      } else {
        hack('Error occurred while adding attendance: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text('Failed to add Attendance',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 205, 21, 21),
          ),
        );
      }
    } catch (e) {
      hack('Add attendance error: $e');
    }
  }

  Duration _parseDurationFromString(String formattedDuration) {
    List<String> parts = formattedDuration.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  // Helper function to format duration as HH:mm
  String _formatDuration(Duration duration) {
    return ' ${duration.inHours.toString().padLeft(2, '0')} hr ${(duration.inMinutes % 60).toString().padLeft(2, '0')} min ';
  }

  String calculatetotallate(Duration mrng, Duration eveng) {
    if (mrng != '' && eveng != '') {
      totallate = mrng + eveng;
      if (totallate != null) {
        return _formatDuration(totallate);
      } else {
        return ''; // Return a default value if totallate is null
      }
    } else {
      return ''; // Return a default value if conditions are not met
    }
  }

  @override
  Widget build(BuildContext context) {
    totalMrnglateDuration = Duration.zero;
    totalearlybylateDuration = Duration.zero;
    totallate = Duration.zero;

    List<DateTime> dates = generateDatesForSelectedMonth();
    return Scaffold(
        appBar: (widget.app == '0')?AppBar(
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
                'Attendance Report',
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
        ):null,
        body: isLoading
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/leave2.jpg'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: SingleChildScrollView(
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
                                  decoration:
                                      BoxDecoration(color: Colors.amber),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.name.toUpperCase(),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    (selectedMonthYear.isEmpty)
                                        ? Text(
                                            'Select Month & Year: ',
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600),
                                          )
                                        : Text(
                                            'Selected\nMonth & Year',
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                    Spacer(),
                                    if (selectedMonthYear.isNotEmpty)
                                      Container(
                                        color: Colors.amber,
                                        child: Text(
                                          ' $selectedMonthYear ',
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _selectDate(context);
                                      },
                                      child: const Text('Select'),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                              66, 255, 254, 254),
                                          offset: Offset(0, 2),
                                          blurRadius: 0.1,
                                        ),
                                      ],
                                    ),
                                    child: SingleChildScrollView(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 30,
                                          headingRowColor:
                                              MaterialStateColor.resolveWith(
                                            (states) => Colors.blueAccent,
                                          ),
                                          border: TableBorder.all(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.black,
                                            width: 0.4,
                                          ),
                                          columns: <DataColumn>[
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text('S.No',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            DataColumn(
                                              label: Text('Date',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            DataColumn(
                                              label: Text('Day',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            DataColumn(
                                              label: Text('IN',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            DataColumn(
                                              label: Text('OUT',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text('Hour',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text('In_Ip',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text('Out_Ip',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text('Late',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text('Early_By',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text('Perm_Mrng',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text('Perm_Evng',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            // if (user_dept == 'SAD')
                                            //   DataColumn(
                                            //     label: Text('Add_Notes',
                                            //         style: TextStyle(
                                            //             fontSize: 18,
                                            //             fontWeight:
                                            //                 FontWeight.bold)),
                                            //   ),
                                            if (user_dept == 'SAD')
                                              DataColumn(
                                                label: Text(' ',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                          ],
                                          rows: List.generate(dates.length,
                                              (index) {
                                            DateTime date = dates[index];
                                            Map<String, dynamic>? data =
                                                viewstaffreport.firstWhere(
                                              (data) {
                                                if (data['date'] != null) {
                                                  DateTime? fromDt =
                                                      DateTime.tryParse(
                                                          data['date']);
                                                  return fromDt != null &&
                                                      fromDt.day == date.day &&
                                                      fromDt.month ==
                                                          date.month;
                                                }
                                                return false;
                                              },
                                              orElse: () {
                                                var holiday =
                                                    viewholiday.firstWhere(
                                                  (holiday) {
                                                    DateTime? holidayDt =
                                                        DateTime.tryParse(
                                                            holiday[
                                                                'holiday_date']);
                                                    return holidayDt != null &&
                                                        holidayDt.day ==
                                                            date.day &&
                                                        holidayDt.month ==
                                                            date.month;
                                                  },
                                                  orElse: () => Map<String,
                                                          dynamic>.from(
                                                      {}), // Return an empty map
                                                );

                                                DateTime? holidayDt =
                                                    DateTime.tryParse(
                                                        holiday['holiday_date']
                                                            .toString());
                                                if (holidayDt != null &&
                                                    holidayDt.day == date.day &&
                                                    holidayDt.month ==
                                                        date.month) {
                                                  return {
                                                    'status': 'Holiday',
                                                    'reason': holiday['reason']
                                                  };
                                                }

                                                return {
                                                  'status': 'Missed to clock in'
                                                };
                                              },
                                            );

                                            // Check if the date is in the inBetweenDates list
                                            Map<String, dynamic>?
                                                inBetweenData =
                                                inBetweenDates.firstWhere(
                                              (data) =>
                                                  data['date'] ==
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(date),
                                              orElse: () => <String,
                                                  dynamic>{}, // Return an empty map if not found,
                                            );

                                            Color rowColor = data != null &&
                                                    data['status'] == 'Holiday'
                                                ? Color.fromARGB(
                                                    255, 255, 184, 91)
                                                : inBetweenData != null &&
                                                        inBetweenData.isNotEmpty
                                                    ? Color.fromARGB(
                                                        255,
                                                        235,
                                                        140,
                                                        140) // Set to black color
                                                    : data != null &&
                                                            data['status'] ==
                                                                'Missed to clock in'
                                                        ? Color.fromARGB(
                                                            255, 255, 197, 197)
                                                        : Colors.white;

// Calculate the late for the current row
                                            String Mrnglate =
                                                calculateTotalHoursMinutes(
                                              data?['work_frm'].toString() ??
                                                  '',
                                              data?['clk_in_tm'].toString() ??
                                                  '',
                                            );

                                            print('Mrnglate:$Mrnglate');

                                            // Parse the late duration and add it to the total
                                            if (Mrnglate.isNotEmpty) {
                                              Duration MrnglateDuration =
                                                  _parseDurationFromString(
                                                      Mrnglate);
                                              totalMrnglateDuration +=
                                                  MrnglateDuration;
                                            }
                                            hack(
                                                'Total Late: ${_formatDuration(totalMrnglateDuration)}');

// Calculate the earlyby for the current row
                                            String earlybylate =
                                                calculateTotalHoursMinutes2(
                                              data?['work_to'].toString() ?? '',
                                              data?['clk_out_tm'].toString() ??
                                                  '',
                                            );

                                            // Parse the late duration and add it to the total
                                            if (earlybylate.isNotEmpty) {
                                              Duration earlybylateDuration =
                                                  _parseDurationFromString(
                                                      earlybylate);
                                              totalearlybylateDuration +=
                                                  earlybylateDuration;
                                            }
                                            hack(
                                                'Total EarlyBy: ${_formatDuration(totalearlybylateDuration)}');

                                            return DataRow(
                                              color: MaterialStateColor
                                                  .resolveWith(
                                                (states) => rowColor,
                                              ),
                                              cells: <DataCell>[
                                                if (user_dept == 'SAD')
                                                  DataCell(Text(
                                                      (index + 1).toString(),
                                                      style: TextStyle(
                                                          fontSize: 15.5,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                                DataCell(Text(
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(date),
                                                    style: TextStyle(
                                                        fontSize: 15.5,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                                DataCell(Text(
                                                    DateFormat('EEEE')
                                                        .format(date),
                                                    style: TextStyle(
                                                        fontSize: 15.5,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                                DataCell(Text(
                                                    data != null &&
                                                            data['clk_in_tm'] !=
                                                                null
                                                        ? formatTime(
                                                            data['clk_in_tm'])
                                                        : '',
                                                    style: TextStyle(
                                                        fontSize: 15.5,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                                DataCell(Text(
                                                    (data!['clk_out_tm'] !=
                                                            '00:00:00.000000')
                                                        ? data != null &&
                                                                data['clk_out_tm'] !=
                                                                    null
                                                            ? formatTime(data[
                                                                'clk_out_tm'])
                                                            : ''
                                                        : 'Missed to clock out ',
                                                    style: (data[
                                                                'clk_out_tm'] ==
                                                            '00:00:00.000000')
                                                        ? TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold)
                                                        : TextStyle(
                                                            fontSize: 15.5,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                                if (user_dept == 'SAD')
                                                  DataCell(Text(
                                                      data != null &&
                                                              data['tot_hr'] !=
                                                                  null
                                                          ? formatTime1(
                                                              data['tot_hr'])
                                                          : '',
                                                      style: TextStyle(
                                                          fontSize: 15.5,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                                if (user_dept == 'SAD')
                                                  DataCell(
                                                    Center(
                                                      child: Row(
                                                        children: [
                                                          data['reason'] !=
                                                                      null &&
                                                                  data['reason']
                                                                      .isNotEmpty
                                                              ? Text(
                                                                  data['status']
                                                                          .toString() +
                                                                      '  :  ' +
                                                                      data['reason']
                                                                          .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.5,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              : inBetweenData !=
                                                                          null &&
                                                                      inBetweenData
                                                                          .isNotEmpty
                                                                  ? Text(
                                                                      inBetweenData['type']
                                                                              .toString() +
                                                                          '  :  ' +
                                                                          inBetweenData['resn']
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.5,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  : Center(
                                                                      child:
                                                                          Text(
                                                                        data['status']?.toString() ??
                                                                            '',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (user_dept == 'SAD')
                                                  DataCell(Text('')),
                                                if (user_dept == 'SAD')
                                                  DataCell(
                                                    Text(
                                                        calculateTotalHoursMinutes(
                                                            data['work_frm']
                                                                    ?.toString() ??
                                                                '',
                                                            data['clk_in_tm']
                                                                    ?.toString() ??
                                                                ''),
                                                        style: TextStyle(
                                                            fontSize: 15.5,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                if (user_dept == 'SAD')
                                                  DataCell(
                                                    Text(
                                                        calculateTotalHoursMinutes2(
                                                            data['work_to']
                                                                    ?.toString() ??
                                                                '',
                                                            data['clk_out_tm']
                                                                    ?.toString() ??
                                                                ''),
                                                        style: TextStyle(
                                                            fontSize: 15.5,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                if (user_dept == 'SAD')
                                                  DataCell(Center(
                                                      child: Text(
                                                          calculatePermMrng(
                                                              late),
                                                          style: TextStyle(
                                                              fontSize: 15.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)))),
                                                if (user_dept == 'SAD')
                                                  DataCell(Center(
                                                    child: Text(data['perm_eve']
                                                            ?.toString() ??
                                                        '- -'),
                                                  )),
                                                // if (user_dept == 'SAD')
                                                //   DataCell(Row(
                                                //     children: [
                                                //       Text("Notes",
                                                //           style: TextStyle(
                                                //               fontSize: 15.5,
                                                //               fontWeight:
                                                //                   FontWeight
                                                //                       .bold)),
                                                //       SizedBox(width: 5),
                                                //       Container(
                                                //         decoration:
                                                //             BoxDecoration(
                                                //           color: Color.fromRGBO(
                                                //               158, 158, 158, 1),
                                                //         ),
                                                //         child: Image(
                                                //           image: AssetImage(
                                                //               'images/print.png'),
                                                //           height: 25,
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   )),
                                                if (user_dept == 'SAD')
                                                  DataCell(
                                                    data['status'] !=
                                                                'Missed to clock in' &&
                                                            data['status'] !=
                                                                'Holiday'
                                                        ? Row(
                                                            children: [
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    deleteDepartment(
                                                                        data['id']
                                                                            .toString());
                                                                  },
                                                                  icon: Icon(
                                                                    Icons
                                                                        .delete_forever_rounded,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 30,
                                                                  )),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    showEditDialog(
                                                                        context,
                                                                        data);
                                                                  },
                                                                  icon: Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color: Colors
                                                                          .blue,
                                                                      size:
                                                                          25)),
                                                            ],
                                                          )
                                                        : (data['status'] !=
                                                                'Holiday')
                                                            ? TextButton(
                                                                onPressed: () {
                                                                  // Get the date of the current row
                                                                  DateTime
                                                                      currentDate =
                                                                      dates[
                                                                          index];

                                                                  // Format the date using DateFormat
                                                                  String
                                                                      formattedDate =
                                                                      DateFormat(
                                                                              'yyyy-MM-dd')
                                                                          .format(
                                                                              currentDate);

                                                                  // Pass the formattedDate to the addAttendance function
                                                                  showEditDialog2(
                                                                      context,
                                                                      formattedDate);
                                                                },
                                                                child: Text(
                                                                  'Add In / Out',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                ))
                                                            : Text(''),
                                                  ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 40,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          child: Text(
                                        'Summary',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15),
// Punched
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Punched',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                staffReportLength.toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// CL
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'CL',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                typeCounts['CL'] != null
                                                    ? typeCounts['CL']
                                                        .toString()
                                                    : '0',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// HALFDAY CL(0.5)
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Halfday CL (0.5)',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                typeCounts['HALFDAY-CL'] != null
                                                    ? typeCounts['HALFDAY-CL']
                                                        .toString()
                                                    : '0',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// OD
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'OD',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                typeCounts['OD'] != null
                                                    ? typeCounts['OD']
                                                        .toString()
                                                    : '0',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// HALFDAY OD(0.5)
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Halfday OD (0.5)',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                typeCounts['HALFDAY-OD'] != null
                                                    ? typeCounts['HALFDAY-OD']
                                                        .toString()
                                                    : '0',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// EARLY CLOCK OUT
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'EARLY CLOCK OUT',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                early_clkout.toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// TOTAL DAYS JANUARY 2024
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'TOTAL DAYS IN $monthName $selectedYear',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                '$daysInMonth',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// MRNG LATE
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'MRNG LATE',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Spacer(),
                                          Container(
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                '${_formatDuration(totalMrnglateDuration)}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// EARLY BY
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'EARLY BY',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Spacer(),
                                          Container(
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                '${_formatDuration(totalearlybylateDuration)}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// TOTAL LATE
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'TOTAL LATE',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Spacer(),
                                          Container(
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                calculatetotallate(
                                                    totalMrnglateDuration,
                                                    totalearlybylateDuration),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// MISSED TO CLOCK IN
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'MISSED TO CLOCK IN',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                mis_clkin.toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// LOP
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'LOP',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                typeCounts['LOP'] != null &&
                                                        dateCounts[
                                                                'Matchedt_cnt'] !=
                                                            null
                                                    ? (int.parse(typeCounts[
                                                                    'LOP']
                                                                .toString()) -
                                                            int.parse(dateCounts[
                                                                    'Matchedt_cnt']
                                                                .toString()))
                                                        .toString()
                                                    : '0',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// HALFDAY LOP(0.5)
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Halfday LOP (0.5)',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                typeCounts['HALFDAY-LOP'] !=
                                                        null
                                                    ? typeCounts['HALFDAY-LOP']
                                                        .toString()
                                                    : '0',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// HALFDAY MISSED TO CLOCK IN(0.5)
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Halfday MISSED TO CLOCK IN (0.5)',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                '0',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// HALFDAY PUNCHED(0.5)
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Halfday PUNCHED (0.5)',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                '0',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// HOLIDAY
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'HOLIDAY',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                holidayLength.toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 5),
// TALLY
                                Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'TALLY',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 25,
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                '0',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
