// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_local_variable, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, non_constant_identifier_names, unused_element, camel_case_types

import 'dart:convert';
import 'package:attendence/Attendance/allstaff_leave_rep.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config.dart';

class View_Leave_Report extends StatefulWidget {
  const View_Leave_Report({Key? key, required this.id, required this.name})
      : super(key: key);

  final String id;
  final String name;

  @override
  State<View_Leave_Report> createState() => _View_Leave_ReportState();
}

class _View_Leave_ReportState extends State<View_Leave_Report> {

  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search = TextEditingController();

  List viewstaffreport = [];
  List filteredData = [];
  bool isSearchVisible = false;
  String selectedReportType = 'Select Month/Year';
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String selectedMonthYear = '';
  bool isLoading = false;

  @override
void initState() {
  super.initState();
  hack(widget.name);
  updateSelectedMonthYear();
  viewstafflevrep(); // Fetch the initial data after updating selectedMonthYear
}


  // Function to calculate the total based on the key
  // double calculateTotal(String key) {
  //   double total = 0;
  //   for (var data in (isSearchVisible ? filteredData : viewstaffreport)) {
  //     total += double.parse(data[key].toString());
  //   }
  //   return total;
  // }

  void updateSelectedMonthYear() {
    setState(() {
      selectedMonthYear =
          DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));
    });
  }

  Future<void> viewstafflevrep() async {
  try {
    var apiUrl = Uri.parse(
      '$backendIP/Leave_Reports/vfetchemp_leaves.php');
    var response = await http.post(apiUrl, body: {
      'userid': widget.id.toString(),
      'month': selectedMonth.toString(),
      'year': selectedYear.toString(),
    });
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      setState(() {
        viewstaffreport = List<Map<String, dynamic>>.from(responseData);
        hack(viewstaffreport);
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
                        // if (shouldFetchData()) {
                        viewstafflevrep();
                        // }
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
                      // if (shouldFetchData()) {
                      viewstafflevrep();
                      // }
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
              'Leave Report',
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
      body: 
      isLoading?
      SingleChildScrollView(
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
              color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50,),
                  Text(widget.name,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Color.fromARGB(255, 0, 68, 255)),),
                  SizedBox(width: 5,),
                  Text(':',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Color.fromARGB(255, 0, 0, 0)),),
                  SizedBox(width: 5,),
                  Text(widget.id,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Color.fromARGB(255, 243, 3, 3)),),
                ],
              ),
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
                      fontSize: 16.0, color: Color.fromARGB(255, 255, 7, 7)),
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
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Leave Date',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Reason',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Leave Type',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Apply Date',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Status',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                          ),
                        ],
                        rows: [
                          ...(isSearchVisible ? filteredData : viewstaffreport)
                              .map((data) {
                            int serialNumber = (isSearchVisible
                                        ? filteredData
                                        : viewstaffreport)
                                    .indexOf(data) +
                                1;
                            return DataRow(
                              cells: <DataCell>[
                                DataCell(Text(serialNumber.toString())),
                                DataCell(Text(data['from_dt'].toString())),
                                DataCell(Text(data['reason'].toString())),
                                DataCell(Text(data['lev_typ'].toString())),
                                DataCell(Text(data['applay_dt'].toString())),
                                DataCell(Text(data['status'].toString())),
                              ],
                            );
                          }).toList(),
                          // Inside the DataTable widget, add a new DataRow for totals
                        ],
                      )),
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
            if (!isSearchVisible)
              viewstaffreport.isNotEmpty
                  ? Text('')
                  : Image(image: AssetImage('images/Search.png')),
          ],
        ),
      )
      : Center(child: CircularProgressIndicator())
    );
  }
}
