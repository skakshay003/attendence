// ignore_for_file: depend_on_referenced_packages, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_hack, prefer_const_constructors, prefer_const_literals_to_create_immutables, duplicate_import, sized_box_for_whitespace, unused_import, use_build_context_synchronously, prefer_interpolation_to_compose_strings
import 'dart:io';
import 'package:attendence/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../config.dart';

class ExcelDatabase extends StatefulWidget {
  @override
  _ExcelDatabaseState createState() => _ExcelDatabaseState();
}

class _ExcelDatabaseState extends State<ExcelDatabase> {
  var backendIP = ApiConstants.backendIP;
  String? filePath;

  @override
  void initState(){
    super.initState();
    fetch_excel();
  }

  Future<void> postFileToBackend(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$backendIP/Attendance_Reports/csv_databse.php',
        ),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'attendance_file', // Updated field name to match the PHP code
        filePath,
      ));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        hack('File uploaded successfully');
        setState(() {
          fetch_excel();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text(
              'File succesfully Uploaded !',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            backgroundColor: Colors.green,
          ),
        );
        hack('Server response: $responseBody');
      } else {
        hack('Error uploading file. Status code: ${response.statusCode}');
        hack('Server response: ${await response.stream.bytesToString()}');
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

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        filePath = result.files.first.path!;
      });
    }
  }

  List excel_su = [];

  Future<void> fetch_excel() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Attendance_Reports/vfetch_excel_su.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          excel_su = jsonDecode(response.body);
          hack(excel_su);
          fetchAllWorkDetails();
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

  Future<void> fetchAllWorkDetails() async {
  // Extract unique emp_ids from excel_su
  Set<String> empIds = Set.from(excel_su.map((data) => data['emp_id']));

  // Fetch work details for each emp_id
  for (String empId in empIds) {
    await fetchWorkDetails(empId);
  }
}

 Future<void> fetchWorkDetails(String empId) async {
  print(empId);

  final response = await http.post(
    Uri.parse('$backendIP/changepass.php'), // Replace with your actual API endpoint
    body: {'id': empId},
  );

  if (response.statusCode == 200) {
    final List<dynamic> workDetailsList = jsonDecode(response.body);
    print(workDetailsList);

    // Assuming workDetailsList contains multiple entries for the same emp_id
    // You might want to adapt this part based on the actual structure of your response
    for (Map<String, dynamic> workDetails in workDetailsList) {
      // Update the excel_su list with the fetched work_frm and work_to values
      for (int i = 0; i < excel_su.length; i++) {
        if (excel_su[i]['emp_id'] == empId) {
          excel_su[i]['work_frm'] = workDetails['work_frm'];
          excel_su[i]['work_to'] = workDetails['work_to'];
          excel_su[i]['depart'] = workDetails['depart'];
        }
      }
      // [{userId: MG1001, depart: emp, work_frm: , work_to: , inTime: 09:20:00, outTime: 17:20:00, clk_in: 0, clk_out: 0, clk_in_dt_tm: 2024-03-04 09:20, clk_out_dt_tm: 2024-03-04 17:20, formattedDate: 2024-03-04, reg_month: 3, reg_year: 2024, late_resn_status: 0, tot_hrs_min: 08:00:00}]
    }
    setState(() {
      print(excel_su);
      transformExcelSuList(excel_su);
    });
  } else {
    throw Exception('Failed to fetch work details');
  }
}

void transformExcelSuList(List excelSuList) {
  for (int i = 0; i < excelSuList.length; i++) {
    // Convert tot_hr format to HH:mm:ss
    String totHr = excelSuList[i]['tot_hr'];
    excelSuList[i]['tot_hrs'] = formatTotHr(totHr);
    
    // Extract month and year from the date
    String date = excelSuList[i]['date'];
    String intime = excelSuList[i]['in_time'];
    String outtime = excelSuList[i]['out_time'];
    excelSuList[i]['clk_in_dt_tm'] = date + ' ' + intime;
    excelSuList[i]['clk_out_dt_tm'] = date + ' ' + outtime;

    excelSuList[i]['clk_in'] = '0';
    excelSuList[i]['clk_out'] = '0';

    excelSuList[i]['month'] = getMonthFromDate(date);
    excelSuList[i]['year'] = getYearFromDate(date);

    excelSuList[i]['late_resn_status'] = '0';
        // Remove unwanted fields
    excelSuList[i].remove('nm');
    excelSuList[i].remove('shift');
    excelSuList[i].remove('wrk_hr');
    excelSuList[i].remove('ot');
    excelSuList[i].remove('status');
    excelSuList[i].remove('remarks');
  }
  print('excelSuList:$excelSuList');
}

String formatTotHr(String totHr) {
  // Convert tot_hr to HH:mm:ss format
  // Assuming the current format is 'H.mm'
  double totHrDouble = double.tryParse(totHr) ?? 0.0;

  int hours = totHrDouble.floor();
  int minutes = ((totHrDouble - hours) * 60).floor();

  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
}




String getMonthFromDate(String date) {
  // Extract month from the date (assuming date is in 'yyyy-MM-dd' format)
  return date.substring(5, 7);
}

String getYearFromDate(String date) {
  // Extract year from the date (assuming date is in 'yyyy-MM-dd' format)
  return date.substring(0, 4);
}

Future<void> delete_su() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Attendance_Reports/delete_excel.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }


Future<void> addAttendance(List selectedRows) async {
    try {
      hack(selectedRows);
      var apiUrl =
          Uri.parse('$backendIP/Attendance_Reports/ex_db_ins_attend.php');

      var response = await http.post(
        apiUrl,
        body: jsonEncode(selectedRows),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Handle the response data as needed
        setState(() {
          delete_su();
        });
        // Show a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Attendance added successfully')),
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 36, 195, 41),
          ),
        );
      } else {
        hack('Error occurred while adding attendance: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to add Attendance')),
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 205, 21, 21),
          ),
        );
      }
    } catch (e) {
      hack('Add attendance error: $e');
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
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: Row(
          children: [
            Text(
              'Excel to Database',
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/leave2.jpg'),
          fit: BoxFit.fill,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (filePath != null)
              Card(
                elevation: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '  Selected File  :  ',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Container(
                        width: 200, // Set the width as per your requirement
                        child: Text(
                          ' $filePath',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _pickFile,
                child: Text('Choose CSV File'),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (filePath != null) {
                    setState(() {
                      hack('Uploading file: $filePath');
                      postFileToBackend(filePath!);
                    });
                  } else {
                    hack('No file selected');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                            child: Text(
                          'No file selected , Please select CSV file !',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )),
                        backgroundColor: Colors.amber,
                      ),
                    );
                  }
                },
                child: Text('Add File'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if(excel_su.isNotEmpty)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addAttendance(excel_su);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Background color
                  onPrimary: Colors.white, // Text color
                  elevation: 3, // Button shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // Button padding
                ),
                child: Text(
                  'Start Process',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
