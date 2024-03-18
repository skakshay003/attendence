// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, non_constant_identifier_names, unnecessary_string_interpolations, unnecessary_cast, prefer_interpolation_to_compose_strings, sized_box_for_whitespace, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, sort_child_properties_last, depend_on_referenced_packages, duplicate_import, unused_import, unnecessary_import, use_super_parameters

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:attendence/print_id/print_id_adm.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:screenshot/screenshot.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class print_id extends StatefulWidget {
  const print_id({
    Key? key,
    required this.id,
    required this.name,
  }) : super(key: key);

  final String id;
  final String name;

  @override
  State<print_id> createState() => _print_idState();
}

class _print_idState extends State<print_id> {
  var backendIP = ApiConstants.backendIP;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String id = '';
  String name = '';
  String desig = '';
  String fath_nm = '';
  String addr = '';
  String homeno = '';
  String offcno = '';
  String b_group = '';
  String company = '';

  bool isLoading = false;

  List id_card_details = [];

  @override
  void initState() {
    super.initState();
    id = widget.id.toUpperCase();
    name = widget.name.toUpperCase();
    id_details();

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

  Future<void> id_details() async {
    try {
      var apiUrl = Uri.parse('$backendIP/vfetchdata.php');
      var response = await http.post(apiUrl, body: {
        'user_id': id,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          id_card_details = List<Map<String, dynamic>>.from(data);
          print(id_card_details);
          isLoading = true;
          setState(() {
            desig = id_card_details[0]['dsig'].toString();
            fath_nm = id_card_details[0]['fath_nm'].toString();
            addr = id_card_details[0]['addr'].toString();
            b_group = id_card_details[0]['blood'].toString();
            homeno = id_card_details[0]['hm_mob'].toString();
            offcno = id_card_details[0]['offc_mob'].toString();
            company = id_card_details[0]['company'].toString();
          });
        });
      } else {
        print(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
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

  void editpopup(
    String user_id,
    String fath,
    String adr,
    String blood,
    String home,
    String offc,
  ) {
    final TextEditingController _fath = TextEditingController(text: fath);
    final TextEditingController _address = TextEditingController(text: adr);
    final TextEditingController _blood = TextEditingController(text: blood);
    final TextEditingController _homeno = TextEditingController(text: home);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future<void> editid() async {
      hack(user_id);
      hack(_fath.text);
      hack(_address.text);
      hack(_blood.text);
      hack(_homeno.text);
      try {
        var apiUrl = Uri.parse('$backendIP/edit_printid.php');

        var response = await http.post(apiUrl, body: {
          'id': user_id,
          'father': _fath.text,
          'addr': _address.text,
          'blood': _blood.text,
          'homeno': _homeno.text,
        });

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          hack(data);
          if (data['message'] == "Data updated successfully") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text('Success!',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                backgroundColor: Colors.green,
              ),
            );
            await id_details(); // Fetch the updated data
          } else {
            print('Error occurred during registration: ${data['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text('Failed! ${data['message']}')),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          print('Error occurred during registration: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Insert error: $e');
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _fath,
                    decoration: InputDecoration(
                      labelText: 'Father Name',
                      hintText: fath_nm,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\d\W]')),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _address,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      hintText: adr,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // fetchEmployeeName();
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
                  DropdownButtonFormField<String>(
                    value: blood,
                    onChanged: (newValue) {
                      setState(() {
                        blood = newValue!;
                        _blood.text = newValue;
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
                      DropdownMenuItem(child: Text('AB+'), value: 'AB+'),
                      DropdownMenuItem(child: Text('AB-'), value: 'AB-'),
                    ],
                    decoration: InputDecoration(
                      label: Text('Blood'),
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
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _homeno,
                    decoration: InputDecoration(
                      labelText: 'Home No .',
                      hintText: home,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Customize the border color
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
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
                          // _nametl.clear();
                          // _idtl.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Close the dialog
                          editid();
                          // _name.clear();
                          // _id.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('Save'),
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

  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> saveImage(Uint8List imageBytes) async {
    try {
      final directory = await getExternalStorageDirectory();
      final file_1 = File('${directory!.path}/$name.png');

      await file_1.writeAsBytes(imageBytes);

      print('Image saved at: ${file_1.path}');
      await _showNotification(file_1.path);
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Center(
      //     child: Text(
      //       file_1.toString(),
      //       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      //     ),
      //   ),
      //   backgroundColor: Colors.green,
      // ));
    } catch (e) {
      print('Error saving image: $e');
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
    'Image Downloaded',
    'Tap to open image',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 10,
          toolbarHeight: 50,
          backgroundColor: Color.fromARGB(255, 123, 251, 247),
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
                'Print ID',
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  // +();
                },
                icon: const Icon(Icons.verified_outlined),
              )
            ],
          ),
        ),
        body: isLoading
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    //front id
                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        child: Column(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  Center(
                                    child: Card(
                                      elevation: 20,
                                      child: Container(
                                        height: 500,
                                        width: 300,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'images/Idcard.png'), // Replace 'assets/background_image.jpg' with your image path
                                            fit: BoxFit
                                                .cover, // Adjust the fit as needed
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: id_card_details[
                                                              0]['pic'] ==
                                                          null ||
                                                      id_card_details[0]['pic']
                                                          .toString()
                                                          .isEmpty
                                                  ? AssetImage(
                                                          'images/no_pic.png')
                                                      as ImageProvider<Object>?
                                                  : NetworkImage(
                                                          '$backendIP/Registration/uploads/' +
                                                              id_card_details[0]
                                                                      ['pic']
                                                                  .toString())
                                                      as ImageProvider<Object>?,
                                              radius: 60,
                                            ),
                                            SizedBox(height: 20.0),
                                            Text(
                                              '$name',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Container(
                                              width: 150,
                                              child: Text(
                                                '$company',
                                                style: TextStyle(
                                                    fontSize: 23,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color.fromARGB(
                                                        255, 1, 99, 179)),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '$desig',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('ID: '),
                                                Text(
                                                  id,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            //back id
                            Center(
                              child: Stack(
                                children: [
                                  Center(
                                    child: Card(
                                      elevation: 20,
                                      child: Container(
                                        height: 550,
                                        width: 300,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'images/Idcard.png'), // Replace 'assets/background_image.jpg' with your image path
                                            fit: BoxFit
                                                .cover, // Adjust the fit as needed
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 50),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                height: 40,
                                                width: 220,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Father Name  :  ',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        (fath_nm == '')
                                                            ? 'No data'
                                                            : '$fath_nm',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 220,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        child: Text(
                                                            'Address          :  ',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))),
                                                    Container(
                                                        height: (addr == '')
                                                            ? 20
                                                            : 100,
                                                        width: 100,
                                                        child: SingleChildScrollView(
                                                            child: Text(
                                                                (addr == '')
                                                                    ? 'No data'
                                                                    : '$addr',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)))),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                width: 220,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text('Blood group   :  ',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Container(
                                                      width: 100,
                                                      child: Text(
                                                        (b_group == '')
                                                            ? 'No data'
                                                            : '$b_group',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                width: 220,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text('Home NO       :  ',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(
                                                        (homeno == '')
                                                            ? 'No data'
                                                            : '$homeno',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                width: 220,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text('Office NO       :  ',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(
                                                        (offcno == '')
                                                            ? 'No data'
                                                            : '$offcno',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () async {
                        Uint8List? imageBytes =
                            await screenshotController.capture();
                        saveImage(imageBytes!);
                      },
                      child: Icon(Icons.download),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                print(id);
                                editpopup(
                                    id, fath_nm, addr, b_group, homeno, offcno);
                              },
                              child: Text('Edit',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    )
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
