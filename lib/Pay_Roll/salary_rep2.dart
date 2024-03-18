// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_hack, depend_on_referenced_packages, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_local_variable, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, non_constant_identifier_names, unused_element, unnecessary_to_list_in_spreads

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config.dart';
import 'Salary_Rep.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

class SalaryReport2 extends StatefulWidget {
  SalaryReport2(
      {Key? key, required this.id, required this.name, required this.clicked, required this.app})
      : super(key: key);

  String id;
  String name;
  String clicked;
  String app;

  void updateArguments(String newId, String newName, String newclicked, String appsts) {
    id = newId;
    name = newName;
    clicked = newclicked;
    app = appsts;
  }

  @override
  State<SalaryReport2> createState() => _SalaryReport2State();
}

class _SalaryReport2State extends State<SalaryReport2> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _search = TextEditingController();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List viewstaffreport = [];
  List filteredData = [];
  bool isSearchVisible = false;
  String selectedReportType = 'Select Month/Year';
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String selectedMonthYear = '';
   int daysInMonth = 0;
  String monthName = '';

  @override
  void initState() {
    super.initState();
    hack(widget.clicked);
    updateSelectedMonthYear();
    summary();
    fetchData();
    selectedReportType = 'Monthly Salary Report'; // Add this line
    select_report(); // Fetch the initial data after updating selectedReportType

    // Initialize the notification plugin
    initializeFlutterLocalNotificationsPlugin();
  }
  
  Future<void> initializeFlutterLocalNotificationsPlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  
  // Function to calculate the total based on the key
  double calculateTotal(String key) {
    double total = 0;
    for (var data in (isSearchVisible ? filteredData : viewstaffreport)) {
      total += double.parse(data[key].toString());
    }
    return total;
  }

  void summary() {
    monthName =
        DateFormat('MMMM').format(DateTime(selectedYear, selectedMonth));

    // Calculate the number of days in the selected month
    daysInMonth = DateTime(2024, selectedMonth + 1, 0).day;
    hack(monthName);
    hack(daysInMonth);
    setState(() {});
  }

  void updateSelectedMonthYear() {
    setState(() {
      selectedMonthYear =
          DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));
    });
  }

  void select_report() {
    if (selectedReportType == 'Monthly Salary Report') {
      viewstaffrep();
      vfetchslip(); // monthly slip
    } else if (selectedReportType == 'Yearly Salary Report') {
      yearlyreport();
      vfetchyearlyslip();
    }
  }

  Future<void> viewstaffrep() async {
    if (widget.clicked != '1') {
      try {
        var apiUrl = Uri.parse(
            '$backendIP/salary_report/vfetchpayroll.php');
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
          });
        } else {
          hack(
              'Error occurred while fetching data. Status code: ${response.statusCode}');
          hack('Response body: ${response.body}');
        }
      } catch (e) {
        hack('Fetch error: $e');
      }
    } else {
      try {
        var apiUrl = Uri.parse(
            '$backendIP/salary_report/vfetch_all_staff_rep.php');
        var response = await http.post(apiUrl, body: {
          'month': selectedMonth.toString(),
          'year': selectedYear.toString(),
        });

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          setState(() {
            viewstaffreport = List<Map<String, dynamic>>.from(responseData);
            hack(viewstaffreport);
            hack('hi');
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
  }

  Future<void> yearlyreport() async {
    if (widget.clicked != '1') {
      try {
        var apiUrl = Uri.parse(
            '$backendIP/salary_report/yearly_staff_rep.php');
        var response = await http.post(apiUrl, body: {
          'userid': widget.id.toString(),
          'year': selectedYear.toString(),
        });
        hack(response.body); // Add this line for debugging

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          setState(() {
            viewstaffreport = List<Map<String, dynamic>>.from(responseData);
            hack(viewstaffreport);
            hack('came');
          });
        } else {
          hack(
              'Error occurred while fetching data. Status code: ${response.statusCode}');
          hack('Response body: ${response.body}');
        }
      } catch (e) {
        hack('Fetch error: $e');
      }
    } else {
      try {
        var apiUrl = Uri.parse(
            '$backendIP/salary_report/yearly_allstaff_rep.php');
        var response = await http.post(apiUrl, body: {
          'year': selectedYear.toString(),
        });

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          setState(() {
            viewstaffreport = List<Map<String, dynamic>>.from(responseData);
            hack(viewstaffreport);
            hack('all');
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
              if (selectedReportType == 'Monthly Salary Report')
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
                        summary();
                        Navigator.pop(context);
                        if (selectedReportType == 'Monthly Salary Report') {
                          viewstaffrep(); // Fetch monthly report data
                          vfetchslip();
                        } else if (selectedReportType ==
                            'Yearly Salary Report') {
                          yearlyreport(); // Fetch yearly report data
                          vfetchyearlyslip();
                        }
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
                      summary();
                      Navigator.pop(context);
                      if (selectedReportType == 'Monthly Salary Report') {
                        viewstaffrep(); // Fetch monthly report data
                        vfetchslip();
                      } else if (selectedReportType == 'Yearly Salary Report') {
                        yearlyreport(); // Fetch yearly report data
                        vfetchyearlyslip();
                      }
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

  List<Map<String, dynamic>> dataList = [];
  Map<String, dynamic> data = {};
  Map<String, dynamic> slipdetails = {};
  String department = '';
  String location = '';
  String doj = '';
  String work_frm = '';
  String work_to = '';
  String act_salary = '';
  // int daysInMonth = 0;
  // String monthName = '';
  int parrre = 0;
  String pf_amt = '';

  //slip

  //actual
  double act_basic = 0.0;
  double act_HRA = 0.0;
  int act_conv_all = 0;
  double act_medical_all = 0.0;
  double Net_Gross = 0.0;

  int act_bonus = 0;
  int bon_ins = 0;

  //earning
  double perday_salary = 0.0;
  double earn = 0.0;
  double ear_basic = 0.0;
  double ear_HRA = 0.0;
  int ear_conv_all = 0;
  double ear_medical_all = 0.0;
  double ear_total_gross = 0.0;
  double LTE = 0.0;
  double LOP_cal = 0.0;
  int Deduct = 0;
  double Net_Salary = 0.0;

  //deduction

  double Total_deduct = 0.0;

  Future<void> fetchData() async {
    try {
      // Make an HTTP request to fetch data based on the profile email
      var apiUrl = Uri.parse('$backendIP/vfetchdata.php');
      var response = await http.post(apiUrl, body: {
        'user_id': widget.id,
        });
      if (response.statusCode == 200) {
        hack(response.body);
        // Parse the JSON response
        // Update the labelTexts based on the fetched data
        setState(() {
          dataList =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          if (dataList.isNotEmpty) {
            data = dataList[0];
            hack('1');
            hack(data);
            setState(() {
              department = data['em_depart'].toString();
              pf_amt = data['pf_amt'];
              location = data['locca'].toString();
              doj = data['doj'].toString();
              work_frm = data['work_frm'].toString();
              work_to = data['work_to'].toString();
              act_salary = data['sala'] == '' ? '0' : data['sala'].toString();
              hack(department);
              hack(location);
              hack(work_frm);
              hack(work_to);
            });
          } else {
            hack('No data');
          }
        });
      } else {
        // Handle API error here
        hack('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      hack('Error2: $e');
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

  int LOP = 0;
  int net_sala = 0;
  int esiamt = 0;
  int insamt = 0;
  int sdamt = 0;
  int arrr = 0;
  int adv = 0;
  double salary_eligible_days = 0;
  int deductionDays = 0;

  Future<void> vfetchslip() async {
    try {
      var apiUrl = Uri.parse('$backendIP/salary_calculation/vfetchslip.php');
      var response = await http.post(apiUrl, body: {
        'user_id': widget.id.toString(),
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });
      if (response.statusCode == 200) {
        slipdetails = jsonDecode(response.body);
        act_bonus = slipdetails['bonus_earn'];
        parrre = slipdetails['prv_arr_earn'];
        LOP = slipdetails['lop'];
        esiamt = slipdetails['esi_amt'];
        insamt = slipdetails['insu_amt'];
        sdamt = slipdetails['sd_deduct'];
        arrr = slipdetails['arr_deduct'];
        adv = slipdetails['adv_deduct'];
        salary_eligible_days= slipdetails['sal_elig_days'];
        deductionDays = slipdetails['tot_late_deduct_days'];
        hack(slipdetails);
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error1: $e');
    }
  }

  Future<void> vfetchyearlyslip() async {
    try {
      var apiUrl = Uri.parse('$backendIP/salary_calculation/vfetchyearslip.php');
      var response = await http.post(apiUrl, body: {
        'user_id': widget.id.toString(),
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });
      if (response.statusCode == 200) {
        slipdetails = jsonDecode(response.body);
        act_bonus = slipdetails['bonus_earn'];
        parrre = slipdetails['prv_arr_earn'];
        LOP = slipdetails['lop'];
        esiamt = slipdetails['esi_amt'];
        insamt = slipdetails['insu_amt'];
        sdamt = slipdetails['sd_deduct'];
        arrr = slipdetails['arr_deduct'];
        adv = slipdetails['adv_deduct'];
        salary_eligible_days= slipdetails['sal_elig_days'];
        deductionDays = slipdetails['tot_late_deduct_days'];
        hack(slipdetails);
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error1: $e');
    }
  }


  
  // // Function to show the bottom sheet with DataTable
  void _showDataTableBottomSheet(BuildContext context) {
    //Actual
      //basic
      act_basic = int.parse(act_salary) * 55 / 100;
      hack('act_basic:$act_basic');
      //HRA
      act_HRA = act_basic * 40 / 100;
      hack('act_HRA:$act_HRA');
      //conv.all
      int salary = int.parse(act_salary);
      if (salary >= 10000) {
        act_conv_all = 1600;
        hack(act_conv_all);
      } else {
        act_conv_all = 800;
        hack(act_conv_all);
      }
      //actual Medical
      double act_for_all = act_basic + act_HRA + act_conv_all;
      hack('act_for_all:$act_for_all');
      double act_result_m = salary - act_for_all;
      hack('act_result_m:$act_result_m');
      act_medical_all = act_result_m / 2;
      hack('act_medical_all:$act_medical_all');
      hack('act_special_all:$act_medical_all');
      hack('act_bonus:$act_bonus');
      //Net Gross
      Net_Gross = act_medical_all +
          act_medical_all +
          act_conv_all +
          act_HRA +
          act_basic;
      hack('Net_Gross:$Net_Gross');
      hack(daysInMonth);
      //perday salary
      perday_salary = int.parse(act_salary) / daysInMonth;
      hack('perday_salary:$perday_salary');
      //earn
      earn = perday_salary * salary_eligible_days;
      hack('earn:$earn');
      //basic
      ear_basic = earn * 55 / 100;
      hack('ear_basic:$ear_basic');
      //HRA
      ear_HRA = ear_basic * 40 / 100;
      hack('HRA:$ear_HRA');
      //conv.all
      if (salary >= 10000) {
        ear_conv_all = 1600;
        hack(ear_conv_all);
      } else {
        ear_conv_all = 800;
        hack(ear_conv_all);
      }
      //Medical all
      double for_all = ear_basic + ear_HRA + ear_conv_all;
      hack('for_all:$for_all');
      double result_m = earn - for_all;
      hack('result_m:$result_m');
      ear_medical_all = result_m / 2;
      hack('ear_medical_all:$ear_medical_all');
      hack('special_all:$ear_medical_all');
      int bon_ins = 0;
      //Total Gross
      ear_total_gross = ear_medical_all +
          ear_medical_all +
          ear_conv_all +
          ear_HRA +
          ear_basic +
          act_bonus +
          bon_ins +
          parrre;
      hack('ear_total_gross:$ear_total_gross');

      //LOP Days

      //late
      LTE = deductionDays * perday_salary;
      hack('late:$LTE');
      //LOP
      LOP_cal = LOP * perday_salary;
      hack('LOP_cal:$LOP_cal');
      //Deduct
      Deduct = sdamt + int.parse(pf_amt);
      hack('Deduct:$Deduct');

      //Total Deduct
      Total_deduct = LOP_cal + sdamt + LTE + int.parse(pf_amt);
      hack('Total_deduct:$Total_deduct');

      //Net_Salary
      Net_Salary = ear_total_gross - Deduct;
      hack('Net_Salary:$Net_Salary');
      setState(() {
        convertwords();
        net_sala = Net_Salary.toInt();
      });
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Text(
                  'SLIP DETAILS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
                SizedBox(height: 10),
                Divider(
                  color: Colors.black,
                  thickness: 2,
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(255, 138, 138,
                                138), // You can set the color of the border
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Emp Code      :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 59,
                                          child: Text(
                                            data['user_id'].toString(),
                                            style: TextStyle(
                                                fontSize: 13,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          )),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Emp Name     :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 59,
                                          child: Text(data['nm'].toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Designation   :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 59,
                                          child: Text(data['dsig'].toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Department   :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 59,
                                          child: Text(
                                              data['em_depart'].toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Bank Name    :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 59,
                                          child: Text(data['bank'].toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(255, 138, 138,
                                138), // You can set the color of the border
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('A/C Number  :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 60,
                                          child: Text(data['acc_no'].toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('PF Code         :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 60,
                                          child: Text(data['pf_cd'].toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('month/year  :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 60,
                                          child: Text('',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Location        :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          width: 60,
                                          child: Text(data['locca'].toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('DOJ                :  ',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                          child: Text(data['doj'].toString(),
                                              style: TextStyle(fontSize: 13))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Total Days',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                daysInMonth.toString(),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Paid days',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                salary_eligible_days.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'LOP Days',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                LOP.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Actual (Rs)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Basic',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  act_basic.toString(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'HRA',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  act_HRA.toString(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Conv.All',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  act_conv_all.toString(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Medical.All',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  act_medical_all.toString(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'LTC',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  '0',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'helper.All',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  '0',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Cca.All',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  '0',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Special.All',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  act_medical_all.toString(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Bonus',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(act_bonus.toString()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Net Gross(Rs)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  Net_Gross.toString(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Earnings(Rs)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Basic',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  ear_basic.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'HRA',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  ear_HRA.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Conv.Al',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  ear_conv_all.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Medical.All',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  ear_medical_all.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'prv.Arrear',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  parrre.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Helper.All',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Cca.All',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Special.All',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  ear_medical_all.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Bonus + Incentive',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  bon_ins.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Total Gross(Rs)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  ear_total_gross.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Deduction(Rs)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'P.F',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  pf_amt.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'E.S.I',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  esiamt.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Adv',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  adv.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Arrear',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  arrr.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'LTE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  LTE.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'LOP',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  LOP_cal.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'SD',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  sdamt.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Ins',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  insamt.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Total Deduct',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  Total_deduct.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  'Net Salary(Rs)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Text(
                                  net_sala.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(255, 138, 138,
                                      138), // You can set the color of the border
                                ),
                              ),
                              height: 50,
                              child: Center(
                                  child: Center(
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'In words : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      netSalaryInWords.toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                    Spacer(),
                    FloatingActionButton(
                      onPressed: () async {
                        generateAndSavePDF();
                      },
                      child: Icon(Icons.download),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> generateAndSavePDF() async {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Container(
              child: pw.Column(
                children: [
                  pw.Center(
                    child: pw.Text(
                      'SLIP DETAILS',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(
                    thickness: 2,
                  ),
                  pw.SizedBox(
                    height: 5,
                  ),
                  pw.SizedBox(
                    height: 10,
                  ),
                  pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    width: 1,
                                    // You can set the color of the border
                                  ),
                                ),
                                child: pw.Row(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Row(
                                            children: [
                                              pw.Text('Emp Code      :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  
                                                  child: pw.Text(
                                                    data['user_id'].toString(),
                                                    style: pw.TextStyle(
                                                        fontSize: 13,),
                                                  )),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text('Emp Name     :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  
                                                  child: pw.Text(
                                                      data['nm'].toString(),
                                                      style: pw.TextStyle(
                                                          fontSize: 13,))),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text('Designation   :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  
                                                  child: pw.Text(
                                                      data['dsig'].toString(),
                                                      style: pw.TextStyle(
                                                          fontSize: 13,))),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text('Department   :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  
                                                  child: pw.Text(
                                                      data['em_depart']
                                                          .toString(),
                                                      style: pw.TextStyle(
                                                          fontSize: 13))),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text('Bank Name    :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  child: pw.Text(
                                                      data['bank'].toString(),
                                                      style: pw.TextStyle(
                                                          fontSize: 13))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    width: 1,
                                    // You can set the color of the border
                                  ),
                                ),
                                child: pw.Row(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Row(
                                            children: [
                                              pw.Text('A/C Number  :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  child: pw.Text(
                                                      data['acc_no'].toString(),
                                                      style: pw.TextStyle(
                                                          fontSize: 13))),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text('PF Code         :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  child: pw.Text(
                                                      data['pf_cd'].toString(),
                                                      style: pw.TextStyle(
                                                          fontSize: 13))),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text('month/year  :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  child: pw.Text('',
                                                      style: pw.TextStyle(
                                                          fontSize: 13))),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text('Location        :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  child: pw.Text(
                                                      data['locca'].toString(),
                                                      style: pw.TextStyle(
                                                          fontSize: 13))),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text('DOJ                :  ',
                                                  style: pw.TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.Container(
                                                  child: pw.Text(
                                                      data['doj'].toString(),
                                                      style: pw.TextStyle(
                                                          fontSize: 13))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8.0),
                                        child: pw.Text(
                                          'Total Days',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Text(
                                        daysInMonth.toString(),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8.0),
                                        child: pw.Text(
                                          'Paid days',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Text(
                                        salary_eligible_days.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 16),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8.0),
                                        child: pw.Text(
                                          'LOP Days',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Text(
                                        LOP.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 16),
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Actual (Rs)',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 16),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Earnings (Rs)',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 16),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 50,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Deduction (Rs)',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 16),
                                      )),
                                    ),
                                  ),
                                ],
                              ),


                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Basic',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        act_basic.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Basic',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        ear_basic.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'P.F',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        pf_amt.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'HRA',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        act_HRA.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'HRA',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        ear_HRA.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'E.S.I',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        esiamt.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Conv.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        act_conv_all.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Conv.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        ear_conv_all.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Adv',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        adv.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Medical.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        act_medical_all.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Medical.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        ear_medical_all.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Arrear',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        arrr.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'LTC',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        '0',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'prv.Arrear',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        parrre.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'LTE',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        LTE.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Helper.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        '0',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Helper.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        '0',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'LOP',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        LOP_cal.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Cca.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        '0',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Cca.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        '0',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'SD',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        sdamt.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Special.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        act_medical_all.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Special.All',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        ear_medical_all.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Ins',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        insamt.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Bonus',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        act_bonus.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Bonus + Incentive',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        bon_ins.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Total Deduct',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        Total_deduct.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Net Gross(Rs)',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        Net_Gross.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Total Gross(Rs)',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        ear_total_gross.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        'Net Salary(Rs)',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 30,
                                      child: pw.Center(
                                          child: pw.Text(
                                        net_sala.toString(),
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10),
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 1,// You can set the color of the border
                                        ),
                                      ),
                                      height: 80,
                                      child: pw.Column(
                                        children: [
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(8.0),
                                            child: pw.Text(
                                              'In words : ',
                                              style: pw.TextStyle(
                                                  fontWeight: pw.FontWeight.bold,
                                                  fontSize: 16),
                                              textAlign: pw.TextAlign.center,
                                            ),
                                          ),
                                          pw.Padding(
                                            padding:
                                                const pw.EdgeInsets.only(left: 12),
                                            child: pw.Text(
                                              netSalaryInWords.toUpperCase(),
                                              style: pw.TextStyle(
                                                  fontWeight: pw.FontWeight.bold,
                                                  fontSize: 12),
                                              textAlign: pw.TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(
                                height: 15,
                              ),
                              pw.Divider(
                                thickness: 2,
                              ),
                  // Add your content here...
                ],
              ),
            ),
          );
        },
      ),
    );

    // Save the PDF
    final bytes = await pdf.save();
    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/${widget.name}.pdf');
    await file.writeAsBytes(bytes);

    // Show notification
    await _showNotification(file.path);
  }

  Future<void> _showNotification(String filePath) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'PDF Downloaded',
      'Tap to open pdf',
      platformChannelSpecifics,
      payload: filePath,
    );

    await _openPDF(filePath);
  }

  Future<void> _openPDF(String filePath) async {
    // Open the PDF file
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // Open the PDF file using the open_file package
        OpenFile.open(filePath);
      }
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }



  String netSalaryInWords = '';
  void convertwords() {
    double Net_Salary = ear_total_gross - Deduct;
    int netSalary = Net_Salary.toInt();

    // Convert the netSalary to words
    netSalaryInWords = formatNumberToWords(netSalary);

    hack('$netSalary in words: $netSalaryInWords');
  }

  String formatNumberToWords(int number) {
    final formatter = NumberFormat('en_US');
    String formattedNumber = formatter.format(number);

    // Remove non-digit characters from the formatted number
    formattedNumber = formattedNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Convert the formatted number to words
    String words = _numberToWords(int.parse(formattedNumber));

    return words;
  }

  String _numberToWords(int number) {
    final units = ['', 'thousand', 'million', 'billion', 'trillion'];
    final ones = [
      '',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'ten',
      'eleven',
      'twelve',
      'thirteen',
      'fourteen',
      'fifteen',
      'sixteen',
      'seventeen',
      'eighteen',
      'nineteen',
    ];
    final tens = [
      '',
      '',
      'twenty',
      'thirty',
      'forty',
      'fifty',
      'sixty',
      'seventy',
      'eighty',
      'ninety',
    ];

    String convertLessThanOneThousand(int num) {
      if (num == 0) {
        return '';
      } else if (num < 20) {
        return ones[num];
      } else if (num < 100) {
        return '${tens[num ~/ 10]} ${convertLessThanOneThousand(num % 10)}';
      } else {
        return '${ones[num ~/ 100]} hundred ${convertLessThanOneThousand(num % 100)}';
      }
    }

    String convert(int num, int unitIndex) {
      if (num == 0) {
        return '';
      }
      final result = '${convertLessThanOneThousand(num)} ${units[unitIndex]}';
      return result.trim();
    }

    String result = '';
    int unitIndex = 0;

    while (number > 0) {
      final chunk = number % 1000;
      if (chunk != 0) {
        result = '${convert(chunk, unitIndex)} $result';
      }
      number ~/= 1000;
      unitIndex++;
    }

    return result.trim();
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
              'Salary Report',
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
      ): null,
      body: SingleChildScrollView(
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
            SizedBox(height: 15),
            Container(
              color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    widget.name.toUpperCase(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 0, 68, 255)),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.id.toUpperCase(),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 243, 3, 3)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              color: Color.fromARGB(110, 158, 158, 158),
              child: ExpansionTile(
                title: Text(selectedReportType,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                children: [
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.grade,
                          color: Color.fromARGB(255, 255, 230, 7)),
                      title: Text('Monthly Salary Report',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(164, 0, 0, 0))),
                      onTap: () {
                        setState(() {
                          selectedReportType = 'Monthly Salary Report';
                        });
                        // Handle other actions if needed
                        // if (shouldFetchData()) {
                        select_report();
                        // }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.grade,
                          color: Color.fromARGB(255, 255, 230, 7)),
                      title: Text('Yearly Salary Report',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(164, 0, 0, 0))),
                      onTap: () {
                        setState(() {
                          selectedReportType = 'Yearly Salary Report';
                        });
                        select_report();
                      },
                    ),
                  ),
                ],
              ),
            ),
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
            viewstaffreport.isNotEmpty
                ? Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: selectedReportType ==
                                        'Monthly Salary Report' ||
                                    selectedReportType == 'Yearly Salary Report'
                                ? DataTable(
                                    columnSpacing: 30,
                                    headingRowColor:
                                        MaterialStateColor.resolveWith(
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
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Name',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Emp_id',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Actual_salary',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Salary_month',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Pf_amt',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Insurance_amt',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Esi_amt',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('salary',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('status',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Slip',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
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
                                            DataCell(
                                                Text(serialNumber.toString())),
                                            DataCell(Text(
                                                data['emp_nm'].toString())),
                                            DataCell(Text(
                                                data['emp_id'].toString())),
                                            DataCell(Text(
                                                data['actual_sal'].toString())),
                                            DataCell(Text(data['salary_month']
                                                .toString())),
                                            DataCell(Text(
                                                data['pf_amt'].toString())),
                                            DataCell(Text(
                                                data['insu_amt'].toString())),
                                            DataCell(Text(
                                                data['esi_amt'].toString())),
                                            DataCell(Text(
                                                data['salary'].toString())),
                                            DataCell(
                                                Text(data['sts'].toString())),
                                            DataCell(InkWell(
                                              onTap: () {
                                                _showDataTableBottomSheet(context);
                                              },
                                              child: Row(
                                                children: [
                                                  Text("Slip"),
                                                  SizedBox(width: 5),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          158, 158, 158, 1),
                                                    ),
                                                    child: Image(
                                                      image: AssetImage(
                                                          'images/print.png'),
                                                      height: 25,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        );
                                      }).toList(),
                                      // Inside the DataTable widget, add a new DataRow for totals
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('Total',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                          DataCell(Text(
                                              '')), // Placeholder cell for 'Name'
                                          DataCell(Text(
                                              '')), // Placeholder cell for 'Emp_id'
                                          DataCell(Text(
                                              '')), // Placeholder cell for 'Salary_month'
                                          DataCell(Text(
                                              '')), // Placeholder cell for other columns
                                          DataCell(Text(calculateTotal('pf_amt')
                                              .toStringAsFixed(2))),
                                          DataCell(Text(
                                              calculateTotal('insu_amt')
                                                  .toStringAsFixed(2))),
                                          DataCell(Text(
                                              calculateTotal('esi_amt')
                                                  .toStringAsFixed(2))),
                                          DataCell(Text(calculateTotal('salary')
                                              .toStringAsFixed(2))),

                                          DataCell(Text(
                                              '')), // Placeholder cell for other columns
                                          DataCell(Text(
                                              '')), // Placeholder cell for other columns
                                        ],
                                      ),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '❗Select a Report type',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  )),
                      ),
                    ),
                  )
                : Image(image: AssetImage('images/Search.png')),
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
    );
  }
}
