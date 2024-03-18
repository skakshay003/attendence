// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_hack, unnecessary_cast, depend_on_referenced_packages, use_key_in_widget_constructors, use_build_context_synchronously, sized_box_for_whitespace, non_constant_identifier_names, unused_local_variable

import 'package:attendence/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../config.dart';

class AddDepartmenthead extends StatefulWidget {
  const AddDepartmenthead({
    Key? key,
    required this.branch,
  }) : super(key: key);

  final String branch;

  @override
  State<AddDepartmenthead> createState() => _AddDepartmentheadState();
}

class _AddDepartmentheadState extends State<AddDepartmenthead> {
  var backendIP = ApiConstants.backendIP;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _empid = TextEditingController();
  final TextEditingController _dept = TextEditingController();
  final TextEditingController _des = TextEditingController();

  String name = '';
  String brnch = '';
  String Employee_id = '';
  String department = 'Select Department';
  String desig = 'Select Designation';
  String lastEmployeeCode = '';

  List departmentData = []; // Store the fetched department data here
  List departmentData123 = []; // Store the fetched department data here

  bool isLoading = false;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    // You can add more validation logic as needed
    return null;
  }

  String? validateEmpId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an employee ID';
    }
    // You can add more validation logic as needed
    return null;
  }

  Future<void> sub() async {
    if (_empid.text.isNotEmpty) {
      if (department != 'Select Department') {
        if (desig != 'Select Designation') {
          try {
            var apiUrl = Uri.parse(
                '$backendIP/Department_Head/add_departhead.php'); // Replace with your API endpoint

            // Update the Employee_id variable with the value from the _empid controller
            Employee_id = _empid.text;

            var response = await http.post(apiUrl, body: {
              'name': _name.text.toUpperCase(),
              'employee_id': _empid.text.toUpperCase(),
              'department': department.toUpperCase(),
              'desig': desig.toUpperCase(),
              'branch': brnch,
            });

            if (response.statusCode == 200) {
              var data = jsonDecode(response.body);
              if (data == "Data inserted successfully") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                        child: Center(
                            child: Text('Success!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))),
                    backgroundColor: Colors.green, // Set the background color
                  ),
                );
                setState(() {
                  department = 'Select Department';
                  desig = 'Select Designation';
                  _name.clear(); // Clear the text field
                  _empid.clear(); // Clear the text field
                  _dept.clear(); // Clear the text field
                  _des.clear(); // Clear the text field
                });
                await subview(); // Fetch the updated data
              } else {
                hack('Error occurred during registration: $data');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                        child: Text(
                      'Department already have a Head / Tl !',
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                    )),
                    backgroundColor: Colors.amber, // Set the background color
                  ),
                );
              }
            } else {
              hack('Error occurred during registration: ${response.body}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(child: Text('Failed!')),
                  backgroundColor: Colors.red, // Set the background color
                ),
              );
            }
          } catch (e) {
            hack('insert error $e');
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Designation is required',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.amber,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text('Department is required',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold))),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
  }

  Future<void> viewdepart() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Department/view_department.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          departmentData123 = jsonDecode(response.body);
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  Future<void> subview() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Department_Head/view_departhead.php'); // Replace with the URL of your PHP script
      var response = await http.post(apiUrl, body: {
        'branch': brnch,
      });

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
    }
  }

  Future<void> deleteDepartment(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to remove ?',
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
      var apiUrl = Uri.parse(
          '$backendIP/Department_Head/deletehead.php'); // Replace with your delete API endpoint
      var response = await http.post(apiUrl, body: {
        'id': id.toString(), // Pass the ID to be deleted
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
              backgroundColor: Colors.green, // Set the background color
            ),
          );
          await subview(); // Refresh the data after deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Failed to delete department')),
              backgroundColor: Colors.red, // Set the background color
            ),
          );
        }
      } else {
        hack('Error occurred during department deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to delete department')),
            backgroundColor: const Color.fromARGB(
                255, 202, 169, 19), // Set the background color
          ),
        );
      }
    } catch (e) {
      hack('Delete error: $e');
    }
  }

  Future<void> fetchEmployeeName() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Department_Head/fetchname_usingid.php');

      var response = await http.post(apiUrl, body: {
        'employee_id': _empid.text,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes

        if (data.isNotEmpty) {
          // Assuming 'name' is an attribute in your JSON response
          var employeeName = data[
              'nm']; // Change 'nm' to the actual attribute name in your response

          if (employeeName != null) {
            setState(() {
              _name.text = employeeName;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text('Employee ID found',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          hack('Employeee id not found');
        }
      } else {
        hack('Error occurred while fetching employee name: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _name.text = '';
      });
      hack('Fetch error: $e');
    }
  }

  // Future<void> fetchLastEmployeeName() async {
  //   var apiUrl = Uri.parse(
  //       '$backendIP/Department_Head/last_empid.php');
  //   var response = await http.get(apiUrl);

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final lastEmployeeCode = data['lastEmployeeCode'];

  //     if (lastEmployeeCode != null && lastEmployeeCode.isNotEmpty) {
  //       // Increment the last employee code by 1
  //       final currentId = int.parse(
  //           lastEmployeeCode.substring(2)); // Extract the numeric part
  //       final newId = 'MT${currentId + 1}';

  //       setState(() {
  //         _empid.text = newId; // Set the incremented value in the text field
  //       });
  //     } else {
  //       hack('Last employee code is empty or invalid');
  //     }
  //   } else {
  //     // Handle the case where the API request fails
  //     hack('Failed to fetch last employee code');
  //   }
  // }

  List branchname = [];

  @override
  void initState() {
    super.initState();
    brnch = widget.branch;
    viewbranch();
    hack(brnch);

    // fetchLastEmployeeCode();
  }

  Future<void> viewbranch() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Registration/vfetch_branch.php');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          branchname = jsonDecode(response.body);
          hack(branchname);
          if (brnch == 'All-Branch') {
            Future.delayed(Duration.zero, () {
              branchpopup(context);
            });
          } else {
            subview(); // Fetch data when the widget initializes
            viewdepart();
          }
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

  String selectedBranch = 'Select branch';

  void branchpopup(BuildContext context) {
    hack('branchname');
    hack(branchname);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            height: 200,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Center(
                    child: Text(
                      'Select branch',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton<String>(
                      value: selectedBranch,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedBranch = newValue;
                            Navigator.pop(context);
                            if (selectedBranch.isNotEmpty) {
                              brnch = selectedBranch.toString();
                              hack(brnch);
                              subview(); // Fetch data when the widget initializes
                              viewdepart();
                            } else {
                              Center(child: CircularProgressIndicator());
                            }
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Select branch', // Set the initial value
                          child: Container(
                            width: 150,
                            child: Text(
                              'Select branch',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        for (int index = 0; index < branchname.length; index++)
                          DropdownMenuItem<String>(
                            value: branchname[index]['branch_name'],
                            child: Container(
                              width: 150,
                              child: Text(
                                branchname[index]['branch_name'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                      underline: Container(),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          hack(selectedBranch);
                          Navigator.pop(context);
                        },
                        child: Text('Ok'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
            icon: Icon(Icons.arrow_back_ios_new_sharp),
          ),
          title: Text(
            'Add Department Head',
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
        body: isLoading
            ? Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        'images/post2.jfif',
                        height: MediaQuery.of(context).size.height / 3.5,
                        width: MediaQuery.of(context).size.width / 2 + 150,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Add Department Head ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 140),
                        child: Text(
                          'Department',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(181, 161, 161, 161),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            value: department,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  department = newValue;
                                });
                              }
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: 'Select Department',
                                child: Text('Select Department'),
                              ),
                              for (int index = 0;
                                  index < departmentData123.length;
                                  index++)
                                DropdownMenuItem<String>(
                                  value: departmentData123[index]['nm'],
                                  child: Text(departmentData123[index]['nm']),
                                ),
                            ],
                            icon: Container(
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.arrow_drop_down,
                                      color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 140),
                        child: Text(
                          'Designation',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(181, 161, 161, 161),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            value: desig,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  desig = newValue;
                                });
                              }
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: 'Select Designation',
                                child: Text('Select Designation'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Head',
                                child: Text('Head'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'TL',
                                child: Text('TL'),
                              ),
                            ],
                            // Add this line to move the dropdown icon to the right
                            icon: Container(
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.arrow_drop_down,
                                      color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 130),
                        child: Text(
                          'Employee Id',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(181, 161, 161, 161),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          controller: _empid,
                          onChanged: (value) {
                            setState(() {
                              fetchEmployeeName();
                            });
                          },
                          validator:
                              validateEmpId, // Add the validator function
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
                      Padding(
                        padding: const EdgeInsets.only(right: 180),
                        child: Text(
                          'Name',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(181, 161, 161, 161),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          controller: _name,
                          onChanged: (value) {
                            setState(() {
                              name = value;
                            });
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                          ],
                              
                          validator: validateName, // Add the validator function
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
                          if (_empid.text.isEmpty) {
                            // Show a Snackbar if Employee ID is empty
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Center(
                                    child: Text(
                                  'Employee ID is required',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )),
                                backgroundColor: Colors.amber,
                              ),
                            );
                            return; // Exit the function if Employee ID is empty
                          } else {
                            sub(); // Submit the form
                            viewdepart();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 243, 187, 33),
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
                          height: 400,
                          child: SingleChildScrollView(
                            child: Scrollbar(
                              thickness: 7,
                              radius: Radius.circular(10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing:
                                      35, // Adjust the spacing between columns as needed
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
                                      label: Text('Name',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Emp_id',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Dept',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Desig',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Delete',
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
                                                    fontWeight:
                                                        FontWeight.bold)))),
                                        DataCell(Center(
                                            child: Text(data['name'].toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)))),
                                        DataCell(Center(
                                            child: Text(
                                                data['emp_id'].toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)))),
                                        DataCell(Center(
                                            child: Text(data['dept'].toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)))),
                                        DataCell(Center(
                                            child: Text(
                                                data['desig'].toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)))),
                                        DataCell(
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                deleteDepartment(data['id']
                                                    .toString()); // Call the delete function
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors
                                                    .red, // Customize the delete button's color
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
            : Center(child: CircularProgressIndicator()));
  }
}
