// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, sized_box_for_whitespace, non_constant_identifier_names, prefer_final_fields, avoid_print, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:intl/intl.dart';

class Salary_Inc_emp extends StatefulWidget {
  const Salary_Inc_emp({
    Key? key,
    required this.id,
    required this.name,
    required this.branch,
  }) : super(key: key);

  final String id;
  final String name;
  final String branch;

  @override
  State<Salary_Inc_emp> createState() => _Salary_Inc_empState();
}

class _Salary_Inc_empState extends State<Salary_Inc_emp> {
  TextEditingController _newFieldController = TextEditingController();
  TextEditingController dojController = TextEditingController();
  TextEditingController dojform = TextEditingController();

  TextEditingController _lastsala = TextEditingController();
  TextEditingController _newsala = TextEditingController();
  TextEditingController _basic = TextEditingController();
  TextEditingController _hr = TextEditingController();
  TextEditingController _convall = TextEditingController();
  TextEditingController _medall = TextEditingController();
  TextEditingController _spclall = TextEditingController();

  var backendIP = ApiConstants.backendIP;
  String branch = '';
  String id = '';
  String name = '';
  List regdata = [];
  List salary_inc = [];
  bool isLoading = false;

  //insert

  String inc_basic = '';
  String inc_hr = '';
  String inc_conv = '';
  String inc_med = '';
  String inc_dt = '';
  int inc_sala = 0;
  String inc_lastsala = '';
  String reg_salary = '';
  String desig = '';

  @override
  void initState() {
    super.initState();
    id = widget.id;
    branch = widget.branch;
    name = widget.name;
    reg();
  }

