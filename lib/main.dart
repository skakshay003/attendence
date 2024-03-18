// ignore_for_file: unused_import, prefer_const_constructors, depend_on_referenced_packages

import 'package:attendence/Company_Section/add_dept/add_department.dart';
import 'package:attendence/admin_login.dart';
import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'bottom_navigator.dart';
import 'payment_dtls_upload.dart';
import 'package:provider/provider.dart';

import 'theme_pro.dart';

void main()async{
 runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Staffin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        fontFamily: 'Calibri',
      ),
      // theme: ThemeData.light(),
      // darkTheme: ThemeData.dark(),
      // themeMode: ThemeMode.system,
      home:
      // AdminPage(),
      HomeNavigator(),
    );
  }
}