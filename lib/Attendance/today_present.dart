// ignore_for_file: file_names, use_build_context_synchronously, non_constant_identifier_names, prefer_final_fields, unused_field, use_super_parameters, curly_braces_in_flow_control_structures, sort_child_properties_last, avoid_print, unnecessary_null_comparison
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, unused_import, use_key_in_widget_constructors, camel_case_types

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin_page.dart';
import '../admin_login.dart';
import '../config.dart';
import 'package:intl/intl.dart';

class today_present extends StatefulWidget {
  const today_present({Key? key}) : super(key: key);

  @override
  State<today_present> createState() => _today_presentState();
}

class _today_presentState extends State<today_present>
    with SingleTickerProviderStateMixin {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search = TextEditingController();

  String formattedDate = '';
  bool isLoading = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    final DateTime currentDate = DateTime.now();
    selectedDate1 =
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";
    // Format selectedDate3 with leading zeros
    selectedDate3 = DateFormat('dd-MM-yyyy').format(currentDate);
    checkLoginStatus();
  }

  String branch = '';

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session2_user = sharedPreferences.getString('branch');
    if (session2_user != null) {
      setState(() {
        branch = session2_user;
        hack(branch);
        vfetch_reg();
        today_present_rep();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  List reg_all = [];
  List<Map<String, String>> userIdList = [];

  Future<void> vfetch_reg() async {
    try {
      var apiUrl = Uri.parse('$backendIP/reg_all.php');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        reg_all = jsonDecode(response.body);
        print(reg_all);
        userIdList = getUserIds(reg_all);
        print(userIdList);
        today_present_rep();
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

  List<Map<String, String>> getUserIds(List userList) {
    List<Map<String, String>> userIdList = [];

    for (Map<String, dynamic> user in userList) {
      String userId = user["user_id"];
      String name = user["nm"];
      if (userId != null &&
          userId.isNotEmpty &&
          name != null &&
          name.isNotEmpty) {
        userIdList.add({"userId": userId, "name": name});
      }
    }

    return userIdList;
  }

  List today_rep = [];

  Future<void> today_present_rep() async {
    try {
      var apiUrl = Uri.parse('$backendIP/today_pres_rep.php');
      var response = await http.post(apiUrl, body: {
        'date': selectedDate1,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        setState(() {
          today_rep = List<Map<String, dynamic>>.from(data);
          hack(today_rep);
          updateStatusInUserIdList(today_rep, userIdList);
          print(userIdList);
          isLoading = true;
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

  void updateStatusInUserIdList(List todayRep, List userIdList) {
    for (Map<String, dynamic> todayData in todayRep) {
      bool isPresent = false;
      String userId = todayData['user_id'];

      for (Map<String, String> user in userIdList) {
        if (user['userId'] == userId) {
          isPresent = true;
          break;
        }
      }

      for (Map<String, String> user in userIdList) {
        if (user['userId'] == userId) {
          user['status'] = isPresent ? 'Present' : 'Absent';
          break;
        }
      }
    }
  }

  String selectedDate1 = '';
  String selectedDate3 = '';
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // Set your desired minimum date
      lastDate: DateTime.now(), // Set your desired maximum date
    );
    if (picked != null)
      setState(() {
        selectedDate1 = "${picked.year}-${picked.month}-${picked.day}";
        selectedDate3 = DateFormat('dd-MM-yyyy').format(picked);
        vfetch_reg();
      });
      await today_present_rep();
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
            'Today Present',
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
        body: isLoading
            ? SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Text(branch,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue)),
                          Spacer(),
                          Text(
                            selectedDate3,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
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
                      SizedBox(height: 16),
                      Center(
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PaginatedDataTable(
                              columnSpacing: 20,
                              header: const Text(
                                'Today Present',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              rowsPerPage: _rowsPerPage, // Use _rowsPerPage here
                              columns: <DataColumn>[
                                DataColumn(
                                  label: Text('S.No',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                DataColumn(
                                  label: Text('Emp ID',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                DataColumn(
                                  label: Text('Name',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                DataColumn(
                                  label: Text('Status',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                              source: _YourDataTableSource(userIdList),
                              availableRowsPerPage: [10, 20, 30, 50],
                        onRowsPerPageChanged: (value) {
                          setState(() {
                            _rowsPerPage = value!;
                          });
                        }
                              // actions: [
                              //   IconButton(
                              //     icon: Icon(Icons.refresh),
                              //     onPressed: () {
                              //       // Handle refresh action
                              //     },
                              //   ),
                              // ],
                            )),
                      ),
                      today_rep.isNotEmpty
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
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}

class _YourDataTableSource extends DataTableSource {
  final List<Map<String, String>> _data;

  _YourDataTableSource(this._data);

  @override
  DataRow getRow(int index) {
    final user = _data[index];
    return DataRow(
      cells: <DataCell>[
        DataCell(Center(child: Text((index + 1).toString()))),
        DataCell(Center(child: Text(user['userId'] ?? ''))),
        DataCell(Text(user['name']?.toUpperCase() ?? '',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        DataCell(
          Center(
            child: Text(
              user['status'] ?? 'Absent',
              style: (user['status'] == 'Present')
                  ? TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)
                  : TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}