// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_hack, unnecessary_cast, depend_on_referenced_packages, use_key_in_widget_constructors, use_build_context_synchronously, sized_box_for_whitespace, non_constant_identifier_names, unused_local_variable, camel_case_types, unused_field, unused_element, curly_braces_in_flow_control_structures, sort_child_properties_last, no_leading_underscores_for_local_identifiers, unused_import, avoid_print, prefer_interpolation_to_compose_strings

import 'package:attendence/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../admin_login.dart';
import '../../config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

class View_Admin extends StatefulWidget {
  const View_Admin({Key? key});

  @override
  State<View_Admin> createState() => _View_State();
}

class _View_State extends State<View_Admin> {
  var backendIP = ApiConstants.backendIP;
  final TextEditingController _offc = TextEditingController();
  final TextEditingController _brnch = TextEditingController();
  final TextEditingController _addr = TextEditingController();
  final TextEditingController _adcode = TextEditingController();
  final TextEditingController _empcode = TextEditingController();
  final TextEditingController _traicode = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String salary = '';
  String dob = '';

  String office = '';
  String branch = '';
  String address = '';
  String adminid = '';
  String employeeid = '';
  String traineeid = '';
  String loginuser = '';
  String company = 'Select Company';
  String department = 'Select Department';
  String location = 'Select Location';
  String blood = 'Select Blood Group';

  String headDepart = '';
  String tlDepart = '';

  List departmentData = []; // Store the fetched department data here
  List userData = []; // Store the fetched department data here
  List companyname = [];

