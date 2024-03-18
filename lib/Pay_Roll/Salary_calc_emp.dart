// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, sort_child_properties_last, deprecated_member_use, camel_case_types, use_key_in_widget_constructors, unused_import, depend_on_referenced_packages, avoid_unnecessary_containers, avoid_hack, prefer_if_null_operators, non_constant_identifier_names, prefer_final_fields, prefer_interpolation_to_compose_strings, unnecessary_null_comparison, file_names, unnecessary_cast, use_build_context_synchronously, prefer_const_literals_to_create_immutables, division_optimization, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:attendence/Attendance/allstaff_leave_rep.dart';
import 'package:attendence/Staff_report/permission/add_permission_adm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Attendance/add_leave_adm.dart';
import '../../admin_login.dart';
import '../config.dart';
import 'Salary_calc_adm.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Salary_Calc_2 extends StatefulWidget {
  @override
  State<Salary_Calc_2> createState() => _Salary_Calc_2State();
  const Salary_Calc_2(
      {Key? key,
      required this.id,
      required this.name,
      required this.selectedYear,
      required this.selectedMonth})
      : super(key: key);

  final String id;
  final String name;
  final int selectedMonth;
  final int selectedYear;
}

class _Salary_Calc_2State extends State<Salary_Calc_2> {
  var backendIP = ApiConstants.backendIP;
  Map<String, dynamic> data = {};
  List viewstattreport = [];
  Map<String, dynamic> slipdetails = {};
  String selectedMonthYear = '';
  final TextEditingController _adv = TextEditingController();
  final TextEditingController _sd = TextEditingController();
  final TextEditingController _pf = TextEditingController();
  final TextEditingController _arr = TextEditingController();
  final TextEditingController _parr = TextEditingController();
  final TextEditingController _ins = TextEditingController();
  final TextEditingController _esi = TextEditingController();
  final TextEditingController _bonus = TextEditingController();
  final TextEditingController _deddays = TextEditingController();

  String id = '';
  String name = '';
  String department = '';
  String sd_amt = '';
  String pf_amt = '';
  String insu_amt = '';
  String esi_amt = '';
  String pf_number = '';
  String location = '';
  String doj = '';
  String work_frm = '';
  String work_to = '';
  String salary_eligible_days = '';
  String act_salary = '0';
  int min_attendance = 0;
  double early_clkout = 0.0;
  double mis_clkin = 0.0;
  int selectedMonth = 0;
  int selectedYear = 0;
  Duration mrngLate = Duration(); // Initialize total late duration
  Duration totalearly_by = Duration(); // Initialize total late duration
  Duration totalLate = Duration(); // Initialize total late duration

  String sub_clicked = '';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String Tot_MrngLate = '';
  String Tot_Early_by = '';
  int viewstattlength = 0;
  int holidayLength = 0;
  int CL = 0;
  int OD = 0;
  int LOP = 0;
  int HALFDAY_LOP = 0;
  int HALFDAY_CL = 0;
  int HALFDAY_OD = 0;
  String monthName = '';

  double HALFDAY_LOP1 = 0.0;
  double HALFDAY_CL1 = 0.0;
  double HALFDAY_OD1 = 0.0;

  bool isLoading = false;

  //slip

  //actual
  double act_basic = 0.0;
  double act_HRA = 0.0;
  int act_conv_all = 0;
  double act_medical_all = 0.0;
  double Net_Gross = 0.0;

  int act_bonus = 0;
  int parrre = 0;
  int bons = 0;
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

  int pfamt = 0;
  int esiamt = 0;
  int sdamt = 0;
  int insamt = 0;
  int adv = 0;
  int arrr = 0;
  double Total_deduct = 0.0;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    id = widget.id;
    selectedMonth = widget.selectedMonth;
    selectedYear = widget.selectedYear;
    summary();
    vfetchslip();
    fetchData();
    viewholidayattend();
    updateSelectedMonthYear();
    _adv.text = '0';
    _arr.text = '0';
    _parr.text = '0';
    _bonus.text = '0';

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

