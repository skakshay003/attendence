// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_local_variable, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, non_constant_identifier_names, unused_element, unused_import, file_names, use_build_context_synchronously, unnecessary_to_list_in_spreads, unnecessary_this

import 'dart:convert';
import 'package:attendence/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../admin_login.dart';
import '../../config.dart';

class LeaveStatus extends StatefulWidget {
  LeaveStatus({
    Key? key,
    required this.id,
    required this.name,
    required this.userdpt,
    required this.app,
  }) : super(key: key);

  String id;
  String name;
  String userdpt;
  String app;

  void updateArguments(String newId, String newName, String newDepart, String appsts) {
    id = newId;
    name = newName;
    userdpt = newDepart;
    app = appsts;
  }

  @override
  State<LeaveStatus> createState() => _LeaveStatusState();
}

class _LeaveStatusState extends State<LeaveStatus> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search = TextEditingController();

  List viewstaffreport = [];
  List filteredData = [];
  bool isSearchVisible = false;
  String selectedReportType = 'Select Report';
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String selectedMonthYear = '';
  String status = 'Approved';
  String user_id = '';
  String name = '';
  String user_depart = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user_depart = widget.userdpt;
    updateSelectedMonthYear();
    viewstafflevrep();
  }

  // Function to calculate the total based on the key
  double calculateTotal(String key) {
    double total = 0;
    for (var data in (isSearchVisible ? filteredData : viewstaffreport)) {
      total += double.parse(data[key].toString());
    }
    return total;
  }

  void updateSelectedMonthYear() {
    setState(() {
      selectedMonthYear =
          DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));
    });
  }

  Future<void> viewstafflevrep() async {
    try {
      hack(selectedMonth);
      hack(selectedYear);
      var apiUrl = Uri.parse('$backendIP/Leave_Reports/vfetchempleave_sts.php');
      var response = await http.post(apiUrl, body: {
        'userid': widget.id,
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });

      if (response.statusCode == 200) {
        // Ensure that the response body is a valid JSON
        var responseData = jsonDecode(response.body);

        if (responseData is List) {
          // The response is a list, process it accordingly
          hack(responseData);

          setState(() {
            viewstaffreport = List<Map<String, dynamic>>.from(responseData);
            isLoading = true;
          });
        } else {
          // The response is not a list, handle the error or unexpected response
          hack('Unexpected response format. Response body: $responseData');
        }
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = true;
      });
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

  Future<void> status_updt(id) async {
    try {
      hack(status);
      var apiUrl = Uri.parse('$backendIP/Leave_Reports/updt_lv_sts.php');
      var response = await http.post(apiUrl, body: {
        'id': id,
        'status': (status == 'Approved')
            ? '1'
            : (status == 'Pending')
                ? '0'
                : '2',
      });
      if (response.statusCode == 200) {
        hack('Updated Succesfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Status Updated Successfully',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)),
          backgroundColor: Colors.green,)
        );
        setState(() {
          viewstafflevrep();
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
      filteredData = viewstaffreport
          .where((data) =>
              data['emp_id']
                  .toString()
                  .toLowerCase()
                  .contains(text.toLowerCase()) ||
              data['emp_nm']
                  .toString()
                  .toLowerCase()
                  .contains(text.toLowerCase()))
          .toList();
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
                        )))
                    .toList(),
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      selectedMonth = value;
                      updateSelectedMonthYear();
                      Navigator.pop(context);
                      viewstafflevrep(); // Update the data when the date changes
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
                      Navigator.pop(context);
                      viewstafflevrep(); // Update the data when the date changes
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

  bool shouldFetchData() {
    // Check if the selected month and year are different from the current month and year
    return selectedMonth != DateTime.now().month ||
        selectedYear != DateTime.now().year;
  }

  Future<void> deleteDepartment(id) async {
    hack(id);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete this Leave?',
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

  Future<void> performDelete(id) async {
    try {
      var apiUrl = Uri.parse('$backendIP/Leave_Reports/delete_lv.php');
      var response = await http.post(apiUrl, body: {
        'id': id,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Department deleted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Leave deleted successfully',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.green,
            ),
          );
          await viewstafflevrep();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Failed to delete department',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        hack('Error occurred during department deletion: ${response.body}');
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

  String formatDate(String dateString) {
    // Parse the input date string
    DateTime date = DateTime.parse(dateString);

    // Format the date as dd-MM-yyyy
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
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
                'Leave Status',
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
        )
        : null,
        body: isLoading
            ? SingleChildScrollView(
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
                    Container(
                      decoration: BoxDecoration(color: Colors.amber),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' : ',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.id.toUpperCase(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Selected Date: ',
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$selectedMonthYear',
                          style: const TextStyle(
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 255, 7, 7)),
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
                    SizedBox(height: 5),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 10,
                              headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.blueAccent,
                              ),
                              border: TableBorder.all(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black,
                                width: 0.4,
                              ),
                              columns: <DataColumn>[
                                if (user_depart == 'SAD')
                                  DataColumn(
                                    label: Text('S.No',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,color:Colors.white)),
                                  ),
                                DataColumn(
                                  label: Text('Leave From',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,color:Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('Leave To',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,color:Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('No of Days',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,color:Colors.white)),
                                ),
                                if (user_depart == 'SAD')
                                  DataColumn(
                                    label: Text('Reason',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,color:Colors.white)),
                                  ),
                                if (user_depart == 'SAD')
                                  DataColumn(
                                    label: Text('Leave Tpe',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,color:Colors.white)),
                                  ),
                                if (user_depart == 'SAD')
                                  DataColumn(
                                    label: Text('Apply Date',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,color:Colors.white)),
                                  ),
                                DataColumn(
                                  label: Text('Status',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,color:Colors.white)),
                                ),
                                DataColumn(
                                  label: Text('Cancel',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,color:Colors.white)),
                                ),
                              ],
                              rows: [
                                ...(isSearchVisible
                                        ? filteredData
                                        : viewstaffreport)
                                    .map((data) {
                                  int serialNumber = (isSearchVisible
                                              ? filteredData
                                              : viewstaffreport)
                                          .indexOf(data) +
                                      1;
                                  return DataRow(
                                    cells: <DataCell>[
                                      if (user_depart == 'SAD')
                                        DataCell(
                                          Center(
                                              child: Text(
                                                  serialNumber.toString())),
                                        ),
                                      DataCell(
                                        Center(
                                            child: Text(formatDate(
                                                data['from_dt'].toString()))),
                                      ),
                                      DataCell(
                                        Center(
                                            child: Text(formatDate(
                                                data['to_dt'].toString()))),
                                      ),
                                      DataCell(
                                        Center(
                                            child: Text(
                                                data['tot_days'].toString())),
                                      ),
                                      if (user_depart == 'SAD')
                                        DataCell(
                                          Center(
                                              child: Text(
                                                  data['reason'].toString())),
                                        ),
                                      if (user_depart == 'SAD')
                                        DataCell(
                                          Center(
                                              child: Text(
                                                  data['lev_typ'].toString())),
                                        ),
                                      if (user_depart == 'SAD')
                                        DataCell(
                                          Center(
                                              child: Text(data['applay_dt']
                                                  .toString())),
                                        ),
                                      (user_depart == 'SAD')
                                          ? DataCell(
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  DropdownButton<String>(
                                                    value: (data['status'] == '0')?'Pending':(data['status'] == '1')?'Approved': (data['status'] == '2')?'Hold':'Pending',
                                                    items: [
                                                      'Approved',
                                                      'Pending',
                                                      'Hold'
                                                    ]
                                                        .map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                          (String value) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                            value: value,
                                                            child: Text(value),
                                                          ),
                                                        )
                                                        .toList(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      // Handle dropdown value change
                                                      if (newValue != null) {
                                                        setState(() {
                                                          // Update the 'sts' field in your data
                                                          status = newValue;
                                                          hack(data['id']);
                                                          status_updt(data['id']
                                                              .toString());
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    (data['status'] == '0')?'Pending':(data['status'] == '1')?'Approved': (data['status'] == '2')?'Hold':'Pending',
                                                    style: TextStyle(
                                                        color: (data['status'] == '1')
                                                            ? Colors.green
                                                            : (data['status'] == '2')
                                                                ? Colors.red
                                                                : (data['status'] == '0')
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )
                                                ],
                                              ),
                                            )
                                          : DataCell(Center(
                                              child: Text(
                                              (data['status'] == '0')?'Pending':(data['status'] == '1')?'Approved': (data['status'] == '2')?'Hold':'Pending',
                                              style: TextStyle(
                                                  color: (data['status'] == '1')
                                                            ? Colors.green
                                                            : (data['status'] == '2')
                                                                ? Colors.red
                                                                : (data['status'] == '0')
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ))),
                                      DataCell(Center(
                                          child: InkWell(
                                              onTap: () {
                                                deleteDepartment(
                                                    data['id'].toString());
                                              },
                                              child: Text(
                                                '❌',
                                                style: TextStyle(fontSize: 16),
                                              )))),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (isSearchVisible)
                      filteredData.isNotEmpty
                          ? Text('')
                          : Image(image: AssetImage('images/Search.png')),
                    viewstaffreport.isNotEmpty
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
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
