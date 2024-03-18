// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, unused_import, use_key_in_widget_constructors, camel_case_types, non_constant_identifier_names, unnecessary_string_interpolations, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:attendence/Pay_Roll/salary_rep2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin_page.dart';
import '../admin_login.dart';
import '../config.dart';

class WFH_Report extends StatefulWidget {
  const WFH_Report({Key? key});

  @override
  State<WFH_Report> createState() => _WFH_ReportState();
}

class _WFH_ReportState extends State<WFH_Report> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('dpt');
    var session2_user = sharedPreferences.getString('branch');
    if (session1_user != null && session2_user != null) {
      setState(() {
        dept = session1_user;
        branch = session2_user;
        hack(branch);
        viewreg();
        wfhstatus();
        // _initAsync();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  // Future<void> _initAsync() async {
  //   await wfhstatus(); // Wait for the completion of wfhstatus method
  //   String initialStatus = wfh_status.isNotEmpty
  //       ? wfh_status[0]['app_status'].toString()
  //       : 'Approved';
  //   setState(() {
  //     status = initialStatus;
  //   });
  //   hack('Status: $status');
  //   // You can use the status variable as needed in the rest of your code
  // }

  List viewreguser = [];
  List wfh_status = [];
  List filteredData = [];
  List rowData = [];
  bool isSearchVisible = false;
  int selectedRowIndex = -1;
  String id = '';
  String name = '';
  String branch = '';
  String dept = '';
  String clicked = '0';
  String status = 'Reject';

  bool tick = true;
  bool isloading = false;

  void onChanged() {
    setState(() {
      tick = true;
    });
  }

  Future<void> viewreg() async {
    try {
      var apiUrl = Uri.parse('$backendIP/salary_report/vfetchreguser.php');
      var response = await http.post(apiUrl, body: {
        'company': branch,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          viewreguser = List<Map<String, dynamic>>.from(data);
          hack(viewreguser);
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

  Future<void> wfhstatus() async {
    try {
      var apiUrl = Uri.parse('$backendIP/WFH_Status/vfetchwfh_status.php');
      var response = await http.post(apiUrl);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          wfh_status = List<Map<String, dynamic>>.from(responseData);
          isloading = true;
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

  Future<void> updt_sts(String ids) async {
    try {
      var apiUrl = Uri.parse('$backendIP/WFH_Status/updt_wfh_sts.php');
      var response = await http.post(apiUrl, body: {
        'id': ids,
        'sts': (status == 'Approved')?'1':(status == 'Pending')?'0':(status == 'Reject')?'2':'',
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        setState(() {
        wfhstatus();
      });
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
              child: Text(
            "Status Updated Successfully",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
          backgroundColor: Colors.green,
        ),
      );
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

  Future<void> deleteDepartment(String ids) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ?',
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
                del_wfh(ids);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> del_wfh(String ids) async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/WFH_Status/delete_wfh.php'); // Replace with your delete API endpoint
      var response = await http.post(apiUrl, body: {
        'id': ids.toString(), // Pass the ID to be deleted
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Department deleted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('WFH deleted successfully',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.green, // Set the background color
            ),
          );
          setState(() {
            wfhstatus();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Failed to delete WFH')),
              backgroundColor: Colors.red, // Set the background color
            ),
          );
        }
      } else {
        hack('Error occurred during branch deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to delete WFH')),
            backgroundColor: const Color.fromARGB(
                255, 202, 169, 19), // Set the background color
          ),
        );
      }
    } catch (e) {
      hack('Delete error: $e');
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
      filteredData = wfh_status
          .where((data) =>
              data['user_id']
                  .toString()
                  .toLowerCase()
                  .contains(text.toLowerCase()) ||
              data['nm'].toString().toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  void viewrowdata(Map<String, dynamic> rowData) {
    id = rowData['user_id'].toString();
    name = rowData['nm'].toString();
  }

  void showMyBottomSheet(BuildContext context, Map<String, dynamic> rowData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(child: contentBox(context, rowData)),
        );
      },
    );
  }

  Widget contentBox(BuildContext context, Map<String, dynamic> rowData) {
    hack(rowData);
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Request Date",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 0, 135, 246),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Text("${rowData['req_dt']}"),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Department",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 135, 246),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        Text("${rowData['emp_dept']}"),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Employee ID",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 0, 135, 246),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Text("${rowData['emp_id']}"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Employee Name",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 0, 135, 246),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Text("${rowData['emp_nm']}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WFH From",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 0, 135, 246),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Text("${rowData['wfh_start_dt']}"),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WFH To",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 135, 246),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        Text("${rowData['wfh_end_dt']}"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Colors.grey, thickness: 1),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                List<DataRow> dataRows = [];

                // Extract day and time information from rowData
                List<Map<String, String>> dayAndTimeData = [
                  {
                    'day': 'Monday',
                    'start': rowData['monst'],
                    'end': rowData['moned']
                  },
                  {
                    'day': 'Tuesday',
                    'start': rowData['tuest'],
                    'end': rowData['tueed']
                  },
                  {
                    'day': 'Wednesday',
                    'start': rowData['wedst'],
                    'end': rowData['weded']
                  },
                  {
                    'day': 'Thursday',
                    'start': rowData['thust'],
                    'end': rowData['thued']
                  },
                  {
                    'day': 'Friday',
                    'start': rowData['frist'],
                    'end': rowData['fried']
                  },
                  {
                    'day': 'Saturday',
                    'start': rowData['satst'],
                    'end': rowData['sated']
                  },
                  {
                    'day': 'Sunday',
                    'start': rowData['sunst'],
                    'end': rowData['suned']
                  },
                ];

                // Build DataRow for each day
                for (var dayData in dayAndTimeData) {
                  dataRows.add(
                    DataRow(
                      cells: [
                        DataCell(Text(dayData['day']!)),
                        DataCell(Text(dayData['start']!)),
                        DataCell(Text(dayData['end']!)),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 30,
                      columns: [
                        DataColumn(
                            label: Text(
                          'DAY',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 135, 246),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )),
                        DataColumn(
                            label: Text(
                          'START TIME',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 135, 246),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )),
                        DataColumn(
                            label: Text(
                          'END TIME',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 135, 246),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )),
                      ],
                      rows: dataRows,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Divider(color: Colors.grey, thickness: 1),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Purpose/Reason For Working at Home : ',
                style: TextStyle(
                    color: const Color.fromARGB(255, 0, 135, 246),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                '${rowData['resn']}',
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Supervisor Name : ',
                style: TextStyle(
                    color: const Color.fromARGB(255, 0, 135, 246),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                '${rowData['sup_nm']}',
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Checkbox(
                value: tick,
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    setState(() {
                      //
                    });
                  }
                },
              ),
              Text(
                'I VIJAYTHUL RAHMAN hereby accept the \nterms & conditions of work from home policy.',
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Text('1.CL cannot availed during WFH.'),
            ],
          ),
          Row(
            children: [
              Text('2.IP and Slack should be online.'),
            ],
          ),
          Row(
            children: [
              Text(
                  '3.REspond to Call/Emails/Messages.\n  If not RESPOND within 10 minutes the managenment \n  cancel the WFH without prior Notice.'),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the bottom sheet
            },
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
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
          title: Row(
            children: [
              Text(
                'Work From Home Report',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
              Spacer(),
              // IconButton(
              //   onPressed: () {
              //     onClick();
              //   },
              //   icon: Icon(Icons.search),
              // )
            ],
          ),
        ),
        body: isloading
            ? SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                            onChanged: onSearchTextChanged,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Search...',
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      Center(
                          child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DataTable(
                              columnSpacing: 30,
                              headingRowColor: MaterialStateColor.resolveWith(
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
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('Emp ID',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('Name',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('WFH From',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('WFH To',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('##',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('Action',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('Remove',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ],
                              rows:
                                  (isSearchVisible ? filteredData : wfh_status)
                                      .map((data) {
                                int serialNumber = (isSearchVisible
                                            ? filteredData
                                            : wfh_status)
                                        .indexOf(data) +
                                    1;
                                return DataRow(
                                  cells: <DataCell>[
                                    DataCell(
                                      Text(serialNumber.toString()),
                                      onTap: () {
                                        // Show details dialog on row click
                                      },
                                    ),
                                    DataCell(
                                      Text(data['emp_id'].toString()),
                                    ),
                                    DataCell(
                                      Text(data['emp_nm'].toString()),
                                    ),
                                    DataCell(
                                      Text(data['wfh_start_dt'].toString()),
                                      onTap: () {
                                        // Show details dialog on row click
                                      },
                                    ),
                                    DataCell(
                                      Text(data['wfh_end_dt'].toString()),
                                      onTap: () {
                                        // Show details dialog on row click
                                      },
                                    ),
                                    DataCell(IconButton(
                                        onPressed: () {
                                          viewrowdata(data);
                                          showMyBottomSheet(context, data);
                                        },
                                        icon: Icon(
                                            Icons.remove_red_eye_outlined))),
                                    DataCell((dept == 'SAD')
                                        ? DropdownButton<String>(
                                            value: (data['app_status'] == '0')
                                                ? 'Pending'
                                                : (data['app_status'] == '1')
                                                    ? 'Approved'
                                                    : (data['app_status'] ==
                                                            '2')
                                                        ? 'Reject'
                                                        : 'Pending',
                                            items: [
                                              'Approved',
                                              'Reject',
                                              'Pending'
                                            ]
                                                .map<DropdownMenuItem<String>>(
                                                  (String value) =>
                                                      DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value,
                                                        style: (value ==
                                                                'Approved')
                                                            ? TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)
                                                            : (value ==
                                                                    'Reject')
                                                                ? TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)
                                                                : TextStyle(
                                                                    color: Colors
                                                                        .blueAccent,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (String? newValue) {
                                              // Handle dropdown value change
                                              if (newValue != null) {
                                                setState(() {
                                                  // Update the 'sts' field in your data
                                                  status = newValue;
                                                  print(status);
                                                  updt_sts(data['id'].toString());
                                                });
                                              }
                                            },
                                          )
                                        : Text(
                                            (data['app_status'] == '0')
                                                ? 'Pending'
                                                : (data['app_status'] == '1')
                                                    ? 'Approved'
                                                    : (data['app_status'] ==
                                                            '2')
                                                        ? 'Reject'
                                                        : '',
                                            style: TextStyle(
                                                color: (status == '0')
                                                    ? Colors.blue
                                                    : (status == '1')
                                                        ? Colors.green
                                                        : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          )),
                                    DataCell(
                                      Center(child: (data['app_status']=='0' || dept == 'SAD')?
                                      InkWell(
                                        onTap: () {
                                          deleteDepartment(data['id'].toString());
                                        },
                                        child: Text('❌'))
                                      : Text('No Access',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.red),)
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )),
                      wfh_status.isNotEmpty
                          ? Text('')
                          : Column(
                              children: [
                                Image(image: AssetImage('images/Search.png')),
                                Text(
                                  'No data found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      if (isSearchVisible)
                        filteredData.isNotEmpty
                            ? Text('')
                            : Image(image: AssetImage('images/Search.png')),
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
