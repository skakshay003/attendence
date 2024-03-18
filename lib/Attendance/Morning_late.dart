// ignore_for_file: depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, avoid_print, avoid_function_literals_in_foreach_calls, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_unnecessary_containers, sized_box_for_whitespace, use_build_context_synchronously, empty_catches, unused_local_variable

import 'dart:convert';
import 'dart:math';
import 'package:attendence/admin_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';

class Morning_Late_Page extends StatefulWidget {
  const Morning_Late_Page({super.key});

  @override
  State<Morning_Late_Page> createState() => _Morning_Late_PageState();
}

class _Morning_Late_PageState extends State<Morning_Late_Page> {
  var backendIP = ApiConstants.backendIP;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    Filter_Date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    hack(Filter_Date);
    checkLoginStatus();
  }

  String branch = '';

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_Id = sharedPreferences.getString('branch');
    if (session1_Id != null) {
      setState(() {
        branch = session1_Id;
        print(branch);
        fetchALLData();
        getUserdata();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  List<dynamic> All_Users = [];
  Future<void> fetchALLData() async {
    try {
      // Make an HTTP request to fetch data based on the profile email
      var apiUrl = Uri.parse('$backendIP/reg_all.php');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        All_Users = json.decode(response.body);
        print(response.body);
      } else {
        // Handle API error here
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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

////////////////////////////////////////////////////////
  List<dynamic> fetchdata = [];
  List<dynamic> uniqueUserIds = [];
  String fetchdataLength = '';
  List<Map<String, dynamic>> lateCountList = [];

  Future<void> getUserdata() async {
    print('hi');

    DateTime? filterDateTime;
    if (Filter_Date.isNotEmpty) {
      try {
        filterDateTime = DateTime.parse(Filter_Date);
      } catch (e) {
        print('Error parsing Filter_Date: $e');
        // Handle parsing error, e.g., set filterDateTime to null or handle the error message
      }
    }
    if (filterDateTime != null) {
      try {
        print('$filterDateTime hello');

        var apiUrl =
            Uri.parse('$backendIP/Attendance_Reports/morning_late.php');
        var response = await http.post(apiUrl, body: {
          'month': filterDateTime.month.toString(),
          'year': filterDateTime.year.toString(),
        });
        
        if (response.statusCode == 200) {
          setState(() {
            fetchdata = json.decode(response.body);
            fetchdataLength = fetchdata.length.toString();
            hack(fetchdataLength);
            hack(fetchdata);
            _dataLoaded = true;

            setState(() {
              uniqueUserIds =
                  fetchdata.map((data) => data['user_id']).toSet().toList();
              hack(uniqueUserIds);
            });

// Define a map to store the late count for each user_id
            Map<String, int> lateCountByUserId = {};

// Iterate over fetchdata to calculate late count for each user_id
            fetchdata.forEach((entry) {
              String userId = entry['user_id'];
              String workFrom = entry['work_frm'];
              String clkInTime = entry['clk_in_tm'];

              // Parse time strings to DateTime objects, handling possible FormatException
              try {
                DateTime workFromTime = DateTime.parse('2000-01-01 $workFrom');
                DateTime clkInTimeParsed =
                    DateTime.parse('2000-01-01 $clkInTime');

                // Check if clk_in_tm is greater than work_frm
                if (clkInTimeParsed.isAfter(workFromTime)) {
                  // Increment late count for the user_id
                  lateCountByUserId.update(userId, (lateCount) => lateCount + 1,
                      ifAbsent: () => 1);
                }
              } catch (e) {
                print('Error parsing date: $e');
                // Handle the error, such as skipping the entry or setting late count to 0
                // Example: lateCountByUserId.update(userId, (lateCount) => 0, ifAbsent: () => 0);
              }
            });

            lateCountByUserId.forEach((userId, lateCount) {
              lateCountList.add({
                'user_id': userId,
                'late_count': lateCount,
              });
            });

// Print the late count list
            lateCountList.forEach((lateCountEntry) {
              print(
                  'User ID: ${lateCountEntry['user_id']}, Late Count: ${lateCountEntry['late_count']}');
            });
            print(lateCountList);
          });
        }
      } catch (e) {
        hack('error $e');
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
  String Filter_Date = '';

  Future<void> _Filter_Date(BuildContext context) async {
    final List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Initialize selectedMonth and selectedYear with values from Filter_Date
    DateTime filterDateTime = DateTime.parse(Filter_Date);
    String? selectedMonth = months[filterDateTime.month - 1];
    int? selectedYear = filterDateTime.year;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Month and Year'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedMonth,
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (String? value) {
                  selectedMonth = value;
                },
                decoration: InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedYear,
                items: List.generate(
                        101, (index) => filterDateTime.year - 50 + index)
                    .map((int year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (int? value) {
                  selectedYear = value;
                },
                decoration: InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedMonth != null && selectedYear != null) {
                  int monthIndex = months.indexOf(selectedMonth!);
                  DateTime selectedDate =
                      DateTime(selectedYear!, monthIndex + 1, 1);
                  String formattedDate =
                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-01";
                  setState(() {
                    Filter_Date = formattedDate;
                    hack(Filter_Date);
                    getUserdata();
                  });
                }
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List att_det = [];
  List filteredData = [];

  Future<void> viewlate_det(String userid) async {
    DateTime? filterDateTime;
    filterDateTime = DateTime.parse(Filter_Date);
    try {
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/vfetch_empwise_attend.php');
      var response = await http.post(apiUrl, body: {
        'userid': userid.toString(),
        'month': filterDateTime.month.toString(),
        'year': filterDateTime.year.toString(),
      });

      if (response.statusCode == 200) {
        // Decode the response body and store it in att_det
        att_det = jsonDecode(response.body);
        print('att_det:$att_det');

        // Filter data based on clk_in_tm exceeding work_frm
        filteredData = att_det.where((entry) {
          String clkInTime = entry['clk_in_tm'];
          String workFromTime = entry['work_frm'];

          try {
            DateTime clkInTimeParsed = DateTime.parse('2000-01-01 $clkInTime');
            DateTime workFromTimeParsed =
                DateTime.parse('2000-01-01 $workFromTime');

            // Check if clk_in_tm is greater than work_frm
            return clkInTimeParsed.isAfter(workFromTimeParsed);
          } catch (e) {
            print('Error parsing date: $e');
            return false; // Handle the error, such as skipping the entry or setting to false
          }
        }).toList();

        // Now, filteredData contains only the entries where clk_in_tm exceeds work_frm
        print('filteredData:$filteredData');
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

  Future<void> showCustomPopup(BuildContext context, String userId) async {
    // Call viewlate_det to fetch and filter data
    await viewlate_det(userId);

    // Show bottom modal sheet with filteredData in a DataTable
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Late Details',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 16,
                  columns: <DataColumn>[
                    DataColumn(
                        label: Center(
                          child: Text('Date',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        )),
                    DataColumn(
                        label: Center(
                          child: Text('Emp ID',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        )),
                    DataColumn(
                        label: Center(
                          child: Text('In Time',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        )),
                    DataColumn(
                        label: Center(
                          child: Text('Out Time',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        )),
                    // Add more DataColumn as needed
                  ],
                  rows: filteredData.map<DataRow>((entry) {
                    // Convert the date string to DateTime
                    DateTime formattedDate =
                        DateTime.parse(entry['date'].toString());

                    // Format the DateTime to the desired format (dd-mm-yyyy)
                    String formattedDateString =
                        DateFormat('dd-MM-yyyy').format(formattedDate);

                    DateTime formattedTime = DateTime.parse(
                        '2000-01-01 ${entry['clk_in_tm'].toString()}');

                    // Format the DateTime to the desired time format (hh:mm a)
                    String formattedTimeString =
                        DateFormat('hh:mm a').format(formattedTime);

                    DateTime workFromTime =
                        DateFormat('HH:mm:ss').parse(entry['work_frm']);
                    DateTime clkInTime =
                        DateFormat('HH:mm:ss').parse(entry['clk_in_tm']);

                    // Ensure that the clkInTime is on the same day as workFromTime
                    if (clkInTime.isBefore(workFromTime)) {
                      clkInTime = clkInTime.add(Duration(days: 0));
                    }

                    // Calculate the difference
                    Duration difference = clkInTime.difference(workFromTime);

                    // Format the difference as hours and minutes
                    String lateDuration =
                        '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';

                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(formattedDateString,
                                style: TextStyle(fontSize: 12)),
                          ),
                          // Customize the DataCell decoration here if needed
                        ),
                        DataCell(
                          Center(
                            child: Text(entry['user_id'].toString(),
                                style: TextStyle(fontSize: 12)),
                          ),
                          // Customize the DataCell decoration here if needed
                        ),
                        DataCell(
                          Center(
                            child: Text(formattedTimeString,
                                style: TextStyle(fontSize: 12)),
                          ),
                          // Customize the DataCell decoration here if needed
                        ),
                        DataCell(
                          Center(child: Text(lateDuration, style: TextStyle(fontSize: 12))),
                          // Customize the DataCell decoration here if needed
                        ),
                        // Add more DataCell as needed
                      ],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Done',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

/////////////////////////////////////////////////////////////////////////////
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
          title: Row(
            children: [
              Text(
                'Morning Late',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  // onClick();
                },
                icon: Icon(Icons.search),
              )
            ],
          ),
        ),
        body: _dataLoaded
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70,
                          color: Colors.white,
                          child: Center(
                              child:
                                  Text(branch, style: TextStyle(fontSize: 25))),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    child: Container(
                      color: const Color.fromARGB(255, 0, 65, 117),
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Select Month & Year :',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _Filter_Date(context);
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width / 2,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      Filter_Date.isNotEmpty
                                          ? DateFormat('MMMM-yyyy').format(
                                              DateTime.parse(Filter_Date))
                                          : '--select--',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              border: TableBorder.all(color: Colors.white),
                              headingRowColor: MaterialStateColor.resolveWith(
                                  (Set<MaterialState> states) {
                                // For the default or other states
                                return Color.fromARGB(
                                    255, 255, 153, 0); // Set your desired color
                              }),
                              headingTextStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight
                                    .bold, // Set your desired font weight
                                color:
                                    Colors.black, // Set your desired text color
                              ),
                              columnSpacing:
                                  20, // Adjust the spacing between columns as needed
                              dataRowHeight: 60,
                              columns: <DataColumn>[
                                DataColumn(
                                  label: Text('S.NO.'),
                                ),
                                DataColumn(
                                  label: Text('NAME'),
                                ),
                                DataColumn(
                                  label: Text('ID'),
                                ),
                                DataColumn(
                                  label: Text('TIMES'),
                                ),
                              ],
                              rows:
                                  uniqueUserIds.asMap().entries.where((entry) {
                                String userId = entry.value;

                                // Find the corresponding data entry for the current user_id
                                dynamic data = fetchdata.firstWhere(
                                    (entry) => entry['user_id'] == userId,
                                    orElse: () =>
                                        null); // Added orElse to handle cases where no match is found

                                String count = '';
                                for (var latecount in lateCountList) {
                                  if (latecount['user_id'] == userId) {
                                    count = latecount['late_count'].toString();
                                    hack(count);
                                    break;
                                  }
                                }

                                String userName = '';
                                String branch_nm = '';
                                for (var takeName in All_Users) {
                                  if (takeName['user_id'] == userId) {
                                    userName = takeName['nm'].toString();
                                    branch_nm =
                                        takeName['branch_name'].toString();
                                    hack(userName);
                                    break;
                                  }
                                }

                                // Return true if count is not empty and branch matches
                                return count.isNotEmpty && branch_nm == branch;
                              }).map<DataRow>((entry) {
                                int index = entry.key;
                                String userId = entry.value;

                                // Find the corresponding data entry for the current user_id
                                // ignore: unused_local_variable
                                dynamic data = fetchdata.firstWhere(
                                    (entry) => entry['user_id'] == userId,
                                    orElse: () =>
                                        null); // Added orElse to handle cases where no match is found

                                String count = '';
                                for (var latecount in lateCountList) {
                                  if (latecount['user_id'] == userId) {
                                    count = latecount['late_count'].toString();
                                    hack(count);
                                    break;
                                  }
                                }

                                String userName = '';
                                String branch_nm = '';
                                for (var takeName in All_Users) {
                                  if (takeName['user_id'] == userId) {
                                    userName = takeName['nm'].toString();
                                    branch_nm =
                                        takeName['branch_name'].toString();
                                    hack(userName);
                                    break;
                                  }
                                }

                                // Calculate the serial number based on the filtered entries
                                int currentSerialNumber = 0;
                                currentSerialNumber++;

                                // for (var lateCountEntry in lateCountList) {
                                //   if (lateCountEntry['user_id'] == userId) {
                                //     currentSerialNumber =
                                //         lateCountList.indexOf(lateCountEntry) +
                                //             1;
                                //     break;
                                //   }
                                // }

                                Color rowColor = index.isEven
                                    ? Color.fromARGB(36, 158, 158, 158)
                                    : Colors.white;

                                return DataRow(
                                  color: MaterialStateColor.resolveWith(
                                      (Set<MaterialState> states) {
                                    return rowColor; // Set the row color
                                  }),
                                  cells: [
                                    DataCell(Text(
                                        currentSerialNumber.toString(),
                                        style: TextStyle(fontSize: 16))),
                                    DataCell(Container(
                                      width: 100,
                                      child: Text(userName.toString(),
                                          style: TextStyle(fontSize: 16)),
                                    )),
                                    DataCell(Text(userId,
                                        style: TextStyle(fontSize: 16))),
                                    DataCell(InkWell(
                                      onTap: () {
                                        viewlate_det(userId);
                                        showCustomPopup(context, userId);
                                      },
                                      child: Container(
                                        child: Center(
                                          child: CircleAvatar(
                                            backgroundColor: Colors.yellow,
                                            child: Text(count.toString(),
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                        ),
                                      ),
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 20,
                          ),
                          uniqueUserIds.isNotEmpty
                              ? Container()
                              : Container(
                                  child: Column(
                                    children: [
                                      Text('No data found'),
                                      SizedBox(
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()));
  }
}
