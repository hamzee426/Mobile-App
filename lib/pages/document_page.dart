import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({Key? key}) : super(key: key);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  List<int>? _documentBytes;
  late final PdfViewerController _pdfViewerController;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    super.initState();
  }

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse:
              (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          // Handle the notification payload here
          await _openPDFFile();
        }
      });
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _openPDFFile() async {
    final String dir = (await getDownloadsDirectory())!.path;
    final String pathName = '$dir/manual.pdf';

    if (await File(pathName).exists()) {
      try {
        await OpenFile.open(pathName); // Use pathName variable here
      } catch (e) {
        print('Error opening PDF: $e');
      }
    } else {
      print('File not found');
    }
  }

  Future<void> savePDFToDevice() async {
    // Check and request storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
      status = await Permission.storage.status;
    }

    if (status.isGranted) {
      final ByteData data = await rootBundle.load('assets/pdf/manual.pdf');
      final List<int> bytes = data.buffer.asUint8List();

      // Get the Downloads directory
      final String downloadsDirectory = (await getDownloadsDirectory())!.path;
      final String pathName = '$downloadsDirectory/Report.pdf';
      // print("BYTES ARE ------- $bytes");
      await File(pathName).writeAsBytes(bytes);

      print('PDF saved to: $pathName');

      // Show a notification after the PDF is saved
      await _showNotification('PDF Saved', 'File saved successfully');
      await OpenFile.open(pathName);
    } else {
      // Handle when permission is denied
      print('Permission to access storage denied');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '426',
      'hamza',
      channelDescription: 'File downloaded',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeNotifications(); // Initialize notifications in initState

    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: SfPdfViewer.asset(
        'assets/pdf/manual.pdf', // Corrected PDF path in assets
        controller: _pdfViewerController,
        key: _pdfViewerKey,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          // Document bytes of a PDF document loaded in SfPdfViewer.
          _documentBytes = details.document.saveSync();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await savePDFToDevice();
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
