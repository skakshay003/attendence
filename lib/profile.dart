// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, depend_on_referenced_packages, avoid_hack, non_constant_identifier_names, avoid_types_as_parameter_names, unnecessary_cast, sized_box_for_whitespace, deprecated_member_use, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, unused_import, prefer_interpolation_to_compose_strings, unused_local_variable, no_leading_underscores_for_local_identifiers, curly_braces_in_flow_control_structures, sort_child_properties_last

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'admin_login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var backendIP = ApiConstants.backendIP;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  String cliId = '';
  String userid = '';
  String depart = '';
  String cliusId = '';
  String newemail = '';
  String sub_clicked = '';
  Map<String, dynamic> data = {};
  String formattedDate = '';
  String formattedTime = '';
  String Logout_dttm = '';
  String reg_year = '';
  String reg_month = '';
  String newbanknm = '';
  String newacc_no = '';
  String new_ifsc = '';
  String see_sal = 'xxxx';
  bool isPasswordVisible = false; // Initially, the password is hidden.
  bool isTextFieldNotEmpty = false;
  bool showNewPasswordField = false;

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var profile = sharedPreferences.getString('session_user');
    var dep = sharedPreferences.getString('depart');
    if (profile != null && dep != null) {
      setState(() {
        userid = profile.toUpperCase();
        depart = dep;
        hack(userid);
        hack(depart);
        fetchData();
        changepassword();
        // Moved getUserdata call here, so it only happens when loginemail is available
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
    }
  }

  bool isloading = false;
  String pic_sts = '';

  Future<void> fetchData() async {
    try {
      // Make an HTTP request to fetch data based on the profile email
      var apiUrl = Uri.parse('$backendIP/vfetchdata.php');
      var response = await http.post(apiUrl, body: {'user_id': userid});
      if (response.statusCode == 200) {
        hack(response.body);
        // Parse the JSON response
        // Update the labelTexts based on the fetched data
        setState(() {
          List<Map<String, dynamic>> dataList =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          if (dataList.isNotEmpty) {
            data = dataList[0];
            hack('1');
            hack(data);
            _userName.text = data['nm'];
            _number.text = data['mob'];
            _addr.text = data['addr'];
            _email.text = data['email'];
            banknm.text = data['bank'];
            acc_no.text = data['acc_no'];
            ifsc.text = data['ifsc'];
            pic_sts = data['team_ld'].toString();
            print(pic_sts);
          } else {
            hack('No data');
          }
          setState(() {
            isloading = true;
          });
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

  Map<String, dynamic> fetchclidata = {};
  List Cli_Files = [];

  String name = '';
  String number = '';
  String address = '';

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _addr = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController banknm = TextEditingController();
  final TextEditingController acc_no = TextEditingController();
  final TextEditingController ifsc = TextEditingController();

  String newnm = '';
  String newnumb = '';
  String newaddr = '';

  bool isediting = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> submitData(
      String uid,
      String id,
      String name,
      String num,
      String addr,
      String email,
      String bank,
      String acc_no,
      String ifsc,
      XFile? _image) async {
    hack(uid);
    hack(id);
    hack(name);
    hack(num);
    hack(addr);
    hack(email);
    hack(bank);
    hack(acc_no);
    hack(ifsc);
    hack(_image);

    try {
      var apiUrl = Uri.parse('$backendIP/edit_profile.php');
      var request = http.MultipartRequest('POST', apiUrl);

      // Add text fields to the request
      request.fields['usId'] = uid;
      request.fields['userid'] = id;
      request.fields['name'] = name;
      request.fields['num'] = num;
      request.fields['addr'] = addr;
      request.fields['email'] = email;
      request.fields['bank'] = bank;
      request.fields['accno'] = acc_no;
      request.fields['ifsc'] = ifsc;

      // Add image file to the request
      if (_image != null) {
        List<int> imageBytes = await File(_image.path).readAsBytes();
        var imageFile = http.MultipartFile.fromBytes(
          'user_image',
          imageBytes,
          filename: 'user_image.jpg',
        );
        request.files.add(imageFile);
        request.fields['team_id'] = '1';
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        hack('Success Changed');
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        hack('Response: $responseString');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              height: 40,
              width: double.infinity,
              color: Colors.green,
              child: Center(
                child: Text(
                  'Update Changed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        setState(() {
          isediting = false;
          sub_clicked = '1';
          fetchData();
        });
      } else {
        hack('Error occurred during change: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed change')),
          ),
        );
        setState(() {
          isediting = false;
        });
      }
    } catch (e) {
      hack('Change error $e');
    }
  }

  ImagePicker picker = ImagePicker();
  XFile? _image; // Assuming _image is of type XFile

  Future<void> chooseImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  String oldpass = '456';
  String id = '789';

  Future<void> changepassword() async {
    try {
      var apiUrl = Uri.parse('$backendIP/changepass.php');

      var response = await http.post(apiUrl, body: {
        'id': userid,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        hack(data); // hack the entire JSON response for debugging purposes

        if (data.isNotEmpty) {
          setState(() {
            var status = data[0]['pass_chg'];
            oldpass = data[0]['pwd'];
            id = data[0]['id'].toString();
            hack(status);
            hack(oldpass);
            hack(id);
          });
        } else {
          hack('Error occurred while fetching pass status: ${response.body}');
        }
      }
    } catch (e) {
      hack('Fetch error: $e');
    }
  }

  String passwordMismatchMessage = '';
  String Newpassword = '';

  void showPasswordChangePopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TextEditingController newPasswordController = TextEditingController();
        TextEditingController oldpassController = TextEditingController();
        Newpassword = newPasswordController.text;

        FocusNode _textField1FocusNode = FocusNode();
        FocusNode _textField2FocusNode = FocusNode();

        bool showNewPasswordField = false;
        Timer? _debounce;

        return AlertDialog(
          title: Text('Change Password'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                // Set the desired height
                height: 133,
                child: Column(
                  children: [
                    TextFormField(
                      controller: oldpassController,
                      focusNode: _textField1FocusNode,
                      onChanged: (value) {
                        // Clear existing debounce timer
                        if (_debounce != null && _debounce!.isActive) {
                          _debounce!.cancel();
                        }

                        // Set a new debounce timer
                        _debounce = Timer(Duration(milliseconds: 500), () {
                          // Validation logic after a delay of 500 milliseconds
                          if (oldpassController.text == oldpass) {
                            // If old password matches, show the new password field
                            setState(() {
                              showNewPasswordField = true;
                              passwordMismatchMessage = '';
                            });
                            FocusScope.of(context)
                                .requestFocus(_textField2FocusNode);
                          } else {
                            // If old password doesn't match, hide the new password field
                            setState(() {
                              showNewPasswordField = false;
                              passwordMismatchMessage =
                                  'Old password does not match. Please try again.';
                            });
                          }
                        });
                      },
                      obscureText:
                          !isPasswordVisible, // Add this line for password visibility
                      decoration: InputDecoration(
                        hintText: 'Old Password',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          child: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color.fromARGB(255, 119, 119, 119),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      passwordMismatchMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Visibility(
                      visible: showNewPasswordField,
                      child: TextField(
                        controller: newPasswordController,
                        focusNode: _textField2FocusNode,
                        decoration: InputDecoration(
                          hintText: 'New Password',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Clear existing debounce timer before closing the dialog
                if (_debounce != null && _debounce!.isActive) {
                  _debounce!.cancel();
                }

                // Perform the update logic with newPasswordController.text
                if (showNewPasswordField) {
                  // Assuming you have the necessary information
                  String newpass = newPasswordController.text;
                  String stus = '1'; // Replace with the actual status

                  // Only update the password if the new password field is visible

                  setState(() {
                    updtpass(id, newpass, stus);
                  });
                }

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updtpass(String id, String newpass, String stus) async {
    if (newpass.isNotEmpty) {
      try {
        var apiUrl = Uri.parse(
            '$backendIP/updatepass.php'); // Replace with your API endpoint

        var response = await http.post(apiUrl, body: {
          'id': id,
          'updtpass': newpass,
          'status': stus,
        });

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['message'] == 'Data updated successfully') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password changed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // You may want to handle success actions here
            await changepassword();
          } else {
            hack('Error updating data: ${data['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating data!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          hack('Error occurred during HTTP request: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to make HTTP request!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        hack('HTTP request error: $e');
      }
    }
  }

  Future<dynamic> logoutdialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
            content: Container(
              height: 150,
              // decoration: BoxDecoration(
              //   color: Colors.red
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Are you sure you want to Logout\nthis account?",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 255, 255,
                              255), // Change the background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                0), // Set the border radius to 0
                          ),
                        ),
                        child: Text("Yes"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          logout();
                          submitForm();
                          logoutdetails();
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 255, 252,
                              251), // Change the background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                0), // Set the border radius to 0
                          ),
                        ),
                        child: Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> logout() async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.remove(
          'session_user'); // Remove the 'uname' key from shared preferences

      // Navigate to LoginPage after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AttendanceLogin()),
      );
      SnackBar(content: Text("Your Account Logout Successfully"));
    } catch (e) {
      hack('the error is $e');
    }
  }

  void submitForm() {
    // Get the current date and time
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    // Create a formatted time string (e.g., "12:34:56")
    formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Get the current date
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Create a formatted date string (e.g., "2023-11-08")
    formattedDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    Logout_dttm =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}' +
            ' ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    // Split the formatted date string
    List<String> dateParts = formattedDate.split('-');
    int extractedYear = int.parse(dateParts[0]);
    int extractedMonth = int.parse(dateParts[1]);

    reg_month = extractedMonth.toString();
    reg_year = extractedYear.toString();
  }

  Future<void> logoutdetails() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Visitors/logout_userdet.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'userid': userid,
        'log_out_tm': formattedTime,
        'log_out_dt_tm': Logout_dttm,
        'log_out_dt': formattedDate,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
      } else {
        hack('Error occurred during HTTP request: ${response.body}');
      }
    } catch (e) {
      hack('HTTP request error: $e');
    }
  }

  String formatDate(String inputDate) {
    DateTime date = DateTime.parse(inputDate);
    String formattedDay = '${date.day}';
    String formattedMonth =
        '${date.month}'.padLeft(2, '0'); // Ensures two digits
    String formattedYear = '${date.year}';
    String formattedDate = '$formattedDay-$formattedMonth-$formattedYear';
    return formattedDate;
  }

  String dob = '';
  String salary = '';
  String selectedDate1 = '';
  String selectedDate3 = '';
  final TextEditingController _seesal = TextEditingController();

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
        _seesal.text = DateFormat('dd-MM-yyyy').format(picked);
        hack(selectedDate3);
      });
  }

  void showPopup(String dob) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('View Salary'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Text('Date of Birth',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Spacer(),
                    Text(''),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _seesal,
                  enabled: false, // Set enabled to false to make it non-editable
                  decoration: InputDecoration(
                    // You can optionally provide decoration to make it visually read-only
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black), // Customize the border color
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
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
                  hack('birth:$dob');
                  hack(selectedDate1);
                  if (selectedDate1 == dob) {
                    hack('equal');
                    see_sal = data['sala'].toString();
                    hack(see_sal);
                    _seesal.clear();
                    selectedDate1 = '';
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Container(
                          height: 40,
                          width: double.infinity,
                          color: Colors.green,
                          child: Center(
                            child: Text(
                              'DOB mached ',
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    hack('not equal');
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Container(
                          height: 40,
                          width: double.infinity,
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              'DOB not mached !',
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                });
              },
              child: Text('Ok'),
            ),
          ],
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
            onPressed: () async {
              Navigator.pop(context, sub_clicked);
            },
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
          ),
          title: Row(
            children: [
              Text(
                'Profile',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Container(
              decoration: BoxDecoration(),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'passchange') {
                    showPasswordChangePopup();
                  } else if (value == 'logout') {
                    logoutdialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'passchange',
                    child: Row(
                      children: [
                        Icon(Icons.key),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          'Change password',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          'Logout',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        body: isloading
            ? WillPopScope(
                onWillPop: () async {
                  Navigator.pop(context, sub_clicked);
                  return false; // Set to true if you want to allow the pop, false otherwise
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Container(
                          height: (!isediting) ? 205 : 150,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _image == null
                                        ? (data['pic'] == null ||
                                                data['pic'].toString().isEmpty
                                            ? NetworkImage(
                                                    '$backendIP/Registration/uploads/images.png')
                                                as ImageProvider<Object>?
                                            : (pic_sts == '1')
                                                ? NetworkImage(
                                                        '$backendIP/Registration/uploads/' +
                                                            data['pic']
                                                                .toString())
                                                    as ImageProvider<Object>?
                                                : NetworkImage(
                                                        'https://staffin.cloud/static/upload' +
                                                            data['pic']
                                                                .toString())
                                                    as ImageProvider<Object>?)
                                        : FileImage(File(_image!.path))
                                            as ImageProvider<Object>?,
                                  ),
                                  Positioned(
                                    top: 70,
                                    left: 72,
                                    child: isediting
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                  Icons.add_a_photo_outlined,
                                                  size: 25,
                                                  color: Colors.white),
                                              onPressed: () {
                                                // Call a function to choose an image
                                                chooseImage();
                                              },
                                            ),
                                          )
                                        : Container(),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (!isediting)
                                SizedBox(
                                  height: 10,
                                ),
                              if (!isediting)
                                Text(
                                  data['user_id'].toString().toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 152, 153, 153),
                                      fontWeight: FontWeight.w500),
                                ),
                              SizedBox(
                                height: 5,
                              ),
                              if (!isediting)
                                Text(
                                  data['nm'].toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                        Scrollbar(
                          thickness: 10,
                          radius: Radius.circular(10),
                          child: Container(
                            height: 380,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10)),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Form(
                                    key: _formKey,
                                    child: Container(
                                      width: 300,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          if (isediting)
                                            Column(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        width: 200,
                                                        child: Text(
                                                          'Name',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Container(
                                                  width: 200,
                                                  child: TextFormField(
                                                    controller: _userName,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        newnm = value;
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter Name';
                                                      }
                                                      return null;
                                                    },
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .deny(RegExp(
                                                              r'[\d\W]')),
                                                    ],
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      fillColor: Color.fromARGB(
                                                          255, 238, 238, 238),
                                                      filled: true,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.business_rounded,
                                                    color: Colors.black54),
                                                title: Text('Company',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['company'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 10,
                                            ),
                                          isediting
                                              ? Column(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 200,
                                                            child: Text(
                                                              'Mobile Number',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Container(
                                                      width: 200,
                                                      child: TextFormField(
                                                        controller: _number,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            newnumb = value;
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter Phone Number';
                                                          } else if (value
                                                                      .length !=
                                                                  10 ||
                                                              !value.contains(
                                                                  RegExp(
                                                                      r'^[0-9]+$'))) {
                                                            return 'Please enter a valid 10-digit Phone Number';
                                                          }
                                                          return null;
                                                        },
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  238,
                                                                  238),
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Card(
                                                  child: ListTile(
                                                    leading: Icon(
                                                        Icons
                                                            .phone_in_talk_outlined,
                                                        color: Colors.black54),
                                                    title: Text('Mobile',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Color.fromARGB(
                                                                    164,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    subtitle: Text(
                                                      data['mob'].toString(),
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          isediting
                                              ? Column(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 200,
                                                            child: Text(
                                                              'Email',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Container(
                                                      width: 200,
                                                      child: TextFormField(
                                                        controller: _email,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            newemail = value;
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter an email address';
                                                          } else if (!RegExp(
                                                                  r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                                                              .hasMatch(
                                                                  value)) {
                                                            return 'Please enter a valid email address';
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  238,
                                                                  238),
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Card(
                                                  child: ListTile(
                                                    leading: Icon(
                                                        Icons.mail_sharp,
                                                        color: Colors.black54),
                                                    title: Text('Email',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Color.fromARGB(
                                                                    164,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    subtitle: Text(
                                                      data['email'].toString(),
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.calendar_month_sharp,
                                                    color: Colors.black54),
                                                title: Text('DOB',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(formatDate(
                                                    data['dob'].toString())),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.payments_outlined,
                                                    color: Colors.black54),
                                                title: Text('Salary',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Row(
                                                  children: [
                                                    Text(
                                                      see_sal,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                    Spacer(),
                                                    IconButton(
                                                        onPressed: () {
                                                          showPopup(data['dob']
                                                              .toString());
                                                        },
                                                        icon: Icon(Icons
                                                            .remove_red_eye))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(Icons.work,
                                                    color: Colors.black54),
                                                title: Text('Department',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['em_depart'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 10,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.personal_injury,
                                                    color: Colors.black54),
                                                title: Text('Depart Head',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['em_depart_hed']
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons
                                                        .personal_injury_outlined,
                                                    color: Colors.black54),
                                                title: Text('Depart Tl',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['em_depart_tl']
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.time_to_leave_sharp,
                                                    color: Colors.black54),
                                                title: Text('No of Cl',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['no_of_cl'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          isediting
                                              ? Column(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 200,
                                                            child: Text(
                                                              'Address',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Container(
                                                      width: 200,
                                                      child: TextFormField(
                                                        controller: _addr,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            newaddr = value;
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter value';
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  238,
                                                                  238),
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Card(
                                                  child: ListTile(
                                                    leading: Icon(
                                                        Icons.location_pin,
                                                        color: Colors.black54),
                                                    title: Text('Address',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Color.fromARGB(
                                                                    164,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    subtitle: Text(
                                                      data['addr'].toString(),
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          isediting
                                              ? Column(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 200,
                                                            child: Text(
                                                              'Bank',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Container(
                                                      width: 200,
                                                      child: TextFormField(
                                                        controller: banknm,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .deny(RegExp(
                                                                  r'[\d\W]')),
                                                        ],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            newbanknm = value;
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter bank name';
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  238,
                                                                  238),
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Card(
                                                  child: ListTile(
                                                    leading: Icon(
                                                        Icons
                                                            .account_balance_sharp,
                                                        color: Colors.black54),
                                                    title: Text('Bank',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Color.fromARGB(
                                                                    164,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    subtitle: Text(
                                                      data['bank'].toString(),
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          isediting
                                              ? Column(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 200,
                                                            child: Text(
                                                              'Account Number',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Container(
                                                      width: 200,
                                                      child: TextFormField(
                                                        controller: acc_no,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            newacc_no = value;
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter account number';
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  238,
                                                                  238),
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Card(
                                                  child: ListTile(
                                                    leading: Icon(
                                                        Icons.wallet_sharp,
                                                        color: Colors.black54),
                                                    title: Text(
                                                        'Account Number',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Color.fromARGB(
                                                                    164,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    subtitle: Text(
                                                      data['acc_no'].toString(),
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          isediting
                                              ? Column(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 200,
                                                            child: Text(
                                                              'IFSC Number',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Container(
                                                      width: 200,
                                                      child: TextFormField(
                                                        controller: ifsc,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            new_ifsc = value;
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter ifsc number';
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  238,
                                                                  238),
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Card(
                                                  child: ListTile(
                                                    leading: Icon(
                                                        Icons.co_present_sharp,
                                                        color: Colors.black54),
                                                    title: Text('IFSC',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Color.fromARGB(
                                                                    164,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    subtitle: Text(
                                                      data['ifsc'].toString(),
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.savings_sharp,
                                                    color: Colors.black54),
                                                title: Text('PF Amount',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['pf_amt'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.savings_sharp,
                                                    color: Colors.black54),
                                                title: Text('SD Amount',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['sd_amt'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.savings_sharp,
                                                    color: Colors.black54),
                                                title: Text('ESI Amount',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['esi_amt'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          if (!isediting)
                                            SizedBox(
                                              height: 15,
                                            ),
                                          if (!isediting)
                                            Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.savings_sharp,
                                                    color: Colors.black54),
                                                title: Text('Insurance Amount',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            164, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                  data['insu_amt'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 130,
                          child: Column(
                            children: [
                              if (depart == 'SAD')
                                SizedBox(
                                  height: isediting ? 0 : 20,
                                ),
                              depart == 'SAD' && !isediting
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Password   :    ',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Container(
                                            width: 100,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                                border: Border.all()),
                                            child: Center(
                                              child: Text(
                                                data['pwd'].toString(),
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 2,
                                              ),
                                            )),
                                      ],
                                    )
                                  : Container(),
                              depart == 'SAD' && !isediting
                                  ? SizedBox(height: 20)
                                  : SizedBox(
                                      height: 40,
                                    ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  isediting
                                      ? ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              submitData(
                                                  data['id'].toString(),
                                                  data['user_id'].toString(),
                                                  _userName.text,
                                                  _number.text,
                                                  _addr.text,
                                                  _email.text,
                                                  banknm.text,
                                                  acc_no.text,
                                                  ifsc.text,
                                                  _image);
                                            }
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                            // You can customize other properties here, like text color, padding, etc.
                                          ),
                                          child: Text(
                                            'Submit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ))
                                      : OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              isediting = true;
                                            });
                                          },
                                          child: Text('Edit Profile')),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  isediting
                                      ? OutlinedButton(
                                          onPressed: () {
                                            // logoutdialog(context);
                                            setState(() {
                                              isediting = false;
                                              _image = null;
                                            });
                                          },
                                          child: Text('cancel'))
                                      : Text('')
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
