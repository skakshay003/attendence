// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, curly_braces_in_flow_control_structures, depend_on_referenced_packages, avoid_hack, unnecessary_string_interpolations, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unused_local_variable, avoid_function_literals_in_foreach_calls, avoid_unnecessary_containers, use_build_context_synchronously, prefer_const_declarations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../admin_login.dart';
import '../../admin_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class AddAttendance extends StatefulWidget {
  const AddAttendance({Key? key}) : super(key: key);

  @override
  State<AddAttendance> createState() => _AddAttendanceState();
}

class _AddAttendanceState extends State<AddAttendance> {
  var backendIP = ApiConstants.backendIP;
  late DateTime selectedDate;
  bool fullday = false;
  bool updateBoth = true;
  bool updateMorning = false;
  bool updateEvening = false;
  TimeOfDay? inTime;
  TimeOfDay? outTime;
  String selected = '';
  List companyname = [];
  List departmentData = [];
  bool checkAll = false;
  String clk_in = "0";
  String clk_out = "0";
  String clk_in_dt_tm = "";
  String clk_out_dt_tm = "";
  String formattedDate = "";
  String reg_month = "";
  String reg_year = "";
  String late_resn_status = "0";
  String totalHoursAndMinutes = "";
  String branch = "";
  bool isLoading = false;

