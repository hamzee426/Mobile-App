import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();
  LatLng? _currentLocation;
  LatLng? _targetLocation;
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
    _setupTargetLocationListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentLocation == null || _targetLocation == null
              ? const Center(
                  child: Text("Loading..."),
                )
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                  initialCameraPosition:
                      CameraPosition(target: _currentLocation!, zoom: 13),
                  markers: {
                    Marker(
                      markerId: MarkerId("_sourcelocation"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                      position: _currentLocation!,
                    ),
                    Marker(
                      markerId: MarkerId("_targetlocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: _targetLocation!,
                    ),
                  },
                ),
          Positioned(
              bottom: 40.0,
              left: 5.0,
              child: Column(children: [
                ElevatedButton(
                    onPressed: () {
                      if (_targetLocation != null) {
                        _launchDirections(_targetLocation!.latitude,
                            _targetLocation!.longitude);
                      }
                    },
                    child: Row(children: [
                      Text(
                        "Directions",
                        style: TextStyle(color: Colors.black),
                      ),
                      Icon(
                        Icons.directions,
                        color: Colors.black,
                      )
                    ])),
              ])),
        ],
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> _getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus _permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }


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
