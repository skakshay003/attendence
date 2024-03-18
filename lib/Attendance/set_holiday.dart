// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_local_variable, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, non_constant_identifier_names, unused_element, camel_case_types, prefer_final_fields, unused_field, sort_child_properties_last, use_build_context_synchronously, unused_import, deprecated_member_use, unnecessary_null_comparison, unnecessary_cast

import 'dart:convert';
import 'package:attendence/Attendance/allstaff_leave_rep.dart';
import 'package:attendence/Staff_report/permission/add_permission_adm.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Attendance/add_leave_adm.dart';
import '../../admin_login.dart';
import 'package:table_calendar/table_calendar.dart';

import '../config.dart';

class Set_Holiday extends StatefulWidget {
  @override
  State<Set_Holiday> createState() => _Set_HolidayState();
}

class _Set_HolidayState extends State<Set_Holiday> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController TakeFromController = TextEditingController();
  final TextEditingController UpToController = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _id = TextEditingController();
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
  String formattedDate = '';
  String status = '';
  String logindepart = '';
  // String selevalue = 'default_value';
  String company = 'All Branch';
  int editingIndex = -1;
  Map<int, String> dropdownValues = {};
  String selectedCompany = 'All Branch';
  String calender_month = '';
  int calender_year = 0000;

  DateTime focusedDay = DateTime.now();

  List<DateTime> selectedDates = [];
  List companyname = [];
  List<Map<String, String>> holidayDetails = [];
  List<Map<String, dynamic>> dataTableRows = [];
  Map<DateTime, String> selectedCompanies = {};
  Map<DateTime, String> selectedReasons = {};

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    focusedDay = DateTime.now();
    calender_month = DateFormat('MMMM').format(focusedDay) as String;
    calender_year = int.parse(DateFormat('yyyy').format(focusedDay));
    viewbranch();
    fetchHolidays();
  }

  List holidays = [];

  Future<void> fetchHolidays() async {
    // Use the calender_month and calender_year to fetch matched rows from the server
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Set_Holiday/fetch_holidays.php'); // Replace with the URL of your PHP script
      var response = await http.post(
        apiUrl,
        body: {
          'month': calender_month.toString(),
          'year': calender_year.toString(),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          holidays = jsonDecode(response.body);
          hack(holidays);
          isLoading = true;
        });
      } else {
        hack('Error occurred while fetching matched rows: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  List branchname = [];

  Future<void> viewbranch() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Registration/vfetch_branch.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          branchname = jsonDecode(response.body);
          hack(branchname);
          // isLoading = true;
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

  Future<void> Set(List<Map<String, dynamic>> dataTableRows) async {
    try {
      if (selectedReasons.isNotEmpty) {
        var apiUrl = Uri.parse('$backendIP/Set_Holiday/add_holiday.php');

        var response = await http.post(
          apiUrl,
          body: jsonEncode(dataTableRows),
        );

        if (response.statusCode == 200) {
          List<dynamic> responseData = jsonDecode(response.body);
          for (var data in responseData) {
            // Handle each response individually
            if (data['message'] == 'Holiday added successfully') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('Holiday added successfully',style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  duration: Duration(seconds: 3),
                  backgroundColor: Color.fromARGB(255, 36, 195, 41),
                ),
              );
              selectedReasons.clear();
            } else if (data['message'] == 'Holiday already added') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('Holiday already added!'),
                  ),
                  duration: Duration(seconds: 3),
                  backgroundColor: Color.fromARGB(255, 205, 21, 21),
                ),
              );
            }
          }
          // After handling responses, fetch holidays
          setState(() {
            fetchHolidays();
          });
        } else {
          // Handle HTTP error
          hack('Error occurred while adding Holiday: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text('Failed to add Holiday'),
              ),
              duration: Duration(seconds: 3),
              backgroundColor: Color.fromARGB(255, 205, 21, 21),
            ),
          );
        }
      } else {
        // Handle empty selected reasons
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text('Reason is Empty!'),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 205, 21, 21),
          ),
        );
      }
    } catch (e) {
      // Handle exceptions
      hack('Add Holiday error: $e');
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

  Future<void> deleteholiday(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete this holiday?',
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
      var apiUrl = Uri.parse(
          '$backendIP/Set_Holiday/delete_holiday.php'); // Replace with your delete API endpoint
      var response = await http.post(apiUrl, body: {
        'id': id.toString(), // Pass the ID to be deleted
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Holiday deleted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Holiday deleted successfully'),
              backgroundColor: Colors.green, // Set the background color
            ),
          );
          dataTableRows.clear();
          await fetchHolidays(); // Refresh the data after deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete holiday'),
              backgroundColor: Colors.red, // Set the background color
            ),
          );
        }
      } else {
        hack('Error occurred during holiday deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete holiday'),
            backgroundColor: const Color.fromARGB(
                255, 202, 169, 19), // Set the background color
          ),
        );
      }
    } catch (e) {
      hack('Delete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    holidayDetails = List.generate(selectedDates.length, (index) => {});
    // Inside your build method, where you generate rows
    dataTableRows = List.generate(
      selectedDates.length,
      (index) {
        DateTime selectedDate = selectedDates[index];
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        String dayOfWeek = DateFormat('EEEE').format(selectedDate);
        String month = DateFormat.MMMM().format(selectedDate);
        String Month = month.toUpperCase();
        String year = DateFormat('yyyy').format(selectedDate);
        // Initialize 'Reason' and 'Branch' for each row
        return {
          'S.No': (index + 1).toString(),
          'Date': formattedDate,
          'Day': dayOfWeek,
          'Month': Month,
          'Year': year,
          'Reason': selectedReasons[selectedDate] ??
              '', // Use selectedReasons, // Initialize with an empty reason
          'Branch': selectedCompanies[
              selectedDate], // Initialize with 'Select Company'
        };
      },
    );

    String formatDate(String inputDate) {
      DateTime date = DateTime.parse(inputDate);
      String formattedDay = '${date.day}';
      String formattedMonth =
          '${date.month}'.padLeft(2, '0'); // Ensures two digits
      String formattedYear = '${date.year}';
      String formattedDate = '$formattedDay-$formattedMonth-$formattedYear';
      return formattedDate;
    }

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
              'Set Holiday',
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                onClick();
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
      ),
      body: isLoading
          ? Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/leave2.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
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
                            color: Color.fromARGB(185, 255, 255, 255),
                            child: TableCalendar(
                              focusedDay: focusedDay,
                              firstDay: DateTime(DateTime.now().year - 1),
                              lastDay: DateTime(DateTime.now().year + 1),
                              selectedDayPredicate: (day) {
                                return selectedDates.contains(day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  if (selectedDates.contains(selectedDay)) {
                                    selectedDates.remove(selectedDay);
                                    selectedCompanies.remove(selectedDay);
                                  } else {
                                    selectedDates.add(selectedDay);
                                    selectedCompanies[selectedDay] =
                                        'All Branch';
                                  }
                                });
                              },
                              onPageChanged: (newFocusedDay) {
                                setState(() {
                                  focusedDay = newFocusedDay;
                                });

                                // Extract the month and year from the new focused day
                                calender_month = DateFormat('MMMM')
                                    .format(newFocusedDay) as String;
                                calender_year = int.parse(
                                    DateFormat('yyyy').format(newFocusedDay));

                                hack(calender_month);
                                hack(calender_year);
                                // Now you can use calender_month and calender_year as needed
                                hack(
                                    'Page changed to: $calender_month-$calender_year');
                                setState(() {
                                  fetchHolidays();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          dataTableRows.isNotEmpty
                              ? Scrollbar(
                                  thickness: 7,
                                  radius: Radius.circular(10),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: 30,
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
                                        DataColumn(label: Text('S.No')),
                                        DataColumn(label: Text('Date')),
                                        DataColumn(label: Text('Day')),
                                        DataColumn(label: Text('Month')),
                                        DataColumn(label: Text('Year')),
                                        DataColumn(label: Text('Reason')),
                                        DataColumn(label: Text('Branch')),
                                      ],
                                      rows: List<DataRow>.generate(
                                        dataTableRows.length,
                                        (index) {
                                          DateTime selectedDate =
                                              selectedDates[index];
                                          return DataRow(
                                            cells: [
                                              DataCell(Center(
                                                  child: Text(
                                                      dataTableRows[index]
                                                          ['S.No']))),
                                              DataCell(Text(dataTableRows[index]
                                                  ['Date'])),
                                              DataCell(Text(
                                                  dataTableRows[index]['Day'])),
                                              DataCell(Text(dataTableRows[index]
                                                  ['Month'])),
                                              DataCell(Text(dataTableRows[index]
                                                  ['Year'])),
                                              DataCell(
                                                Container(
                                                  width: 150,
                                                  child: TextFormField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedReasons[
                                                                selectedDate] =
                                                            value; // Store reason for each date
                                                        dataTableRows[index]
                                                            ['Reason'] = value;
                                                      });
                                                    },
                                                    enabled: true,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Type Reason . . .',
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter reason';
                                                      }
                                                      return null;
                                                    },
                                                    initialValue: selectedReasons[
                                                        selectedDate], // Set initial value
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                DropdownButton<String>(
                                                  value: selectedCompanies[
                                                      selectedDate],
                                                  onChanged:
                                                      (String? newValue) async {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        selectedCompanies[
                                                                selectedDate] =
                                                            newValue;
                                                        dataTableRows[index][
                                                                'branch_name'] =
                                                            newValue;
                                                      });
                                                    }
                                                  },
                                                  items: [
                                                    DropdownMenuItem<String>(
                                                      value: 'All Branch',
                                                      child: Container(
                                                        width: 150,
                                                        child: Text(
                                                          'All Branch',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    for (int i = 0;
                                                        i < branchname.length;
                                                        i++)
                                                      DropdownMenuItem<String>(
                                                        value: branchname[i]
                                                            ['branch_name'],
                                                        child: Container(
                                                          width: 150,
                                                          child: Text(
                                                            branchname[i]
                                                                ['branch_name'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                  underline: Container(),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  '* Select dates to Add Holidays in $calender_month',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Set(dataTableRows.cast<Map<String, dynamic>>());
                              },
                              child: Text(
                                'Set',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                              color: Colors.amber,
                              child: Center(
                                  child: Text(
                                'Holidays in $calender_month',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ))),
                          SizedBox(height: 10),
                          SingleChildScrollView(
                            child: Scrollbar(
                              thickness: 7,
                              radius: Radius.circular(10),
                              child: Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 35,
                                    headingRowColor:
                                        MaterialStateColor.resolveWith(
                                      (states) => Colors.blueAccent,
                                    ),
                                    border: TableBorder.all(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black,
                                      width: 0.4,
                                    ),
                                    columns: <DataColumn>[
                                      DataColumn(
                                        label: Text('S.No',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('HoliDate',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Reason',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Month',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Year',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Branch',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    rows: List<DataRow>.generate(
                                        holidays.length, (index) {
                                      int serialNumber = index + 1;
                                      return DataRow(
                                        cells: <DataCell>[
                                          DataCell(Center(
                                            child: Text('$serialNumber',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                          DataCell(
                                            Center(
                                              child: Text(
                                                formatDate(holidays[index]
                                                        ['holiday_date']
                                                    .toString()),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(Center(
                                            child: Text(
                                                holidays[index]['reason']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                                holidays[index]['month']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                                holidays[index]['year']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                                holidays[index]['branch']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                          DataCell(
                                            ElevatedButton(
                                              onPressed: () {
                                                deleteholiday((holidays[index]
                                                        ['id']
                                                    .toString())); // Call the delete function
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors
                                                    .red, // Customize the delete button's color
                                              ),
                                              child: Container(
                                                height: 43,
                                                width: 35,
                                                child: Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
