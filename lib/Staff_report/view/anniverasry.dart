// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, avoid_hack, library_private_types_in_public_api, use_key_in_widget_constructors, depend_on_referenced_packages, use_build_context_synchronously, non_constant_identifier_names, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_card/animated_card.dart';
import '../../admin_login.dart';
import '../../admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class AnniversaryReport extends StatefulWidget {
  @override
  _AnniversaryReportState createState() => _AnniversaryReportState();
}

class _AnniversaryReportState extends State<AnniversaryReport> {
  var backendIP = ApiConstants.backendIP;
  String branch = '';
  DateTime selectedMonth = DateTime.now();
  List<Map<String, dynamic>> birthdayData = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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
        viewAnniversaryReport();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }


  Future<void> viewAnniversaryReport() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/view/vfetchregdatereport.php');

      var response = await http.post(apiUrl,body: {
        'company': branch,
      });

      if (response.statusCode == 200) {
        setState(() {
          // Parse the response body as a list of maps
          birthdayData =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
          hack(birthdayData);
          isLoading = true;
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
          'Anniversary Reports',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ),
      body: 
      isLoading?
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMonthSelector(),
            SizedBox(height: 20),
            _buildBirthdayList(),
          ],
        ),
      )
      : Center(child: CircularProgressIndicator())
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 80,
        ),
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

  Widget _buildBirthdayList() {
    List<Map<String, dynamic>> filteredAnniversaries = birthdayData
        .where((data) =>
            DateTime.parse(data['doj']).month == selectedMonth.month)
        .toList();

    if (filteredAnniversaries.isEmpty) {
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
                      fit: BoxFit.cover)),
            ),
            Text(
              'No Anniversary in ${_getMonthLabel(selectedMonth)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Sort the list based on Date of Joining
    filteredAnniversaries.sort((a, b) =>
        DateTime.parse(a['doj']).compareTo(DateTime.parse(b['doj'])));

    return Column(
  children: [
    Text(
      'Anniversary in ${_getMonthLabel(selectedMonth)}',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    ),
    SizedBox(height: 10),
    for (var data in filteredAnniversaries)
      Column(
        children: [
          AnimatedCard(
            direction: AnimatedCardDirection.left,
            initDelay: Duration(milliseconds: 0),
            duration: Duration(seconds: 1),
            curve: Curves.easeOutBack,
            child: Card(
              elevation: dataIsToday(data['doj']) ? 20 : 10,
              color: dataIsToday(data['doj'])
                  ? Color.fromARGB(255, 59, 255, 216)
                  : null,
              child: ListTile(
                title: Text(
                  data['nm'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Date of Joining:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          _formatDate(data['doj']),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    _buildServiceDuration(data['doj']),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10), // Adjust the height as needed
        ],
      ),
  ],
);

  }

  bool dataIsToday(String dojString) {
    DateTime dateOfJoining = DateTime.parse(dojString);
    DateTime currentDate = DateTime.now();
    return dateOfJoining.month == currentDate.month &&
        dateOfJoining.day == currentDate.day;
  }

  String _getMonthLabel(DateTime dateTime) {
    return DateFormat.yMMMM().format(dateTime);
  }

  Widget _buildServiceDuration(String doj) {
    DateTime dateOfJoining = DateTime.parse(doj);
    DateTime currentDate = DateTime.now();

    Map<String, int> difference = _calculateDateDifference(
      dateOfJoining,
      currentDate,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Service Duration:",
          style: TextStyle(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          '${difference['years']} years, ${difference['months']} months, ${difference['days']} days',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateDateDifference(
    DateTime startDate,
    DateTime endDate,
  ) {
    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;
    int days = endDate.day - startDate.day;

    if (days < 0) {
      months--;
      days += DateTime(endDate.year, endDate.month - 1, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }

  String _formatDate(String dojString) {
    DateTime doj = DateTime.parse(dojString);
    return DateFormat('dd-MM-yyyy').format(doj);
  }
}
