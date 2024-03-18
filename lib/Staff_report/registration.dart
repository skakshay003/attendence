// ignore_for_file: prefer_const_constructors, unused_element, depend_on_referenced_packages, use_key_in_widget_constructors, library_private_types_in_public_api, sized_box_for_whitespace, avoid_hack, avoid_unnecessary_containers, deprecated_member_use, sort_child_properties_last, curly_braces_in_flow_control_structures, use_build_context_synchronously, non_constant_identifier_names, unnecessary_cast, unused_local_variable, prefer_final_fields, unused_field, prefer_interpolation_to_compose_strings, unnecessary_null_comparison, unused_import, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks, use_super_parameters

import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../admin_login.dart';
import '../admin_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import '../config.dart';
import 'package:flutter/services.dart';

class RegistrationForm extends StatefulWidget {
  @override
  const RegistrationForm({Key? key, required this.usnm, required this.branch})
      : super(key: key);

  final String usnm;
  final String branch;
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController useridController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController homeNumberController = TextEditingController();
  final TextEditingController userDepartmentController =
      TextEditingController();
  final TextEditingController userDepartmentHeadController =
      TextEditingController();
  final TextEditingController userDepartmentTLController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController clController = TextEditingController();
  final TextEditingController permissionHRController = TextEditingController();
  final TextEditingController workFromController = TextEditingController();
  final TextEditingController workToController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController pfCodeController = TextEditingController();
  final TextEditingController _employee_contri =
      TextEditingController(text: '0');
  final TextEditingController _employer_contri =
      TextEditingController(text: '0');
  final TextEditingController bankbranch = TextEditingController();
  final TextEditingController ifscNumberController = TextEditingController();
  final TextEditingController pan_num = TextEditingController();
  final TextEditingController traineecontroller = TextEditingController();
  final TextEditingController teamidController = TextEditingController();
  final TextEditingController offcnumberController = TextEditingController();
  final TextEditingController passchngController = TextEditingController();
  final TextEditingController insuranceamntController = TextEditingController();
  final TextEditingController esiamountController = TextEditingController();
  final TextEditingController actiController = TextEditingController();
  final TextEditingController aadhar_num = TextEditingController();
  final TextEditingController _incrementsala = TextEditingController(text: '0');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String department = 'Select Department';
  String blood = 'Select Blood Group';
  String Location = 'Select Location';
  String selectedGender = 'male';
  String selectedPrefix = 'Mr';
  String pic = '';
  String cmp = '';
  String offnm = '';
  bool isLoading = false;
  String selheadValue = 'Select Head'; // Default value
  String seltlValue = 'Select Tl'; // Default value
  String sub_clicked = '';

  final TextEditingController _dpt = TextEditingController();
  final TextEditingController _dpthead = TextEditingController();
  final TextEditingController _id = TextEditingController();
  final TextEditingController _name = TextEditingController();

  final TextEditingController _idtl = TextEditingController();
  final TextEditingController _nametl = TextEditingController();

  Future<void> fetchEmployeeName() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Department_Head/fetchname_usingid.php');

