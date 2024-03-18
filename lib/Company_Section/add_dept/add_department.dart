// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_hack, unnecessary_cast, depend_on_referenced_packages, use_key_in_widget_constructors, use_build_context_synchronously, sized_box_for_whitespace, avoid_unnecessary_containers, unused_import

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../config.dart';

class AddDepartment extends StatefulWidget {
  const AddDepartment({Key? key}) : super(key: key);

  @override
  State<AddDepartment> createState() => _AddDepartmentState();
}

class _AddDepartmentState extends State<AddDepartment> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _departmnt = TextEditingController();
  String department = '';
  bool isLoading = false;

  List<Map<String, dynamic>> departmentData = [];

  Future<void> sub() async {
    if (department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Please Add Department!')),
          backgroundColor: Colors.yellow.shade600,
        ),
      );
    } else {
      hack(department);
      if (department.isNotEmpty) {
        try {
          var apiUrl = Uri.parse('$backendIP/Department/add_department.php');

          var response = await http.post(apiUrl, body: {
            'ad_depart': department.toUpperCase(),
          });

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data == "Department already exists!") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(child: Text(data)),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                      child: Text('Department Successfully added !',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  backgroundColor: Colors.green,
                ),
              );
              await subview();
              // Clear the department variable after a successful submission
              setState(() {
                department = '';
              });
            }
          } else {
            hack('Error occurred during registration: ${response.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Center(child: Text('Department name should not be empty')),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          hack('Insert error $e');
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
    }
  }

  Future<void> subview() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Department/view_department.php');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          departmentData = List<Map<String, dynamic>>.from(data);
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

  Future<void> deleteDepartment(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete this department?',
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
      var apiUrl = Uri.parse('$backendIP/Department/delete_department.php');
      var response = await http.post(apiUrl, body: {
        'id': id.toString(),
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Department deleted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Department deleted successfully',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.green,
            ),
          );
          await subview();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Failed to delete department')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        hack('Error occurred during department deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to delete department')),
            backgroundColor: Colors.yellow.shade600,
          ),
        );
      }
    } catch (e) {
      hack('Delete error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    subview();
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
            'Add Department',
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
        body: isLoading
            ? SingleChildScrollView(
                child: Center(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'images/post1.jpg',
                            height: 190,
                            width: MediaQuery.of(context).size.width / 2 + 150,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Add Department Name',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 40,
                            width: 250,
                            decoration: BoxDecoration(
                              color: Color(0xB5A1A1A1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              style: TextStyle(color: Colors.white),
                              controller: _departmnt,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'[\d\W]')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  department = value;
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type here ...',
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 9,
                                  horizontal: 15,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              sub();
                              _departmnt.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFFF3BB21),
                            ),
                            child: Text('Submit'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Scrollbar(
                            thickness: 7,
                            radius: Radius.circular(10),
                            child: Container(
                              height: 298,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columnSpacing: 35,
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
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Departments',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('  Delete',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                  ],
                                  rows: departmentData.map((data) {
                                    int serialNumber =
                                        departmentData.indexOf(data) + 1;
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(Center(
                                          child: Text('$serialNumber',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        )),
                                        DataCell(Center(
                                          child: Text(data['nm'].toString(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        )),
                                        DataCell(
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                deleteDepartment(
                                                    data['id'].toString());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red,
                                              ),
                                              child: Container(
                                                height: 43,
                                                width: 35,
                                                child: Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
