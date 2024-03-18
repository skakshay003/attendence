// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_local_variable, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, non_constant_identifier_names, unused_element, unused_import, file_names, unnecessary_to_list_in_spreads, use_build_context_synchronously

import 'dart:convert';
import 'package:attendence/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config.dart';
import 'Salary_Rep.dart';

class SalaryApproval extends StatefulWidget {
  @override
  State<SalaryApproval> createState() => _SalaryApprovalState();
}

class _SalaryApprovalState extends State<SalaryApproval> {
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    viewstaffrep();
    updateSelectedMonthYear();
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

  Future<void> viewstaffrep() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/salary_approval/view_all_staff_Rep.php');
      var response = await http.post(apiUrl, body: {
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
// Approved', 'Approve', 'Pending', 'Hold
  Future<void> status_updt(id) async {
    try {
      hack(status);
      var apiUrl = Uri.parse(
          '$backendIP/salary_approval/status_updt.php');
      var response = await http.post(apiUrl, body: {
        'id': id,
        'status': (status == 'Pending')?'0':(status == 'Approved')?'1':(status == 'Hold')?'2':'3',
      });
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          viewstaffrep();
        });
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Status Updated',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)),
          backgroundColor: Colors.green,)
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
                      viewstaffrep(); // Update the data when the date changes
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
                      viewstaffrep(); // Update the data when the date changes
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
              'Salary Approval',
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
            // ExpansionTile
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
                Container(
                  color: Colors.amber,
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
                          label: Text('Name',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Emp_id',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Actual_salary',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Salary_month',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Proceed_salary',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('salary',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('status',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        // DataColumn(
                        //   label: Text('Slip',
                        //       style: TextStyle(
                        //           fontSize: 18, fontWeight: FontWeight.bold)),
                        // ),
                      ],
                      rows: [
                        ...(isSearchVisible ? filteredData : viewstaffreport)
                            .map((data) {
                          int serialNumber =
                              (isSearchVisible ? filteredData : viewstaffreport)
                                      .indexOf(data) +
                                  1;
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(serialNumber.toString()),
                              ),
                              DataCell(
                                Text(data['emp_nm'].toString()),
                              ),
                              DataCell(
                                Text(data['emp_id'].toString()),
                              ),
                              DataCell(
                                Text(data['actual_sal'].toString()),
                              ),
                              DataCell(
                                Text(data['salary_month'].toString()),
                              ),
                              DataCell(
                                Text(data['process_dt'].toString()),
                              ),
                              DataCell(
                                Text(data['salary'].toString()),
                              ),
                              DataCell(
                                DropdownButton<String>(
                                  value: (data['sts'] == '0')?'Pending':(data['sts'] == '1')?'Approved':(data['sts'] == '2')?'Hold':'Pending',
                                  items:
                                      ['Approved', 'Pending', 'Hold']
                                          .map<DropdownMenuItem<String>>(
                                            (String value) =>
                                                DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,style: 
                                              (value == 'Pending')?
                                              TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue
                                              ) : (value == 'Approved')?
                                              TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green
                                              ) : (value == 'Hold')?
                                              TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red
                                              )
                                              : TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue
                                              ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (String? newValue) async {
                                    // Handle dropdown value change
                                    if (newValue != null) {
                                      setState(() {
                                        // Update the 'sts' field in your data
                                        status = newValue;
                                      });
                                      await status_updt(data['id'].toString());
                                    }
                                  },
                                ),
                              ),
                              // DataCell(Row(
                              //   children: [
                              //     Text("Slip"),
                              //     SizedBox(
                              //       width: 5,
                              //     ),
                              //     Container(
                              //       decoration: BoxDecoration(
                              //         color: Color.fromRGBO(158, 158, 158, 1),
                              //       ),
                              //       child: Image(
                              //           image: AssetImage('images/hack.png'),
                              //           height: 25),
                              //     ),
                              //   ],
                              // ))
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
                  : Column(
                  children: [
                    Image(image: AssetImage('images/Search.png')),
                    Text('No data found',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
                  ],
                ),
            if (!isSearchVisible)
            viewstaffreport.isNotEmpty
                ? Text('')
                : Column(
                  children: [
                    Image(image: AssetImage('images/Search.png')),
                    Text('No data found',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
                  ],
                ),
          ],
        ),
      )
      : Center(child: CircularProgressIndicator())
    );
  }
}