  bool isLoading = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();

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

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var session1_user = sharedPreferences.getString('session_user');
    var session2_user = sharedPreferences.getString('branch');
    if (session1_user != null && session2_user != null) {
      setState(() {
        loginuser = session1_user;
        branch = session2_user;
        hack(loginuser);
        hack(branch);
        // Moved getUserdata call here, so it only happens when loginuser is available
        viewbranch();
        viewLocation();
        viewcompany();
        viewdepart();
        viewadmin();
        submitForm();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  Future<void> viewadmin() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/view/vfetchadmin.php'); // Replace with the URL of your PHP script
      var response = await http.post(apiUrl, body: {
        'branch': branch,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          userData = List<Map<String, dynamic>>.from(data);
          hack(userData);
          userData.sort((a, b) => a['user_id'].compareTo(b['user_id']));
          isLoading = true;
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

  List branchname = [];

  Future<void> viewbranch() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Registration/vfetch_branch.php'); // Replace with the URL of your PHP script
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          branchname = jsonDecode(response.body);
          hack(branchname);
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

  List company_name = []; // Declare company_name as List<dynamic>
  String cmp = '';

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
        });
      } else {
        hack('Error occurred while fetching data: ${response.body}');
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
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
            } else {
              headDepart = 'No Department Head';
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
            } else {
              tlDepart = 'No Department TL';
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

  List locationData = [];

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

  XFile? _image;
  ImagePicker picker = ImagePicker();

  Future<void> _getImage(
      Map<String, dynamic> data, String salary, String dob) async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
        print(pickedImage);
        print(_image);
        Navigator.pop(context);
      });
      await showEditDialog(context, data, salary, dob);
      setState(() {
        _image = null; // Set _image to null after using it
      });
    }
  }

  Future<void> showEditDialog(BuildContext context, Map<String, dynamic> data,
      String sala, String birth) async {
    String pic_sts = data['team_ld'].toString();
    TextEditingController nameController =
        TextEditingController(text: data['nm']);
    TextEditingController passController =
        TextEditingController(text: data['pwd']);
    TextEditingController mobController =
        TextEditingController(text: data['mob']);
    TextEditingController addrController =
        TextEditingController(text: data['addr']);
    TextEditingController em_departController =
        TextEditingController(text: data['em_depart']);
    TextEditingController em_depart_hedController =
        TextEditingController(text: data['em_depart_hed']);
    TextEditingController clientController =
        TextEditingController(text: data['no_of_cl']);
    TextEditingController emailController =
        TextEditingController(text: data['email']);
    TextEditingController teamldController =
        TextEditingController(text: data['em_depart_tl']);
    TextEditingController desigController =
        TextEditingController(text: data['dsig']);
    TextEditingController dojController =
        TextEditingController(text: data['doj']);
    TextEditingController pfcdController =
        TextEditingController(text: data['pf_cd']);
    TextEditingController locatController = TextEditingController(
        text: (data['locca'] == '') ? 'Select Location' : data['locca']);
    TextEditingController bankController =
        TextEditingController(text: data['bank']);
    TextEditingController accnoController =
        TextEditingController(text: data['acc_no']);
    TextEditingController ifscController =
        TextEditingController(text: data['ifsc']);
    TextEditingController dobController =
        TextEditingController(text: data['dob']);
    TextEditingController _pan =
        TextEditingController(text: data['pan_num'].toString());
    TextEditingController pfamntController =
        TextEditingController(text: data['pf_amt']);
    TextEditingController _aadhar = TextEditingController(text: data['sd_amt']);
    TextEditingController fathnmController =
        TextEditingController(text: data['fath_nm']);
    TextEditingController bloodController = TextEditingController(
        text: (data['blood'] == '') ? 'Select Blood Group' : data['blood']);
    TextEditingController hmmobController =
        TextEditingController(text: data['hm_mob']);
    TextEditingController offcmobController =
        TextEditingController(text: data['offc_mob']);
    TextEditingController insamntController =
        TextEditingController(text: data['insu_amt'].toString());
    TextEditingController esiamntController =
        TextEditingController(text: data['esi_amt'].toString());
    TextEditingController work_frm =
        TextEditingController(text: data['work_frm']);
    TextEditingController work_to =
        TextEditingController(text: data['work_to']);
    TextEditingController dt_rejoin = TextEditingController(
        text: (data['rejoin_dt'] == '0001-01-01')
            ? 'Select Date'
            : data['rejoin_dt']);
    TextEditingController dt_leaving = TextEditingController(
        text: (data['reliving_dt'] == '0001-01-01')
            ? 'Select Date'
            : data['reliving_dt']);
    TextEditingController _cmpnm = TextEditingController();
    TextEditingController salaController = TextEditingController(text: 'xxxx');
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String dob = '';
    String salary = '';
    String selectedDate1 = '';
    String selectedDate3 = '';

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900), // Set your desired minimum date
        lastDate: DateTime.now(), // Set your desired maximum date
      );
      if (picked != null)
        setState(() {
          selectedDate1 =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          hack(selectedDate1);
          hack(sala);
          selectedDate3 = DateFormat('dd-MM-yyyy').format(picked);
          hack(selectedDate3);
        });
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

    void showPopup() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('View Salary'),
            content: Container(
              height: 100,
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Text('Date of Birth',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text(
                        selectedDate3,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      'Select date',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(172, 120, 255, 244),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    hack('birth:$birth');
                    hack(selectedDate1);
                    if (selectedDate1 == birth) {
                      hack(sala);
                      salaController.clear();
                      hack('equal');
                      salaController.text = sala;
                      hack(salaController);
                    } else {
                      hack('not');
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
    }

    DateTime selectedDate = DateTime.now();

    Future<void> _selectDatedoj(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101),
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          dojController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        });
      }
    }

    Future<void> _selectDatedorej(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101),
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          dt_rejoin.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        });
      }
    }

    Future<void> _selectDatedorel(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101),
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          dt_leaving.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        });
      }
    }

    // Future<void> _selectDatedob(BuildContext context) async {
    //   final DateTime? picked = await showDatePicker(
    //     context: context,
    //     initialDate: selectedDate,
    //     firstDate: DateTime(2000),
    //     lastDate: DateTime(2101),
    //   );

    //   if (picked != null && picked != selectedDate) {
    //     setState(() {

    //     });
    //   }
    // }

    void handleAgeRequirementMet() {
      // Your logic when the age requirement is met
      // For example, you can proceed with further actions or validations
    }

    void showSnack(String text) {
      if (_scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!)
            .showSnackBar(SnackBar(
          content: Center(
              child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          )),
          backgroundColor: Colors.amber,
        ));
      }
    }

    Future<void> _selectDatedob(BuildContext context) async {
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
            selectedDate = picked;
            dojController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
          });

          // Proceed with your logic here
          // For example, you can call a function to handle the next steps
          handleAgeRequirementMet();
        } else {
          // Show a snackbar indicating that the selected date doesn't meet the age requirement
          Navigator.pop(context);
          showSnack('You must be 18 years or older.');
        }
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User Details'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (_image != null)
                            ? Image(
                                image: FileImage(File(_image!.path))
                                    as ImageProvider<Object>)
                            : (data['pic'] == null ||
                                    data['pic'].toString().isEmpty)
                                ? Image.network(
                                    '$backendIP/Registration/uploads/images.png',
                                    fit: BoxFit.cover,
                                  )
                                : (pic_sts == '1')
                                    ? Image.network(
                                        '$backendIP/Registration/uploads/' +
                                            data['pic'].toString(),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        'https://staffin.cloud/static/upload/' +
                                            data['pic'].toString(),
                                        fit: BoxFit.cover,
                                      )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      _getImage(data, salary, dob);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Change Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
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
                  TextFormField(
                    controller: passController,
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Branch Name'),
                        ],
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButton<String>(
                              value: branch,
                              onChanged: (String? newValue) async {
                                if (newValue != null) {
                                  setState(() {
                                    branch = newValue;
                                  });
                                  await viewcompany();
                                  setState(() {
                                    setState(() {
                                      _cmpnm.text = cmp;
                                    });
                                  });
                                }
                              },
                              items: [
                                for (int index = 0;
                                    index < branchname.length;
                                    index++)
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
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text('Company Name'),
                    ],
                  ),
                  TextFormField(
                    controller: _cmpnm,
                    decoration: InputDecoration(
                        hintText: cmp,
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 119, 118, 118))),
                    enabled: false,
                  ),
                  TextFormField(
                    controller: mobController,
                    decoration: InputDecoration(labelText: 'Mobile No.'),
                    keyboardType: TextInputType.number,
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
                  TextFormField(
                    controller: addrController,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
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
                  ),
                  TextFormField(
                    controller: fathnmController,
                    decoration:
                        InputDecoration(labelText: 'Father / Spouse Name'),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                    ],
                  ),
                  TextFormField(
                    controller: hmmobController,
                    decoration: InputDecoration(labelText: 'Emergency Number.'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != '') {
                        if (value!.length != 10 ||
                            !value!.contains(RegExp(r'^[0-9]+$'))) {
                          return 'Please enter a valid 10-digit Emergency Number';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Date of Birth',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      _selectDatedob(context);
                    },
                    child: TextFormField(
                      controller: dobController, // Use the existing controller
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
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Blood Group'),
                        ],
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButton<String>(
                              value: bloodController
                                  .text, // Set the initial value here
                              onChanged: (String? newValue) async {
                                if (newValue != null) {
                                  setState(() {
                                    blood = newValue;
                                    bloodController.text = newValue;
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem(
                                    child: Text('Select Blood Group'),
                                    value: 'Select Blood Group'),
                                DropdownMenuItem(
                                    child: Text('A+'), value: 'A+'),
                                DropdownMenuItem(
                                    child: Text('A-'), value: 'A-'),
                                DropdownMenuItem(
                                    child: Text('B+'), value: 'B+'),
                                DropdownMenuItem(
                                    child: Text('B-'), value: 'B-'),
                                DropdownMenuItem(
                                    child: Text('O+'), value: 'O+'),
                                DropdownMenuItem(
                                    child: Text('O-'), value: 'O-'),
                                DropdownMenuItem(
                                    child: Text('AB+'), value: 'AB+'),
                                DropdownMenuItem(
                                    child: Text('AB-'), value: 'AB-'),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Employee Department'),
                    ],
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButton<String>(
                          value: em_departController
                              .text, // Set the initial value here
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              setState(() {
                                department = newValue;
                              });

                              await viewdpthead(); // Assuming viewdpthead updates headdepart
                              await viewdpttl(); // Assuming viewdpttl updates tlDepart

                              setState(() {
                                em_departController.text = newValue;
                                // Update other controllers or values if needed
                                em_depart_hedController.text = headDepart;
                                // Update other controllers or values if needed
                                teamldController.text = newValue;
                                // Update other controllers or values if needed
                                teamldController.text = tlDepart;
                                // Update other controllers or values if needed
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'Select Department',
                              child: Container(
                                width: 150,
                                child: Text(
                                  'Select Department',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            for (int index = 0;
                                index < departmentData.length;
                                index++)
                              DropdownMenuItem<String>(
                                value: departmentData[index]['nm'],
                                child: Container(
                                  width: 150,
                                  child: Text(
                                    departmentData[index]['nm'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Employee Department Head'),
                    ],
                  ),
                  TextFormField(
                    controller: em_depart_hedController,
                    enabled:
                        false, // Set enabled to false to make it non-editable
                    decoration: InputDecoration(
                      hintText: headDepart,
                      hintStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 34, 34, 34)),
                      // You can optionally provide decoration to make it visually read-only
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Employee Department Tl'),
                    ],
                  ),
                  TextFormField(
                    controller: teamldController,
                    enabled:
                        false, // Set enabled to false to make it non-editable
                    decoration: InputDecoration(
                      hintText: tlDepart,
                      hintStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 34, 34, 34)),
                      // You can optionally provide decoration to make it visually read-only
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Location'),
                        ],
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButton<String>(
                              value: locatController
                                  .text, // Set the initial value here
                              onChanged: (String? newValue) async {
                                if (newValue != null) {
                                  setState(() {
                                    location = newValue;
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Select Location',
                                  child: Container(
                                    width: 150,
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
                                    value:
                                        locationData[index]['addr'].toString(),
                                    child: Container(
                                      width: 150,
                                      child: Text(
                                        locationData[index]['addr'].toString(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: offcmobController,
                    decoration: InputDecoration(labelText: 'Office No.'),
                    keyboardType: TextInputType.number,
                    enabled: false,
                  ),
                  TextFormField(
                    controller: desigController,
                    decoration: InputDecoration(labelText: 'Designation'),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                    ],
                  ),
                  TextFormField(
                    controller: clientController,
                    decoration: InputDecoration(labelText: 'No.of cl'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Work From'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      // Set initial time to 9:20
                      TimeOfDay initialTime = TimeOfDay(hour: 9, minute: 20);

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
                        work_frm.text = formattedTime;
                      }
                    },
                    child: TextFormField(
                      controller: work_frm, // Use the existing controller
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Work To'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      // Set initial time to 9:20
                      TimeOfDay initialTime = TimeOfDay(hour: 17, minute: 20);
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
                        work_to.text = formattedTime;
                      }
                    },
                    child: TextFormField(
                      controller: work_to, // Use the existing controller
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Date of Joining'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      _selectDatedoj(context);
                    },
                    child: TextFormField(
                      controller: dojController, // Use the existing controller
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Date of Re-Joining'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      _selectDatedorej(context);
                    },
                    child: TextFormField(
                      controller: dt_rejoin, // Use the existing controller
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Date of Releaving'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      _selectDatedorel(context);
                    },
                    child: TextFormField(
                      controller: dt_leaving, // Use the existing controller
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
                  TextFormField(
                    controller: _pan,
                    decoration: InputDecoration(labelText: 'Pan Number'),
                  ),
                  TextFormField(
                    controller: _aadhar,
                    decoration: InputDecoration(labelText: 'Aadhar Number'),
                  ),
                  TextFormField(
                    controller: bankController,
                    decoration: InputDecoration(labelText: 'Bank'),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                    ],
                  ),
                  TextFormField(
                    controller: accnoController,
                    decoration: InputDecoration(labelText: 'Account No.'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: ifscController,
                    decoration: InputDecoration(labelText: 'IFSC code'),
                  ),
                  TextFormField(
                    controller: pfcdController,
                    decoration: InputDecoration(labelText: 'UAL'),
                  ),
                  TextFormField(
                    controller: pfamntController,
                    decoration: InputDecoration(labelText: 'PF_amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: insamntController,
                    decoration: InputDecoration(labelText: 'Insurance_Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: esiamntController,
                    decoration: InputDecoration(labelText: 'ESI_Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: salaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Salary',
                        suffixIcon: IconButton(
                            onPressed: () {
                              showPopup();
                            },
                            icon: Icon(Icons.remove_red_eye))),
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
                  String workFrom = work_frm.text;
                  String workTo = work_to.text;
                  if (workFrom.isNotEmpty) {
                    TimeOfDay parsedTime = parseTime(workFrom);
                    String formattedTime = _formatTime(parsedTime);
                    print(formattedTime);
                    work_frm.text = formattedTime + ':00'.toString();
                  }

                  if (workTo.isNotEmpty) {
                    TimeOfDay parsedTime = parseTime(workTo);
                    String formattedTime = _formatTime2(parsedTime);
                    print(formattedTime);
                    work_to.text = formattedTime + ':00'.toString();
                  }
                  Map<String, dynamic> updatedData = {
                    'id': data['id'],
                    'name': nameController.text,
                    'password': passController.text,
                    'mobileno': mobController.text,
                    'address': addrController.text,
                    'em_depart': department,
                    'em_depart_head': headDepart,
                    'client': clientController.text,
                    'email': emailController.text,
                    'team_ld': tlDepart,
                    'desig': desigController.text,
                    'salary': salaController.text,
                    'doj': dojController.text,
                    'pf_cd': pfcdController.text,
                    'locate': location,
                    'bank': bankController.text,
                    'acc_no': accnoController.text,
                    'ifsc': ifscController.text,
                    'dob': dobController.text,
                    'pan': _pan.text,
                    'pf_amnt': pfamntController.text,
                    'aadhar': _aadhar.text,
                    'company': _cmpnm.text,
                    'fathername': fathnmController.text,
                    'blood': blood,
                    'homeno': hmmobController.text,
                    'officeno': offcmobController.text,
                    'ins_amnt': insamntController.text,
                    'esi_amnt': esiamntController.text,
                    'work_from': work_frm.text,
                    'work_to': work_to.text,
                    'branch': branch,
                    'dt_rejoin': dt_rejoin.text,
                    'dt_leaving': dt_leaving.text,
                  };
                  updateBranch(updatedData);
                  Navigator.of(context).pop();
                } else {
                  '';
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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

  String _formatTime(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  String _formatTime2(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  // Future<void> updateBranch(Map<String, dynamic> updatedData) async {
  //   hack('hhh');
  //   try {
  //     var apiUrl = Uri.parse('$backendIP/view/update_admin.php');

  //     var request = http.MultipartRequest('POST', apiUrl);

  //     request.fields.addAll({
  //       'id': updatedData['id'].toString(),
  //       'name': updatedData['name'],
  //       'password': updatedData['password'],
  //       'mobileno': updatedData['mobileno'],
  //       'address': updatedData['address'],
  //       'em_depart': updatedData['em_depart'],
  //       'em_depart_head': updatedData['em_depart_head'],
  //       'client': updatedData['client'],
  //       'email': updatedData['email'],
  //       'desig': updatedData['desig'],
  //       'salary': updatedData['salary'],
  //       'doj': updatedData['doj'],
  //       'pf_cd': updatedData['pf_cd'],
  //       'locate': updatedData['locate'],
  //       'bank': updatedData['bank'],
  //       'acc_no': updatedData['acc_no'],
  //       'ifsc': updatedData['ifsc'],
  //       'dob': updatedData['dob'],
  //       'pan': updatedData['pan'],
  //       'pf_amnt': updatedData['pf_amnt'],
  //       'aadhar': updatedData['aadhar'],
  //       'company': updatedData['company'],
  //       'fathername': updatedData['fathername'],
  //       'blood': updatedData['blood'],
  //       'homeno': updatedData['homeno'],
  //       'officeno': updatedData['officeno'],
  //       'ins_amnt': updatedData['ins_amnt'],
  //       'esi_amnt': updatedData['esi_amnt'],
  //       'work_from': updatedData['work_from'],
  //       'work_to': updatedData['work_to'],
  //       'branch': updatedData['branch'],
  //       'dt_rejoin': updatedData['dt_rejoin'],
  //       'dt_leaving': updatedData['dt_leaving'],
  //     });

  //     if (_image != null) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath('image', _image!.path),
  //       );
  //     }

  //     var response = await request.send();

  //     if (response.statusCode == 200) {
  //       var responseData = await response.stream.bytesToString();
  //       var data = jsonDecode(responseData);
  //       print(data);
  //       if (data is Map<String, dynamic> && data.containsKey('message')) {
  //         if (data['message'] == 'Data updated successfully') {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Center(
  //                   child: Text('User details updated successfully!',
  //                       style: TextStyle(
  //                           color: Colors.white, fontWeight: FontWeight.bold))),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //           await viewadmin(); // Refresh the data after update
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Center(
  //                   child: Text('Failed to update user details',
  //                       style: TextStyle(fontWeight: FontWeight.bold))),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //       } else {
  //         hack('Error: Unexpected response format');
  //       }
  //     } else {
  //       hack(
  //           'Error occurred during user update. Status code: ${response.statusCode}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Center(
  //               child: Text('Failed to update user details',
  //                   style: TextStyle(fontWeight: FontWeight.bold))),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     hack('Update error: $e');

  //   }
  // }

  Future<void> updateBranch(Map<String, dynamic> updatedData) async {
    try {
      var apiUrl = Uri.parse('$backendIP/view/update_admin.php');

      var request = http.MultipartRequest('POST', apiUrl);

      // Add data fields to the request
      request.fields.addAll({
        'id': updatedData['id'].toString(),
        'name': updatedData['name'],
        'password': updatedData['password'],
        'mobileno': updatedData['mobileno'],
        'address': updatedData['address'],
        'em_depart': updatedData['em_depart'],
        'em_depart_head': updatedData['em_depart_head'],
        'client': updatedData['client'],
        'email': updatedData['email'],
        'desig': updatedData['desig'],
        'salary': updatedData['salary'],
        'doj': updatedData['doj'],
        'pf_cd': updatedData['pf_cd'],
        'locate': updatedData['locate'],
        'bank': updatedData['bank'],
        'acc_no': updatedData['acc_no'],
        'ifsc': updatedData['ifsc'],
        'dob': updatedData['dob'],
        'pan': updatedData['pan'],
        'pf_amnt': updatedData['pf_amnt'],
        'aadhar': updatedData['aadhar'],
        'company': updatedData['company'],
        'fathername': updatedData['fathername'],
        'blood': updatedData['blood'],
        'homeno': updatedData['homeno'],
        'officeno': updatedData['officeno'],
        'ins_amnt': updatedData['ins_amnt'],
        'esi_amnt': updatedData['esi_amnt'],
        'work_from': updatedData['work_from'],
        'work_to': updatedData['work_to'],
        'branch': updatedData['branch'],
        'dt_rejoin': updatedData['dt_rejoin'],
        'dt_leaving': updatedData['dt_leaving'],
      });

      // Add image file if available
      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _image!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        print(data);
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          if (data['message'] == 'Data updated successfully') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text('User details updated successfully!',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                backgroundColor: Colors.green,
              ),
            );
            await viewadmin(); // Refresh the data after update
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text('Failed to update user details',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Handle unexpected response format
          print('Error: Unexpected response format');
        }
      } else {
        // Handle HTTP error
        print(
            'Error occurred during user update. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text('Failed to update user details',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle other errors
      print('Update error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Center(
      //         child: Text('Failed to update user details',
      //             style: TextStyle(fontWeight: FontWeight.bold))),
      //     backgroundColor: Colors.red,
      //   ),
      // );
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

  Future<void> deleteUser(id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to remove this admin ?',
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

  Future<void> performDelete(id) async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/view/delete_admin.php'); // Replace with your delete API endpoint
      var response = await http.post(apiUrl, body: {
        'id': id.toString(), // Pass the ID to be deleted
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Department deleted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('User deleted successfully',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.green, // Set the background color
            ),
          );
          await viewadmin(); // Refresh the data after deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Failed to delete user',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              backgroundColor: Colors.red, // Set the background color
            ),
          );
        }
      } else {
        hack('Error occurred during department deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to delete user')),
            backgroundColor: const Color.fromARGB(
                255, 202, 169, 19), // Set the background color
          ),
        );
      }
    } catch (e) {
      hack('Delete error: $e');
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

  String formattedDate = '';

  void submitForm() {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Get the current date
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
  }

  void bank_viewpopup(
      BuildContext context,
      String bank,
      String branch,
      String mr_mrs_ms,
      String name,
      String fath_nm,
      String add,
      String loc,
      String des,
      String doj,
      String company) {
    String salutation = '';
    String gender = '';

    if (mr_mrs_ms == 'Mr') {
      salutation = "S/o";
      gender = "He";
    } else if (mr_mrs_ms == 'Ms') {
      salutation = "D/o";
      gender = "She";
    } else {
      salutation = "W/o";
      gender = "She";
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Container(
            alignment: pw.Alignment.centerRight, // Adjust alignment as needed
            child: pw.Text(
              '$formattedDate',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            'TO:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'The Branch Manager,',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '$bank,',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '$branch.',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Subject :',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            ' Request to open a Bank Account for the Company\'s Employee.',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Dear Sir,',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 15),
          pw.SizedBox(height: 10),
          pw.Text(
            'You are requested to open a salary account for $mr_mrs_ms.$name,',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.Text(
            '$salutation.$fath_nm, $add, $loc.',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 15),
          pw.SizedBox(height: 10),
          pw.Text(
            '$gender has been employed as the $des w.e.f $doj at our firm $company. Please find a photocopy of the required documents, photographs, and the filled application form attached with this request letter.',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 15),
          pw.SizedBox(height: 10),
          pw.Text(
            'Kindly open a salary bank account with online bank facilities and ATM services as soon as possible.',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 20),
          pw.SizedBox(height: 10),
          pw.Container(
            alignment: pw.Alignment.center, // Adjust alignment as needed
            child: pw.Text(
              'Thank You',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    showDialog(
      //barrierColor: Color.fromARGB(178, 255, 255, 255),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TO:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'The Branch Manager,',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      (bank == '') ? 'No Data ,' : '$bank,',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      (branch == '') ? 'No Data .' : '$branch.',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Subject :',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' Request to open a Bank Account for the Company\'s Employee.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Dear Sir,',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'You are requested to open a salary account for $mr_mrs_ms.$name,',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$salutation.$fath_nm, $add, $loc.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      '$gender has been employed as the $des w.e.f $doj at our firm $company. Please find a photocopy of the required documents, photographs, and the filled application form attached with this request letter.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Kindly open a salary bank account with online bank facilities and ATM services as soon as possible.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Thank You',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        // Close the dialog
                        Navigator.of(context).pop();

                        // Generate PDF and save
                        final bytes = await pdf.save();
                        final directory = await getExternalStorageDirectory();
                        final file = File('${directory!.path}/$name.pdf');
                        await file.writeAsBytes(bytes);

                        // Show notification
                        await _showNotification(file.path);

                       
                        hack(file);
                      },
                      child: Text('Download'),
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
    'Tap to open PDF',
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

  bool isSearchVisible = false;
  List filteredData = [];
  final TextEditingController _search = TextEditingController();

  Future<void> onClick() async {
    setState(() {
      isSearchVisible = !isSearchVisible;
      _search.clear();
      filteredData.clear();
    });
  }

  void onSearchTextChanged(String text) {
    setState(() {
      filteredData = userData
          .where((data) =>
              data['user_id']
                  .toString()
                  .toLowerCase()
                  .contains(text.toLowerCase()) ||
              data['nm'].toString().toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
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
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_sharp),
          ),
          title: Row(
            children: [
              Text(
                'View Admin',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  onClick();
                },
                icon: Icon(Icons.search),
              )
            ],
          ),
        ),
        body: isLoading
            ? SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/poni.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.6),
                        BlendMode.srcOver,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Branch Name',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' : ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              branch,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (isSearchVisible) SizedBox(height: 15),
                      if (isSearchVisible)
                        Container(
                          height: 50.0,
                          width: 250.0,
                          child: TextField(
                            controller: _search,
                            onChanged: onSearchTextChanged,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Search...',
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      Container(
                        height: (userData.isEmpty) ? 100 : 500,
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: MaterialStateColor.resolveWith(
                                (states) => Colors.blue), // Set the color
                          ),
                          child: Scrollbar(
                            thickness: 7,
                            radius: Radius.circular(10),
                            child: SingleChildScrollView(
                              child: ScrollbarTheme(
                                data: ScrollbarThemeData(
                                  thumbColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.blue), // Set the color
                                ),
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
                                          label: Text('Mob',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        DataColumn(
                                          label: Text('Department',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        DataColumn(
                                          label: Text('Emp_Depart_Head',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        DataColumn(
                                          label: Text('Emp_Depart_Tl',
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
                                          label: Text('Blood',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        DataColumn(
                                          label: Text('Edit',
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
                                        DataColumn(
                                          label: Text('Bank - view',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                      ],
                                      rows: (isSearchVisible
                                              ? filteredData
                                              : userData)
                                          .map((data) {
                                        int serialNumber = (isSearchVisible
                                                    ? filteredData
                                                    : userData)
                                                .indexOf(data) +
                                            1;
                                        return DataRow(
                                          cells: <DataCell>[
                                            DataCell(Center(
                                              child: Text('$serialNumber',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )),
                                            DataCell(Text(
                                                data['nm'] == ''
                                                    ? 'No Data'
                                                    : data['nm'].toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                            DataCell(Text(
                                                data['user_id'] == ''
                                                    ? 'No Data'
                                                    : data['user_id']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                            DataCell(Text(
                                                data['mob'] == ''
                                                    ? 'No Data'
                                                    : data['mob'].toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                            DataCell(Center(
                                              child: Text(
                                                  data['em_depart'] == ''
                                                      ? 'No Data'
                                                      : data['em_depart']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )),
                                            DataCell(Center(
                                              child: Text(
                                                  data['em_depart_hed'] == ''
                                                      ? 'No Data'
                                                      : data['em_depart_hed']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )),
                                            DataCell(Center(
                                              child: Text(
                                                  data['em_depart_tl'] == ''
                                                      ? 'No Data'
                                                      : data['em_depart_tl']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )),
                                            DataCell(Text(
                                                data['dsig'] == ''
                                                    ? 'No Data'
                                                    : data['dsig'].toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                            DataCell(Center(
                                              child: Text(
                                                  data['blood'] == ''
                                                      ? 'No Data'
                                                      : data['blood']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )),
                                            DataCell(
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    salary =
                                                        data['sala'].toString();
                                                    dob =
                                                        data['dob'].toString();
                                                  });
                                                  hack('salary:$salary');
                                                  showEditDialog(context, data,
                                                      salary, dob);
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
                                            DataCell(
                                              ElevatedButton(
                                                onPressed: () {
                                                  deleteUser(data['id']
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
                                            DataCell(Center(
                                                child: InkWell(
                                                    onTap: () {
                                                      bank_viewpopup(
                                                          context,
                                                          data['bank']
                                                              .toString(),
                                                          data['branch']
                                                              .toString(),
                                                          data['mr_mrs_ms']
                                                              .toString(),
                                                          data['nm'].toString(),
                                                          data['fath_nm']
                                                              .toString(),
                                                          data['addr']
                                                              .toString(),
                                                          data['locca']
                                                              .toString(),
                                                          data['dsig']
                                                              .toString(),
                                                          data['doj']
                                                              .toString(),
                                                          data['company']
                                                              .toString());
                                                    },
                                                    child: Image(
                                                        image: AssetImage(
                                                            'images/pdf.png'))))),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isSearchVisible)
                        filteredData.isEmpty
                            ? Column(
                                children: [
                                  Image(image: AssetImage('images/Search.png')),
                                  Text(
                                    'No data found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              )
                            : Text(''),
                      userData.isEmpty
                          ? Column(
                              children: [
                                Image(image: AssetImage('images/Search.png')),
                                Text(
                                  'No data found',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          : Text(''),
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
