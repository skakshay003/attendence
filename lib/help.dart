// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
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
              'Help',
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader('1. Getting Started'),
            SubSection('a. Sign Up/Login', [
              ListItem(
                  'To use the app, start by signing up or logging in with your credentials.'),
              ListItem(
                  'Follow the on-screen instructions to create a new account or log in to an existing one.'),
            ]),
            SubSection('b. Dashboard Overview', [
              ListItem('Once logged in, you\'ll be directed to the dashboard.'),
              ListItem(
                  'View your attendance summary, upcoming events, and other relevant information at a glance.'),
            ]),
            SectionHeader('2. Marking Attendance'),
            SubSection('a. Manual Attendance', [
              ListItem(
                  'Tap on the "Mark Attendance" button to manually record your attendance.'),
              ListItem(
                  'Select the appropriate date and time, and confirm the action.'),
            ]),
            SubSection('b. QR Code Scan', [
              ListItem(
                  'Some events may use QR codes for attendance. Scan the provided QR code with your device\'s camera to mark attendance.'),
            ]),
            SectionHeader('3. View Attendance History'),
            ListItem('Access your attendance history to review past records.'),
            ListItem(
                'Filter by date, event, or course to find specific attendance details.'),
            SectionHeader('4. Notifications'),
            ListItem(
                'Enable app notifications to receive alerts for upcoming events, reminders to mark attendance, and other important updates.'),
            SectionHeader('5. Profile Settings'),
            SubSection('a. Edit Profile', [
              ListItem(
                  'Update your personal information, including name, email, and profile picture.'),
            ]),
            SubSection('b. Change Password', [
              ListItem(
                  'Change your password regularly to ensure account security.'),
            ]),
            SectionHeader('6. Frequently Asked Questions (FAQs)'),
            ListItem('Check our FAQs for quick answers to common queries.'),
            ListItem(
                'Topics include troubleshooting, account management, and app features.'),
            SectionHeader('7. Contact Support'),
            ListItem(
                'If you encounter issues not covered in the FAQs, reach out to our support team.'),
            ListItem(
                'Use the "Contact Support" option to send an email or access our live chat support.'),
            SectionHeader('8. App Updates'),
            ListItem(
                'Stay informed about the latest app features and improvements by keeping your app up to date.'),
            SectionHeader('9. Privacy and Security'),
            ListItem(
                'Read our privacy policy to understand how your data is handled and protected.'),
            ListItem(
                'Ensure you are using a secure network when accessing the app.'),
                
            SectionHeader('10. Feedback'),
            ListItem(
                'We value your feedback! Share your thoughts on the app\'s performance, suggest new features, or report any issues.'),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SubSection extends StatelessWidget {
  final String title;
  final List<Widget> content;

  SubSection(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        ...content,
      ],
    );
  }
}

class ListItem extends StatelessWidget {
  final String text;

  ListItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: 16.0),
          ),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HelpPage(),
  ));
}