      var response = await http.post(apiUrl, body: {
        'employee_id': _id.text,
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
                content: Text('Employee ID found'),
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

  Future<void> fetchEmployeeName2() async {
    try {
      var apiUrl =
          Uri.parse('$backendIP/Department_Head/fetchname_usingid.php');

      var response = await http.post(apiUrl, body: {
        'employee_id': _id.text,
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
              _nametl.text = employeeName;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Employee ID found'),
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
        _nametl.text = '';
      });
      hack('Fetch error: $e');
    }
  }

  void _showAddDialog(String dept) {
    final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Department Head'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _dpt,
                    decoration: InputDecoration(
                      hintText: dept,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    enabled: false,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _id,
                    decoration: InputDecoration(
                      labelText: 'User ID',
                      hintText: 'Type here . . . ',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        fetchEmployeeName();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Userid';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: '',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Close the dialog
                          _nametl.clear();
                          _idtl.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Close the dialog
                          if (_formKey2.currentState!.validate()) {
                                    // The form is valid, you can submit the data or perform other actions
                                    // For now, let's hack the mobile number
                                    // hack('Mobile Number: ${numberController.text}');
                                    if(department != 'Select Department'){
                            sub();
                          _name.clear();
                          _id.clear();
                          Navigator.of(context).pop();
                          }else{
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Center(child: Text('Select Department !',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)),
                              backgroundColor: Colors.amber,)
                            );
                          }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Center(
                                          child: Text(
                                            'Please fill the required fields !',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        backgroundColor:
                                            Color.fromARGB(255, 253, 215, 2),
                                      ),
                                    );
                                  }
                        },
                        child: Text('Add'),
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

  Future<void> sub() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Department_Head/add_departhead.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'name': _name.text,
        'employee_id': _id.text.toUpperCase(),
        'department': department,
        'desig': 'Head',
        'branch': branch,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data == "Data inserted successfully") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Success!'),
              backgroundColor: Colors.green, // Set the background color
            ),
          );
          await viewdpthead(); // Fetch the updated data
        } else {
          hack('Error occurred during registration: $data');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Employee Already a Head/Tl in a Department!',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.amber, // Set the background color
            ),
          );
        }
      } else {
        hack('Error occurred during registration: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed!'),
            backgroundColor: Colors.red, // Set the background color
          ),
        );
      }
    } catch (e) {
      hack('insert error $e');
    }
  }

  void _showAddDialog2(String dept) {
    final GlobalKey<FormState> _formKey3 = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Department TL'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _dpt,
                    decoration: InputDecoration(
                      hintText: dept,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    enabled: false,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _idtl,
                    decoration: InputDecoration(
                      labelText: 'User ID',
                      hintText: 'Type here . . . ',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        fetchEmployeeName2();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Userid';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _nametl,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: '',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Close the dialog
                          _nametl.clear();
                          _idtl.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Close the dialog
                           if (_formKey3.currentState!.validate()) {
                                    // The form is valid, you can submit the data or perform other actions
                                    // For now, let's hack the mobile number
                                    // hack('Mobile Number: ${numberController.text}');
                                    if(department != 'Select Department'){
                            subtl();
                          _name.clear();
                          _id.clear();
                          Navigator.of(context).pop();
                          }else{
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Center(child: Text('Select Department !',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)),
                              backgroundColor: Colors.amber,)
                            );
                          }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Center(
                                          child: Text(
                                            'Please fill the required fields !',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        backgroundColor:
                                            Color.fromARGB(255, 253, 215, 2),
                                      ),
                                    );
                                  }
                        },
                        child: Text('Add'),
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

  Future<void> subtl() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Department_Head/add_departhead.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'name': _nametl.text,
        'employee_id': _idtl.text.toUpperCase(),
        'department': department,
        'desig': 'TL',
        'branch': branch,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data == "Data inserted successfully") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Success!'),
              backgroundColor: Colors.green, // Set the background color
            ),
          );
          await viewdpttl(); // Fetch the updated data
        } else {
          hack('Error occurred during registration: $data');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Employee Already a Head/Tl in a Department!',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.amber, // Set the background color
            ),
          );
        }
      } else {
        hack('Error occurred during registration: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed!'),
            backgroundColor: Colors.red, // Set the background color
          ),
        );
      }
    } catch (e) {
      hack('insert error $e');
    }
  }

  Future<void> fetchtrainee() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Registration/vfetchtrainee.php'); // Replace with the URL of your PHP script
      var response = await http.post(apiUrl, body: {
        'user_id': traineecontroller.text,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        setState(() {
          traineeData = List<Map<String, dynamic>>.from(data);
          hack(traineeData);
          department = traineeData[0]['em_depart'];
          selectedDate1 = traineeData[0]['dob'];
          selectedDate2 = traineeData[0]['doj'];
          selectedGender = traineeData[0]['gender'].toString();
          nameController.text = traineeData[0]['nm'].toString();
          passController.text = traineeData[0]['pwd'];
          numberController.text = traineeData[0]['mob'];
          emailController.text = traineeData[0]['email'];
          aadhar_num.text = traineeData[0]['aadhar_num'];
          pan_num.text = traineeData[0]['pan_num'];
          selectedPrefix = (traineeData[0]['mr_mrs_ms'] == 'Mr.'
              ? 'Mr'
              : traineeData[0]['mr_mrs_ms'] == 'Mrs.'
                  ? 'Mrs'
                  : traineeData[0]['mr_mrs_ms'] == 'Ms.'
                      ? 'Ms'
                      : traineeData[0]['mr_mrs_ms'].toString());
          fatherNameController.text = traineeData[0]['fath_nm'];
          addressController.text = traineeData[0]['addr'];
          homeNumberController.text = traineeData[0]['hm_mob'];
          blood = (traineeData[0]['blood'] == '')
              ? 'Select Blood Group'
              : traineeData[0]['blood'];
          department = traineeData[0]['em_depart'];
          selheadValue = traineeData[0]['em_depart_hed'];
          seltlValue = traineeData[0]['em_depart_tl'];
          Location = (traineeData[0]['locca'] == '')
              ? 'Select Location'
              : traineeData[0]['locca'];
          designationController.text = traineeData[0]['dsig'];
          clController.text = traineeData[0]['no_of_cl'];
          salaryController.text = traineeData[0]['sala'].toString();
          bankNameController.text = traineeData[0]['bank'];
          accountNumberController.text = traineeData[0]['acc_no'].toString();
          pfCodeController.text = traineeData[0]['pf_cd'].toString();
          bankbranch.text = traineeData[0]['sd_amt'].toString();
          ifscNumberController.text = traineeData[0]['ifsc'].toString();
          teamidController.text = traineeData[0]['team_ld'].toString();
          offcnumberController.text = traineeData[0]['offc_mob'].toString();
          insuranceamntController.text = traineeData[0]['insu_amt'].toString();
          esiamountController.text = traineeData[0]['esi_amt'].toString();
          workFromController.text = traineeData[0]['work_frm'].toString();
          workToController.text = traineeData[0]['work_to'].toString();
          pic = traineeData[0]['pic'].toString();
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

  FocusNode _textField1FocusNode = FocusNode();
  FocusNode _textField2FocusNode = FocusNode();
  FocusNode _textField3FocusNode = FocusNode();
  FocusNode _textField4FocusNode = FocusNode();
  FocusNode _textField5FocusNode = FocusNode();
  FocusNode _textField6FocusNode = FocusNode();
  FocusNode _textField7FocusNode = FocusNode();
  FocusNode _textField8FocusNode = FocusNode();
  FocusNode _textField9FocusNode = FocusNode();
  FocusNode _textField10FocusNode = FocusNode();
  FocusNode _textField11FocusNode = FocusNode();
  FocusNode _textField12FocusNode = FocusNode();
  FocusNode _textField13FocusNode = FocusNode();
  FocusNode _textField14FocusNode = FocusNode();
  FocusNode _textField15FocusNode = FocusNode();
  FocusNode _textField16FocusNode = FocusNode();
  FocusNode _textField17FocusNode = FocusNode();
  FocusNode _textField18FocusNode = FocusNode();
  FocusNode _textField19FocusNode = FocusNode();
  FocusNode _textField20FocusNode = FocusNode();
  FocusNode _textField21FocusNode = FocusNode();
  FocusNode _textField22FocusNode = FocusNode();

  XFile? _image;
  String branch = '';
  String selectedDate1 = '0000-00-00';
  String selectedDate2 = '0000-00-00';

  String headDepart = '';
  String tlDepart = '';
  String formattedDate = '';
  int reg_year = 0;
  int reg_month = 0;
  String loginuser = '';
  String user = '';
  String newLastUserId = '';
  String clicked = '0';
  String teamid = '1';

  List companyname = [];
  List departmentData = [];
  List locationData = [];
  List traineeData = [];

  List branchname = [];

  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loginuser = widget.usnm;
    branch = widget.branch;
    viewbranch();
  }

  Future<void> viewbranch() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Registration/vfetch_branch.php');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          branchname = jsonDecode(response.body);
          hack(branchname);
          if (branch == 'All-Branch') {
            Future.delayed(Duration.zero, () {
              branchpopup(context);
            });
          } else {
            hack(loginuser);
            hack(branch);
            viewcompany();
            // Moved getUserdata call here, so it only happens when loginuser is available
            if (loginuser == 'ad') {
              user = 'admin';
            } else if (loginuser == 'emp') {
              user = 'employee';
            } else {
              user = 'trainee';
            }
            hack(user);
            fetchcompanycode();
            viewdepart();
            viewLocation();
            permissionHRController.text = '03:00:00';
            actiController.text = '0';
            passchngController.text = '0';
            pan_num.text = '0';
            salaryController.text = '0';
            insuranceamntController.text = '0';
            esiamountController.text = '0';
            String randomPassword = generateRandomPassword();
            passController.text = randomPassword;
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
                              branch = selectedBranch.toString();
                              hack(loginuser);
                              hack(branch);
                              viewcompany();
                              // Moved getUserdata call here, so it only happens when loginuser is available
                              if (loginuser == 'ad') {
                                user = 'admin';
                              } else if (loginuser == 'emp') {
                                user = 'employee';
                              } else {
                                user = 'trainee';
                              }
                              hack(user);
                              fetchcompanycode();
                              viewdepart();
                              viewLocation();
                              permissionHRController.text = '03:00:00';
                              actiController.text = '0';
                              passchngController.text = '0';
                              pan_num.text = '0';
                              salaryController.text = '0';
                              insuranceamntController.text = '0';
                              esiamountController.text = '0';
                              String randomPassword = generateRandomPassword();
                              passController.text = randomPassword;
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

  String generateRandomPassword({int length = 6}) {
    const String charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final random = Random();
    return List.generate(
        length, (index) => charset[random.nextInt(charset.length)]).join();
  }

  Future<void> _getImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  String selectedDate3 = '';
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // Set your desired minimum date
      lastDate: DateTime.now(), // Set your desired maximum date
    );

    if (picked != null) {
      // Calculate the minimum birth date to meet the age requirement
      final minimumBirthDate =
          DateTime.now().subtract(Duration(days: 18 * 365));

      if (picked.isBefore(minimumBirthDate)) {
        setState(() {
          selectedDate1 = "${picked.year}-${picked.month}-${picked.day}";
          selectedDate3 = DateFormat('dd-MM-yyyy').format(picked);
        });

        // Proceed with your logic here
        // For example, you can call a function to handle the next steps
        handleAgeRequirementMet();
      } else {
        // Show a snackbar indicating that the selected date doesn't meet the age requirement
        showSnack('You must be 18 years or older.');
      }
    }
  }

  void handleAgeRequirementMet() {
    // Your logic when the age requirement is met
    // For example, you can proceed with further actions or validations
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Center(
            child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        )),
        backgroundColor: Colors.amber,
      ));
    }
  }

  String selectedDate5 = '';
  String selectedDate6 = '';
  Future<void> _increment(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015), // Set your desired minimum date
      lastDate: DateTime(2050), // Set your desired maximum date
    );
    if (picked != null)
      setState(() {
        selectedDate5 = "${picked.year}-${picked.month}-${picked.day}";
        selectedDate6 = DateFormat('dd-MM-yyyy').format(picked);
      });
  }

  String selectedDate4 = '';
  Future<void> _dateofjoin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015), // Set your desired minimum date
      lastDate: DateTime(2050), // Set your desired maximum date
    );
    if (picked != null)
      setState(() {
        selectedDate2 = "${picked.year}-${picked.month}-${picked.day}";
        selectedDate4 = DateFormat('dd-MM-yyyy').format(picked);
      });
  }

  Future<void> viewdepart() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Department/view_department.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          departmentData = jsonDecode(response.body);
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  Future<void> viewLocation() async {
    try {
      var apiUrl = Uri.parse('$backendIP/location/view_location.php');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          locationData = List<Map<String, dynamic>>.from(data);
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  Future<void> viewdpthead() async {
    if (department.isNotEmpty) {
      try {
        var apiUrl = Uri.parse(
            '$backendIP/Registration/vfetchhead.php'); // Replace with your API endpoint

        var response = await http.post(apiUrl, body: {
          'department': department,
          'branch': branch,
        });

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);

          // hack the updated data
          hack(data);

          setState(() {
            if (data.isNotEmpty) {
              headDepart = data[0]['name'].toString();
              selheadValue = 'Select Head';
            } else {
              headDepart = '';
              selheadValue = 'Select Head';
            }
          });
        } else {
          hack('Error occurred during registration: ${response.body}');
        }
      } catch (e) {
        hack('insert error $e');
      }
    }
  }

  Future<void> viewdpttl() async {
    if (department.isNotEmpty) {
      try {
        var apiUrl = Uri.parse(
            '$backendIP/Registration/vfetchtl.php'); // Replace with your API endpoint

        var response = await http.post(apiUrl, body: {
          'department': department,
          'branch': branch,
        });

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);

          // hack the updated data
          hack(data);

          setState(() {
            if (data.isNotEmpty) {
              tlDepart = data[0]['name'].toString();
              seltlValue = 'Select Tl';
            } else {
              tlDepart = '';
              seltlValue = 'Select Tl';
            }
          });
        } else {
          hack('Error occurred during registration: ${response.body}');
        }
      } catch (e) {
        hack('insert error $e');
      }
    }
    // If tlDepart is empty, set the controller's text to an empty string
    // if (tlDepart.isEmpty) {
    //   setState(() {
    //     userDepartmentTLController.text = '';
    //   });
    // } else {
    //   // If tlDepart has a value, set the controller's text to that value
    //   userDepartmentTLController.text = tlDepart;
    // }
  }

  TimeOfDay parseTime(String time) {
    try {
      DateTime dateTime = DateFormat('hh:mm a').parse(time);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      hack('Error parsing time: $e');
      // Handle the error, e.g., return a default time
      return TimeOfDay(hour: 0, minute: 0);
    }
  }

  Future<void> reg() async {
    String workFrom = workFromController.text;
    String workTo = workToController.text;
    if (workFrom.isNotEmpty) {
      TimeOfDay parsedTime = parseTime(workFrom);
      String formattedTime = _formatTime(parsedTime);
      workFromController.text = formattedTime + ':00'.toString();
    }

    if (workTo.isNotEmpty) {
      TimeOfDay parsedTime = parseTime(workTo);
      String formattedTime = _formatTime2(parsedTime);
      workToController.text = formattedTime + ':00'.toString();
    }

    http.MultipartFile imageFile =
        http.MultipartFile.fromString('user_image', '');

    if (_image != null) {
      List<int> imageBytes = await File(_image!.path).readAsBytes();
      imageFile = http.MultipartFile.fromBytes(
        'user_image',
        imageBytes,
        filename: 'user_image.jpg',
      );
    } else {
      hack("Warning: _image is null, setting imageFile to empty");
    }
    hack(imageFile);
    if (department != 'Select Department') {
      if (blood != 'Select Blood Group') {
        if (Location != 'Select Location') {
          if (selectedDate2 != '0000-00-00') {
            if (selheadValue != 'Select Head') {
              if (seltlValue != 'Select Tl') {
                if (workFromController.text != '') {
                  if (workToController.text != '') {
                    try {
                      var apiUrl =
                          '$backendIP/Registration/ins_register.php'; // Replace with your API endpoint

                      var request =
                          http.MultipartRequest('POST', Uri.parse(apiUrl));

                      request.files.add(imageFile);
                      request.fields['company'] = cmp;
                      request.fields['name'] = nameController.text;
                      request.fields['userid'] = useridController.text;
                      request.fields['pass'] = passController.text;
                      request.fields['mobile'] = numberController.text;
                      request.fields['email'] = emailController.text;
                      request.fields['fathername'] = fatherNameController.text;
                      request.fields['address'] = addressController.text;
                      request.fields['homenumber'] = homeNumberController.text;
                      request.fields['dob'] = selectedDate1;
                      request.fields['bloodgroup'] = blood;
                      request.fields['userdepart'] = department;
                      request.fields['userdpthd'] = selheadValue;
                      request.fields['location'] = Location;
                      request.fields['designation'] =
                          designationController.text;
                      request.fields['clerk'] = clController.text;
                      request.fields['per_hr'] = permissionHRController.text;
                      request.fields['work_from'] = workFromController.text;
                      request.fields['work_to'] = workToController.text;
                      request.fields['salary'] = salaryController.text;
                      request.fields['doj'] = selectedDate2;
                      request.fields['bank_name'] = bankNameController.text;
                      request.fields['acc_number'] =
                          accountNumberController.text;
                      request.fields['pf_code'] = pfCodeController.text;
                      request.fields['pf_amount'] = '0';
                      request.fields['bank_branch'] = bankbranch.text;
                      request.fields['ifsc'] = ifscNumberController.text;
                      request.fields['pan_num'] = pan_num.text;
                      request.fields['depart'] = loginuser;
                      request.fields['offcnumber'] = offcnumberController.text;
                      request.fields['pass_chng'] = passchngController.text;
                      request.fields['ins_amnt'] = insuranceamntController.text;
                      request.fields['esi_amnt'] = esiamountController.text;
                      request.fields['reg_date'] = formattedDate;
                      request.fields['month'] = reg_month.toString();
                      request.fields['year'] = reg_year.toString();
                      request.fields['team_ld'] = teamid;
                      request.fields['userdpttl'] = seltlValue;
                      request.fields['acti'] = actiController.text;
                      request.fields['branchnm'] = branch;
                      request.fields['aadhar_num'] = aadhar_num.text;
                      request.fields['gender'] = selectedGender;
                      request.fields['mr_ms_mrs'] = selectedPrefix;
                      request.fields['employee_contri'] = _employee_contri.text;
                      request.fields['employer_contri'] = _employer_contri.text;

                      final response = await request.send();
                      if (response.statusCode == 200) {
                        // var data = jsonDecode(response.body);
                        //response; if needed
                        final responseData = await response.stream.toBytes();
                        final responseString =
                            String.fromCharCodes(responseData);
                        hack('Response: $responseString');
                        // hack the updated data
                        hack(response);
                        if (responseString.trim() ==
                            'Data inserted successfully') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text(
                                  'Registered Successfully',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromRGBO(0, 0, 0, 1)),
                                ),
                              ),
                              backgroundColor:
                                  Color.fromARGB(255, 110, 226, 42),
                            ),
                          );
                          companyNameController.clear();
                          nameController.clear();
                          useridController.clear();
                          passController.clear();
                          numberController.clear();
                          emailController.clear();
                          fatherNameController.clear();
                          addressController.clear();
                          homeNumberController.clear();
                          userDepartmentController.clear();
                          userDepartmentHeadController.clear();
                          userDepartmentTLController.clear();
                          designationController.clear();
                          clController.clear();
                          bankNameController.clear();
                          accountNumberController.clear();
                          pfCodeController.clear();
                          bankbranch.clear();
                          ifscNumberController.clear();
                          traineecontroller.clear();
                          teamidController.clear();
                          setState(() {
                            String randomPassword = generateRandomPassword();
                            passController.text = randomPassword;
                            blood = 'Select Blood Group';
                            Location = 'Select Location';
                            department = 'Select Department';
                            fetchcompanycode();
                            sub_clicked = '1';
                          });
                        } else if (responseString.trim() ==
                            'UserId already Registered') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text('UserId Already Registered !',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                              backgroundColor: Color.fromARGB(255, 247, 41, 41),
                            ),
                          );
                        } else if (responseString.trim() ==
                            'Mobile number already exists') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Center(
                              child: Text(
                                'Mobile number already exists !',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            backgroundColor: Colors.amber,
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text('Registration Failed !',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                              backgroundColor: Color.fromARGB(255, 247, 41, 41),
                            ),
                          );
                        }
                      } else {
                        hack('Error occurred during registration:');
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
                          child: Text('Please Select work to Time !',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                        backgroundColor: Colors.amber,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text('Please Select work from Time !',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                      backgroundColor: Colors.amber,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text('Department Tl is not Selected !',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                    backgroundColor: Color.fromARGB(255, 250, 235, 30),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('Department Head is not Selected !',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  backgroundColor: Color.fromARGB(255, 250, 235, 30),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text('Join Date is not Selected !',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                backgroundColor: Color.fromARGB(255, 250, 235, 30),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text('Please select location !',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              backgroundColor: Color.fromARGB(255, 247, 209, 41),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text('Please select blood group !',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            backgroundColor: Color.fromARGB(255, 247, 209, 41),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Please select user Department !',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          backgroundColor: Color.fromARGB(255, 247, 209, 41),
        ),
      );
    }
  }

  List<Map<String, dynamic>> userid = [];

  Future<void> fetchcompanycode() async {
    var apiUrl = Uri.parse('$backendIP/Registration/vfetchcompanycode.php');

    var response = await http.post(apiUrl, body: {
      'user': loginuser,
      'branch': branch,
    });

    if (response.statusCode == 200) {
      try {
        final dynamic data = json.decode(response.body);

        if (data is Map) {
          // Handle the case where data is a map
          setState(() {
            userid = [data.cast<String, dynamic>()];
            hack(userid);
            fetchLastUserId();
          });
        } else {
          hack("Invalid data format: $data");
        }
      } catch (e) {
        hack("Error decoding response: $e");
      }
    }
  }

  Future<void> fetchLastUserId() async {
    var apiUrl = Uri.parse('$backendIP/Registration/vfetchlastid.php');

    var response = await http.post(apiUrl, body: {
      'user': loginuser,
      'branch': branch,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      hack(data);
      String lastUserId = data['lastuserid'].toString();
      hack(lastUserId);

      // Extract the last 4 digits
      String last4Digits = lastUserId.substring(lastUserId.length - 4);

      // Handle the case where last4Digits is null or empty
      if (last4Digits == null || last4Digits.isEmpty) {
        last4Digits = '0000';
      }

      // Convert the last 4 digits to an integer
      int last4DigitsInt;

      try {
        last4DigitsInt = int.parse(last4Digits);
      } catch (e) {
        hack('Error parsing last4Digits: $e');
        // Handle the case where parsing fails, set a default value, or show an error message
        last4DigitsInt = 1000; // Replace with your desired default value
      }

      // Increment the last 4 digits by 1
      int newLast4DigitsInt = last4DigitsInt + 1;

      // Convert the new last 4 digits back to a string
      String newLast4DigitsString =
          newLast4DigitsInt.toString().padLeft(4, '0');

      hack(newLast4DigitsString);

      // Combine the userid and newLast4DigitsString
      String loginCode = "${user}_code";
      String combinedUserId;

      if (userid.isNotEmpty) {
        combinedUserId = "${userid[0][loginCode]}$newLast4DigitsString";
      } else {
        hack('Error: userid is empty');
        // Handle the case when userid is empty, e.g., set a default value or show an error message
        combinedUserId = 'error'; // Replace with your desired default value
      }
      setState(() {
        hack(combinedUserId);
        useridController.text = combinedUserId;
        isLoading = true;
      });

      // Now you can use combinedUserId as needed in your application
    } else {
      hack('Failed to fetch last user id');
    }
  }

  void submitForm() {
    // Get the current date
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    hack(formattedDate);

    // Split the formatted date string
    List<String> dateParts = formattedDate.split('-');
    int extractedYear = int.parse(dateParts[0]);
    int extractedMonth = int.parse(dateParts[1]);

    reg_month = extractedMonth;
    reg_year = extractedYear;
    hack(reg_month);
    hack(reg_year);
  }

  String _formatTime(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  String _formatTime3(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    // Determine if it's AM or PM
    String period = (hour < 12) ? 'AM' : 'PM';

    // Convert to 12-hour format
    hour = hour % 12;
    hour = (hour == 0) ? 12 : hour;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return formattedTime;
  }

  String _formatTime4(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    // Determine if it's AM or PM
    String period = (hour < 12) ? 'AM' : 'PM';

    // Convert to 12-hour format
    hour = hour % 12;
    hour = (hour == 0) ? 12 : hour;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return formattedTime;
  }

  String _formatTime2(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  int hourOf12HourFormat(int hour) {
    // Convert hour to 12-hour format
    return hour > 12 ? hour - 12 : hour;
  }

  List company_name = []; // Declare company_name as List<dynamic>

  Future<void> viewcompany() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Registration/vfetch_companyname.php');
      var response = await http.post(apiUrl, body: {
        'branch': branch,
      });

      if (response.statusCode == 200) {
        setState(() {
          company_name = jsonDecode(response.body);
          hack(company_name);
          cmp = company_name[0]["office_name"];
          offnm = company_name[0]["office_number"];
          offcnumberController.text = offnm.toString();
          // locationController.text = company_name[0]["addr"];
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  int salary = 0;
  int Conv_all = 0;
  double result = 0.0;
  double for_med = 0.0;
  double basic = 0.0;
  double HRA = 0.0;
  double medical_all = 0.0;

  Future<void> cal_salary_inc() async {
    setState(() {
      hack('salary:$salary');
      basic = salary * 55 / 100;

      hack('basic:$basic');
      HRA = basic * 40 / 100;
      hack('HRA:$HRA');
      if (salary >= 10000) {
        Conv_all = 1600;
        hack('Conv_all:$Conv_all');
      } else {
        Conv_all = 800;
        hack('Conv_all:$Conv_all');
      }
      //medical
      for_med = basic + HRA + Conv_all;
      hack('for_med:$for_med');
      result = salary - for_med;
      hack('result:$result');
      medical_all = result / 2;
      hack('medical_all:$medical_all');
    });
  }

  Future<void> inssalary_increment() async {
    if (selectedDate5 != '') {
      if (_incrementsala.text != '') {
        try {
          print('increment');
          var apiUrl = Uri.parse('$backendIP/Registration/sala_inc.php');
          var response = await http.post(apiUrl, body: {
            'user_id': useridController.text,
            'salary': salary.toString(),
            'basic': basic.toString(),
            'hr': HRA.toString(),
            'conv_all': Conv_all.toString(),
            'medical_all': medical_all.toString(),
            'spl_all': medical_all.toString(),
            'incre_dt': selectedDate5.toString(),
            'sal_last': _incrementsala.text,
            'position': designationController.text,
          });

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            print(data);
            if (data['message'] == 'Data inserted successfully') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('Increment Added Successfully !',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (data['message'] ==
                'Record with the same incre_dt already exists') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('Already Added !',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  backgroundColor: Colors.amber,
                ),
              );
            }
          } else {
            hack('Error occurred while fetching data: ${response.body}');
          }
        } catch (e) {
          hack('Fetch error: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text('Please enter Salary !',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            backgroundColor: Colors.amber,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Please select Increment Date !',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          backgroundColor: Colors.amber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
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
            user.toUpperCase() + ' REGISTRATION FORM',
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text('Company Name',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Spacer(),
                              Container(
                                width: 150,
                                child: Text(
                                  cmp,
                                  style: TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                'Branch Name',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Spacer(),
                              Container(
                                width: 150,
                                child: Text(
                                  branch,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          SizedBox(height: 16),
                          Text('User Profile',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Choose File',
                                style: TextStyle(fontSize: 16),
                              ),

                              SizedBox(
                                  width:
                                      10), // Add some spacing between the button and the image
                              (clicked == '0')
                                  ? _image != null
                                      ? Container(
                                          height: 80,
                                          width:
                                              70, // Adjust the height as needed
                                          child: Image(
                                              image:
                                                  FileImage(File(_image!.path))
                                                      as ImageProvider<Object>),
                                        )
                                      : Text('No image selected.',
                                          style: TextStyle(color: Colors.red))
                                  : Card(
                                      child: Container(
                                        height: 80,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          image: (traineeData.isNotEmpty &&
                                                  traineeData[0]['pic'] != null)
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    '$backendIP/Registration/uploads/' +
                                                        traineeData[0]['pic']
                                                            .toString(),
                                                  ),
                                                  fit: BoxFit
                                                      .cover, // Adjust as needed
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),

                              SizedBox(width: 10),
                              FloatingActionButton(
                                onPressed: _getImage,
                                tooltip: 'Pick Image',
                                child: Icon(Icons.add_a_photo_outlined),
                              ),
                            ],
                          ),
                          if (loginuser != 'trainee') SizedBox(height: 16),
                          if (loginuser != 'trainee')
                            Text('Trainee ID(Fetch Trainee Details) :',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          if (loginuser != 'trainee') SizedBox(height: 10),
                          if (loginuser != 'trainee')
                            Row(
                              children: [
                                Container(
                                  height: 60,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: 'Trainee Id',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors
                                                .black), // Set the border color to black
                                        borderRadius: BorderRadius.circular(
                                            12), // Match the border radius
                                      ),
                                    ),
                                    controller: traineecontroller,
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  height: 40,
                                  width: 89,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        clicked = '1';
                                        fetchtrainee();
                                      });
                                      hack(clicked);
                                    },
                                    child: Text(
                                      'Fetch',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: Color.fromARGB(255, 101, 230,
                                          51), // Set the background color to yellow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Customize the border radius as needed
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Name',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                height: 64,
                                width:
                                    80, // Adjust the width according to your needs
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          const Color.fromARGB(139, 0, 0, 0)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: DropdownButtonFormField<String>(
                                      value: selectedPrefix,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedPrefix = newValue!;
                                          hack(selectedPrefix);
                                        });
                                      },
                                      items: <String>['Mr', 'Ms', 'Mrs']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add some spacing between the dropdown and the text field
                              Expanded(
                                child: TextFormField(
                                  controller: nameController,
                                  focusNode: _textField1FocusNode,
                                  enabled: true,
                                  onFieldSubmitted: (value) {
                                    _textField1FocusNode.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_textField4FocusNode);
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'[\d\W]')),
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter name';
                                    }
                                    if (value.length < 3) {
                                      return 'Name must be at least 3 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Employee Id',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          TextFormField(
                            controller: useridController,
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter id';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Gender',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    value: 'male',
                                    groupValue:
                                        selectedGender, // Assuming you have a variable to hold the selected value
                                    onChanged: (value) {
                                      // Handle radio button selection
                                      setState(() {
                                        selectedGender = value!;
                                        hack(selectedGender);
                                      });
                                    },
                                  ),
                                  Text('Male'),
                                  Radio(
                                    value: 'female',
                                    groupValue: selectedGender,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value!;
                                        hack(selectedGender);
                                      });
                                    },
                                  ),
                                  Text('Female'),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Password',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          TextFormField(
                            controller: passController,
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length < 3) {
                                return 'Name must be at least 6 characters'; // Validation message for invalid input
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Mobile Number',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          TextFormField(
                            controller: numberController,
                            focusNode: _textField4FocusNode,
                            enabled: true,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField5FocusNode);
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Phone Number';
                              } else if (value.length != 10 ||
                                  !value.contains(RegExp(r'^[0-9]+$'))) {
                                return 'Please enter a valid 10-digit Phone Number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          Text('Email',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: emailController,
                            focusNode: _textField5FocusNode,
                            enabled: true,
                            validator: (value) {
                              // Check if the entered email is valid
                              if (value!.isEmpty) {
                                return 'Please enter your email address';
                              }
                              final emailRegex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null; // Return null if the entered email is valid
                            },
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField6FocusNode);
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),
                          Text('FatherName / Spouse Name',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: fatherNameController,
                            focusNode: _textField6FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField7FocusNode);
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[\d\W]')),
                            ],

                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Address',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: addressController,
                            focusNode: _textField7FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField8FocusNode);
                            },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Emergency Number',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: homeNumberController,
                            focusNode: _textField8FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField9FocusNode);
                            },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Text('Date of Birth',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 10),
                              Text(
                                selectedDate3,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: Text(
                                  'Select date',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(172, 120, 255, 244),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Blood Group',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            value: blood,
                            onChanged: (newValue) {
                              setState(() {
                                blood = newValue!;
                              });
                            },
                            items: [
                              DropdownMenuItem(
                                  child: Text('Select Blood Group'),
                                  value: 'Select Blood Group'),
                              DropdownMenuItem(child: Text('A+'), value: 'A+'),
                              DropdownMenuItem(child: Text('A-'), value: 'A-'),
                              DropdownMenuItem(child: Text('B+'), value: 'B+'),
                              DropdownMenuItem(child: Text('B-'), value: 'B-'),
                              DropdownMenuItem(child: Text('O+'), value: 'O+'),
                              DropdownMenuItem(child: Text('O-'), value: 'O-'),
                              DropdownMenuItem(
                                  child: Text('AB+'), value: 'AB+'),
                              DropdownMenuItem(
                                  child: Text('AB-'), value: 'AB-'),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Select an option',
                              hintStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 34, 34, 34),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Employee Department',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            value: department,
                            onChanged: (newValue) {
                              setState(() {
                                department = newValue!;
                                viewdpthead();
                                viewdpttl();
                                hack(department);
                              });
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'Select Department',
                                child: Text('Select Department'),
                              ),
                              for (int index = 0;
                                  index < departmentData.length;
                                  index++)
                                DropdownMenuItem<String>(
                                  value: departmentData[index]['nm'],
                                  child: Text(
                                    departmentData[index]['nm'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Select an option',
                              hintStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 34, 34, 34),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text('Employee Department Head',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selheadValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selheadValue = newValue!;
                                    });
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: 'Select Head',
                                      child: Text('Select Head'),
                                    ),
                                    if (headDepart != '')
                                      DropdownMenuItem(
                                        value: (headDepart),
                                        child: Text(headDepart),
                                      ),
                                    DropdownMenuItem(
                                      value: 'No Department Head',
                                      child: Text('No Department Head'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Select an option',
                                    hintStyle: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 34, 34, 34),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: 64,
                                width:
                                    64, // Adjust the width according to your needs
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          const Color.fromARGB(139, 0, 0, 0)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                    child: IconButton(
                                        onPressed: () {
                                          _showAddDialog(department);
                                        },
                                        icon: Icon(Icons.add))),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Employee Department TL',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: seltlValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      seltlValue = newValue!;
                                    });
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: 'Select Tl',
                                      child: Text('Select Tl'),
                                    ),
                                    if (tlDepart != '')
                                      DropdownMenuItem(
                                        value: (tlDepart),
                                        child: Text(tlDepart),
                                      ),
                                    DropdownMenuItem(
                                      value: 'No Department TL',
                                      child: Text('No Department TL'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Select an option',
                                    hintStyle: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 34, 34, 34),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: 64,
                                width:
                                    64, // Adjust the width according to your needs
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          const Color.fromARGB(139, 0, 0, 0)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                    child: IconButton(
                                        onPressed: () {
                                          _showAddDialog2(department);
                                        },
                                        icon: Icon(Icons.add))),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text('Location',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  Text(' *',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red)),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: DropdownButton<String>(
                                  value: Location,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        Location = newValue;
                                      });
                                    }
                                  },
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: 'Select Location',
                                      child: Container(
                                        width:
                                            150, // Set the maximum width you prefer
                                        child: Text(
                                          'Select Location',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    for (int index = 0;
                                        index < locationData.length;
                                        index++)
                                      DropdownMenuItem<String>(
                                        value: locationData[index]['addr'],
                                        child: Container(
                                          width:
                                              150, // Set the maximum width you prefer
                                          child: Text(
                                            locationData[index]['addr']
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('Office Mobile Number',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: offcnumberController,
                            focusNode: _textField10FocusNode,
                            keyboardType: TextInputType.number,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField11FocusNode);
                            },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          // SizedBox(height: 16),
                          // Text('Password Change',
                          //     style:
                          //         TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          // TextFormField(
                          //   controller: passchngController,
                          //   enabled:
                          //       false, // Set enabled to false to make it non-editable
                          //   decoration: InputDecoration(
                          //     hintText: passchngController.text,
                          //     // You can optionally provide decoration to make it visually read-only
                          //     border: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //           color: Colors.black), // Customize the border color
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 16),
                          // Text('Job Location',
                          //     style: TextStyle(
                          //         fontSize: 16, fontWeight: FontWeight.w600)),
                          // TextFormField(
                          //   controller: locationController,
                          //   focusNode: _textField11FocusNode,
                          //   onFieldSubmitted: (value) {
                          //     // Move focus to the next text field when submitted
                          //     _textField1FocusNode.unfocus();
                          //     FocusScope.of(context)
                          //         .requestFocus(_textField12FocusNode);
                          //   },
                          //   enabled:
                          //       true, // Set enabled to false to make it non-editable
                          //   decoration: InputDecoration(
                          //     // You can optionally provide decoration to make it visually read-only
                          //     border: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //           color: Colors
                          //               .black), // Customize the border color
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: 16),
                          Text('Designation',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: designationController,
                            focusNode: _textField12FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField13FocusNode);
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[\d\W]')),
                            ],

                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('No.of CL',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: clController,
                            focusNode: _textField13FocusNode,
                            keyboardType: TextInputType.number,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField14FocusNode);
                            },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Permission HR',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: permissionHRController,
                            enabled:
                                false, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              hintText: permissionHRController.text,
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Work From',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              // Set initial time to 9:20
                              TimeOfDay initialTime =
                                  TimeOfDay(hour: 9, minute: 20);

                              // Show time picker and wait for user input
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                                builder: (BuildContext context, Widget? child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: false),
                                    child: child!,
                                  );
                                },
                              );

                              // Update the controller with the selected time
                              if (pickedTime != null) {
                                String formattedTime = _formatTime3(pickedTime);
                                workFromController.text = formattedTime;
                              }
                            },
                            child: TextFormField(
                              controller:
                                  workFromController, // Use the existing controller
                              enabled: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {},
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Work To',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(' *',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              // Set initial time to 9:20
                              TimeOfDay initialTime =
                                  TimeOfDay(hour: 17, minute: 20);
                              // Show time picker and wait for user input
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                                builder: (BuildContext context, Widget? child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: false),
                                    child: child!,
                                  );
                                },
                              );

                              // Update the controller with the selected time
                              if (pickedTime != null) {
                                String formattedTime = _formatTime4(pickedTime);
                                workToController.text = formattedTime;
                              }
                            },
                            child: TextFormField(
                              controller:
                                  workToController, // Use the existing controller
                              enabled: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    // Your onPressed logic here
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Row(
                                children: [
                                  Text('Date of joining',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  Text(' *',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red)),
                                ],
                              ),
                              SizedBox(width: 7),
                              Text(
                                selectedDate4,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _dateofjoin(context),
                                child: Text(
                                  'Select date',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(172, 120, 255, 244),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('Pan Number',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: pan_num,
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Aadhar Number',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: aadhar_num,
                            keyboardType: TextInputType.number,
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(118, 0, 0,
                                      0), // Set your desired border color here
                                  width: 1.0, // Set the border width
                                ),
                                borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Status',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Spacer(),
                                DropdownButton<String>(
                                  value: 'Active', // Initial value
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: 'Active',
                                      child: Text('Active'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Inactive',
                                      child: Text('Inactive'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    // Handle dropdown value change
                                    hack("Selected value: $value");
                                    if (value == 'Active') {
                                      actiController.text = '0';
                                    } else {
                                      actiController.text = '1';
                                    }
                                    hack("Selected value: $actiController");
                                  },
                                ),
                                SizedBox(
                                  width: 15,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Bank Name',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: bankNameController,
                            focusNode: _textField15FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField16FocusNode);
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[\d\W]')),
                            ],

                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Branch Name(Bank)',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: bankbranch,
                            focusNode: _textField19FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField20FocusNode);
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[\d\W]')),
                            ],

                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Account Number',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: accountNumberController,
                            focusNode: _textField16FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField17FocusNode);
                            },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('IFSC Number',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: ifscNumberController,
                            focusNode: _textField20FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField21FocusNode);
                            },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('UAL',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: pfCodeController,
                            focusNode: _textField17FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField18FocusNode);
                            },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('PF Amount',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text('Employee Contribution',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _employee_contri,
                                  enabled:
                                      true, // Set enabled to false to make it non-editable
                                  decoration: InputDecoration(
                                    // You can optionally provide decoration to make it visually read-only
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .black), // Customize the border color
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text('Employer Contribution',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _employer_contri,
                                  focusNode: _textField18FocusNode,
                                  onFieldSubmitted: (value) {
                                    // Move focus to the next text field when submitted
                                    _textField1FocusNode.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_textField21FocusNode);
                                  },
                                  enabled:
                                      true, // Set enabled to false to make it non-editable
                                  decoration: InputDecoration(
                                    // You can optionally provide decoration to make it visually read-only
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .black), // Customize the border color
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('Insurance Amount',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: insuranceamntController,
                            focusNode: _textField21FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField22FocusNode);
                            },
                            keyboardType: TextInputType.number,
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('ESI Amount',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            controller: esiamountController,
                            focusNode: _textField22FocusNode,
                            keyboardType: TextInputType.number,
                            // onFieldSubmitted: (value) {
                            //   // Move focus to the next text field when submitted
                            //   _textField1FocusNode.unfocus();
                            //   FocusScope.of(context).requestFocus(_textField4FocusNode);
                            // },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Salary',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: salaryController,
                            focusNode: _textField14FocusNode,
                            onFieldSubmitted: (value) {
                              // Move focus to the next text field when submitted
                              _textField1FocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_textField15FocusNode);
                            },
                            enabled:
                                true, // Set enabled to false to make it non-editable
                            decoration: InputDecoration(
                              // You can optionally provide decoration to make it visually read-only
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Customize the border color
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                salaryController.text == ''
                                    ? salary = 0
                                    : salary = int.parse(salaryController.text);
                                cal_salary_inc();
                              });
                            },
                          ),
                          SizedBox(height: 16),