  Future<void> reg() async {
    try {
      var apiUrl = Uri.parse('$backendIP/vfetchdata.php');
      var response = await http.post(apiUrl, body: {
        'user_id': id,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          regdata = List<Map<String, dynamic>>.from(data);
          hack(regdata);
          _lastsala.text = regdata[0]['sala'].toString();
          _newsala.text = '0';
          desig = regdata[0]['dsig'].toString();
          print(reg_salary);
          print(desig);
          viewsalaryinc();
        });
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
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

  Future<void> viewsalaryinc() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Salary_Increment/vfetch_sala_inc.php');
      var response = await http.post(apiUrl, body: {
        'user_id': id,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          salary_inc = List<Map<String, dynamic>>.from(data);
          hack(salary_inc);
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

  Future<void> upst_salary() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Salary_Increment/updt_sala.php');
      var response = await http.post(apiUrl, body: {
        'user_id': id,
        'salary': inc_sala.toString(),
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
              child: Text(
            "Increment added successfully !",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
          backgroundColor: Colors.green,
        ),
      );
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
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

  Future<void> upst_salary2(int sal) async {
    try {
      var apiUrl = Uri.parse('$backendIP/Salary_Increment/updt_sala.php');
      var response = await http.post(apiUrl, body: {
        'user_id': id,
        'salary': sal.toString(),
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
              child: Text(
            "Updated Successfully !",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
          backgroundColor: Colors.green,
        ),
      );
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
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

  Future<void> add_increment() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Registration/sala_inc.php');
      var response = await http.post(apiUrl, body: {
        'user_id': id,
        'incre_dt': inc_dt,
        'salary': inc_sala.toString(),
        'basic': inc_basic,
        'hr': inc_hr,
        'conv_all': inc_conv,
        'medical_all': inc_med,
        'spl_all': inc_med,
        'sal_last': inc_lastsala,
        'position': desig,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        
          await upst_salary();
         setState(() {
           reg();
         });
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
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

  Future<void> add_increment2(
      int _newsal, String lst, String dat, String ids) async {
    print(ids);
    try {
      var apiUrl = Uri.parse('$backendIP/Salary_Increment/edit_inc.php');
      var response = await http.post(apiUrl, body: {
        'id': ids,
        'incre_dt': dat,
        'salary': _newsal.toString(),
        'basic': basic.toString(),
        'hr': HRA.toString(),
        'conv_all': Conv_all.toString(),
        'medical_all': medical_all.toString(),
        'spl_all': medical_all.toString(),
        'sal_last': lst,
        'position': desig,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        
        await  upst_salary2(_newsal);
        setState(() {
           reg();
        });
      } else {
        hack(
            'Error occurred while fetching data. Status code: ${response.statusCode}');
        hack('Response body: ${response.body}');
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

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDatedoj(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dojController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        dojform.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
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
      _basic.text = basic.toString();
      hack('basic:$basic');

      HRA = basic * 40 / 100;
      _hr.text = HRA.toString();
      hack('HRA:$HRA');

      if (salary >= 10000) {
        Conv_all = 1600;
        hack('Conv_all:$Conv_all');
      } else {
        Conv_all = 800;
        hack('Conv_all:$Conv_all');
      }
      _convall.text = Conv_all.toString();

      //medical
      for_med = basic + HRA + Conv_all;
      hack('for_med:$for_med');
      result = salary - for_med;
      hack('result:$result');
      medical_all = result / 2;
      hack('medical_all:$medical_all');
      _medall.text = medical_all.toString();
      _spclall.text = medical_all.toString();
    });
  }

  Future<void> cal_salary_inc2() async {
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

  void _showEditPopup(BuildContext context, data) {
    TextEditingController lst_sal =
        TextEditingController(text: data['sal_last']);
    TextEditingController _dt = TextEditingController(text: data['incre_dt']);
    TextEditingController _newsal = TextEditingController(text: data['salary']);

    Future<void> _editinc_dt(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          _dt.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        });
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Details'),
            content: Container(
              height: 250,
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () async {
                      _editinc_dt(context);
                    },
                    child: TextFormField(
                      controller: _dt, // Use the existing controller
                      decoration: InputDecoration(
                        label: Text('Increment Date'),
                        enabled: false,
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
                  TextFormField(
                    controller: lst_sal,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Last Salary',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _newsal,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Salary',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _newsal.text == ''
                            ? salary = 0
                            : salary = int.parse(_newsal.text);
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  // Handle the onPressed action here
                  setState(() {
                    cal_salary_inc2();
                  });
                  await add_increment2(salary, lst_sal.text, _dt.text,
                        data['id'].toString());
                  _newsala.clear();
                  lst_sal.clear();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  _newsala.clear();
                  lst_sal.clear();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

  // Function to show the bottom sheet
  void _showAddDataBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allow the bottom sheet to take the full screen height
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Increment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            onTap: () async {
                              _selectDatedoj(context);
                            },
                            child: TextFormField(
                              controller:
                                  dojform, // Use the existing controller
                              decoration: InputDecoration(
                                label: Text('Increment Date'),
                                enabled: false,
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
                          TextFormField(
                            controller: _lastsala,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Last Salary',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _newsala,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Salary',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _newsala.text == ''
                                    ? salary = 0
                                    : salary = int.parse(_newsala.text) + int.parse(_lastsala.text);
                                cal_salary_inc();
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _basic,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Basic',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _hr,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'HR',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _convall,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Conv_All',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _medall,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Medical All',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _spclall,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Spcl All',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          // SizedBox(height: 10),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _basic.clear();
                          _convall.clear();
                          _hr.clear();
                          _lastsala.clear();
                          _medall.clear();
                          _spclall.clear();
                          _newsala.clear();
                          reg();
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if(dojform.text == ''){
                            print('crct');
                             _selectDatedoj(context);
                          }else{
                            setState(() {
                            inc_basic = _basic.text;
                            inc_sala = int.parse(_newsala.text) + int.parse(_lastsala.text);
                            inc_hr = _hr.text;
                            inc_conv = _convall.text;
                            inc_med = _medall.text;
                            inc_dt = dojController.text;
                            inc_lastsala = _lastsala.text;
                          });
                          _basic.clear();
                          _convall.clear();
                          _hr.clear();
                          _lastsala.clear();
                          _medall.clear();
                          _spclall.clear();
                          _newsala.clear();
                          // Close the bottom sheet
                          add_increment();
                          Navigator.pop(context);
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

  Future<void> deleteDepartment(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete this Increment ?',
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
      var apiUrl = Uri.parse('$backendIP/Salary_Increment/del_inc.php');
      var response = await http.post(apiUrl, body: {
        'id': id.toString(),
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['message'] == 'Department deleted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text('Increment deleted successfully',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.green,
            ),
          );
          await reg();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Failed to delete increment')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        hack('Error occurred during department deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to delete increment')),
            backgroundColor: Colors.yellow.shade600,
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
        backgroundColor:
            Color.fromARGB(255, 123, 251, 247), // Choose a primary color
        shadowColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: Text(
          ' SALARY INCREMENT',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: isLoading
          ? Container(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            branch,
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'ID :   ',
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF487B95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
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
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        height: salary_inc.isNotEmpty ? MediaQuery.of(context).size.height/2 : 100,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 30,
                                  headingRowColor: MaterialStateColor.resolveWith(
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
                                      label: Text('Emp ID',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Last Salary',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Inc Salary',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Basic',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('HR',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Conv_All',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Medical_All',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Spcl_All',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Increment Date',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('Position',
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
                                  ],
                                  rows: salary_inc.map((data) {
                                    int serialNumber =
                                        salary_inc.indexOf(data) + 1;
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Text(serialNumber.toString(),
                                              style:
                                                  TextStyle(color: Colors.black)),
                                          onTap: () {},
                                        ),
                                        DataCell(
                                          Text(data['user_id'].toString()),
                                        ),
                                        DataCell(
                                          Text(data['sal_last'].toString()),
                                        ),
                                        DataCell(
                                          Text(data['salary'].toString()),
                                        ),
                                        DataCell(
                                          Text(data['basic'].toString()),
                                        ),
                                        DataCell(
                                          Text(data['hr'].toString()),
                                        ),
                                        DataCell(
                                          Text(data['conv_all'].toString()),
                                        ),
                                        DataCell(
                                          Text(data['medical_all'].toString()),
                                        ),
                                        DataCell(
                                          Text(data['spl_all'].toString()),
                                        ),
                                        DataCell(
                                          Text(data['incre_dt'].toString()),
                                        ),
                                        DataCell(
                                          Text((data['position'] == '')
                                              ? 'No Data'
                                              : data['position'].toString()),
                                        ),
                                        DataCell(IconButton(
                                            onPressed: () {
                                              _showEditPopup(context, data);
                                            },
                                            icon: Icon(Icons.edit))),
                                        DataCell(IconButton(
                                            onPressed: () {
                                              deleteDepartment(
                                                  data['id'].toString());
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    salary_inc.isNotEmpty
                        ? Text('')
                        : Column(
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
                          ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              _showAddDataBottomSheet(context);
                            },
                            child: Icon(Icons.add),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