  void min_attend() {
    const requiredWorkingDays = 4; // Use a constant for required working days

    min_attendance = daysInMonth - (holidayLength + requiredWorkingDays);
    if (entriesBelowThresholdCount <= min_attendance) {
      salary_eligible_days =
          ((entriesBelowThresholdCount + CL + early_clkout) - deductionDays)
              .toString();
      hack('Condition 1: salary_eligible_days = $salary_eligible_days');
    } else if (viewstattlength >= min_attendance) {
      salary_eligible_days =
          ((entriesBelowThresholdCount + CL + holidayLength + early_clkout) -
                  deductionDays)
              .toString();
      hack('Condition 2: salary_eligible_days = $salary_eligible_days');
    }
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

  List<Map<String, dynamic>> dataList = [];

  Future<void> fetchData() async {
    try {
      // Make an HTTP request to fetch data based on the profile email
      var apiUrl = Uri.parse('$backendIP/vfetchdata.php');
      var response = await http.post(apiUrl, body: {'user_id': id});
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
              pf_number = data['pf_amt'].toString();
              location = data['locca'].toString();
              doj = data['doj'].toString();
              work_frm = data['work_frm'].toString();
              work_to = data['work_to'].toString();
              _sd.text = data['sd_amt'] == '' ? '0' : data['sd_amt'].toString();
              _pf.text = data['pf_amt'] == '' ? '0' : data['pf_amt'].toString();
              _ins.text =
                  data['insu_amt'] == '' ? '0' : data['insu_amt'].toString();
              _esi.text =
                  data['esi_amt'] == '' ? '0' : data['esi_amt'].toString();
              act_salary = data['sala'] == '' ? '0' : data['sala'].toString();
              hack(department);
              hack(pf_number);
              hack(location);
              hack(work_frm);
              hack(work_to);
              viewstaffatt();
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
      hack('Error: $e');
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

  Future<void> viewstaffatt() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/vfetch_empwise_attend.php');
      var response = await http.post(apiUrl, body: {
        'userid': id,
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          viewstattreport = List<Map<String, dynamic>>.from(responseData);
          viewstattlength = viewstattreport.length;
          hack(viewstattreport);
          hack(viewstattlength);
          calc_clockout();
          min_attend();
          calc_late();
          calc_earlyby();
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

  void calc_late() {
    for (var entry in viewstattreport) {
      if (entry['clk_in_tm'] != null && entry['work_frm'] != null) {
        // Parse 'work_frm' and 'clk_in_tm' strings to DateTime objects
        DateTime workFromTime =
            DateTime.parse('${entry['date']} ${entry['work_frm']}');
        DateTime clkInTime =
            DateTime.parse('${entry['date']} ${entry['clk_in_tm']}');
        hack(workFromTime);
        hack(clkInTime);
        // Calculate late time by subtracting 'work_frm' time from 'clk_in_tm' time
        Duration late = clkInTime.difference(workFromTime);
        hack('late : $late');
        // Accumulate total late time
        mrngLate += late.abs();
        hack('total late : $mrngLate');
      }
      setState(() {
        tot_late();
      });
    }

    // Convert total late time to hours and minutes
    int totalLateHours = mrngLate.inHours;
    int totalLateMinutes = (mrngLate.inMinutes % 60);

    // Display the total late time
    hack('Total Late: $totalLateHours hr $totalLateMinutes min');
    Tot_MrngLate = '$totalLateHours hr $totalLateMinutes min'.toString();
  }

  void calc_earlyby() {
    for (var entry in viewstattreport) {
      if (entry['clk_out_tm'] != null && entry['work_to'] != null) {
        // Parse 'work_frm' and 'clk_in_tm' strings to DateTime objects
        DateTime workToTime =
            DateTime.parse('${entry['date']} ${entry['work_to']}');
        DateTime clkoutTime =
            DateTime.parse('${entry['date']} ${entry['clk_out_tm']}');
        hack(workToTime);
        hack(clkoutTime);
        // Calculate late time by subtracting 'work_frm' time from 'clk_in_tm' time
        Duration early_by = clkoutTime.difference(workToTime);
        hack('early by : $early_by');
        // Accumulate total late time
        totalearly_by += early_by.abs();
        hack('total early_by : $totalearly_by');
      }
    }
    setState(() {
      tot_late();
    });
    // Convert total late time to hours and minutes
    int totalearly_byHours = totalearly_by.inHours;
    int totalearly_byMinutes = (totalearly_by.inMinutes % 60);

    // Display the total late time
    hack('Total early_by: $totalearly_byHours hr $totalearly_byMinutes min');
    Tot_Early_by =
        '$totalearly_byHours hr $totalearly_byMinutes min'.toString();
  }

  String Tot_overall_late = '';
  int totalLate_byMinutes2 = 0;
  double deductionDays = 0.0;

  void tot_late() {
    totalLate = (mrngLate + totalearly_by);
    hack('overall Late: $totalLate');
    // Convert total late time to hours and minutes
    int totalLate_byHours = totalLate.inHours;
    int totalLate_byMinutes = (totalLate.inMinutes % 60);

    Tot_overall_late =
        '$totalLate_byHours hr $totalLate_byMinutes min'.toString();

    // Convert total late time to minutes
    totalLate_byMinutes2 = totalLate.inMinutes;

    // Calculate deduction based on totalLate minutes

    if (totalLate_byMinutes < 210) {
      // < 3:30
      deductionDays = 0.0;
    } else if (totalLate_byMinutes < 240) {
      // >= 3:30 < 4:00
      deductionDays = 0.5;
    } else if (totalLate_byMinutes < 270) {
      // >= 4:00 < 4:30
      deductionDays = 1.0;
    } else if (totalLate_byMinutes < 300) {
      // >= 4:30 < 5:00
      deductionDays = 1.5;
    } else if (totalLate_byMinutes < 330) {
      // >= 5:00 < 5:30
      deductionDays = 2.0;
    } else if (totalLate_byMinutes < 360) {
      // >= 5:30 < 6:00
      deductionDays = 2.5;
    } else if (totalLate_byMinutes < 390) {
      // >= 6:00 < 6:30
      deductionDays = 3.0;
    }

    hack('Deduct $deductionDays days');
  }

  // Function to compare time strings with the minimum threshold
  bool isTimeBelowThreshold(String timeString, Duration threshold) {
    DateTime entryTime = DateTime.parse("1970-01-01 " + timeString);
    DateTime thresholdTime =
        DateTime(1970, 1, 1, threshold.inHours, threshold.inMinutes % 60);

    return entryTime.isBefore(thresholdTime);
  }

  int daysInMonth = 0;
  int entriesBelowThresholdCount = 0;

  void calc_clockout() {
    // Set the minimum threshold for tot_hr
    final Duration minimumThreshold = Duration(hours: 03, minutes: 30);

    // Filter the viewstaffreport based on the criteria
    List entriesBelowThreshold = viewstattreport
        .where((data) =>
            data['tot_hr'] != null &&
            !isTimeBelowThreshold(data['tot_hr'], minimumThreshold))
        .toList();

    // Get the count of entries below the minimum threshold
    entriesBelowThresholdCount = entriesBelowThreshold.length;

    hack(
        'Number of entries with tot_hr above $minimumThreshold: $entriesBelowThresholdCount');

    // hack details of entries below the threshold
    for (Map<String, dynamic> entry in entriesBelowThreshold) {
      hack('Entry: $entry');
    }
    early_clkout =
        (viewstattlength.toDouble() - entriesBelowThresholdCount.toDouble()) /
            2;
    hack(early_clkout);
    mis_clkin = (daysInMonth -
        (entriesBelowThresholdCount + holidayLength + early_clkout));
    hack('mis_clkin:$mis_clkin');
    setState(() {
      _deddays.text = (mis_clkin + LOP + HALFDAY_LOP).toString();
      isLoading = true;
    });
  }

  Future<void> onClick() async {
    // setState(() {
    //   isSearchVisible = !isSearchVisible;
    //   _search.clear();
    //   filteredData.clear();
    // });
  }

  // void onSearchTextChanged(String text) {
  //   setState(() {
  //     filteredData = viewstaffreport
  //         .where((data) =>
  //             data['from_dt']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(text.toLowerCase()) ||
  //             data['status']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(text.toLowerCase(

  //                 )))
  //         .toList();
  //   });
  // }

  List viewholiday = [];
  List viewleavedt = [];

  Future<void> viewholidayattend() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/vfetch_holiday_attend.php');
      var response = await http.post(apiUrl, body: {
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          viewholiday = List<Map<String, dynamic>>.from(responseData);
          hack(viewholiday);
          holidayLength = viewholiday.length;
          hack(holidayLength);
          hack(viewholiday[0]['holiday_date']);
          viewleave();
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

  List<Map<String, dynamic>> inBetweenDates = [];
  Map<String, int> typeCounts = {};
  Map<String, int> dateCounts = {};

  Future<void> viewleave() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Attendance_Reports/view_emp_lv.php');
      var response = await http.post(apiUrl, body: {
        'userid': id,
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          viewleavedt = List<Map<String, dynamic>>.from(responseData);
          hack(viewleavedt);
          hack(selectedMonth);

          // Iterate through each row in viewleavedt
          for (var row in viewleavedt) {
            DateTime fromDt = DateTime.parse(row['from_dt']);
            DateTime toDt = DateTime.parse(row['to_dt']);

            // Generate a list of maps for each date between from_dt and to_dt
            List<Map<String, dynamic>> inBetweenDates = List.generate(
              toDt.difference(fromDt).inDays + 1,
              (index) => {
                'date': DateFormat('yyyy-MM-dd')
                    .format(fromDt.add(Duration(days: index))),
                'type': row['lev_typ'],
                'resn': row['reason'],
              },
            );

            // Filter inBetweenDates based on selectedMonth
            int selectedMonthInt = int.parse(selectedMonth.toString());
            inBetweenDates = inBetweenDates
                .where((entry) =>
                    DateTime.parse(entry['date']).month == selectedMonthInt)
                .toList();

            // Count occurrences of each type in the filtered list
            for (var entry in inBetweenDates) {
              String type = entry['type'];
              typeCounts[type] = (typeCounts[type] ?? 0) + 1;
            }

// hack the filtered in-between dates for each row
            hack('In-between dates for row ${row['id']} in $selectedMonth:');
            hack(inBetweenDates);
            hack('--------------------------');

// hack the counts of each type in the filtered list
            hack('Type counts in $selectedMonth:');
            hack(typeCounts);

// Iterate through viewHoliday and inBetweenDates
            for (var holiday in viewholiday) {
              String holidayDate = holiday['holiday_date'];
              dateCounts[holidayDate] = dateCounts[holidayDate] ?? 0;

              for (var entry in inBetweenDates) {
                String entryDate = entry['date'];

                // Compare date strings and update counts
                if (entryDate == holidayDate) {
                  dateCounts[holidayDate] = (dateCounts[holidayDate] ?? 0) + 1;
                  // Subtract 1 from the type count if it matches the holiday date
                  String type = entry['type'];
                  typeCounts[type] = (typeCounts[type] ?? 0) - 1;
                }
              }
            }

// hack the updated counts for each type and date with count greater than zero
            hack(
                'Type counts in $selectedMonth after removing matching holiday dates:');
            hack(typeCounts);

            hack('Date counts:');
            dateCounts.forEach((date, count) {
              if (count > 0) {
                hack({'Matchedt_cnt': count});
              }
            });
          }
          CL = typeCounts['CL'] ?? 0;
          OD = typeCounts['OD'] ?? 0;
          LOP = typeCounts['LOP'] ?? 0;
          HALFDAY_CL = typeCounts['HALFDAY-CL'] ?? 0;
          HALFDAY_OD = typeCounts['HALFDAY-OD'] ?? 0;
          HALFDAY_LOP = typeCounts['HALFDAY-LOP'] ?? 0;
          HALFDAY_LOP1 = (HALFDAY_LOP / 2);
          HALFDAY_CL1 = (HALFDAY_CL / 2);
          HALFDAY_OD1 = (HALFDAY_OD / 2);
          hack('halfday: $HALFDAY_LOP1');
          hack('hi  ' + CL.toString());
          hack('hlo  ' + OD.toString());
          hack('hiiii  ' + LOP.toString());
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

  String formattedDate = "";
  String reg_month = "";
  String reg_year = "";

  void submitForm() {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Get the current date
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    hack(formattedDate);
    List<String> dateParts = formattedDate.split('-');
    int extractedYear = int.parse(dateParts[0]);
    int extractedMonth = int.parse(dateParts[1]);

    reg_month = extractedMonth.toString();
    reg_year = extractedYear.toString();
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

  String slip_sts = '0';

  Future<void> generate_salary() async {
    try {
      // Make an HTTP request to fetch data based on the profile email
      var apiUrl = Uri.parse('$backendIP/salary_calculation/add_salary.php');
      var response = await http.post(apiUrl, body: {
        'emp_id': id,
        'emp_name': name,
        'desig': dataList[0]['dsig'].toString(),
        'doj': doj,
        'locc': location,
        'pf_amt': _pf.text.toString(),
        'pf_num': dataList[0]['pf_cd'].toString(),
        'actual_sala': act_salary.toString(),
        'punch': entriesBelowThresholdCount.toString(),
        'punch_hlf': early_clkout.toString(),
        'cl': CL.toString(),
        'cl_hlf': HALFDAY_CL.toString(),
        'od': OD.toString(),
        'od_hlf': HALFDAY_OD.toString(),
        'holiday': holidayLength.toString(),
        'missed_clkin': mis_clkin.toString(),
        'lop': LOP.toString(),
        'lop_hlf': HALFDAY_LOP.toString(),
        'missed_clkin_hlf': early_clkout.toString(),
        'early_clkout': early_clkout.toString(),
        'mrng_late': Tot_MrngLate,
        'early_by': Tot_Early_by,
        'tot_late': Tot_overall_late,
        'tot_late_dedt_days': deductionDays.toString(),
        'tot_month_days': daysInMonth.toString(),
        'min_attend_need': min_attendance.toString(),
        'sal_elig_days': salary_eligible_days.toString(),
        'process_dt': formattedDate,
        'salary_dt': formattedDate,
        'adv_deduct': _adv.text.toString(),
        'arr_deduct': _arr.text.toString(),
        'sd_deduct': _sd.text.toString(),
        'days_extra_deduct': deductionDays.toString(),
        'bonus_earn': _bonus.text.toString(),
        'prr_arr_earn': _parr.text.toString(),
        'sts': '0',
        'salary_month': formattedDate,
        'salary': Net_Salary.toString(),
        'ins_amt': _ins.text.toString(),
        'esi_amt': _esi.text.toString(),
        'mnth': reg_month,
        'year': reg_year,
      });
      if (response.statusCode == 200) {
        hack(response.body);
        if (response.body == '"Data inserted successfully"') {
          setState(() {
            slip_sts = '1';
            sub_clicked = '1';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.thumb_up,
                      color: Colors.white), // Add an icon for emphasis
                  SizedBox(width: 20), // Add some spacing
                  Text(
                    'Salary Generated',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.green, // Change the background color
              duration: Duration(
                  seconds: 3), // Adjust the duration the SnackBar is displayed
              behavior:
                  SnackBarBehavior.floating, // Display as a floating SnackBar
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10)), // Add rounded corners
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .hideCurrentSnackBar(); // Dismiss the SnackBar
                },
              ),
            ),
          );
        } else if (response.body == '"Data exist"') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning,
                      color: Colors.white), // Add an icon for emphasis
                  SizedBox(width: 8), // Add some spacing
                  Text(
                    'Salary already generated',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.orange, // Change the background color
              duration: Duration(
                  seconds: 3), // Adjust the duration the SnackBar is displayed
              behavior:
                  SnackBarBehavior.floating, // Display as a floating SnackBar
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10)), // Add rounded corners
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .hideCurrentSnackBar(); // Dismiss the SnackBar
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Failed to generate salary!',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Handle API error here
        hack('Failed to insert data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      hack('Error: $e');
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

  Future<void> vfetchslip() async {
    try {
      hack('id:$id');
      hack('id:$selectedMonth');
      hack('id:$selectedYear');
      var apiUrl = Uri.parse('$backendIP/salary_calculation/vfetchslip.php');
      var response = await http.post(apiUrl, body: {
        'user_id': id.toString(),
        'month': selectedMonth.toString(),
        'year': selectedYear.toString(),
      });
      if (response.statusCode == 200) {
        slipdetails = jsonDecode(response.body);
        hack(slipdetails);
        if (slipdetails.isNotEmpty) {
          setState(() {
            slip_sts = '1';
          });
        } else {
          setState(() {
            slip_sts = '0';
          });
        }
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  Future<void> deleteDepartment(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ?',
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

  Future<void> performDelete(String id) async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/salary_calculation/regenerate_salary.php');
      var response = await http.post(apiUrl, body: {
        'id': id,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Department deleted successfully') {
          setState(() {
            slip_sts = '0';
            sub_clicked = '1';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Generated Salary deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete GENERATED SALARY'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        hack('Error occurred during department deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete department'),
            backgroundColor: Colors.yellow.shade600,
          ),
        );
      }
    } catch (e) {
      hack('Delete error: $e');
    }
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

  int net_sala = 0;

  // Function to show the bottom sheet with DataTable
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
    act_bonus = int.parse(_bonus.text);
    hack('act_bonus:$act_bonus');
    //Net Gross
    Net_Gross =
        act_medical_all + act_medical_all + act_conv_all + act_HRA + act_basic;
    hack('Net_Gross:$Net_Gross');

    //perday salary
    perday_salary = int.parse(act_salary) / daysInMonth;
    hack('perday_salary:$perday_salary');
    //earn
    earn = perday_salary * double.parse(salary_eligible_days);
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
    hack(_parr.text);
    parrre = int.parse(_parr.text);
    hack(_bonus.text);
    bons = int.parse(_bonus.text);
    bon_ins = 0;
    //Total Gross
    ear_total_gross = ear_medical_all +
        ear_medical_all +
        ear_conv_all +
        ear_HRA +
        ear_basic +
        bons +
        bon_ins +
        parrre;
    hack('ear_total_gross:$ear_total_gross');

    //LOP Days

    hack('Lop days:$LOP');
    hack(_pf.text);
    int pfamt = int.parse(_pf.text);
    hack(_esi.text);
    int esiamt = int.parse(_esi.text);
    hack(_sd.text);
    int sdamt = int.parse(_sd.text);
    hack(_ins.text);
    int insamt = int.parse(_ins.text);
    hack(_adv.text);
    int adv = int.parse(_adv.text);
    hack(_arr.text);
    int arrr = int.parse(_arr.text);
    //late
    LTE = deductionDays * perday_salary;
    hack('late:$LTE');
    //LOP
    LOP_cal = LOP * perday_salary;
    hack('LOP_cal:$LOP_cal');
    //Deduct
    Deduct = sdamt + pfamt;
    hack('Deduct:$Deduct');

    //Total Deduct
    Total_deduct = LOP_cal + sdamt + LTE + pfamt;
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
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Center(
                          child: Text(
                        'SLIP DETAILS',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Emp Code      :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 59,
                                                child: Text(
                                                  data['user_id'].toString(),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Emp Name     :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 59,
                                                child: Text(
                                                    data['nm'].toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        overflow: TextOverflow
                                                            .ellipsis))),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Designation   :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 59,
                                                child: Text(
                                                    data['dsig'].toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        overflow: TextOverflow
                                                            .ellipsis))),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Department   :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 59,
                                                child: Text(
                                                    data['em_depart']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        overflow: TextOverflow
                                                            .ellipsis))),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Bank Name    :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 59,
                                                child: Text(
                                                    data['bank'].toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        overflow: TextOverflow
                                                            .ellipsis))),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('A/C Number  :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 60,
                                                child: Text(
                                                    data['acc_no'].toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        overflow: TextOverflow
                                                            .ellipsis))),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('PF Code         :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 60,
                                                child: Text(
                                                    data['pf_cd'].toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        overflow: TextOverflow
                                                            .ellipsis))),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('month/year  :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 60,
                                                child: Text('',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        overflow: TextOverflow
                                                            .ellipsis))),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Location        :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                width: 60,
                                                child: Text(
                                                    data['locca'].toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        overflow: TextOverflow
                                                            .ellipsis))),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('DOJ                :  ',
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                child: Text(
                                                    data['doj'].toString(),
                                                    style: TextStyle(
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 8.0),
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 8.0),
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      salary_eligible_days,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 8.0),
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      LOP.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Actual (Rs)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Basic',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'HRA',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Conv.All',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Medical.All',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'LTC',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'helper.All',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Cca.All',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Special.All',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Bonus',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                      child: Text(bons.toString()),
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Net Gross(Rs)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Earnings(Rs)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Basic',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 50,
                                    child: Center(
                                        child: Center(
                                      child: Text(
                                        pfamt.toString(),
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
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
                                        color: const Color.fromARGB(
                                            255,
                                            138,
                                            138,
                                            138), // You can set the color of the border
                                      ),
                                    ),
                                    height: 80,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'In words : ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12),
                                          child: Text(
                                            netSalaryInWords.toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Divider(
                              color: Colors.black,
                              thickness: 2,
                            ),
                          ],
                        ),
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
                        // Uint8List? imageBytes =
                        //     await screenshotController.capture();
                        // saveImage(imageBytes!);
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
                                        salary_eligible_days,
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
                                        pfamt.toString(),
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
                                        esi_amt.toString(),
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
                                        bons.toString(),
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
    final file = File('${directory!.path}/$name.pdf');
    await file.writeAsBytes(bytes);

    // Show notification
    await _showNotification(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(234, 243, 243, 243),
      appBar: AppBar(
        elevation: 10,
        toolbarHeight: 50,
        backgroundColor: Color.fromARGB(255, 123, 251, 247),
        shadowColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, sub_clicked);
          },
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: Row(
          children: [
            Text(
              'SALARY CALCULATION',
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
            Spacer(),
            // IconButton(
            //   onPressed: () {
            //     // +();
            //   },
            //   icon: const Icon(Icons.search),
            // )
          ],
        ),
      ),
      body: isLoading
          ? WillPopScope(
              onWillPop: () async {
                Navigator.pop(context, sub_clicked);
                return false; // Set to true if you want to allow the pop, false otherwise
              },
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        color: Colors.grey[300],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            'NAME :   ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF487B95),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF487B95),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '  ID        :   ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF487B95),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    id.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF487B95),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildFormSection(
                        title: 'Employee Information',
                        fields: [
                          _buildTextField(
                              label: 'Emp.ID',
                              initialValue: id,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Name',
                              initialValue: name.toUpperCase(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'DOJ',
                              initialValue:
                                  doj == '0000-00-00' ? 'No Data' : doj,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildFormSection(
                        title: 'Salary Details',
                        fields: [
                          _buildTextField(
                              label: 'Department',
                              initialValue: department,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Pf Number',
                              initialValue:
                                  pf_number == '' ? 'No Data' : pf_number,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Location',
                              initialValue:
                                  location == '' ? 'No Data' : location,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Adjust as needed
                        children: [
                          Text(
                            'Actual Salary ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          SizedBox(
                              width:
                                  5), // Add some spacing between the text and the TextFormField
                          Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                border:
                                    Border.all(width: 1, color: Colors.black),
                              ),
                              child: Center(
                                  child: Text(
                                act_salary.toString(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ))),
                          SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildFormSection(
                        title: 'Earning and Deduction Days',
                        fields: [
                          _buildTextField(
                              label: 'Earning Days',
                              initialValue: (entriesBelowThresholdCount +
                                      holidayLength +
                                      CL +
                                      OD +
                                      HALFDAY_CL1 +
                                      HALFDAY_OD1 +
                                      early_clkout)
                                  .toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Deduction Days',
                              initialValue:
                                  (mis_clkin + LOP + HALFDAY_LOP1).toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildFormSection(
                        title: 'Count Summary',
                        fields: [
                          _buildTextField(
                              label: 'Punched',
                              initialValue: entriesBelowThresholdCount == 0
                                  ? 'No Data'
                                  : entriesBelowThresholdCount.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Halfday Punched(0.5)',
                              initialValue: (early_clkout.toDouble())
                                  .truncate()
                                  .toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'CL',
                              initialValue: CL.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Halfday CL(0.5)',
                              initialValue: (HALFDAY_CL1.toDouble())
                                  .truncate()
                                  .toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'OD',
                              initialValue: OD.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Halfday OD(0.5)',
                              initialValue: (HALFDAY_OD1.toDouble())
                                  .truncate()
                                  .toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Holiday',
                              initialValue: holidayLength.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Mng.Late',
                              initialValue: Tot_MrngLate,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Total.Late',
                              initialValue: Tot_overall_late,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildFormSection(
                        title: 'Count Summary',
                        fields: [
                          _buildTextField(
                              label: 'Missed To ClockIn',
                              initialValue: mis_clkin.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'LOP',
                              initialValue: LOP.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Halfday LOP(0.5)',
                              initialValue: HALFDAY_LOP1.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Halfday Missed To ClockIn(0.5)',
                              initialValue: '',
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Early Clock Out',
                              initialValue: early_clkout.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Earlyby',
                              initialValue: Tot_Early_by,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Permission',
                              initialValue: '0',
                              readOnly: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildFormSection(
                        title: 'Earning Days',
                        fields: [
                          _buildTextField(
                              label: 'Punched',
                              initialValue: entriesBelowThresholdCount == 0
                                  ? 'No Data'
                                  : entriesBelowThresholdCount.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Total.CL+OD',
                              initialValue: (CL + OD).toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Holiday',
                              initialValue: holidayLength.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Total Earnings',
                              initialValue: (entriesBelowThresholdCount +
                                      holidayLength +
                                      CL +
                                      OD +
                                      HALFDAY_CL1 +
                                      HALFDAY_OD1 +
                                      early_clkout)
                                  .toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Total Days $monthName : $selectedYear',
                              initialValue: daysInMonth.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Min.Attendance.Need',
                              initialValue: min_attendance.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildFormSection(
                        title: 'Earning Days',
                        fields: [
                          _buildTextField(
                              label: 'Missed Punch & Early Clockout',
                              initialValue:
                                  (mis_clkin + early_clkout).toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Total.LOP',
                              initialValue: LOP.toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Total Deduction',
                              initialValue:
                                  (mis_clkin + LOP + HALFDAY_LOP1).toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Tally(Earnings+Deduction)',
                              initialValue: ((entriesBelowThresholdCount +
                                          holidayLength +
                                          CL +
                                          OD +
                                          HALFDAY_CL1 +
                                          HALFDAY_OD1 +
                                          early_clkout) +
                                      (mis_clkin + LOP + HALFDAY_LOP1))
                                  .toString(),
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: "Permission+Late Deduction Day's",
                              initialValue: '0',
                              readOnly: true,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: "Salary Eligibile Day's",
                              initialValue: salary_eligible_days,
                              readOnly: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation:
                            4, // Adjust the elevation for a subtle shadow effect
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Add rounded corners
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.lightBlue[100],
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _adv,
                                    decoration: InputDecoration(
                                      labelText: 'Adv.Amount',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _arr,
                                    decoration: InputDecoration(
                                      labelText: 'Arrear.Amount',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _sd,
                                    decoration: InputDecoration(
                                      labelText: 'SD Amount',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _pf,
                                    decoration: InputDecoration(
                                      labelText: 'PF.Amount',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _deddays,
                                    decoration: InputDecoration(
                                      labelText: 'Deduction days',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _ins,
                                    decoration: InputDecoration(
                                      labelText: 'Insurance.Amount',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _esi,
                                    decoration: InputDecoration(
                                      labelText: 'ESI',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _parr,
                                    decoration: InputDecoration(
                                      labelText: 'Previous Arrear.Amount',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    controller: _bonus,
                                    decoration: InputDecoration(
                                      labelText: 'Bonus Amount',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 27, 114, 148)),
                                      ),
                                    ),
                                    readOnly: true,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (slip_sts == '0')
                                ? ElevatedButton(
                                    onPressed: () {
                                      submitForm();
                                      generate_salary();
                                    },
                                    child: Text('Generate Salary'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Color.fromARGB(255, 20, 221, 30),
                                      onPrimary: Colors.white,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      hack(slipdetails['id']);
                                      deleteDepartment(
                                          slipdetails['id'].toString());
                                    },
                                    child: Text('Regenerate Salary'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Color.fromARGB(255, 255, 12, 12),
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                            SizedBox(
                              width: 10,
                            ),
                            (slip_sts == '1')
                                ? ElevatedButton(
                                    onPressed: () {
                                      _showDataTableBottomSheet(context);
                                    },
                                    child: Text('Slip'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Color.fromARGB(255, 59, 216, 20),
                                      onPrimary: Colors.white,
                                    ),
                                  )
                                : Text('')
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFormSection(
      {required String title, required List<Widget> fields}) {
    return Card(
      elevation: 4, // Adjust the elevation for a subtle shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Add rounded corners
      ),
      child: Container(
        padding: EdgeInsets.all(16), // Increase padding for spacing
        decoration: BoxDecoration(
          color: Colors.lightBlue[100], // Set a background color
          borderRadius: BorderRadius.circular(
              10), // Add rounded corners to match the Card shape
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Increase font size for emphasis
              ),
            ),
            SizedBox(
                height: 12), // Add additional spacing between title and fields
            Column(
              children: fields,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required bool readOnly,
    required TextInputType keyboardType,
  }) {
    TextEditingController controller =
        TextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 27, 114, 148)),
          ),
        ),

        controller: controller,
        readOnly: readOnly, // Make the text field read-only
        keyboardType: keyboardType,
      ),
    );
  }
}