//basic
                          Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Basic',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Container(
                                      width: 70,
                                      color: Colors.white,
                                      child: Center(
                                        child: Text(
                                          basic.toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(height: 5),
//Hra
                          Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'HRA',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Container(
                                      width: 70,
                                      color: Colors.white,
                                      child: Center(
                                        child: Text(
                                          HRA.toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(height: 5),
                          //convall
                          Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Conv.All',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Container(
                                      width: 70,
                                      color: Colors.white,
                                      child: Center(
                                        child: Text(
                                          Conv_all.toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(height: 5),
                          //medical
                          Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Medical.All',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Container(
                                      width: 70,
                                      color: Colors.white,
                                      child: Center(
                                        child: Text(
                                          medical_all.toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(height: 5),
                          //special
                          Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Special.All',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Container(
                                      width: 70,
                                      color: Colors.white,
                                      child: Center(
                                        child: Text(
                                          medical_all.toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(height: 5),
                          Row(
                            children: <Widget>[
                              Text('Increment Date',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 10),
                              Text(
                                selectedDate6,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _increment(context),
                                child: Text(
                                  'Select date',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(172, 120, 255, 244),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Positiion',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: Text(
                                          designationController.text == ''
                                              ? ' No Data '
                                              : designationController.text,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      child: Text(
                                'Salary  : ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ))),
                              Expanded(
                                  child: Container(
                                child: TextFormField(
                                  controller: _incrementsala,
                                  keyboardType: TextInputType.number,
                                  enabled:
                                      true, // Set enabled to false to make it non-editable
                                  decoration: InputDecoration(
                                    // You can optionally provide decoration to make it visually read-only
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .black), // Customize the border color
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Salary';
                                    }
                                    return null;
                                  },
                                ),
                              )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  submitForm();
                                  inssalary_increment();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 24),
                                  side: BorderSide(
                                      width: 2,
                                      color: Colors
                                          .blue), // Adjust border width and color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust border radius
                                  ),
                                ),
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue, // Text color
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                hack(workFromController);
                                hack(workToController);
                                if (_formKey.currentState!.validate()) {
                                  // The form is valid, you can submit the data or perform other actions
                                  // For now, let's hack the mobile number
                                  // hack('Mobile Number: ${numberController.text}');
                                  reg();
                                  submitForm();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Center(
                                        child: Text(
                                          'Please fill the required fields !',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      backgroundColor:
                                          Color.fromARGB(255, 253, 215, 2),
                                    ),
                                  );
                                }
                              },
                              child: Text('Submit',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