  List<Map<String, dynamic>> selectedEmployeeData = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    inTime = TimeOfDay(hour: 9, minute: 20);
    outTime = TimeOfDay(hour: 17, minute: 20);
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session2_user = sharedPreferences.getString('branch');
    if (session2_user != null) {
      setState(() {
        branch = session2_user;
        hack(branch);
        viewemployee();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  String Date = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        Date =
            selectedDate.toLocal().toString().substring(0, 10);
        print(Date);
      });
    }
  }

  Future<void> _selectInTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: inTime ?? TimeOfDay.now(),
      helpText: 'Select In Time (12-hour format)',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        inTime = picked;
      });
    }
  }

  Future<void> _selectOutTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: outTime ?? TimeOfDay.now(),
      helpText: 'Select Out Time (12-hour format)',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        outTime = picked;
      });
    }
  }

  String formatTimeOfDayTo24Hours(TimeOfDay time) {
    return '${_formatTimeComponent(time.hour)}:${_formatTimeComponent(time.minute)}:00';
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm()
        .format(dateTime); // Format in 12-hour format with AM/PM
  }

  Map<String, dynamic> convertTimeOfDayToMap(TimeOfDay time) {
    return {
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  Future<void> viewemployee() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/vfetchattenddetail.php');
      var response = await http.post(apiUrl, body: {
        'branch': branch,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          departmentData = List<Map<String, dynamic>>.from(data);
          hack(departmentData);
          departmentData.sort((a, b) => a['user_id'].compareTo(b['user_id']));
          isLoading = true;
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
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

  Future<void> addAttendance(List<Map<String, dynamic>> selectedRows) async {
    try {
      hack(selectedRows);
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/add_attendance.php');

      var response = await http.post(
        apiUrl,
        body: jsonEncode(selectedRows),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Handle the response data as needed

        // Show a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Attendance added successfully',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))),
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 36, 195, 41),
          ),
        );
      } else {
        hack('Error occurred while adding attendance: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to add Attendance',style: TextStyle(fontWeight: FontWeight.bold))),
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 205, 21, 21),
          ),
        );
      }
    } catch (e) {
      hack('Add attendance error: $e');
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
    selectedEmployeeData = [];
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    List<String> dateParts = formattedDate.split('-');
    int extractedYear = int.parse(dateParts[0]);
    int extractedMonth = int.parse(dateParts[1]);

    reg_month = extractedMonth.toString();
    reg_year = extractedYear.toString();

    DateTime inDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      inTime!.hour,
      inTime!.minute,
    );

    DateTime outDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      outTime!.hour,
      outTime!.minute,
    );

    String inDateTimeString = DateFormat("yyyy-MM-dd HH:mm").format(inDateTime);
    String outDateTimeString =
        DateFormat("yyyy-MM-dd HH:mm").format(outDateTime);

    hack("Formatted In DateTime: $inDateTimeString");
    hack("Formatted Out DateTime: $outDateTimeString");

    List<Map<String, dynamic>> selectedRows = [];

    for (var data in departmentData) {
      if (data['isSelected'] == true) {
        selectedRows.add(data);
      }
    }

    for (var row in selectedRows) {
      String empName = row['nm'].toString();
      String userId = row['user_id'].toString();
      String depart = row['depart'].toString();
      String work_frm = row['work_frm'].toString();
      String work_to = row['work_to'].toString();
      String totalHoursAndMinutes =
          calculateTotalHoursAndMinutes(inTime!, outTime!).toString();

      // Create a map with the selected data and add it to the list
      Map<String, dynamic> selectedData = {
        'userId': userId,
        'depart': depart,
        'work_frm': work_frm,
        'work_to': work_to,
        'inTime': '',
        'outTime': '',
        'clk_in': clk_in,
        'clk_out': clk_out,
        'clk_in_dt_tm': inDateTimeString,
        'clk_out_dt_tm': outDateTimeString,
        'formattedDate': (Date =='')? formattedDate : Date,
        'reg_month': reg_month.toString(),
        'reg_year': reg_year.toString(),
        'late_resn_status': late_resn_status,
        'tot_hrs_min': totalHoursAndMinutes,
      };

      if (fullday && updateMorning) {
        // Update for full day with morning
        selectedData['inTime'] = work_frm;
        selectedData['outTime'] = '';
      } else if (fullday && updateEvening) {
        // Update for full day with evening
        selectedData['inTime'] = '';
        selectedData['outTime'] = work_to;
      } else if (fullday && updateBoth) {
        selectedData['inTime'] = work_frm;
        selectedData['outTime'] = work_to;
      } else {
        // Update for other cases
        if (updateBoth) {
          // Update both morning and evening
          // selectedData['inTime'] = formatTimeOfDay(inTime!).toString();
          // selectedData['outTime'] = formatTimeOfDay(outTime!).toString();
          selectedData['inTime'] = formatTimeOfDayTo24Hours(inTime!);
          selectedData['outTime'] = formatTimeOfDayTo24Hours(outTime!);
        } else if (updateMorning) {
          // Update morning only
          selectedData['inTime'] = formatTimeOfDayTo24Hours(inTime!);
          selectedData['outTime'] = '';
        } else if (updateEvening) {
          // Update evening only
          selectedData['inTime'] = '';
          selectedData['outTime'] = formatTimeOfDayTo24Hours(outTime!);
        }
      }
      selectedEmployeeData.add(selectedData);
    }

    // Now, selectedEmployeeData list contains the data of the selected employees.
    hack('Selected Employee Data: $selectedEmployeeData');
  }

  List<String> getSelectedEmployeeNames() {
    List<Map<String, dynamic>> selectedRows = [];

    for (var data in departmentData) {
      if (data['isSelected'] == true) {
        selectedRows.add(data);
      }
    }

    List<String> selectedEmployeeNames = [];

    for (var row in selectedRows) {
      selectedEmployeeNames.add(row['nm'].toString());
      selectedEmployeeNames.add(row['depart'].toString());
      selectedEmployeeNames.add(row['work_frm'].toString());
      selectedEmployeeNames.add(row['work_to'].toString());
    }

    return selectedEmployeeNames;
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
            'Add Attendance',
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
        body: isLoading
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/bg4.jpg"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.8),
                      BlendMode.srcOver,
                    ),
                  ),
                ),
                child: Column(children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Select Date : ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 5),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Icon(Icons.calendar_today, size: 20),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Full Day",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Checkbox(
                        value: fullday,
                        onChanged: (value) {
                          setState(() {
                            fullday = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Radio(
                        value: true,
                        groupValue: updateBoth,
                        onChanged: (value) {
                          setState(() {
                            updateBoth = value as bool;
                            updateMorning = false;
                            updateEvening = false;
                          });
                        },
                      ),
                      Text(
                        "Update Both",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 35,
                      ),
                      Radio(
                        value: true,
                        groupValue: updateMorning,
                        onChanged: (value) {
                          setState(() {
                            // fullday = false;
                            updateMorning = value as bool;
                            updateBoth = false;
                            updateEvening = false;
                          });
                        },
                      ),
                      Text(
                        "Update Morning",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: true,
                        groupValue: updateEvening,
                        onChanged: (value) {
                          setState(() {
                            // fullday = false;
                            updateEvening = value as bool;
                            updateBoth = false;
                            updateMorning = false;
                          });
                        },
                      ),
                      Text(
                        "Update Evening",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (!fullday)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        if (updateMorning || updateBoth)
                          Column(
                            children: [
                              Text(
                                "In Time : ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (updateMorning || updateBoth)
                          Text(
                            "${inTime != null ? formatTimeOfDay(inTime!) : 'Select Time'}",
                            style: TextStyle(
                              color: Color.fromARGB(255, 7, 19, 245),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (updateMorning || updateBoth)
                          IconButton(
                            onPressed: () => _selectInTime(context),
                            icon: Icon(Icons.access_time),
                          ),
                        // Spacer(),
                        if (updateEvening || updateBoth)
                          Text(
                            "Out Time : ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (updateEvening || updateBoth)
                          Text(
                            "${outTime != null ? formatTimeOfDay(outTime!) : 'Select Time'}",
                            style: TextStyle(
                              color: Color.fromARGB(255, 7, 19, 245),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (updateEvening || updateBoth)
                          IconButton(
                            onPressed: () => _selectOutTime(context),
                            icon: Icon(Icons.access_time),
                          ),
                      ],
                    ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('Company Name',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text(
                        branch,
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      height: 300, // Adjust the height as needed
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 40,
                          border: TableBorder.all(color: Colors.red),
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text('S.No',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600)),
                            ),
                            DataColumn(
                                label: Text("EMP Name",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600))),
                            DataColumn(
                                label: Text("EMP Id",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600))),
                            DataColumn(
                              label: Row(
                                children: [
                                  Text("Check All / \n Uncheck All",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600)),
                                  Checkbox(
                                    value: checkAll,
                                    onChanged: (value) {
                                      setState(() {
                                        checkAll = value!;
                                        // Set the state of all individual checkboxes based on "Check All" state
                                        departmentData.forEach((data) {
                                          data['isSelected'] = checkAll;
                                        });
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                          rows: departmentData.map((data) {
                            int serialNumber = departmentData.indexOf(data) + 1;
                            return DataRow(
                              cells: <DataCell>[
                                DataCell(Text('$serialNumber',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600))),
                                DataCell(Text(data['nm'].toString(),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600))),
                                DataCell(Text(data['user_id'].toString(),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600))),
                                DataCell(
                                  Center(
                                    child: Checkbox(
                                      value: data['isSelected'] ?? false,
                                      onChanged: (value) {
                                        setState(() {
                                          data['isSelected'] = value;
                                          // Handle the individual checkbox state change
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                // Add other cells as needed
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      // Divider(),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          submitForm();
                          if (selectedEmployeeData.isNotEmpty) {
                            // At least one employee is selected, proceed with adding attendance
                            addAttendance(selectedEmployeeData
                                .cast<Map<String, dynamic>>());
                          } else {
                            // No employee selected, show Snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Center(
                                    child: Center(child: Text('Please select an employee',style: TextStyle(fontWeight: FontWeight.bold)))),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text("Add"),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ]),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
