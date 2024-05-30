import 'package:envision_eye/Screens/Login/login_screen.dart';
import 'package:envision_eye/Screens/firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AccSettings extends StatefulWidget {
  const AccSettings({Key? key});

  @override
  State<AccSettings> createState() => _AccSettingsState();
}

class _AccSettingsState extends State<AccSettings> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;

  @override
  void initState() {
    _user = null;
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      setState(() {
        _user = _auth.currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings"),
      ),
      body: Column(
        children: [
          Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.email, size: 30),
              title: Text('Logged in as ${_user?.email ?? "Unknown"}'),
            ),
          ),
          SizedBox(
            height: 500,
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
            child: Text(
              "Sign out",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
