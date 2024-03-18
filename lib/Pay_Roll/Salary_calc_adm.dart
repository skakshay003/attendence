// ignore_for_file: file_names, use_build_context_synchronously, non_constant_identifier_names, prefer_final_fields, unused_field, use_super_parameters, avoid_print
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, unused_import, use_key_in_widget_constructors, camel_case_types

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin_page.dart';
import '../admin_login.dart';
import '../config.dart';
import 'Salary_calc_emp.dart';
import 'package:intl/intl.dart';

class Salary_Calc_1 extends StatefulWidget {
  const Salary_Calc_1({Key? key}) : super(key: key);

  @override
  State<Salary_Calc_1> createState() => _Salary_Calc_1State();
}

class _Salary_Calc_1State extends State<Salary_Calc_1>
    with SingleTickerProviderStateMixin {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search1 = TextEditingController();
  final TextEditingController _search2 = TextEditingController();

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String selectedMonthYear = '';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    updateSelectedMonthYear();
  }

  List viewempuser = [];
  List viewsaduser = [];
  List rowData = [];
  List filteredData = [];
  List sal_gen = [];
  bool isSearchVisible = false;
  int selectedRowIndex = -1;
  String id = '';
  String name = '';
  String branch = '';
  String clicked = '0';
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
      });
      await viewempreg();
      await viewadreg();
      setState(() {
        vfetchpayroll();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  void updateSelectedMonthYear() {
    setState(() {
      selectedMonthYear =
          DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));
    });
  }

  Future<void> vfetchpayroll() async {
    try {
      print(selectedMonth);
      print(selectedYear);
      var apiUrl = Uri.parse('$backendIP/salary_calculation/check_gen_sts.php');
      var response = await http.post(apiUrl, body: {
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });

      if (response.statusCode == 200) {
        var sal_gen = jsonDecode(response.body);

        setState(() {
          print(sal_gen);
          isLoading = true;
          // Function to check if user_id exists in sal_gen list
          bool isUserInSalGen(String userId) {
            for (var sal in sal_gen) {
              if (sal['emp_id'] == userId) {
                return true;
              }
            }
            return false;
          }

          // Add a variable to viewsaduser if user_id exists in sal_gen list
          for (var user in viewsaduser) {
            user['record'] = isUserInSalGen(user['user_id']) ? 'yes' : 'no';
          }

          // Add a variable to viewempuser if user_id exists in sal_gen list
          for (var user in viewempuser) {
            user['record'] = isUserInSalGen(user['user_id']) ? 'yes' : 'no';
          }

          print(viewempuser);
          print(viewsaduser);
        });
      } else {
        print(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Fetch error1: $e');
    }
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
              data['nm'].toString().toLowerCase().contains(text.toLowerCase()))
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
              data['nm'].toString().toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  bool isAllStaffClicked() {
    hack(clicked);
    return true;
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
                  'Salary Calculation',
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
                                  fontSize: 16.0, fontWeight: FontWeight.w600),
                            )
                          : Text(
                              'Selected\nMonth & Year',
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w600),
                            ),
                      Spacer(),
                      if (selectedMonthYear.isNotEmpty)
                        Container(
                          color: Colors.lightBlue[100],
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
                  SizedBox(height: 16),
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
                          DataColumn(
                            label: Text('Status',
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
                                onTap: () async {
                                  viewrowdata(data);
                                  String? refresh =
                                      await Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return Salary_Calc_2(
                                          id: id,
                                          name: name,
                                          selectedMonth: selectedMonth,
                                          selectedYear: selectedYear,
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
                                  if (refresh == '1') {
                                    setState(() {
                                      checkLoginStatus();
                                    });
                                  } else {
                                    hack('refresh is null');
                                  }
                                },
                              ),
                              DataCell(
                                Text(data['nm'].toString()),
                                onTap: () async {
                                  viewrowdata(data);
                                  String? refresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Salary_Calc_2(
                                              id: id,
                                              name: name,
                                              selectedMonth: selectedMonth,
                                              selectedYear: selectedYear,
                                            )),
                                  );
                                  if (refresh == '1') {
                                    setState(() {
                                      checkLoginStatus();
                                    });
                                  } else {
                                    hack('refresh is null');
                                  }
                                },
                              ),
                              DataCell(
                                (data['record'].toString() == 'yes')
                                    ? Center(
                                        child: Text(
                                        '✔️',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.green),
                                      ))
                                    : Center(child: Text('❌')),
                                onTap: () async {
                                  viewrowdata(data);
                                  String? refresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Salary_Calc_2(
                                              id: id,
                                              name: name,
                                              selectedMonth: selectedMonth,
                                              selectedYear: selectedYear,
                                            )),
                                  );
                                  if (refresh == '1') {
                                    setState(() {
                                      checkLoginStatus();
                                    });
                                  } else {
                                    hack('refresh is null');
                                  }
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
                          DataColumn(
                            label: Text('Status',
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
                                onTap: () async {
                                  viewrowdata(data);
                                  String? refresh =
                                      await Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return Salary_Calc_2(
                                          id: id,
                                          name: name,
                                          selectedMonth: selectedMonth,
                                          selectedYear: selectedYear,
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
                                  if (refresh == '1') {
                                    setState(() {
                                      checkLoginStatus();
                                    });
                                  } else {
                                    hack('refresh is null');
                                  }
                                },
                              ),
                              DataCell(
                                Text(data['nm'].toString()),
                                onTap: () async {
                                  viewrowdata(data);
                                  String? refresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Salary_Calc_2(
                                              id: id,
                                              name: name,
                                              selectedMonth: selectedMonth,
                                              selectedYear: selectedYear,
                                            )),
                                  );
                                  if (refresh == '1') {
                                    setState(() {
                                      checkLoginStatus();
                                    });
                                  } else {
                                    hack('refresh is null');
                                  }
                                },
                              ),
                              DataCell(
                                (data['record'].toString() == 'yes')
                                    ? Center(
                                        child: Text(
                                        '✔️',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.green),
                                      ))
                                    : Center(child: Text('❌')),
                                onTap: () async {
                                  viewrowdata(data);
                                  String? refresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Salary_Calc_2(
                                              id: id,
                                              name: name,
                                              selectedMonth: selectedMonth,
                                              selectedYear: selectedYear,
                                            )),
                                  );
                                  if (refresh == '1') {
                                    setState(() {
                                      checkLoginStatus();
                                    });
                                  } else {
                                    hack('refresh is null');
                                  }
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
