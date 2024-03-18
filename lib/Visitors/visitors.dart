// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_hack, unnecessary_cast, depend_on_referenced_packages, use_key_in_widget_constructors, use_build_context_synchronously, sized_box_for_whitespace, non_constant_identifier_names, unused_local_variable, camel_case_types, unused_field, unused_element, prefer_interpolation_to_compose_strings, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin_login.dart';
import '../config.dart';
import 'package:intl/intl.dart';

class ViewVisitors extends StatefulWidget {
  const ViewVisitors({Key? key});

  @override
  State<ViewVisitors> createState() => _ViewState();
}

class _ViewState extends State<ViewVisitors> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search = TextEditingController();

  String loginuser = '';
  List visitorsData = []; // Store the fetched department data here
  bool isSearchVisible = false;
  List filteredData = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  String formatTime(String timeString) {
    // Split the timeString into hours, minutes, and seconds
    List<String> parts = timeString.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2].split('.')[0]); // Remove microseconds part

    // Create a TimeOfDay instance
    final time = TimeOfDay(hour: hours, minute: minutes);

    // Format the TimeOfDay instance
    return time.format(context);
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('session_user');
    if (session1_user != null) {
      setState(() {
        loginuser = session1_user;
        hack(loginuser);
        // Moved getUserdata call here, so it only happens when loginuser is available
        viewVisitors();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  bool isLoading = false;

  Future<void> viewVisitors() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Visitors/vfetch_visitors.php');
      var response = await http.post(apiUrl);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          visitorsData = List<Map<String, dynamic>>.from(data);
          hack(visitorsData);
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

  Future<void> onClick() async {
    setState(() {
      isSearchVisible = !isSearchVisible;
      _search.clear();
      filteredData.clear();
    });
  }

  void onSearchTextChanged(String text) {
    setState(() {
      filteredData = visitorsData
          .where((data) => data['user']
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        toolbarHeight: 50,
        backgroundColor: Color.fromARGB(255, 3, 255, 247),
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
              'View Visitors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                onClick();
              },
              icon: Icon(
                Icons.search,
                color: Colors.black,
                size: 35,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/visitors.jpg'),
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.91),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (isSearchVisible) SizedBox(height: 15),
                    if (isSearchVisible)
                      Container(
                        height: 50.0,
                        width: 300.0,
                        child: TextField(
                          controller: _search,
                          onChanged: onSearchTextChanged,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintText: 'Search...',
                          ),
                        ),
                      ),
                    SizedBox(height: 15),
                    SingleChildScrollView(
                      child: PaginatedDataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blueAccent,
                        ),
                        columnSpacing: 30,
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: [10, 20, 30, 50],
                        onRowsPerPageChanged: (value) {
                          setState(() {
                            _rowsPerPage = value!;
                          });
                        },
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'S.No',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Employee ID',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Log In Time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Log Out Time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        source: _YourDataTableSource(
                          data: filteredData.isNotEmpty
                              ? filteredData
                              : visitorsData,
                          formattedInTimes: visitorsData
                              .map((rowData) =>
                                  formatTime(rowData['log_in_tm'].toString()))
                              .toList(),
                          formattedInDates: visitorsData
                              .map((rowData) =>
                                  formatDate(rowData['log_dt'].toString()))
                              .toList(),
                          formattedOutTimes: visitorsData.map((rowData) {
                            String logOutTime =
                                rowData['log_out_tm'] ?? '00:00:00';
                            return formatTime(logOutTime);
                          }).toList(),
                          formattedoutDates: visitorsData.map((rowData) {
                            String logOutDate =
                                rowData['log_out_dt'] ?? '0000-00-00';
                            return formatDate(logOutDate);
                          }).toList(),
                          
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class _YourDataTableSource extends DataTableSource {
  final List data;
  final List<String> formattedInTimes;
  final List<String> formattedInDates;
  final List<String> formattedOutTimes;
  final List<String> formattedoutDates;

  _YourDataTableSource({
    required this.data,
    required this.formattedInTimes,
    required this.formattedInDates,
    required this.formattedOutTimes,
    required this.formattedoutDates,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    int serialNumber = data.indexOf(data[index]) + 1;
    Map<String, dynamic> rowData = data[index];

    return DataRow(
      cells: <DataCell>[
        DataCell(
          Text(
            '$serialNumber',
            style: TextStyle(fontSize: 16),
          ),
        ),
        DataCell(
          Text(
            rowData['user'].toString().toUpperCase(),
            style: TextStyle(fontSize: 16),
          ),
        ),
        DataCell(
          Row(
            children: [
              Text(
                formattedInTimes[index],
                style: TextStyle(fontSize: 16),
              ),
              Text(
                ' , ',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                formattedInDates[index],
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Text(
                formattedOutTimes[index],
                style: TextStyle(fontSize: 16),
              ),
              Text(
                ' , ',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                formattedoutDates[index],
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            rowData['loctn'].toString(),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
