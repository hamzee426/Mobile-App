import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key});

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage(); // Load selected language when the page initializes
  }

  _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ??
          ''; // Retrieve the selected language from SharedPreferences
    });
  }

  _saveSelectedLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = language;
    });
    await prefs.setString('selectedLanguage',
        language); // Save selected language to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Language"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          buildLanguageTile('English', Icons.language, Colors.blue),
          
          
        ],
      ),
    );
  }

  Widget buildLanguageTile(String language, IconData icon, Color iconColor) {
    CollectionReference lang =
        FirebaseFirestore.instance.collection("Language");
    bool isSelected = selectedLanguage == language;

    void onTapFunction(String language, String documentId) {
      setState(() {
        selectedLanguage = language;
      });

      String valueToUpdate = language == 'English' ? "1" : "0";

      lang.doc(documentId).update({'lang': valueToUpdate}).then((_) {
        print('Language updated successfully!');
      }).catchError((error) {
        print('Error updating Language: $error');
      });
    }

    return InkWell(
      onTap: () {
        onTapFunction(language, '9LKGhgk0OPO7bn2fsepA');
        setState(() {
          _saveSelectedLanguage(language);
          selectedLanguage = language;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.transparent : Colors.transparent,
              ),
              child: Icon(
                icon,
                size: 30,
                color: iconColor,
              ),
            ),
            SizedBox(width: 20),
            Text(
              language,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
}
