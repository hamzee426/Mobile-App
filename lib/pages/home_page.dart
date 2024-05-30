import 'package:envision_eye/pages/account_settings_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:envision_eye/pages/emergency.dart';
import 'package:envision_eye/pages/language_page.dart';
import 'package:envision_eye/pages/map_page.dart';
import 'package:envision_eye/pages/document_page.dart';


void main() {
  runApp(Routes());
}

class Routes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/googleMaps': (context) => const MapPage(),
        '/pdfGenerator': (context) => const DocumentPage(),
        '/languageSelect': (context) => const LanguagePage(),
        '/emergency': (context) => const Emergency(),
        '/accsettings': (context) => const AccSettings()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _audioplayer = AudioPlayer();
  StreamSubscription<QuerySnapshot>? _subscription;
  bool _shouldListenToChanges = false;
  bool _isFirstLaunch = true;
  GeoPoint? _realTimeLocation;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _shouldListenToChanges = true; // Set to false when not needed
    if (_shouldListenToChanges) {
      _listenToDatabaseChanges();
    }
    // _playRingtone();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Replace 'app_icon' with your app icon name
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _listenToDatabaseChanges() {
    _subscription = FirebaseFirestore.instance
        .collection('Emergency')
        .snapshots()
        .listen((event) {
      if (_isFirstLaunch) {
        _isFirstLaunch = false; // Set flag to false after the first launch
        return; // Do not trigger the alarm on the first launch
      }
      if (event.docChanges.isNotEmpty) {
        _triggerNotificationAndAlarm();
        _fetchRealTimeLocation().then((location) {
          if (location != null) {
            _realTimeLocation = location;
          }
        });
      }
    });
  }

  Future<GeoPoint?> _fetchRealTimeLocation() async {
    // Fetch the real-time location from Firestore
    // Adjust the path and query based on your Firestore structure
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RealTimeLocation')
        .doc('userId')
        .get();

    if (snapshot.exists) {
      GeoPoint? location = snapshot.get('location');
      return location;
    } else {
      return null;
    }
  }

  Future<void> _triggerNotificationAndAlarm() async {
    await _showNotification();
    _playRingtone();
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('427', 'Emergency Alert',
            channelDescription: 'Emergency Button has been pressed',
            importance: Importance.max,
            priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Emergency Alert',
      'Emergency Button has been pressed',
      platformChannelSpecifics,
    );
  }

  Future<void> _playRingtone() async {
    await _audioplayer.play(AssetSource("alarm/emergency.mp3"));
  }

  @override
  void dispose() {
    _audioplayer.dispose(); // Dispose the AudioPlayer instance
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envision Eye'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/googleMaps');
            },
            child: const Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(Icons.map, size: 50),
                title: Text('Track your device'),
                subtitle: Text('Track with Google Maps'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/emergency');
            },
            child: const Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(Icons.emergency, size: 50),
                title: Text('Emergency'),
                subtitle: Text('Emergency Details'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/pdfGenerator');
            },
            child: const Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf, size: 50),
                title: Text('Generate Report'),
                subtitle: Text('Generate PDFs'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/languageSelect');
            },
            child: const Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(Icons.language, size: 50),
                title: Text('Language Select'),
                subtitle: Text('Choose Language'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/accsettings');
            },
            child: const Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(Icons.account_box, size: 50),
                title: Text('Account Settings'),
                subtitle: Text('Setup your account'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
