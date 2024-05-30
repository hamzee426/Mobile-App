import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatefulWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  State<Emergency> createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          // If data is available
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var emergency = snapshot.data!.docs[index];
                var timestamp = emergency.get('timestamp').toString();
                var timeStart = timestamp.indexOf('at') + 3;
                var settingtime = timestamp.substring(timeStart, timeStart + 11);
                var time = settingtime.substring(0, 5) +
                    ' ' +
                    settingtime.substring(9,11);
                String datePart = timestamp.substring(0, 12); // "18, 2024"
                List<String> dateArray =
                    datePart.split(" "); // ["May", "18,", "2024"]
                String day = dateArray[1]
                    .replaceAll(",", ""); // Remove the comma from "18,"
                String month = dateArray[0]; // "May"
                String date = day + " " + month+ " "+ dateArray[2];

                // Assuming 'location' is a GeoPoint field containing latitude and longitude
                double latitude = emergency.get('latitude');
                double longitude = emergency.get('longitude');

                // Format the timestamp to display date and time
                String formattedDateTime = "Date : " + date + " \nTime : " + time;

                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.blueGrey,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latitude: $latitude',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'Longitude: $longitude',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '$formattedDateTime', // Display formatted date and time
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                  // Add InkWell for tap interaction
                  onTap: () {
                    _launchDirections(latitude, longitude);
                  },
                );
              },
            );
          }

          // If there is no data
          return Center(
            child: Text('No emergencies found.'),
          );
        },
      ),
    );
  }

  // Function to launch directions using Google Maps
  _launchDirections(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Error locating the person.';
    }
  }
}
