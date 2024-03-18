// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_hack, unnecessary_cast, depend_on_referenced_packages, use_key_in_widget_constructors, use_build_context_synchronously, sized_box_for_whitespace, non_constant_identifier_names, unused_local_variable, camel_case_types, avoid_unnecessary_containers

import 'package:attendence/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin_login.dart';
import '../../config.dart';
import 'package:flutter/services.dart';

class Add_branch extends StatefulWidget {
  const Add_branch({Key? key, required this.loginuser}) : super(key: key);

  final String loginuser;

  @override
  State<Add_branch> createState() => _Add_branchState();
}

class _Add_branchState extends State<Add_branch> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _offc = TextEditingController();
  final TextEditingController _brnch = TextEditingController();
  final TextEditingController _addr = TextEditingController();
  final TextEditingController _adcode = TextEditingController();
  final TextEditingController _empcode = TextEditingController();
  final TextEditingController _traicode = TextEditingController();
  final TextEditingController _offcnum = TextEditingController();

  String office = '';
  String branch = '';
  String address = '';
  String adminid = '';
  String employeeid = '';
  String traineeid = '';
  String loginuser = '';
  String office_num = '';
  bool isLoading = false;
  String sub_clicked = '';

  List departmentData = []; // Store the fetched department data here

  @override
  void initState() {
    super.initState();
    loginuser = widget.loginuser;
    setState(() {
      hack(loginuser);
      // Moved getUserdata call here, so it only happens when loginuser is available
      subview(); // Fetch data when the widget initializes
      fetchOfficeData();
    });
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('session_user');
    if (session1_user != null) {
      setState(() {
        loginuser = session1_user;
        hack(loginuser);
        // Moved getUserdata call here, so it only happens when loginuser is available
        subview(); // Fetch data when the widget initializes
        fetchOfficeData();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  Future<bool> checkExistingIDs(
      String adminID, String employeeID, String traineeID) async {
    try {
      var apiUrl = Uri.parse('$backendIP/branch/check_existing_id.php');

      var response = await http.post(apiUrl, body: {
        'admin_id': adminID.toUpperCase(),
        'employee_id': employeeID.toUpperCase(),
        'trainee_id': traineeID.toUpperCase(),
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Assuming your server responds with a JSON object containing 'exists' field
        return data['exists'];
      } else {
        // Handle non-200 status codes
        hack(
            'Error occurred while checking existing IDs: ${response.statusCode}');
        return false; // Assuming an error means the IDs do not exist
      }
    } catch (e) {
      hack('Check existing IDs error: $e');
      return false; // Assuming an error means the IDs do not exist
    }
  }

  Future<void> sub() async {
    if (office.isNotEmpty) {
      if (branch.isNotEmpty) {
        if (address.isNotEmpty) {
          if (adminid.isNotEmpty) {
            if (traineeid.isNotEmpty) {
              if (employeeid.isNotEmpty) {
                if (office_num.length == 10) {
                  if (adminid != traineeid &&
                      adminid != employeeid &&
                      employeeid != adminid &&
                      employeeid != traineeid &&
                      traineeid != adminid &&
                      traineeid != employeeid) {
                    try {
                      // Check if the admin, employee, and trainee IDs already exist
                      bool exist = await checkExistingIDs(
                          adminid, employeeid, traineeid);

                      if (exist) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Center(child: Text('Id already exists!')),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // IDs are unique, proceed with inserting the data
                        var apiUrl =
                            Uri.parse('$backendIP/branch/add_branch.php');

                        var response = await http.post(apiUrl, body: {
                          'office_name': office.toUpperCase(),
                          'branch_name': branch.toUpperCase(),
                          'address': address.toUpperCase(),
                          'admin_id': adminid.toUpperCase(),
                          'employee_id': employeeid.toUpperCase(),
                          'trainee_id': traineeid.toUpperCase(),
                          'offc_number': office_num
                        });

                        if (response.statusCode == 200) {
                          var data = jsonDecode(response.body);

                          if (data is Map<String, dynamic> &&
                              data.containsKey('message')) {
                            if (data['message'] ==
                                'Office name already exists') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                      child:
                                          Text('Office name already exists!')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else if (data['message'] ==
                                'Data inserted successfully') {
                              hack(office);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                      child: Text('Branch Successfully added !',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              setState(() {
                                subview();
                                office = '';
                                branch = '';
                                address = '';
                                adminid = '';
                                employeeid = '';
                                traineeid = '';
                                office_num = '';
                                _adcode.clear();
                                _addr.clear();
                                _brnch.clear();
                                _empcode.clear();
                                _offc.clear();
                                _offcnum.clear();
                                _traicode.clear();
                                setState(() {
                                  sub_clicked = '1';
                                });
                              }); // Fetch the updated data
                            } else if (data['message'] ==
                                'Branch name already exists') {
                              // Handle other cases here
                              hack('hi');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                      child: Text('Branch name already exists!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            // Handle an unexpected response format
                            hack('Error: Unexpected response format');
                          }
                        } else {
                          // Handle non-200 status codes
                          hack(
                              'Error occurred during registration. Status code: ${response.statusCode}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child: Text('Failed!')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
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
                            child: Text(
                          'Enter unique IDs to add Branch !',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )),
                        backgroundColor: Colors.amber,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Center(child: Text('Please enter valid 10 digit Office Number !')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(child: Text('Please enter Employee Id !')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(child: Text('Please enter Trainee Id !')),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text('Please enter Admin Id !')),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Please enter location !')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Please enter branch name !')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Please eneter office name !')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchOfficeData() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/branch/fetch_office_name.php'); // Replace with the URL of your PHP script to fetch office data
      var response = await http.post(apiUrl, body: {
        'office_name': office,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _brnch.text = data['branch_name'];
            _addr.text = data['addr'];
            _adcode.text = data['admin_code'];
            _empcode.text = data['employee_code'];
            _traicode.text = data['trainee_code'];
          });
        } else {
          // Handle the case where no data was found for the entered "Office Name"
        }
      } else {
        // Handle non-200 status codes
        hack(
            'Error occurred while fetching office data: ${response.statusCode}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  String oldbranch = '';
  String newbranch = '';

  Future<void> showEditDialog(
      BuildContext context, Map<String, dynamic> data) async {
    TextEditingController branchController =
        TextEditingController(text: data['branch_name']);
    TextEditingController addressController =
        TextEditingController(text: data['addr']);
    TextEditingController adminIdController =
        TextEditingController(text: data['admin_code']);
    TextEditingController employeeIdController =
        TextEditingController(text: data['employee_code']);
    TextEditingController traineeIdController =
        TextEditingController(text: data['trainee_code']);
    TextEditingController offcnumController =
        TextEditingController(text: data['office_number']);

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Branch Details'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: branchController,
                    decoration: InputDecoration(labelText: 'Branch Name'),
                    validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter branch name';
                                    }
                                    return null;
                                  },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                    ],
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                    validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter branch address';
                                    }
                                    return null;
                                  },
                  ),
                  TextFormField(
                    controller: adminIdController,
                    decoration: InputDecoration(labelText: 'Admin Id'),
                    validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Admin ID';
                                    }
                                    return null;
                                  },
                  ),
                  TextFormField(
                    controller: employeeIdController,
                    decoration: InputDecoration(labelText: 'Employee Id'),
                    validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Employee ID';
                                    }
                                    return null;
                                  },
                  ),
                  TextFormField(
                    controller: traineeIdController,
                    decoration: InputDecoration(labelText: 'Trainee Id'),
                    validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Trainee ID';
                                    }
                                    return null;
                                  },
                  ),
                  TextFormField(
                    controller: offcnumController,
                    decoration: InputDecoration(labelText: 'Office Number'),
                    validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Phone Number';
                              } else if (value.length != 10 ||
                                  !value.contains(RegExp(r'^[0-9]+$'))) {
                                return 'Please enter a valid 10-digit Phone Number';
                              }
                              return null;
                            },
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // The form is valid, you can submit the data or perform other actions
                  // For now, let's hack the mobile number
                  // hack('Mobile Number: ${numberController.text}');
                  // Update the data and call the update function
                  Map<String, dynamic> updatedData = {
                    'id': data['id'],
                    'branch_name': branchController.text,
                    'addr': addressController.text,
                    'admin_code': adminIdController.text,
                    'employee_code': employeeIdController.text,
                    'trainee_code': traineeIdController.text,
                    'offc_num': offcnumController.text,
                  };
                  oldbranch = data['branch_name'].toString();
                  newbranch = branchController.text;
                  updtbranch(oldbranch, newbranch);
                  updateBranch(updatedData);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text(
                          'Please fill the required fields !',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      backgroundColor: Color.fromARGB(255, 253, 215, 2),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updtbranch(oldbranch, newbranch) async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/branch/updt_brnch_inreg.php'); // Replace with the URL of your PHP script
      var response = await http.post(apiUrl, body: {
        'old': oldbranch,
        'new': newbranch,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          sub_clicked = '1';
        });
        hack(data);
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  Future<void> updateBranch(Map<String, dynamic> updatedData) async {
    try {
      bool exist = await checkExistingIDs(adminid, employeeid, traineeid);
      if (exist) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Center(
                    child: Text(
              'Id already exists!',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ))),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        if (updatedData['admin_code'] != updatedData['trainee_code'] &&
            updatedData['admin_code'] != updatedData['employee_code'] &&
            updatedData['employee_code'] != updatedData['admin_code'] &&
            updatedData['employee_code'] != updatedData['trainee_code'] &&
            updatedData['trainee_code'] != updatedData['admin_code'] &&
            updatedData['trainee_code'] != updatedData['employee_code']) {
          var apiUrl = Uri.parse(
              '$backendIP/branch/update_branch.php'); // Replace with your API endpoint for updating

          var response = await http.post(apiUrl, body: {
            'id': updatedData['id'].toString(),
            'branch_name': updatedData['branch_name'],
            'addr': updatedData['addr'],
            'admin_code': updatedData['admin_code'],
            'employee_code': updatedData['employee_code'],
            'trainee_code': updatedData['trainee_code'],
            'offc_num': updatedData['offc_num'],
          });

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);

            if (data is Map<String, dynamic> && data.containsKey('message')) {
              if (data['message'] == 'Data updated successfully') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text('Branch details updated successfully!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  sub_clicked = '1';
                });
                await subview(); // Refresh the data after update
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                        child: Center(
                            child: Text('Failed to update branch details'))),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              hack('Error: Unexpected response format');
            }
          } else {
            hack(
                'Error occurred during branch update. Status code: ${response.statusCode}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text('Failed to update branch details')),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text(
                'Enter unique IDs to add Branch !',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              )),
              backgroundColor: Colors.amber,
            ),
          );
        }
      }
    } catch (e) {
      hack('Update error: $e');
    }
  }

  Future<void> subview() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/branch/view_branch.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          departmentData = List<Map<String, dynamic>>.from(data);
          hack(departmentData);
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
            'Are you sure you want to delete this branch ?',
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
          '$backendIP/branch/delete_branch.php'); // Replace with your delete API endpoint
      var response = await http.post(apiUrl, body: {
        'id': id.toString(), // Pass the ID to be deleted
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Department deleted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Branch deleted successfully',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.green, // Set the background color
            ),
          );
          setState(() {
            sub_clicked = '1';
          });
          await subview(); // Refresh the data after deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Failed to delete branch')),
              backgroundColor: Colors.red, // Set the background color
            ),
          );
        }
      } else {
        hack('Error occurred during branch deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to delete branch')),
            backgroundColor: const Color.fromARGB(
                255, 202, 169, 19), // Set the background color
          ),
        );
      }
    } catch (e) {
      hack('Delete error: $e');
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
              Navigator.pop(context, sub_clicked);
            },
            icon: Icon(Icons.arrow_back_ios_new_sharp),
          ),
          title: Text(
            'Add Branch',
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
        body: isLoading
            ? WillPopScope(
                onWillPop: () async {
                  Navigator.pop(context, sub_clicked);
                  return false; // Set to true if you want to allow the pop, false otherwise
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Image.asset(
                        'images/branch.jpg',
                        height: 190,
                        width: 250,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Add branch here',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 160),
                        child: Text(
                          'Office Name',
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
                          controller: _offc,
                          onChanged: (value) {
                            setState(() {
                              office = value;
                            });
                            // Call the function to fetch data based on the entered "Office Name"
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                          ],
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
                        padding: const EdgeInsets.only(right: 150),
                        child: Text(
                          'Branch Name',
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
                          controller: _brnch,
                          onChanged: (value) {
                            setState(() {
                              branch = value;
                            });
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                          ],
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
                          'Location',
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
                          controller: _addr,
                          onChanged: (value) {
                            setState(() {
                              address = value;
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
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 120),
                        child: Text(
                          'Admin Id - Code',
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
                          controller: _adcode,
                          onChanged: (value) {
                            setState(() {
                              adminid = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Eg.MTA',
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
                        padding: const EdgeInsets.only(right: 100),
                        child: Text(
                          'Employee Id - Code',
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
                          controller: _empcode,
                          onChanged: (value) {
                            setState(() {
                              employeeid = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Eg.MTA',
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
                        padding: const EdgeInsets.only(right: 120),
                        child: Text(
                          'Trainee Id - Code',
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
                          controller: _traicode,
                          onChanged: (value) {
                            setState(() {
                              traineeid = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Eg.MTA',
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
                        padding: const EdgeInsets.only(right: 120),
                        child: Text(
                          'Office Number',
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
                          controller: _offcnum,
                          onChanged: (value) {
                            setState(() {
                              office_num = value;
                            });
                          },
                          keyboardType: TextInputType.number,
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
                          hack(departmentData);
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
                          height: 200,
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Office Name',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Branch Name',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Location',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Adm_code',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Emp_code',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Trni_code',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Office Number',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Delete',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Edit',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                  ],
                                  rows: departmentData.map((data) {
                                    int serialNumber =
                                        departmentData.indexOf(data) + 1;
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('$serialNumber')),
                                        DataCell(Text(
                                            data['office_name'].toString())),
                                        DataCell(Text(
                                            data['branch_name'].toString())),
                                        DataCell(Text(data['addr'].toString())),
                                        DataCell(Text(
                                            data['admin_code'].toString())),
                                        DataCell(Text(
                                            data['employee_code'].toString())),
                                        DataCell(Text(
                                            data['trainee_code'].toString())),
                                        DataCell(Text(
                                            data['office_number'].toString())),
                                        DataCell(
                                          ElevatedButton(
                                            onPressed: () {
                                              deleteDepartment((data['id']
                                                  .toString())); // Call the delete function
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors
                                                  .red, // Customize the delete button's color
                                            ),
                                            child: Container(
                                              height: 43,
                                              width: 35,
                                              child: Icon(Icons.delete_outline,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ElevatedButton(
                                            onPressed: () {
                                              showEditDialog(context, data);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors
                                                  .red, // Customize the delete button's color
                                            ),
                                            child: Container(
                                              height: 43,
                                              width: 35,
                                              child: Icon(
                                                  Icons.edit_note_outlined,
                                                  color: Colors.white),
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
              )
            : Center(child: CircularProgressIndicator()));
  }
}
