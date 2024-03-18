// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, unused_import, use_key_in_widget_constructors, camel_case_types, use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'package:attendence/Pay_Roll/salary_rep2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../admin_login.dart';
import '../admin_page.dart';
import '../config.dart';
import 'view_staff_leaverep.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllStaff_Leave_Report extends StatefulWidget {
  const AllStaff_Leave_Report({Key? key}) : super(key: key);

  @override
  State<AllStaff_Leave_Report> createState() => _AllStaff_Leave_ReportState();
}

class _AllStaff_Leave_ReportState extends State<AllStaff_Leave_Report>
    with SingleTickerProviderStateMixin {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search1 = TextEditingController();
  final TextEditingController _search2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  List viewempuser = [];
  List viewsaduser = [];
  List rowData = [];
  List filteredData = [];
  bool isSearchVisible = false;
  int selectedRowIndex = -1;
  String id = '';
  String name = '';
  String branch = '';
  bool isLoading = false;
  String userType = 'Employee';
  int _currentPageIndex = 0;

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session2_user = sharedPreferences.getString('branch');
    if (session2_user != null) {

      setState(() {
        branch = session2_user;
        print(branch);
        viewempreg();
        viewadreg();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  Future<void> viewempreg() async {
    try {
      var apiUrl = Uri.parse('$backendIP/salary_report/vfetchempuser.php');
      var response = await http.post(apiUrl, body: {
        'company': branch,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          viewempuser = List<Map<String, dynamic>>.from(data);
          print(viewempuser);
          isLoading = true;
        });
      } else {
        print(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  Future<void> viewadreg() async {
    try {
      var apiUrl = Uri.parse('$backendIP/salary_report/vfecthsaduser.php');
      var response = await http.post(apiUrl, body: {
        'company': branch,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          viewsaduser = List<Map<String, dynamic>>.from(data);
          print(viewsaduser);
          isLoading = true;
        });
      } else {
        print(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  Future<void> onClick() async {
    setState(() {
      isSearchVisible = !isSearchVisible;
      _search1.clear();
      _search2.clear();
      filteredData.clear();
    });
  }

  void onSearchTextChanged1(String text) {
    setState(() {
      filteredData = viewempuser
              .where((data) =>
                  data['user_id']
                      .toString()
                      .toLowerCase()
                      .contains(text.toLowerCase()) ||
                  data['nm']
                      .toString()
                      .toLowerCase()
                      .contains(text.toLowerCase()))
              .toList();
    });
  }

  void onSearchTextChanged2(String text) {
    setState(() {
      filteredData = viewsaduser
              .where((data) =>
                  data['user_id']
                      .toString()
                      .toLowerCase()
                      .contains(text.toLowerCase()) ||
                  data['nm']
                      .toString()
                      .toLowerCase()
                      .contains(text.toLowerCase()))
              .toList();
    });
  }

  Future<void> viewrowdata(Map<String, dynamic> rowData) async {
    print(rowData);
    id = rowData['user_id'].toString();
    name = rowData['nm'].toString();
    print('ID: $id, Name: $name');
  }


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                  'Print ID',
                  style: TextStyle(fontSize: 20, color: Colors.black87),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    onClick();
                  },
                  icon: Icon(Icons.search),
                )
              ],
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Employee',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                    child: Text('Admin',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          body: TabBarView(children: [
            buildSalaryReportTab1(),
            buildSalaryReportTab2(),
          ])),
    );
  }

  Widget buildSalaryReportTab1() {
    
    return isLoading
        ? SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'EMPLOYEE REPORT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (isSearchVisible) SizedBox(height: 15),
                  if (isSearchVisible)
                    Container(
                      height: 50.0,
                      width: 250.0,
                      child: TextField(
                        controller: _search1,
                        onChanged: onSearchTextChanged1,
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
                        ],
                        rows: (isSearchVisible ? filteredData : viewempuser)
                            .map((data) {
                          int serialNumber =
                              (isSearchVisible ? filteredData : viewempuser)
                                      .indexOf(data) +
                                  1;
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(serialNumber.toString()),
                                onTap: () {},
                              ),
                              DataCell(
                                Text(data['user_id'].toString()),
                                onTap: () {
                                  viewrowdata(data);
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return View_Leave_Report(
                                          id: id,
                                          name: name,
                                        );
                                      },
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);
                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              DataCell(
                                Text(data['nm'].toString()),
                                onTap: () {
                                  viewrowdata(data);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => View_Leave_Report(
                                          id: id,
                                          name: name,
                                        )
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (isSearchVisible)
                    filteredData.isNotEmpty
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
                  if (!isSearchVisible)
                    viewempuser.isNotEmpty || viewsaduser.isNotEmpty
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
        : Center(child: CircularProgressIndicator());
  }

  Widget buildSalaryReportTab2() {
    
    return isLoading
        ? SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'ADMIN REPORT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  if (isSearchVisible) SizedBox(height: 15),
                  if (isSearchVisible)
                    Container(
                      height: 50.0,
                      width: 250.0,
                      child: TextField(
                        controller: _search2,
                        onChanged: onSearchTextChanged2,
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
                        ],
                        rows: (isSearchVisible ? filteredData : viewsaduser)
                            .map((data) {
                          int serialNumber =
                              (isSearchVisible ? filteredData : viewsaduser)
                                      .indexOf(data) +
                                  1;
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(serialNumber.toString()),
                                onTap: () {},
                              ),
                              DataCell(
                                Text(data['user_id'].toString()),
                                onTap: () {
                                  viewrowdata(data);
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return View_Leave_Report(
                                          id: id,
                                          name: name,
                                        );
                                      },
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);
                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              DataCell(
                                Text(data['nm'].toString()),
                                onTap: () {
                                  viewrowdata(data);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => View_Leave_Report(
                                          id: id,
                                          name: name,
                                        )
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (isSearchVisible)
                    filteredData.isNotEmpty
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
                  if (!isSearchVisible)
                    viewempuser.isNotEmpty || viewsaduser.isNotEmpty
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
        : Center(child: CircularProgressIndicator());
  }
}
