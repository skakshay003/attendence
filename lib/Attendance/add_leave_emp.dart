// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_local_variable, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, non_constant_identifier_names, unused_element, camel_case_types, prefer_final_fields, unused_field, sort_child_properties_last, use_build_context_synchronously, unused_import

import 'dart:convert';
import 'package:attendence/Attendance/allstaff_leave_rep.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin_login.dart';
import '../config.dart';
import 'add_leave_adm.dart';

class AddLeave_emp extends StatefulWidget {
  const AddLeave_emp({Key? key, required this.id, required this.name})
      : super(key: key);

  final String id;
  final String name;

  @override
  State<AddLeave_emp> createState() => _AddLeave_empState();
}

class _AddLeave_empState extends State<AddLeave_emp> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _id = TextEditingController();
  final TextEditingController _reasn = TextEditingController();
  final TextEditingController _totdays = TextEditingController();
  final TextEditingController calendar_today = TextEditingController();

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
  String currentDate = '';
  String dep = '';
  String selectedLeaveType = 'SELECT';
  String From = '';
  String To = '';
  String formattedDate = '';
  String currentMonth = '';
  String currentYear = '';
  String status = '';
  String logindepart = '';
  String formatFrom = '';
  String formatTo = '';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('session_user');
    if (session1_user != null) {
      setState(() {
        logindepart = session1_user;
        hack(logindepart);

        final currentDateMap = getCurrentDate();
        String dateString = currentDateMap['formattedDate'];
        DateTime currentDate = DateTime.parse(dateString);
        String formatted = DateFormat('dd/MM/yyyy').format(currentDate);
        calendar_today.text = formatted;

        _name.text = widget.name.toString();
        _id.text = widget.id.toString().toUpperCase();
        final currentDay = currentDateMap['day'];
        currentMonth = currentDateMap['month'].toString(); // Update this line
        currentYear = currentDateMap['year'].toString(); // Update this line

        formattedDate = currentDateMap['formattedDate'];

        hack('Current Date: $currentDay');
        hack('Current Month: $currentMonth');
        hack('Current Year: $currentYear');
        hack('Formatted Date: $formattedDate');

        if (logindepart == 'SAD') {
          status = '1';
        } else {
          status = '0';
        }
        hack(status);
        changepassword();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  String calculateTotalDays() {
    if (From.isNotEmpty && To.isNotEmpty) {
      DateTime fromDate = DateTime.parse(From);
      DateTime toDate = DateTime.parse(To);

      // Ensure fromDate is not after toDate
      if (fromDate.isAfter(toDate)) {
        // Swap values if fromDate is after toDate
        DateTime temp = fromDate;
        fromDate = toDate;
        toDate = temp;
      }

      // Calculate the difference in days
      int totalDays = toDate.difference(fromDate).inDays;

      // If the dates are different, add 1 to totalDays
      if (totalDays > 0) {
        totalDays += 1;
      } else if (totalDays == 0) {
        totalDays = 1;
      }

      // Display the total days in the _totdays controller
      _totdays.text = totalDays.toString();

      return totalDays.toString();
    }
    return '0';
  }

  Future<void> _fromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950), // Set your desired minimum date
      lastDate: DateTime(2050), // Set your desired maximum date
    );
    if (picked != null) {
      setState(() {
        From =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        formatFrom =
    "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().padLeft(4, '0')}";
        calculateTotalDays(); // Call calculateTotalDays after updating From
      });
    }
  }

  Future<void> _toDate(BuildContext context) async {
  DateTime fromDate = DateTime.parse(From);
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: fromDate, // Start from the selected "From" date
    firstDate: fromDate, // Set the minimum date to the selected "From" date
    lastDate: DateTime(2050), // Set your desired maximum date
  );
  if (picked != null) {
    setState(() {
      To = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      formatTo = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().padLeft(4, '0')}";
      calculateTotalDays(); // Call calculateTotalDays after updating To
    });
  }
}

  Map<String, dynamic> getCurrentDate() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return {
      'day': now.day,
      'month': now.month,
      'year': now.year,
      'formattedDate': formattedDate,
    };
  }

  String depart = '';

  Future<void> changepassword() async {
    try {
      var apiUrl = Uri.parse('$backendIP/changepass.php');

      var response = await http.post(apiUrl, body: {
        'id': widget.id,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes

        if (data.isNotEmpty) {
          setState(() {
            depart = data[0]['depart'];
            hack(depart);
          });
        } else {
          hack('Error occurred while fetching pass status: ${response.body}');
        }
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

  Future<void> submit() async {
    try {
      if (From != '') {
        if (To != '') {
          hack(From);
          hack(To);
          hack(formattedDate);
          var apiUrl = Uri.parse('$backendIP/Leave_Reports/add_leave.php');
          var response = await http.post(apiUrl, body: {
            'appl_date': formattedDate,
            'emp_id': _id.text,
            'lv_type': selectedLeaveType,
            'resn': _reasn.text,
            'from': From,
            'to': To,
            'tot': _totdays.text,
            'deprt': depart,
            'month': currentMonth,
            'year': currentYear,
            'status': status,
          });

          if (response.statusCode == 200) {
            var responseData = jsonDecode(response.body);
            setState(() {
              if (responseData is Map<String, dynamic> &&
                  responseData.isNotEmpty) {
                viewstaffreport = [responseData]; // Wrap responseData in a list
                hack(viewstaffreport);
              } else {
                hack('No data received from the server');
              }
            });

            // Show a SnackBar when data insertion is successful
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text('Leave added successfully')),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            _reasn.clear();
            _totdays.clear();
            From = '';
            To = '';
            selectedLeaveType = 'SELECT';
          } else {
            hack(
                'Error occurred while fetching data. Status code: ${response.statusCode}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text('! Failed to add leave')),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            hack('Response body: ${response.body}');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Please select to date')),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Please select from date')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      hack('Insert error: $e');
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
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: Row(
          children: [
            Text(
              'Add Leave',
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
      body: Container(
        height: MediaQuery.of(context).size.height,
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
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Application Date',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: calendar_today,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      focusNode: _textField1FocusNode,
                      onFieldSubmitted: (value) {
                        // Move focus to the next text field when submitted
                        _textField1FocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_textField2FocusNode);
                      },
                      enabled:
                          false, // Set enabled to false to make it non-editable
                      decoration: InputDecoration(
                        // You can optionally provide decoration to make it visually read-only
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  Colors.black), // Customize the border color
                        ),
                      ),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter location';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Employee Name',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _name,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      focusNode: _textField2FocusNode,
                      onFieldSubmitted: (value) {
                        // Move focus to the next text field when submitted
                        _textField1FocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_textField3FocusNode);
                      },
                      enabled:
                          false, // Set enabled to false to make it non-editable
                      decoration: InputDecoration(
                        // You can optionally provide decoration to make it visually read-only
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  Colors.black), // Customize the border color
                        ),
                      ),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter location';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Employee Id',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _id,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      focusNode: _textField3FocusNode,
                      onFieldSubmitted: (value) {
                        // Move focus to the next text field when submitted
                        _textField1FocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_textField4FocusNode);
                      },
                      enabled:
                          false, // Set enabled to false to make it non-editable
                      decoration: InputDecoration(
                        // You can optionally provide decoration to make it visually read-only
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  Colors.black), // Customize the border color
                        ),
                      ),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter location';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 15),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              '  Leave Type',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: DropdownButton<String>(
                              value: selectedLeaveType,
                              onChanged: (value) {
                                setState(() {
                                  selectedLeaveType = value!;
                                });
                              },
                              items: [
                                'SELECT',
                                'LOP',
                                if(logindepart == 'SAD')'CL',
                                'OD',
                                if(logindepart == 'SAD')'HALFDAY-CL',
                                'HALFDAY-LOP',
                                'HALFDAY-OD'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              icon: Icon(Icons
                                  .arrow_drop_down), // Customized icon for dropdown
                              iconSize: 24, // Set the icon size as needed
                            ),
                          ),
                          SizedBox(width: 10)
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Reason',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _reasn,
                      style: TextStyle(fontSize: 20),
                      focusNode: _textField4FocusNode,
                      onFieldSubmitted: (value) {
                        // Move focus to the next text field when submitted
                        _textField1FocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_textField5FocusNode);
                      },
                      enabled: true,
                      decoration: InputDecoration(
                        // Customize the border color and width
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Colors.grey, // Set your preferred border color
                            width: 1.0, // Set your preferred border width
                          ),
                        ),
                        // Customize the focused border color and width
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .blue, // Set your preferred focused border color
                            width:
                                2.0, // Set your preferred focused border width
                          ),
                        ),
                        // Customize the enabled (idle) border color and width
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Set your preferred enabled border color
                            width: 0, // Set your preferred enabled border width
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Reason';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.1, color: Colors.black)),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '  Leave From',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Text(
                            formatFrom,
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _fromDate(context),
                            child: Text(
                              'Select date',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(172, 120, 255, 244),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.1, color: Colors.black)),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '  Leave To',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Text(
                            formatTo,
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 10),
                          if(From != '')
                          ElevatedButton(
                            onPressed: () => _toDate(context),
                            child: Text(
                              'Select date',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(172, 120, 255, 244),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Total Days',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _totdays,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      focusNode: _textField5FocusNode,
                      onFieldSubmitted: (value) {
                        // Move focus to the next text field when submitted
                        _textField1FocusNode.unfocus();
                      },
                      enabled:
                          false, // Set enabled to false to make it non-editable
                      decoration: InputDecoration(
                        // You can optionally provide decoration to make it visually read-only
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  Colors.black), // Customize the border color
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_reasn.text != '') {
                            if (selectedLeaveType != 'SELECT') {
                              submit();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                      child:
                                          Text('Please select Leave type !')),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Center(child: Text('Reason is Empty !')),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
