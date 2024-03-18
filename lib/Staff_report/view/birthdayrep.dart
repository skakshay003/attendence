// ignore_for_file: unused_import, depend_on_referenced_packages, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_hack, prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, unused_local_variable, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../admin_login.dart';
import '../../admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class BirthdayReport extends StatefulWidget {
  @override
  _BirthdayReportState createState() => _BirthdayReportState();
}

class _BirthdayReportState extends State<BirthdayReport> {
  var backendIP = ApiConstants.backendIP;
  DateTime selectedMonth = DateTime.now();
  String branch = '';
  late Future<List<Map<String, dynamic>>> birthdayDataFuture = Future.value([]);
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
        birthdayDataFuture = viewBirthdayReport();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> viewBirthdayReport() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/view/vfetchbirthdayreports.php');

      var response = await http.post(apiUrl,body: {
        'branch': branch,
      });

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        hack('Error occurred while fetching data: ${response.body}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
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
      hack('Fetch error: $e');
      throw Exception('Failed to load data');
    }
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Select Month: ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        DropdownButton<int>(
          value: selectedMonth.month,
          onChanged: (int? newValue) {
            setState(() {
              selectedMonth = DateTime(selectedMonth.year, newValue!, 1);
            });
          },
          items: _buildMonthItems(),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> _buildMonthItems() {
    DateTime currentDate = DateTime.now();
    List<DropdownMenuItem<int>> items = [];
    for (int i = 0; i < 12; i++) {
      DateTime month = DateTime(currentDate.year, currentDate.month - i, 1);
      int monthValue = month.month;
      String monthAsString = DateFormat.MMM().format(month);
      items.add(
        DropdownMenuItem<int>(
          value: monthValue,
          child: Text(monthAsString),
        ),
      );
    }
    return items;
  }

  Widget _buildBirthdayList(List<Map<String, dynamic>> birthdayData) {
  List<Map<String, dynamic>> filteredBirthdays = birthdayData
      .where((data) => DateTime.parse(data['dob']).month == selectedMonth.month)
      .toList();

  final noBirthdaysText =
      'No birthdays in ${DateFormat.yMMMM().format(selectedMonth)}';

  if (filteredBirthdays.isEmpty) {
    return Container(
        height: MediaQuery.of(context).size.height - 300,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 250,
              width: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/Search.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              noBirthdaysText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    filteredBirthdays.sort((a, b) {
      DateTime dateA = DateTime.parse(a['dob']);
      DateTime dateB = DateTime.parse(b['dob']);
      return DateTime(2000, dateA.month, dateA.day)
          .compareTo(DateTime(2000, dateB.month, dateB.day));
    });

    bool isTodayBirthday = false;
    List<String> todayBirthdayNames = [];
    DateTime today = DateTime.now();

    for (var birthday in filteredBirthdays) {
      DateTime dob = DateTime.parse(birthday['dob']);
      if (isToday(dob)) {
        isTodayBirthday = true;
        todayBirthdayNames.add(birthday['nm'] ?? '');
      }
    }

// Concatenate the names into a single string
    String concatenatedNames = todayBirthdayNames.join('\n');

// Now you have a single string containing all the names separated by commas

// Now you have a list of names in todayBirthdayNames

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 250,
              width: MediaQuery.of(context).size.width - 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: isTodayBirthday
                      ? AssetImage('images/cake2.png')
                      : AssetImage('images/cake.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: todayBirthdayNames.length == 1 ? 50 : 30,
              left: 100,
              child: todayBirthdayNames.length == 1
                  ? Text(
                      '🍰$concatenatedNames🍰',
                      style: TextStyle(
                        fontSize: 22,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle
                            .italic, // You can experiment with different styles
                        color: Color.fromARGB(210, 1, 49, 238),
                      ),
                    )
                  : Text(''),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          height: 315,
          child: Column(
            children: [
              Expanded(
                child: Card(
                  elevation: 10,
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Scrollbar(
                      controller: _scrollController,
                      thickness: 8.0,
                      radius: Radius.circular(4.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredBirthdays.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              SizedBox(height: 13),
                              Card(
                                elevation: 10,
                                color: index % 2 == 0
                                    ? Color.fromARGB(255, 133, 251, 247)
                                    : Color.fromARGB(255, 254, 254, 254),
                                child: Container(
                                  width: 250,
                                  child: ListTile(
                                    title: Text(
                                      filteredBirthdays[index]['nm'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date of Birth:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _formatDate(filteredBirthdays[index]
                                                      ['dob'] ??
                                                  '') ??
                                              '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 7),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month;
  }

  String _formatDate(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    return DateFormat('dd-MM-yyyy').format(dob);
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
          'Birthday Reports',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMonthSelector(),
            SizedBox(height: 20),
            FutureBuilder(
              future: birthdayDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Map<String, dynamic>> birthdayData =
                      snapshot.data as List<Map<String, dynamic>>;
                  return _buildBirthdayList(birthdayData);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
